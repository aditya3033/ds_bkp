--------------------------------------------- DATA STITCHING DDLS TO BE ADDED HERE ---------------------------------------------------------------------
-- CATALOG: app_DSI_DataStitching
-- SCHEMA: default
-- ROOT PATH: 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/[table_name]

CREATE CATALOG IF NOT EXISTS app_DSI_DataStitching
  MANAGED LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching';

-- PERMISSIONS
GRANT ALL PRIVILEGES ON CATALOG app_DSI_DataStitching TO sys_app_all;
GRANT SELECT, USE SCHEMA, USE CATALOG, MODIFY ON CATALOG app_DSI_DataStitching TO sys_app_write;
GRANT SELECT, USE SCHEMA, USE CATALOG ON CATALOG app_DSI_DataStitching TO sys_app_read;

USE CATALOG app_DSI_DataStitching;

CREATE SCHEMA IF NOT EXISTS default
  MANAGED LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default';

USE SCHEMA app_DSI_DataStitching.default;

-- change

CREATE OR REPLACE TABLE app_DSI_DataStitching.default.dim_date (
  Date DATE COMMENT 'Date',
  `BusDay#ofMo` TINYINT COMMENT 'Business Day of Month (bus days on/before date in current month)',
  `BusDay#ofQtr` TINYINT COMMENT 'Business Day of Quarter (bus days on/before date in current quarter)',
  `BusDay#ofYear` SMALLINT COMMENT 'Business Day of Year (bus days on/before date in current year)',
  IsBOM STRING COMMENT 'Is date the beginning of month',
  IsEOM STRING COMMENT 'Is date the end of the month',
  IsHoliday STRING COMMENT 'Is date a holiday',
  IsBudgetException STRING COMMENT 'Is date excluded from budget (sales)',
  BegOfMonthDate DATE COMMENT 'Date of the beginning of the current month (e.g. 1/1, 2/1)',
  EndOfMonthDate DATE COMMENT 'Date of the end of the current month (e.g. 1/31, 2/28)',
  BusBegOfMonthDate DATE COMMENT 'Date of the first business day in current month',
  BusEndOfMonthDate DATE COMMENT 'Date of the last business day in current month',
  `Day#ofWeek` TINYINT COMMENT 'Day of week (Sunday = 1, etc.)',
  `Day#ofMo` TINYINT COMMENT 'Month day',
  `Day#ofYear` SMALLINT COMMENT 'Day of year (days on/before date in current year)',
  `Week#` TINYINT COMMENT 'Calendar week number of year (partial first week common)',
  `Month#` TINYINT COMMENT 'Month number of year (1-12)',
  `Quarter#` TINYINT COMMENT 'Quarter number of year (1-4)',
  IsBusinessDay STRING COMMENT 'Is date a business day for Direct Supply',
  Year SMALLINT COMMENT 'Year Number',
  Weekday STRING COMMENT 'Day of Week',
  Month STRING COMMENT 'Month Name')
USING delta
LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/dim_date'
TBLPROPERTIES (
  'delta.minReaderVersion' = '1',
  'delta.minWriterVersion' = '2');


CREATE TABLE IF NOT EXISTS app_DSI_DataStitching.default.dim_contact_ds (
  DSContactID STRING COMMENT 'Identifier for merged Location',
  FirstName STRING COMMENT 'Contact First Name',
  LastName STRING COMMENT 'Contact Last Name',
  EmailAddress STRING COMMENT 'Contact Email Address')
USING delta
LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/dim_contact_ds'
TBLPROPERTIES (
  'delta.minReaderVersion' = '1',
  'delta.minWriterVersion' = '2')

-- change

