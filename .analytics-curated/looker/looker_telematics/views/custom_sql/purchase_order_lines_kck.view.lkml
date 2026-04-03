view: purchase_order_lines_kck {
  derived_table: {
    sql:
      with prodbom_stg as (
-- Bill of Materials Calculation associated to a Production Order --
select
  ID, -- GUID --
  BOMID, -- Bill of Materials (BOM) ID --
  BOMQTY, -- Qty of Units on the BOM Line --
  DEFAULTDIMENSION, -- Default Financial Dimension Combination --
  INVENTDIMID, -- Component Inventory Dimension Combination ID --
  INVENTREFID, -- Inventory Reference ID to find Purchase order associated for subcontracted work --
  INVENTTRANSID, -- Component Inventory Transaction ID --
  ITEMID, -- Item ID of Component --
  LINENUM, -- Line Number of BOM Line --
  PRODID, -- Production Order ID --
  QTYBOMCALC, -- BOMQTY * amount of manufactured Units being Produced --
  QTYINVENTCALC, -- BOMQTY * amount of manufactured Units being Produced (Actual Inventory being decremented if amount of units doesn't match BOM) --
  RAWMATERIALDATE::DATE, -- Date Raw Material converted to Finished good --
  UNITID, -- Unit Type (Ea) --
  VENDID, -- Vendor ID associated for subcontracted work --
  DATAAREAID, -- Legal Entity --
  RECID -- Record ID of PRODBOM table --
from
  analytics.microsoft_dynamics_365_fno.prodbom
)

, ecoresproduct_stg as (
-- All Products (Released and Inactive) --
select
  ID, -- GUID --
  PRODUCTTYPE, -- Product Type ID field (needs mapping) --
  DISPLAYPRODUCTNUMBER, -- Product Number "Display" --
  SEARCHNAME, -- Product Search Name --
  ENGCHGPRODUCTOWNERID, -- Engineering Change Management Product Owner User ID --
  ENGCHGPRODUCTCATEGORYDETAILS, -- Engineering Change Management ID field mapping to category details --
  ENGCHGPRODUCTRELEASEPOLICY, -- Engineering Change Management ID field mapping to release policy details --
  ENGCHGPRODUCTREADINESSPOLICY, -- Engineering Change Management ID field mapping to readiness policy details --
  MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the product --
  MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the product --
  MODIFIEDBY, -- User who last modified the product --
  CREATEDDATETIME::DATE as CREATEDDATE, -- Date the product was created --
  CREATEDDATETIME::DATE as CREATEDTIME, -- Time the product was created --
  CREATEDBY, -- User who created the product --
  DATAAREAID, -- Legal entity --
  RECID, -- Record ID --
  VERSIONNUMBER, -- Version Number ID --
  VALIDFORYARDORDER_CUSTOM -- Custom field used in Telematics IOA - not used in MBY --
from
  analytics.microsoft_dynamics_365_fno.ecoresproduct
)

, ecoresproducttranslation_stg as (
-- Product Translations --
select
  ID, -- GUID --
  DESCRIPTION, -- Full Product name description --
  LANGUAGEID, -- Language Code --
  NAME, -- Product Full Name --
  PRODUCT, -- PRODUCT ID ECORESPRODUCT --
  MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the product --
  MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the product --
  MODIFIEDBY, -- User who last modified the product --
  DATAAREAID, -- Legal entity --
  RECID, -- Record ID --
  VERSIONNUMBER -- Version Number ID --
from
  analytics.microsoft_dynamics_365_fno.ecoresproducttranslation
)


, purchtable_stg as (
-- Purchase Order Headers --
select
  ID, -- GUID --
  case
    when DOCUMENTSTATE = '0' then 'Draft'
    when DOCUMENTSTATE = '30' then 'Approved'
    when DOCUMENTSTATE = '40' then 'Confirmed'
    when DOCUMENTSTATE = '50' then 'Finalized'
    else CONCAT(DOCUMENTSTATE, ' - needs mapping')
  end as DOCUMENTSTATE, -- Document State Reference ? --
  case
    when DOCUMENTSTATUS = '5' then 'Packing Slip'
    when DOCUMENTSTATUS = '7' then 'Invoice'
    else CONCAT(DOCUMENTSTATUS, ' - needs mapping')
  end as DOCUMENTSTATUS, -- Document Status ? --
  ISENCUMBRANCEREQUIRED, -- Encumbrance Required T/F --
  case
    when PURCHASETYPE = '3' then 'Purch'
    else CONCAT(PURCHASETYPE, ' - needs mapping')
  end as PURCHASETYPE, -- Purchase Type ID (case mapping) --
  case
    when PURCHSTATUS = '1' THEN 'Open order'
    when PURCHSTATUS = '2' THEN 'Received'
    when PURCHSTATUS = '3' THEN 'Invoiced'
    when PURCHSTATUS = '4' THEN 'Cancelled'
    else CONCAT(PURCHSTATUS, ' - needs mapping')
  end as PURCHSTATUS, -- Purchase Status (case mapping) --
  ORDERACCOUNT, -- Vendor Account ID ordered --
  ACCOUNTINGDATE::DATE as ACCOUNTINGDATE, -- Accounting Date --
  ADDRESSREFRECID, -- Address Reference ID logisticslocation RECID maybe ? --
  CURRENCYCODE, -- Currency Code --
  DEFAULTDIMENSION, -- Default Financial Dimension Combination --
  DELIVERYDATE::DATE as DELIVERYDATE, -- Promised Delivery Date not actual --
  DELIVERYNAME, -- Delivery Address Name --
  DELIVERYPOSTALADDRESS, -- Address Reference ID logisticspostaladdress RECID maybe? --
  EMAIL, -- Email address of vendor account used in PO --
  INVENTLOCATIONID, -- Inventory Location ID --
  INVENTSITEID, -- Inventory Site ID --
  INVOICEACCOUNT, -- Vendor account ID invoiced --
  ITEMBUYERGROUPID, -- Buyer Group --
  LANGUAGEID, -- Language --
  PAYMENT, -- Payment Terms --
  PAYMMODE, -- Payment Mode ? --
  PAYMSPEC, -- Payment Specs ? --
  POSTINGPROFILE, -- Posting Profile --
  PURCHID, -- PO Number --
  PURCHNAME, -- PO Vendor name from Account --
  REQUESTER, -- Requester User ID maps to users --
  RETURNITEMNUM, -- Item Number associated to Return Order --
  CONFIRMEDSHIPDATE::DATE as CONFIRMEDSHIPDATE, -- Confirmed Shipping Date (not actual) --
  REQUESTEDSHIPDATE::DATE as REQUESTEDSHIPDATE, -- Requested Shipping Date (not actual) --
  SOURCEDOCUMENTHEADER, -- Source Document ID ? --
  SOURCEDOCUMENTLINE, -- Source Document Line ? --
  TAXGROUP, -- Tax Group --
  VENDGROUP, -- Vendor Group --
  VENDORREF, -- Vendor Reference --
  WORKERPURCHPLACER, -- User ID who placed PO --
  MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the PO --
  MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the PO --
  MODIFIEDBY, -- User who last modified the PO --
  CREATEDDATETIME::DATE as CREATEDDATE, -- Date the PO was created --
  CREATEDDATETIME::DATE as CREATEDTIME, -- Time the PO was created --
  CREATEDBY, -- User who created the PO --
  DATAAREAID, -- Legal entity --
  RECID -- Record ID --
from
  analytics.microsoft_dynamics_365_fno.purchtable
where
  INVENTSITEID = 'KCK'
)

, purchline_stg as (
-- Purchase Order All Lines --
select
  ID, -- GUID --
  PURCHASETYPE, -- Purchase Type ID (case mapping) --
  case
    when PURCHSTATUS = '1' THEN 'Deleted/Draft'
    when PURCHSTATUS = '2' THEN 'Received'
    when PURCHSTATUS = '3' THEN 'Invoiced'
    when PURCHSTATUS = '4' THEN 'Cancelled'
    else CONCAT(PURCHSTATUS, ' - needs mapping')
  end as PURCHSTATUS, -- Purchase Status (case mapping) --
  RETURNSTATUS, -- Return order status (case mapping) --
  STOCKEDPRODUCT, -- Stocked Product status T/F --
  WORKFLOWSTATE, -- Workflow State --
  TAXGROUP, -- Tax Group --
  ADDRESSREFRECID, -- Address Reference ID logisticslocation RECID maybe ? --
  CURRENCYCODE, -- Currency Code --
  CUSTOMERREF, -- Customer Reference ? Not vendor ? --
  DEFAULTDIMENSION, -- Default Financial Dimension Combination --
  DELIVERYNAME, -- Delivery Address Name --
  DELIVERYPOSTALADDRESS, -- Address Reference ID logisticspostaladdress RECID maybe? --
  INVENTDIMID, -- Inventory Dimension ID Dimension Combination --
  INVENTTRANSID, -- Inventory Transaction ID --
  ITEMID, -- Item ID --
  LEDGERDIMENSION, -- Actual Financial Dimension Combination ? --
  LINEAMOUNT, -- Purchase Line amount --
  LINENUMBER, -- Purchase Line Number --
  NAME, -- PO Line Product Name --
  PRICEUNIT, -- Price unit --
  PURCHID, -- PO Number --
  PURCHPRICE, -- Unit Price --
  PURCHQTY, -- Qty of items purchased on the line --
  PURCHUNIT, -- PO line unit type --
  REQUESTER, -- Requester User ID maps to users --
  SOURCEDOCUMENTLINE, -- Source Document Line ? --
  VENDACCOUNT, -- Vendor Account --
  VENDGROUP, -- Vendor Group --
  CONFIRMEDSHIPDATE::DATE, -- Confirmed Shipping Date (not actual) --
  REQUESTEDSHIPDATE::DATE, -- Requested Shipping Date (not actual) --
  MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the PO --
  MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the PO --
  MODIFIEDBY, -- User who last modified the PO --
  CREATEDDATETIME::DATE as CREATEDDATE, -- Date the PO was created --
  CREATEDDATETIME::TIME as CREATEDTIME, -- Time the PO was created --
  CREATEDBY, -- User who created the PO --
  DATAAREAID, -- Legal entity --
  RECID -- Record ID --
from
  analytics.microsoft_dynamics_365_fno.purchline
)

, logisticspostaladdress_stg as (
-- Logistics Location Postal Address --
select
  ID, -- GUID --
  ADDRESS, -- Delivery Postal Address --
  CITY, -- City --
  COUNTY, -- County --
  LOCATION, -- Location ID --
  STATE, -- State --
  STREET, -- Street --
  ZIPCODE, -- Zip Code --
  MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the originating document --
  MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the originating document --
  MODIFIEDBY, -- User who last modified the originating document --
  CREATEDDATETIME::DATE as CREATEDDATE, -- Date the PO was originating document --
  CREATEDDATETIME::DATE as CREATEDTIME, -- Time the PO was originating document --
  CREATEDBY, -- User who created the originating document --
  DATAAREAID, -- Legal entity --
  RECID -- Record ID --
from
  analytics.microsoft_dynamics_365_fno.logisticspostaladdress
)

, inventtable_stg as (
-- Inventory Managment Items --
select
  ID, -- GUID --
  PURCHMODEL, -- Purchasing Model ? --
  SALESMODEL, -- Sales model ? --
  SALESPRICEMODELBASIC, -- Sales Price Model ? --
  ITEMID, -- Item ID --
  BOMUNITID, -- BOM Unit Type --
  DEFAULTDIMENSION, -- Default Financial Dimension Combination --
  NAMEALIAS, -- Item Name Alias --
  PRIMARYVENDORID, -- Preferred Vendor --
  PRODUCT, -- Product Table ID --
  PRODUCTLIFECYCLESTATEID, -- Product Lifecycle State --
  MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the pack slip --
  MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the pack slip --
  MODIFIEDBY, -- User who last modified the pack slip --
  CREATEDDATETIME::DATE as CREATEDDATE, -- Date the pack slip was created --
  CREATEDDATETIME::DATE as CREATEDTIME, -- Time the pack slip was pack slip --
  CREATEDBY, -- User who created the pack slip --
  DATAAREAID, -- Legal entity --
  RECID -- Record ID --
from
  analytics.microsoft_dynamics_365_fno.inventtable
where
  DATAAREAID = 'esi'
)

, vendtable_stg as (
-- All Vendors --
select
  ID, -- GUID --
  W_9, -- W9 eligible? --
  PAYMTERMID, -- Payment Terms --
  ACCOUNTNUM, -- Vendor Account Number --
  BANKACCOUNT, -- Bank Account Type --
  CURRENCY, -- Currency --
  DEFAULTINVENTSTATUSID, -- Default Inventory Status Purchasing trans --
  PARTY, -- GAB RecID --,
  PAYMMODE, -- Payment Mode --
  TAX_1099_FIELDS, -- 1099 vendors connector ID --
  VENDGROUP, -- Vendor Group --
  MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the vendor --
  MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the vendor --
  MODIFIEDBY, -- User who last modified the vendor --
  CREATEDDATETIME::DATE as CREATEDDATE, -- Date the vendor was created --
  CREATEDDATETIME::DATE as CREATEDTIME, -- Time the vendor was created --
  CREATEDBY, -- User who created the vendor --
  DATAAREAID, -- Legal entity --
  RECID, -- Record ID --
  TAX_1099_REGNUM, -- 1099 Registration number --
from
  analytics.microsoft_dynamics_365_fno.vendtable
)

, dirpartytable_stg as (
-- Global Address Book (GAB) --
select
  ID, -- GUID --
  INSTANCERELATIONTYPE, -- Instance Relationship Type --
  LANGUAGEID, -- Language --
  NAME, -- Full Name of Party --
  NAMEALIAS, -- Alias Name of Party --
  PARTYNUMBER, -- Party Number --
  PRIMARYADDRESSLOCATION, -- LogLoc table address location ID primary to party --
  PRIMARYCONTACTEMAIL, -- Primary Contact Email maps to an email table RECID --
  MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the party --
  MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the party --
  MODIFIEDBY, -- User who last modified the party --
  CREATEDDATETIME::DATE as CREATEDDATE, -- Date the party was created --
  CREATEDDATETIME::DATE as CREATEDTIME, -- Time the party was created --
  CREATEDBY, -- User who created the vendor --
  DATAAREAID, -- Legal entity --
  RECID, -- Record ID --
from
  analytics.microsoft_dynamics_365_fno.dirpartytable
  )

, purchase_order_headers_kck_int as (
select
  -- Header Details --
  purchtable_stg.PURCHID as PO_NUMBER,
  purchtable_stg.DELIVERYDATE as REQUESTED_RECEIPT_DATE,
  purchtable_stg.INVENTSITEID as SITE,
  purchtable_stg.INVENTLOCATIONID as WAREHOUSE,
  purchtable_stg.DOCUMENTSTATE as DOCUMENT_STATE,
  purchtable_stg.DOCUMENTSTATUS as DOCUMENT_STATUS,
  purchtable_stg.PURCHSTATUS as PURCHASE_ORDER_STATUS,
  case
    when prodbom_stg.PRODID like 'PRD%' then PRODID
    else 'Not Referenced'
  end as REFERENCE_NUMBER,
  prodbom_stg.INVENTTRANSID as REFERENCE_LOT,
  purchtable_stg.DELIVERYNAME as DELIVERY_NAME,
  logisticspostaladdress_stg.ADDRESS as DELIVERY_ADDRESS,
  case
    when prodbom_stg.PRODID like 'PRD%' then 'Production Line'
    else 'Not Referenced'
  end as REFERENCE_TYPE,
  purchtable_stg.ORDERACCOUNT as VENDOR_ACCOUNT,
  vendtable_stg.VENDGROUP as VENDOR_GROUP,
  dirpartytable_stg.NAME as VENDOR_NAME,
  purchtable_stg.CREATEDBY as ORDERER
from
  purchtable_stg
left join
  logisticspostaladdress_stg
  on purchtable_stg.DELIVERYPOSTALADDRESS = logisticspostaladdress_stg.RECID
left join
  prodbom_stg
  on purchtable_stg.PURCHID = prodbom_stg.INVENTREFID
left join
  vendtable_stg
  on purchtable_stg.ORDERACCOUNT = vendtable_stg.ACCOUNTNUM
left join
  dirpartytable_stg
  on vendtable_stg.PARTY = dirpartytable_stg.RECID
  )

, purchase_order_lines_kck_int as (
select
  -- Header Details --
  purchtable_stg.PURCHID as PO_NUMBER,
  -- Line & Product Details --
  purchline_stg.LINENUMBER as LINE_NUMBER,
  purchline_stg.ITEMID as ITEM_NUMBER,
  case
    when ecoresproducttranslation_stg.NAME is not null then ecoresproducttranslation_stg.NAME
    when ecoresproducttranslation_stg.NAME is null then purchline_stg.NAME
  end as PRODUCT_NAME,
  purchline_stg.PURCHQTY as QUANTITY,
  purchline_stg.PURCHUNIT as UNIT,
  purchline_stg.PURCHPRICE as UNIT_PRICE,
  purchline_stg.LINEAMOUNT as NET_AMOUNT,
  purchline_stg.CUSTOMERREF as CUSTOMER_REFERENCE,
  purchline_stg.PURCHSTATUS as LINE_STATUS,
  purchline_stg.INVENTTRANSID as LOT_ID,
  purchline_stg.CREATEDDATE as CREATED_DATE,
  purchline_stg.CREATEDTIME as CREATED_TIME,
  case
    when purchtable_stg.DOCUMENTSTATE = 'Draft' and purchtable_stg.PURCHSTATUS = 'Open order' and purchline_stg.PURCHSTATUS = 'Deleted/Draft' then 'Open order'
    when purchtable_stg.DOCUMENTSTATE = 'Draft' and purchtable_stg.PURCHSTATUS != 'Open order' and purchline_stg.PURCHSTATUS = 'Deleted/Draft' then 'Open order'
    when purchtable_stg.DOCUMENTSTATE = 'Approved' and purchtable_stg.PURCHSTATUS = 'Open order' and purchline_stg.PURCHSTATUS = 'Deleted/Draft' then 'Open order'
    when purchtable_stg.DOCUMENTSTATE = 'Approved' and purchtable_stg.PURCHSTATUS != 'Open order' and purchline_stg.PURCHSTATUS = 'Deleted/Draft' then 'Deleted'
    when purchtable_stg.DOCUMENTSTATE = 'Confirmed' and purchtable_stg.PURCHSTATUS = 'Open order' and purchline_stg.PURCHSTATUS = 'Deleted/Draft' then 'Open order'
    when purchtable_stg.DOCUMENTSTATE = 'Confirmed' and purchtable_stg.PURCHSTATUS != 'Open order' and purchline_stg.PURCHSTATUS = 'Deleted/Draft' then 'Deleted'
    when purchtable_stg.DOCUMENTSTATE in ('Approved', 'Confirmed') and purchline_stg.PURCHSTATUS != 'Deleted/Draft' then purchline_stg.PURCHSTATUS
    when purchline_stg.PURCHSTATUS = 'Cancelled' then 'Cancelled'
  end as PURCHASE_ORDER_LINE_STATUS,
  '' as POSTING_ITEM_GROUP,
  '' as ITEM_COST_GROUP,
  '' as PRODUCT_TYPE
from
  purchline_stg
left join
  purchtable_stg
  on purchline_stg.PURCHID = purchtable_stg.PURCHID
left join
  inventtable_stg
  on purchline_stg.ITEMID = inventtable_stg.ITEMID
left join
  ecoresproduct_stg
  on inventtable_stg.PRODUCT = ecoresproduct_stg.RECID
left join
  ecoresproducttranslation_stg
  on ecoresproduct_stg.RECID = ecoresproducttranslation_stg.PRODUCT
  )

, sum_purchase_order_lines_kck_int as (
select
  PO_NUMBER,
  SUM(NET_AMOUNT) as SUM_NET_AMOUNT
from
  purchase_order_lines_kck_int
where
  PURCHASE_ORDER_LINE_STATUS in ('Open order', 'Received', 'Invoiced')
group by
  PO_NUMBER
)

, purchase_order_lines_kck_mart as (
select
  PO_NUMBER,
  ITEM_NUMBER,
  PRODUCT_NAME,
  QUANTITY,
  UNIT,
  UNIT_PRICE,
  NET_AMOUNT,
  PURCHASE_ORDER_LINE_STATUS
from
  purchase_order_lines_kck_int
where
  PURCHASE_ORDER_LINE_STATUS in ('Open order', 'Received', 'Invoiced')
order by
  PO_NUMBER
)

, purchase_order_headers_kck_mart as (
select
  purchase_order_headers_kck_int.PO_NUMBER,
  purchase_order_headers_kck_int.REQUESTED_RECEIPT_DATE,
  purchase_order_headers_kck_int.SITE,
  purchase_order_headers_kck_int.DOCUMENT_STATE,
  purchase_order_headers_kck_int.PURCHASE_ORDER_STATUS,
  purchase_order_headers_kck_int.VENDOR_GROUP,
  purchase_order_headers_kck_int.VENDOR_ACCOUNT,
  purchase_order_headers_kck_int.VENDOR_NAME,
  purchase_order_headers_kck_int.REFERENCE_TYPE,
  purchase_order_headers_kck_int.REFERENCE_NUMBER,
  sum_purchase_order_lines_kck_int.SUM_NET_AMOUNT::DECIMAL(15,2) as SUM_NET_AMOUNT,
  purchase_order_headers_kck_int.ORDERER
from
  purchase_order_headers_kck_int
left join
  sum_purchase_order_lines_kck_int
  on purchase_order_headers_kck_int.PO_NUMBER = sum_purchase_order_lines_kck_int.PO_NUMBER
order by
  PO_NUMBER
)

select * from purchase_order_lines_kck_mart
      ;;
  }

  dimension: PO_NUMBER {
    type: string
    sql: ${TABLE}.PO_NUMBER ;;
  }

  dimension: ITEM_NUMBER {
    type: string
    sql: ${TABLE}.ITEM_NUMBER ;;
  }

  dimension: PRODUCT_NAME {
    type: string
    sql: ${TABLE}.PRODUCT_NAME ;;
  }

  dimension: QUANTITY {
    type: number
    sql: ${TABLE}.QUANTITY ;;
  }

  dimension: UNIT {
    type: string
    sql: ${TABLE}.UNIT ;;
  }

  dimension: UNIT_PRICE {
    type: number
    sql: ${TABLE}.UNIT_PRICE ;;
  }

  dimension: NET_AMOUNT {
    type: number
    sql: ${TABLE}.NET_AMOUNT ;;
  }

  dimension: PURCHASE_ORDER_LINE_STATUS {
    type: string
    sql: ${TABLE}.PURCHASE_ORDER_LINE_STATUS ;;
  }

}
