from pyspark.sql import SparkSession
from pyspark.sql.window import Window
from pyspark.sql.functions import *
from datetime import datetime
import time

from dependencies.utilities import *


def run(spark: SparkSession, config_dict: dict, module: str, sub_module: str, job: str, full_refresh: int = 0):
    print(f"Running {module}.{sub_module}.{job}")
    trigger_time = datetime.now()
    start_time = time.time()
    try:
        order_dsi = """
                    (SELECT l.LineId
							,x.Date AS OrderDate
							,UPPER(RTRIM(f.SourceLocationId)) AS Location
							,UPPER(RTRIM(c.SourceContactKey)) AS ContactKey
							,l.LineOfBusinessCurrentKey
							,l.OrderChannelCd
                            ,l.ProductCurrentKey
							,cast(CASE 
									WHEN l.LineStatusCd = 'I'
										THEN 1
									ELSE 0
									END AS BIT) AS OrderCancelled
							,UPPER(RTRIM(l.OrderNbr)) AS OrderNbr
							,l.OrderWhen
							,x.LineQty
							,l.LineUnitSell
							,x.LineAmount
							,l.UnitMeasureCd AS LineUMCd
							,UPPER(RTRIM(l.OrderCorpContractCd)) AS OrderCorpContractCd
							,l.OrderCorpContractNm AS OrderCorpContractNm
							,UPPER(RTRIM(l.OrderGPOContractCd)) AS OrderGPOContractCd
							,l.OrderGPOContractNm AS OrderGPOContractNm
							,x.Contracted AS ContractedProduct
						FROM (
							SELECT d.Date
								,ISNULL(l.LineUnitQty, lo.Qty) AS LineQty
								,ISNULL(l.BK_ProductSales, lo.Qty * lo.UnitSell) AS LineAmount
								,l.LineId
								,Contracted = cast(max(CASE 
											WHEN mi.RefNum IS NOT NULL
												THEN 1
											ELSE 0
											END) AS BIT)
							FROM FinProfit_DM.dbo.factline l
							INNER JOIN FinProfit_DM.dbo.DimDate d ON d.DateKey = OrderDateKey
							INNER JOIN FinProfit_DM.dbo.DimProductCurrent p ON p.ProductCurrentKey = l.ProductCurrentKey
							LEFT JOIN MDID_TRAN.dbo.TrLines lo ON lo.LineID = l.LineID
							LEFT JOIN MDID_Btrieve.dbo.clcontyp nact
							INNER JOIN USER_SUPPLY_CHAIN.dbo.pm_NA_ContractProductListExclusionsHist nx ON nx.Contract = nact.[Contract]
							--check for contracted net sell
							INNER JOIN USER_SUPPLY_CHAIN.dbo.pm_NA_ProductListExclusionsHist ns ON ns.CategoryID = nx.CategoryID
							INNER JOIN REPORTING.dbo.All_Products_MainInfo mi ON ns.ProdNum = right(mi.RefNum, 5)
							INNER JOIN USER_SUPPLY_CHAIN.dbo.pm_NA_ProductListExclusionsCategory ce ON ns.CategoryID = ce.CategoryID
							--and ce.Purpose = 3 --customer specific
							INNER JOIN USER_SUPPLY_CHAIN.dbo.pm_NA_NetSellPurpose cep ON ce.Purpose = cep.PurposeID ON l.orderCorpContractcd = nact.Contract
								AND nact.nationalacctrep NOT IN (
									''
									,'wjb'
									) --not adopted by an NA rep so probably not a corp we are targeting/contracted with
								AND Sell_Other1 IS NOT NULL
								AND L.Orderwhen >= nx.CreatedWhenUTC
								AND L.Orderwhen < nx.RetiredWhenUTC
								AND L.Orderwhen >= ns.CreatedWhenUTC
								AND L.Orderwhen < ns.RetiredWhenUTC
								AND p.sourcecatprodnbr = mi.refnum WHERE l.LineStatusCd <> 'I'
								AND l.IsCancelledPreBillCreditFlag = 'N'
								AND l.OrderChannelCd NOT IN (
									'A'
									,'C'
									,'M'
									)
								AND l.OrderSbuId <> 4
								AND d.DATE > dateadd(year, datediff(year, 0, getdate()) - 7, 0)
							GROUP BY l.lineid
								,d.DATE
								,ISNULL(l.LineUnitQty, lo.Qty)
								,ISNULL(l.BK_ProductSales, lo.Qty * lo.UnitSell)
							) AS x
							INNER JOIN FinProfit_DM.dbo.FactLine l on x.lineid = l.lineid
							INNER JOIN FinProfit_DM.dbo.DimLocationCurrent f on f.LocationCurrentKey = l.ShipLocationCurrentKey
							INNER JOIN FinProfit_DM.dbo.DimContactCurrent c on c.ContactCurrentKey = l.ContactCurrentKey
							INNER JOIN FinProfit_DM.dbo.DimLineOfBusinessCurrent b on b.LobCurrentKey = l.LineOfBusinessCurrentKey
						) AS A
                    """

        order_dsi_df = read_sql_dse(
            spark, config_dict, order_dsi, "FinProfit_DM")

        inserted_count = delta_merge(spark, config_dict, "dshe_fact_order_dse", order_dsi_df, full_refresh)
        
        print(f"{'/-'*40}")
        print(f"{'--'*40}")
    except Exception:
        end_time = time.time()
        elapsed_time = end_time - start_time
        exc_type, exc_msg, stack_trace = get_sys_exception()
        log_run_metrics(spark, config_dict, module, sub_module, job, "Failure", 0, elapsed_time, str(trigger_time), exc_type, exc_msg, stack_trace)
        print(f"{module}.{sub_module}.{job} job failed")
        print(f"{'/-'*10} Exception Type {'/-'*10}")
        print(exc_type)
        print(f"{'/-'*10} Exception Message {'/-'*10}")
        print(exc_msg)
        print(f"{'/-'*10} Stack Trace {'/-'*10}")
        print(stack_trace)
        spark.stop()
    else:     
        end_time = time.time()
        elapsed_time = end_time - start_time
        log_run_metrics(spark, config_dict, module, sub_module, job, "Success", inserted_count, elapsed_time, str(trigger_time), None, None, None)
        print(f"{module}.{sub_module}.{job} job ran successfully. Count = {inserted_count}")
    finally:
        print(f"Execution of {module}.{sub_module}.{job} job took {elapsed_time} seconds")