CREATE OR REPLACE TABLE app_DSI_DataStitching.default.dim_contact_dssi (
  CustCode STRING COMMENT 'DSSI Provider Code (ref dim_location_dssi)',
  CustLocNum STRING COMMENT 'DSSI Customer’s Location Number (ref dim_location_dssi)',
  CustContNum INT COMMENT 'Unique integer identifier for Contact',
  Username STRING COMMENT 'Unique username within Provider',
  FirstName STRING COMMENT 'Person’s first name',
  LastName STRING COMMENT 'Person’s last name',
  DSSIDSEContactKey STRING COMMENT 'Optional reference to DSE Contact (ref dim_contact_dse.ContactKey)',
  JobCd STRING COMMENT 'DSSI Job Code',
  Active STRING COMMENT 'Login enabled (Y/N)',
  TestFlag STRING COMMENT 'Test/Production status code - test accounts cannot order (T/P)',
  EmailAddress STRING COMMENT 'Person’s email address',
  Created TIMESTAMP COMMENT 'Date and time record was created',
  CreatedBy STRING COMMENT 'DS employee’s login for who created',
  ContactGrp STRING COMMENT 'Calculated code to define contact groups.  Accounts for DSSI master contacts.',
  DSContactID STRING COMMENT 'Calculated code:  use if valid DSSIDSEContactKey, else CustContNum (ref dim_contact_ds.DSContactID)')
USING delta
LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/dim_contact_dssi'
TBLPROPERTIES (
  'delta.minReaderVersion' = '1',
  'delta.minWriterVersion' = '2')


CREATE TABLE IF NOT EXISTS app_DSI_DataStitching.default.dim_location_ds (
  DSLocationID STRING COMMENT 'Identifier for merged Location',
  LocName STRING COMMENT 'Location Name',
  AddressLine1 STRING COMMENT 'Location Address Line 1',
  AddressLine2 STRING COMMENT 'Location Address Line 2',
  City STRING COMMENT 'Location City',
  State STRING COMMENT 'Location State',
  Zip STRING COMMENT 'Location Zip',
  PhoneAreaCode STRING COMMENT 'Phone Area Code',
  Phone STRING COMMENT 'Phone Number (7 digit no dashes)',
  PhoneExt STRING COMMENT 'Optional Phone Extension')
USING delta
LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/dim_location_ds'
TBLPROPERTIES (
  'delta.minReaderVersion' = '1',
  'delta.minWriterVersion' = '2')


CREATE TABLE IF NOT EXISTS app_DSI_DataStitching.default.dim_location_dssi (
  CustCode STRING COMMENT 'DSSI Provider Code',
  CustLocNum STRING COMMENT 'DSSI Customer’s Location Number/Code',
  FacilityKey INT COMMENT 'DSSI Location Identifier',
  Status STRING COMMENT 'Location Active Status/Type (A, I, S, T)',
  DSSIDSELocation STRING COMMENT 'Optional reference to DSE Location (ref dim_location_dse.Location)',
  DSSILocName STRING COMMENT 'Location Name',
  AddressLine1 STRING COMMENT 'Location Address Line 1',
  AddressLine2 STRING COMMENT 'Location Address Line 2',
  City STRING COMMENT 'Location City',
  State STRING COMMENT 'Location State',
  Zip STRING COMMENT 'Location Zip',
  PhoneAccess STRING COMMENT 'Phone Prefix/Country Code (typically 1)',
  PhoneAreaCode STRING COMMENT 'Phone Area Code',
  Phone STRING COMMENT 'Phone Number (7 digit no dashes)',
  PhoneExt STRING COMMENT 'Optional Phone Extension',
  KeepActive STRING COMMENT 'Y/N indicator, once used for DSE link',
  LiveDate TIMESTAMP COMMENT 'Date location can begin ordering (go live)',
  LocTestFlag STRING COMMENT 'Test flag code for prod/test  (P, T)',
  LocType TINYINT COMMENT 'Code for position in location hierarchy (3=corp, 2=division,1=region,0=fac)',
  CreatedDate TIMESTAMP COMMENT 'When record was created',
  DSLocationID STRING COMMENT 'Calculated code:  use DSSIDSELocation if valid, else CustCode.CustLocNum (ref dim_location_ds)',
  TotalBedCnt SMALLINT COMMENT 'Number of all beds at Location')
USING delta
LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/dim_location_dssi'
TBLPROPERTIES (
  'delta.minReaderVersion' = '1',
  'delta.minWriterVersion' = '2')


CREATE TABLE IF NOT EXISTS app_DSI_DataStitching.default.fact_order_dssi (
  CustCode STRING COMMENT 'DSSI Provider Code (ref dim_location_dssi)',
  CustLocNum STRING COMMENT 'DSSI Customer’s Location Number/Code (ref dim_location_dssi)',
  FacilityKey INT COMMENT 'DSSI Facility Key (ref dim_location_dssi)',
  CustContNum INT COMMENT 'DSSI Contact Identifier (ref dim_contact_dssi.CustContNum)',
  Date DATE COMMENT 'Order Date (ref dim_date.Date)',
  POCancelled BOOLEAN COMMENT 'Canceled indicator',
  PONbr STRING COMMENT 'DSSI Purchase Order Number (with credit logic)',
  LinePoNbr STRING COMMENT 'DSSI Source system key/Orig PO Number (chlines.chponum)',
  LineNbr SMALLINT COMMENT 'DSSI Source system key/Line Number (chlines.AccLineNum)',
  LineQty SMALLINT COMMENT 'Quantity Ordered',
  LineUnitSell DECIMAL(19,4) COMMENT 'Sell price of item',
  LineAmount DECIMAL(19,4) COMMENT 'Total Line Amount (Qty*UnitSell) plus any line charges',
  LineUMCd STRING COMMENT 'Unit of Measure ordered (CA for Case, EA for Each, etc.)',
  ProductNbr STRING COMMENT 'Supplier’s Product Number for item',
  ProductDesc STRING COMMENT 'Product/Item Description',
  SupplierCd STRING COMMENT 'DSSI’s Supplier (Distribution center) Code',
  SupplierName STRING COMMENT 'DSSI’s Supplier (Distribution center) Name',
  ParentSupplierCd STRING COMMENT 'DSSI Corp Supplier Code',
  ParentSupplierName STRING COMMENT 'DSSI Corp Supplier Name')
USING delta
LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/fact_order_dssi'
TBLPROPERTIES (
  'delta.minReaderVersion' = '1',
  'delta.minWriterVersion' = '2')


CREATE TABLE IF NOT EXISTS app_DSI_DataStitching.default.fact_activity_dssmart (
  Location STRING COMMENT 'DSE Location Code (ref dim_location_dse.Location)',
  Date DATE COMMENT 'Event Date (ref dim_date.Date)',
  LoginsDSSmart INT COMMENT 'Count of DSSmart Login events',
  VitalsDSSmart INT COMMENT 'Count of Vital Submissions taken')
USING delta
LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/fact_activity_dssmart'
TBLPROPERTIES (
  'delta.minReaderVersion' = '1',
  'delta.minWriterVersion' = '2')

-- change
CREATE OR REPLACE TABLE app_DSI_DataStitching.default.dim_contact_dse (
  ContactKey STRING COMMENT 'Unique Contact Code/Identifier (ClCont.ContactKey)',
  BaseLocation STRING COMMENT 'Main location for Contact (ref dim_location_dse.Location)',
  IsSlug STRING COMMENT 'Y/N indicator for a “Slug” contact.  Typically “N”',
  PreName STRING COMMENT 'Name Prefix/Title (e.g. Mr., Mrs., Dr.)',
  FirstName STRING COMMENT 'Contact First Name (formal)',
  MiddleName STRING COMMENT 'Contact Middle Name/Initial',
  LastName STRING COMMENT 'Contact Last Name',
  Suffix STRING COMMENT 'Contact Suffix (e.g. Jr., Sr., RN, MD)',
  Salutation STRING COMMENT 'Contact First/NickName',
  JobCd STRING COMMENT 'Contact Job/Occupation Code (~80 codes total)',
  JobCdDescription STRING COMMENT 'Contact Job Description (free form)',
  PhoneAccess STRING COMMENT 'Phone Prefix/Country Code (typically 1)',
  PhoneAreaCode STRING COMMENT 'Phone Area Code',
  Phone STRING COMMENT 'Phone core number (7 digit no hyphen)',
  PhoneExt STRING COMMENT 'Phone Extension',
  DateCreated TIMESTAMP COMMENT 'Date and time record created',
  DateUpdated TIMESTAMP COMMENT 'Date and time record last updated',
  PersonID INT COMMENT 'Alternate identifier field for contact',
  EmailAddress STRING COMMENT 'Contact email address (if known)',
  DSContactID STRING COMMENT 'Calculated reference to combined Contact (ref dim_contact_ds)',
  Status STRING COMMENT 'Contact Status (Active/Inactive)',
  JobBucketCd STRING COMMENT 'Job Bucket Code.  Coalesce Job Code/Desc to one of 14 buckets',
  JobBucket STRING COMMENT 'Job Bucket Name (e.g. Nursing, Maintenance, Administrator)',
  JobTitle STRING COMMENT 'Contact Job Description (free form)')
USING delta
LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/dim_contact_dse'
TBLPROPERTIES (
  'delta.minReaderVersion' = '1',
  'delta.minWriterVersion' = '2')

-- change
CREATE OR REPLACE TABLE app_DSI_DataStitching.default.dim_location_dse (
  Location STRING COMMENT 'Unique location code/identifier (ClLocn.Location)',
  LocStatusCd STRING COMMENT 'Location Status (ClLocn.Status)',
  CorpLocation STRING COMMENT 'Corporate Location Code (ClLocn.CorpLocation, self ref)',
  OwnManageLease STRING COMMENT 'Own/Manage/Lease Code (ClLocn.OwnManageLease)',
  OwnerLocation STRING COMMENT 'Owner Location Code (ClLocn.OwnerLocation, self ref)',
  DSELocName STRING COMMENT 'Location Name (ClLocn.Name)',
  AddressLine1 STRING COMMENT 'Location Address Line #1 (ClLocn.AddressLine1)',
  AddressLine2 STRING COMMENT 'Location Address Line #2 (ClLocn.AddressLine2).  Optional',
  City STRING COMMENT 'Location City (ClLocn.City)',
  State STRING COMMENT 'Location State (ClLocn.State)',
  Zip STRING COMMENT 'Location Zip (ClLocn.Zip)',
  Country STRING COMMENT 'Location Country (ClLocn.Country)',
  PhoneAreaCode STRING COMMENT 'Phone Area Code (ClLocn.PhoneAreaCode)',
  Phone STRING COMMENT 'Phone Number (ClLocn.Phone, e.g. 555-5555)',
  PhoneExt STRING COMMENT 'Optional Phone Extension (ClLocn.PhoneExtension)',
  CreatedDate TIMESTAMP COMMENT 'When Location was created.  Null if unknown (ClLocn.CreateDate)',
  UpdatedDate TIMESTAMP COMMENT 'When Location was last updated (ClLocn.DateUpdated)',
  LocTypeCd STRING COMMENT 'Location Type Code (many–similar to MarketCd)',
  LocType STRING COMMENT 'Location Type Name (many, similar to Market)',
  DivisionCd STRING COMMENT 'Location Division Code (I,C)',
  Division STRING COMMENT 'Location Division Name (Independent, Corporate)',
  MarketCd STRING COMMENT 'Location Market Code (AL, AM, XN, SN, AC)',
  Market STRING COMMENT 'Location Market Name (Senior Living, Ambulatory, Special Market, Skilled Nursing, Acute)',
  ForProfitCd STRING COMMENT 'For Profit Code (F, N, C, blank)',
  ForProfit STRING COMMENT 'For Profit Name (For Profit, Not For Profit, Non-Profit, Unknown)',
  CorpLocationNm STRING COMMENT 'Corporation Location Name (via CorpLocation)',
  LocCorpContractCd STRING COMMENT 'Corporate Contract Code',
  LocCorpContractNm STRING COMMENT 'Corporate Contract Name',
  LocCorpContractPriceClass STRING COMMENT 'Corporate Contract Price Class Code',
  LocCorpContractBaseClass STRING COMMENT 'Corporate Contract Base Class (Level A, B, C D)',
  LocGPOContractCd STRING COMMENT 'GPO Contract Code (optional)',
  LocGPOContractName STRING COMMENT 'GPO Contract Name (optional)',
  LocGPOContractPriceClass STRING COMMENT 'GPO Contract Price Class Code (optional)',
  LocGPOContractBaseClass STRING COMMENT 'GPO Contract Base Class (Level A, B, C D) (optional)',
  DSLocationID STRING COMMENT 'Calculated reference to combined Location (ref dim_location_ds)',
  AcuteCareBedCnt INT COMMENT 'Number of beds for Acute Care',
  AlzheimersBedCnt INT COMMENT 'Number of beds for Alzheimers',
  AssistedLivingBedCnt INT COMMENT 'Number of beds for Assisted Living',
  HospiceBedCnt INT COMMENT 'Number of beds for Hospice',
  IndependentLivingBedCnt INT COMMENT 'Number of beds for Independent Living',
  IntermediateCareBedCnt INT COMMENT 'Number of beds for Intermediate Care',
  LongTermCareSkilledNursingBedCnt INT COMMENT 'Number of beds for Long Term Care/Skilled Nursing',
  OtherBedCnt INT COMMENT 'Number of beds for Other purposes',
  SubacuteCareBedCnt INT COMMENT 'Number of beds for Subacute Care',
  TotalBedCnt INT COMMENT 'Number of all beds at Location',
  OwnerLocationNm STRING COMMENT 'Owning Location Name')
USING delta
LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/dim_location_dse'
TBLPROPERTIES (
  'delta.minReaderVersion' = '1',
  'delta.minWriterVersion' = '2')


-- change
CREATE OR REPLACE TABLE app_DSI_DataStitching.default.dim_order_dse_channel (
  OrderChannelCd STRING COMMENT 'Ordering Channel Code used when placing the order',
  OrderChannel STRING COMMENT 'Name of Ordering Channel (Phone, DSSI, etc.)',
  OrderChannelGrp STRING COMMENT 'Ordering Channel Group Name (Phone/E-commerce)',
  OrderChannelSubGrp STRING COMMENT 'Ordering Channel Sub-group Name')
USING delta
LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/dim_order_dse_channel'
TBLPROPERTIES (
  'delta.minReaderVersion' = '1',
  'delta.minWriterVersion' = '2')


-- change
CREATE OR REPLACE TABLE app_DSI_DataStitching.default.dim_order_dse_lob (
  LineOfBusinessCurrentKey INT COMMENT 'Generated Identifier',
  LOBCd STRING COMMENT 'Line of Business Code (01, 02, etc.)',
  LOB STRING COMMENT 'Line of Business Name (Aptura, Supply, Capital, etc.)',
  LOBGroupCd STRING COMMENT 'Line of Business Group Code (A, B, etc.)',
  LOBGroup STRING COMMENT 'Line of Business Group Name (Products, Services, etc.)')
USING delta
LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/dim_order_dse_lob'
TBLPROPERTIES (
  'delta.minReaderVersion' = '1',
  'delta.minWriterVersion' = '2')


CREATE TABLE IF NOT EXISTS app_DSI_DataStitching.default.fact_login_tels (
  Location STRING COMMENT 'TELS login Location (ref dim_location_dse)',
  ContactKey STRING COMMENT 'Person/Customer who placed order (ref dim_contact_dse)',
  Date DATE COMMENT 'TELS login Date (ref dim_date.Date)',
  LoginTELS INT COMMENT 'Count of TELS logins (any)'
USING delta
LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/fact_login_tels'
TBLPROPERTIES (
  'delta.minReaderVersion' = '1',
  'delta.minWriterVersion' = '2');


-- change
CREATE OR REPLACE TABLE app_DSI_DataStitching.default.fact_order_dse (
  LineId INT COMMENT 'Line source identifier (TrLines.LineID)',
  OrderDate DATE COMMENT 'Date order was placed (ref dim_date)',
  Location STRING COMMENT 'Order Location (ref dim_location_dse)',
  ContactKey STRING COMMENT 'Person/Customer who placed order (ref dim_contact_dse)',
  LineOfBusinessCurrentKey INT COMMENT 'Order Line of Business (ref dim_order_dse_lob)',
  OrderChannelCd STRING COMMENT 'Ordering channel used to place order (ref dim_order_dse_channel)',
  ProductCurrentKey INT COMMENT 'Product ordered (ref dim_product_dse)',
  OrderCancelled BOOLEAN COMMENT 'Is Order Canceled',
  OrderNbr STRING COMMENT 'Order Number',
  OrderWhen TIMESTAMP COMMENT 'Date and Time order was placed',
  LineQty DECIMAL(18,4) COMMENT 'Line units ordered',
  LineUnitSell DECIMAL(18,4) COMMENT 'Line sell price per unit',
  LineAmount DECIMAL(18,4) COMMENT 'Total line amount (LineQty*LineUnitSell + line charges)',
  LineUMCd STRING COMMENT 'Unit of measure (e.g. case, each…)',
  OrderCorpContractCd STRING COMMENT 'Contract Code at time of order',
  OrderCorpContractNm STRING COMMENT 'Contract Name at time of order',
  OrderGPOContractCd STRING COMMENT '(Optional) GPO Contract Code at time of order',
  OrderGPOContractNm STRING COMMENT '(Optional) GPO Contract Name at time of order',
  ContractedProduct BOOLEAN COMMENT 'Contracted product (price) at time of order')
USING delta
LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/fact_order_dse'
TBLPROPERTIES (
  'delta.minReaderVersion' = '1',
  'delta.minWriterVersion' = '2');

-- new
CREATE TABLE IF NOT EXISTS app_DSI_DataStitching.default.dim_product_dse (
  ProductCurrentKey INT COMMENT 'Product source identifier (DimProductCurrent.ProductCurrentKey)',
  ProductNbr STRING COMMENT 'DS (categorized) or Supplier (non-categorized) product number',
  ProductSegmentId INT COMMENT 'DS product segment identifier (first category tier)',
  ProductSegment STRING COMMENT 'DS product segment name',
  ProductProgramId INT COMMENT 'DS product program identifier (second category tier)',
  ProductProgram STRING COMMENT 'DS product program name',
  ProductSubGroupId STRING COMMENT 'DS product sub group identifier (third category tier)',
  ProductSubGroup STRING COMMENT 'DS product sub group name',
  ProductPriceFamily STRING COMMENT 'DS product price family.  Similar to product model name',
  ProductType STRING COMMENT 'DS product type',
  ProductSubType STRING COMMENT 'DS product sub-type',
  ProductPreFlatNbr STRING COMMENT 'DS product number before prem flattening (delineates similar products)',
  ProductDesc STRING COMMENT 'Line/Product description',
  SupplierCd STRING COMMENT 'Supplier Code',
  SupplierNm STRING COMMENT 'Supplier Name')
  USING delta 
  LOCATION 's3://ds-data-databricks-sandbox/catalog/unity/data_platform/tables/app_DSI_DataStitching/default/dim_product_dse'
  TBLPROPERTIES (
    'delta.minReaderVersion' = '1',
    'delta.minWriterVersion' = '2');



