view: purchase_order_lines_mby {
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

      , inventtrans_stg as (
      -- Inventory Transactions --
      select
      ID, -- GUID --
      case
      when statusissue = 1 then 'Sold'
      when statusissue = 2 then 'Deducted'
      when statusissue = 3 then 'On order'
      when statusissue = 4 then 'Reserved Physical'
      when statusissue = 5 then 'Reserved Ordered'
      when statusissue = 6 then 'Quotation issue'
      else null
      end as statusissue, -- statusissue (Losing inventory transactions) 0 - statusreceipt transaction (not losing inventory) 1 - Sold 2 - Deducted 3 - On order (I think?) Reserved Physical ? Reserved Ordered ? Quotation issue ? --
      case
      when statusreceipt = 1 then 'Purchased'
      when statusreceipt = 2 then 'Received'
      when statusreceipt = 3 then 'Ordered'
      when statusreceipt = 4 then 'Registered'
      when statusreceipt = 5 then 'Arrived'
      when statusreceipt = 6 then 'Quotation receipt'
      else null
      end as statusreceipt, -- statusreceipt (Adding inventory transactions) 0 - statusissue transaction (not adding inventory) 1 - Purchased 2 - Received 3 - Ordered (I think?) Registered ? Arrived ? Quotation Receipt ? --
      currencycode, -- Currency used in transaction --
      DATEFINANCIAL::DATE as DATEFINANCIAL, -- Financial Date --
      DATEPHYSICAL::DATE as DATEPHYSICAL, -- Physical Date --
      INVENTDIMID, -- Inventory Dimension ID Dimension Combination --
      INVENTTRANSORIGIN, -- key mapping field inventtrans to inventtransorigin to inventdim --
      INVOICEID, -- Invoice ID associated with transaction --
      ITEMID, -- Item ID --
      PACKINGSLIPID, -- Pack Slip number --
      QTY, -- Quantity --
      DATAAREAID, -- Legal entity --
      RECID -- Record ID --
      from
      analytics.microsoft_dynamics_365_fno.inventtrans
      )

      , inventtranssum_stg as (
      -- Inventory Transactions --
      select
      statusissue, -- statusissue (Losing inventory transactions) 0 - statusreceipt transaction (not losing inventory) 1 - Sold 2 - Deducted 3 - On order (I think?) Reserved Physical ? Reserved Ordered ? Quotation issue ? --
      statusreceipt, -- statusreceipt (Adding inventory transactions) 0 - statusissue transaction (not adding inventory) 1 - Purchased 2 - Received 3 - Ordered (I think?) Registered ? Arrived ? Quotation Receipt ? --
      currencycode, -- Currency used in transaction --
      DATEFINANCIAL, -- Financial Date --
      DATEPHYSICAL, -- Physical Date --
      INVENTTRANSORIGIN, -- key mapping field inventtrans to inventtransorigin to inventdim --
      ITEMID, -- Item ID --
      PACKINGSLIPID, -- Pack Slip number --
      sum(QTY) as QTY, -- Quantity --
      DATAAREAID -- Legal entity --
      from
      inventtrans_stg
      group by
      statusissue,
      statusreceipt,
      currencycode,
      DATEFINANCIAL,
      DATEPHYSICAL,
      INVENTTRANSORIGIN,
      ITEMID,
      PACKINGSLIPID,
      DATAAREAID
      )

      , inventtransorigin_stg as (
      -- Inventory Transactions Originator (Mapping Table) --
      select
      ID, -- GUID --
      INVENTTRANSID, -- Inventory Transaction ID --
      ITEMID, -- Item ID --
      REFERENCEID, -- Associated Document SO, PO, PRODUCTION, Work, etc --
      DATAAREAID, -- Legal entity --
      RECID -- Record ID --
      from
      analytics.microsoft_dynamics_365_fno.inventtransorigin
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
      INVENTSITEID in ('MBY', 'VUP', 'RND', 'TDC', 'WHM')
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

      , generaljournalentry_stg as (
      -- Financial Vouchers --
      select
      ID, -- GUID --
      JOURNALCATEGORY, -- Journal Category --
      case
      when POSTINGLAYER = '0' then 'Current'
      else CONCAT(POSTINGLAYER, ' - needs mapping')
      end as POSTINGLAYER,
      ACCOUNTINGDATE::DATE as ACCOUNTINGDATE, -- ACCOUNTING DATE --
      DOCUMENTDATE::DATE as DOCUMENTDATE, -- Document Date --
      DOCUMENTNUMBER, -- Document Number (Packing Slip / Product Receipt) --
      JOURNALNUMBER, -- Journal Number --
      LEDGER, -- Ledger combination reference? --
      SUBLEDGERVOUCHER, -- Voucher number ? --
      SUBLEDGERVOUCHERDATAAREAID, -- Legal entity of Voucher? --
      LEDGERENTRYJOURNAL, -- Ledger entry journal reference ? --
      MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the originating document --
      MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the originating document --
      MODIFIEDBY, -- User who last modified the originating document --
      CREATEDDATETIME::DATE as CREATEDDATE, -- Date the PO was originating document --
      CREATEDDATETIME::DATE as CREATEDTIME, -- Time the PO was originating document --
      CREATEDBY, -- User who created the originating document --
      DATAAREAID, -- Legal entity --
      RECID -- Record ID --
      from
      analytics.microsoft_dynamics_365_fno.generaljournalentry
      )

      , postingtype_map as (
      -- EW mapping posting types --
      select distinct
      POSTINGTYPE as POSTINGTYPEID,
      case
      when POSTINGTYPE = '41' then 'Vendor balance'
      when POSTINGTYPE = '71' then 'Purchase expenditure for product'
      when POSTINGTYPE = '82' then 'Cost of purchased materials received'
      when POSTINGTYPE = '84' then 'Cost of purchased materials invoiced'
      when POSTINGTYPE = '203' then 'Purchase accrual'
      else CONCAT(POSTINGTYPE, ' - needs mapping')
      end as POSTINGTYPE
      from
      analytics.microsoft_dynamics_365_fno.generaljournalaccountentry
      order by
      POSTINGTYPE
      )

      , generaljournalaccountentry_stg as (
      -- Voucher Account Entries --
      select
      generaljournalaccountentry.ID, -- GUID --
      postingtype_map.POSTINGTYPE, -- Posting Type ID or needs mapping? --
      generaljournalaccountentry.ACCOUNTINGCURRENCYAMOUNT, -- Amount posted in Accounting Currency --
      generaljournalaccountentry.GENERALJOURNALENTRY, -- General Journal Entry table RecId (maybe?) --
      generaljournalaccountentry.LEDGERACCOUNT, -- Ledger & Dimension Combination of Transaction --
      generaljournalaccountentry.REPORTINGCURRENCYAMOUNT, -- Amount posted in Reporting Currency --
      generaljournalaccountentry.TEXT, -- Document associated to transaction if applicable --
      generaljournalaccountentry.TRANSACTIONCURRENCYAMOUNT, -- Amount posted in Transaction Currency --
      generaljournalaccountentry.TRANSACTIONCURRENCYCODE, -- Transaction Currency --
      TO_VARCHAR(generaljournalaccountentry.MAINACCOUNT) as MAINACCOUNT, -- Main Account --
      generaljournalaccountentry.MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the originating document --
      generaljournalaccountentry.MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the originating document --
      generaljournalaccountentry.MODIFIEDBY, -- User who last modified the originating document --
      generaljournalaccountentry.CREATEDDATETIME::DATE as CREATEDDATE, -- Date the PO was originating document --
      generaljournalaccountentry.CREATEDDATETIME::DATE as CREATEDTIME, -- Time the PO was originating document --
      generaljournalaccountentry.CREATEDBY, -- User who created the originating document --
      generaljournalaccountentry.DATAAREAID, -- Legal entity --
      generaljournalaccountentry.RECID -- Record ID --
      from
      analytics.microsoft_dynamics_365_fno.generaljournalaccountentry
      left join
      postingtype_map
      on generaljournalaccountentry.POSTINGTYPE = postingtype_map.POSTINGTYPEID
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

      , vendpackingslipjour_stg as (
      -- Vendor Product Receipt Journals --
      select
      ID, -- GUID --
      PURCHASETYPE, -- Purchase Type --
      ORDERACCOUNT, -- Order Account --
      COUNTRYREGIONID, -- Country Region --
      DEFAULTDIMENSION, -- Default Dimension Combination --
      DELIVERYDATE::DATE as DELIVERYDATE, -- Delivery Date --
      DELIVERYNAME, -- Delivery Name --
      DELIVERYPOSTALADDRESS, -- Delivery Postal Address ID --
      DOCUMENTDATE::DATE as DOCUMENTDATE, -- Document Date --
      INVOICEACCOUNT, -- Invoice Account Vendor --
      ITEMBUYERGROUPID, -- Item Buyer Group --
      LANGUAGEID, -- Language --
      PACKINGSLIPID, -- Pack Slip --
      PURCHID, -- PO Number --
      REQUESTER, -- Requester User --
      SOURCEDOCUMENTHEADER, -- Source Document Header ID --
      MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the pack slip --
      MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the pack slip --
      MODIFIEDBY, -- User who last modified the pack slip --
      CREATEDDATETIME::DATE as CREATEDDATE, -- Date the pack slip was created --
      CREATEDDATETIME::DATE as CREATEDTIME, -- Time the pack slip was pack slip --
      CREATEDBY, -- User who created the pack slip --
      DATAAREAID, -- Legal entity --
      RECID -- Record ID --
      from
      analytics.microsoft_dynamics_365_fno.vendpackingslipjour
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

      , vendinvoicetrans_stg as (
      -- Vendor Invoice Transactions --
      select
      ID, -- GUID --
      PARTDELIVERY, -- Part Delivery Status T/F --
      READYFORPAYMENT, -- Ready for Payment T/F --
      PURCHID, -- PO number --
      DESTCOUNTRYREGIONID, -- Destination Country --
      CURRENCYCODE, -- Currency --
      DEFAULTDIMENSION, -- Default Financial Dimension Combination --
      DELIVERYNAME, -- Delivery Address Name --
      DELIVERYPOSTALADDRESS, -- Address Reference ID logisticspostaladdress RECID maybe? --
      DESTCOUNTY, -- Destination County --
      DESTSTATE, -- Destination State --
      EXTERNALITEMID, -- External Item ID --
      INTERNALINVOICEID, -- Invoice ID (Internal?) --
      INVENTDATE, -- Inventory Date --
      INVENTDIMID, -- Inventory Dimension Combination --
      INVENTQTY, -- Quantity of Units Sold --
      INVENTTRANSID, -- Inventory Transaction ID --
      INVOICEDATE::DATE as INVOICEDATE, -- Invoice Date --
      INVOICEID, -- Invoice ID --
      ITEMID, -- Item ID --
      LINEAMOUNT, -- Line Amount --
      NAME, -- Inventory Item Name --
      ORIGPURCHID, -- Orginating PO Number --
      PRICEUNIT, -- Price Unit --
      PROCUREMENTCATEGORY, -- Procurement Category RECID --
      PURCHASELINELINENUMBER, -- PO Line Number --
      PURCHPRICE, -- Purchase Price --
      PURCHUNIT, -- Purchase Line Unit --
      QTY, -- Quantity --
      SOURCEDOCUMENTLINE, -- Source Document Line ? --
      TAX_1099_DATE::DATE as TAX_1099_DATE, -- 1099 Tax Date --
      TAXGROUP, -- Tax Group --
      MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the invoice --
      MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the invoice --
      MODIFIEDBY, -- User who last modified the invoice --
      CREATEDDATETIME::DATE as CREATEDDATE, -- Date the invoice was created --
      CREATEDDATETIME::DATE as CREATEDTIME, -- Time the invoice was created --
      CREATEDBY, -- User who created the invoice --
      DATAAREAID, -- Legal entity --
      RECID -- Record ID --
      from
      analytics.microsoft_dynamics_365_fno.vendinvoicetrans
      )

      , vendinvoicejour_stg as (
      -- Vendor Invoice Journals / Headers --
      select
      ID, -- GUID --
      ORDERACCOUNT, -- Ordering Vendor Account ID --
      COSTLEDGERVOUCHER, -- Voucher number --
      COUNTRYREGIONID, -- Country --
      CURRENCYCODE, -- Currency --
      DEFAULTDIMENSION, -- Default Financial Dimension Combination --
      DELIVERYDATE_ES::DATE as DELIVERYDATE_ES, -- Delivery Received Date? --
      DELIVERYNAME, -- Delivery Address Name --
      DELIVERYPOSTALADDRESS, -- Address Reference ID logisticspostaladdress RECID maybe? --
      DOCUMENTDATE::DATE as DOCUMENTDATE, -- Document Date --
      DUEDATE::DATE as DUEDATE, -- Due Date --
      EXCHRATE, -- Exchange Rate --
      FIXEDDUEDATE::DATE as FIXEDDUEDATE, -- Fixed Due Date --
      INTERNALINVOICEID, -- Invoice ID (Internal?) --
      INVOICEACCOUNT, -- Invoice Account Number --
      INVOICEAMOUNT, -- Total Invoice Amount --
      INVOICEDATE::DATE as INVOICEDATE, -- Invoice Date --
      INVOICEID, -- Invoice ID --
      ITEMBUYERGROUPID, -- Item Buyer Group --
      LANGUAGEID, -- Language --
      LEDGERVOUCHER, -- Voucher Number --
      PAYMENT, -- Payment Terms --
      POSTINGPROFILE, -- Posting Profile --
      PURCHID, -- PO Number --
      QTY, -- Total Invoice Qty --
      REMITTANCEADDRESS, -- Remittance Address RECID --
      SALESBALANCE, -- Sales Balance Total --
      SOURCEDOCUMENTHEADER, -- Source Document Header ? --
      SOURCEDOCUMENTLINE, -- Source Document Line ? --
      SUMMARKUP, -- Sum Markup on Invoice --
      TAXGROUP, -- Tax Group --
      VENDGROUP, -- Vendor Group --
      RECEIVEDDATE::DATE as RECEIVEDDATE, -- Received Date --
      STATE, -- State --
      MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the invoice --
      MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the invoice --
      MODIFIEDBY, -- User who last modified the invoice --
      CREATEDDATETIME::DATE as CREATEDDATE, -- Date the invoice was created --
      CREATEDDATETIME::DATE as CREATEDTIME, -- Time the invoice was created --
      CREATEDBY, -- User who created the invoice --
      DATAAREAID, -- Legal entity --
      RECID -- Record ID --
      from
      analytics.microsoft_dynamics_365_fno.vendinvoicejour
      )

      , vendpackingsliptrans_stg as (
      -- Vendor Packing Slip Lines --
      select
      ID, -- GUID --
      STOCKEDPRODUCT, -- Stocked Product T/F --
      DESTCOUNTRYREGIONID, -- Country (Destination) --
      ACCOUNTINGDATE::DATE as ACCOUNTINGDATE, -- Accounting Date --
      COSTLEDGERVOUCHER, -- Voucher Number --
      CURRENCYCODE_W, -- Currency Code --
      DELIVERYDATE::DATE as DELIVERYDATE, -- Delivery Date --
      DESTCOUNTY, -- County (Destination) --
      DESTSTATE, -- State (Destination) --
      EXTERNALITEMID, -- Item ID (External)
      INVENTDATE::DATE as INVENTDATE, -- Inventory Date --
      INVENTDIMID, -- Invent Dimension Combination --
      INVENTQTY, -- Quantity of Inventory on Pack Slip Line --
      INVENTREFID, -- Inventory Reference to Document (PRD) --
      INVENTREFTRANSID, -- Invent Trans ID of Reference Document Line --
      INVENTTRANSID, -- Receiving Transaction ID ==
      ITEMID, -- Item ID --
      LINEAMOUNT_W, -- Total Line Amount Cost --
      LINENUM, -- Pack Slip Line Num --
      NAME, -- Item Name --
      ORDERED, -- Qty Ordered --
      PACKINGSLIPID, -- Pack Slip ID --
      PROCUREMENTCATEGORY, -- Procurement Category RECID --
      PURCHASELINEEXPECTEDDELIVERYDATE::DATE as PURCHASELINEEXPECTEDDELIVERYDATE, -- Expected Delivery Date (Not Actual) --
      PURCHASELINELINENUMBER, -- PO Line Number --
      PURCHUNIT, -- PO Line Unit --
      QTY, -- Actual Quantity --
      SOURCEDOCUMENTLINE, -- Source Document Line ? --
      VENDPACKINGSLIPJOUR, -- Vendor Packing Slip Journal Header RECID --
      MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the pack slip --
      MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the pack slip --
      MODIFIEDBY, -- User who last modified the pack slip --
      CREATEDDATETIME::DATE as CREATEDDATE, -- Date the pack slip was created --
      CREATEDDATETIME::DATE as CREATEDTIME, -- Time the pack slip was created --
      CREATEDBY, -- User who created the pack slip --
      DATAAREAID, -- Legal entity --
      RECID -- Record ID --
      from
      analytics.microsoft_dynamics_365_fno.vendpackingsliptrans
      )

      , vendpackingslipjour_stg as (
      -- Vendor Packing Slip Journal (Header) --
      select
      ID, -- GUID --
      ORDERACCOUNT, -- Order Vendor Account ID --
      COUNTRYREGIONID, -- Country --
      DEFAULTDIMENSION, -- Default Financial Dimension Combination --
      DELIVERYDATE::DATE as DATE, -- Delivery Date --
      DELIVERYNAME, -- Delivery Name --
      DELIVERYPOSTALADDRESS, -- Address Reference ID logisticspostaladdress RECID maybe? --
      INVOICEACCOUNT, -- Invoice Account --
      ITEMBUYERGROUPID, -- Item Buyer Group --
      LANGUAGEID, -- Language --
      PACKINGSLIPID, -- Packing Slip ID --
      PURCHID, -- PO ID --
      REQUESTER, -- Requesting User ID --
      SOURCEDOCUMENTHEADER, -- Source Document Header ? --
      MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the pack slip --
      MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the pack slip --
      MODIFIEDBY, -- User who last modified the pack slip --
      CREATEDDATETIME::DATE as CREATEDDATE, -- Date the pack slip was created --
      CREATEDDATETIME::DATE as CREATEDTIME, -- Time the pack slip was created --
      CREATEDBY, -- User who created the pack slip --
      DATAAREAID, -- Legal entity --
      RECID -- Record ID --
      from
      analytics.microsoft_dynamics_365_fno.vendpackingslipjour
      )

      , dimensionattributevalueset_stg as (
      -- Financial Dimension Set applied to Transaction --
      select
      ID, -- GUID --
      IMPLIEDDATAAREAID, -- Implied Legal Entity --
      MAINACCOUNT, -- Main Account RECID ? --
      MAINACCOUNTVALUE, -- Main Account Value ? --
      DEPARTMENT, -- Department RECID --
      DEPARTMENTVALUE, -- Department Value --
      COSTCENTER, -- CostCenter RECID --
      COSTCENTERVALUE, -- CostCenter Value --
      ITEMGROUP, -- Item Group RECID --
      ITEMGROUPVALUE, -- Item Group Value --
      MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the dimension combination --
      MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the dimension combination --
      MODIFIEDBY, -- User who last modified the dimension combination --
      CREATEDDATETIME::DATE as CREATEDDATE, -- Date the dimension combination was created --
      CREATEDDATETIME::DATE as CREATEDTIME, -- Time the dimension combination was created --
      CREATEDBY, -- User who created the dimension combination --
      DATAAREAID, -- Legal entity --
      RECID -- Record ID --
      from
      analytics.microsoft_dynamics_365_fno.dimensionattributevalueset
      )

      , mainaccount_stg as (
      select
      ID, -- GUID --
      TYPE, -- Type needs mapping --
      ACCOUNTCATEGORYREF, -- Account Category Reference (needs mapping) --
      LEDGERCHARTOFACCOUNTS, -- Ledger Chart of Accounts RECID --
      TO_VARCHAR(MAINACCOUNTID) as MAINACCOUNTID, -- Main Account Number --
      NAME, -- Account Name --
      MODIFIEDDATETIME::DATE as MODIFIEDDATE,  -- Date of the last modification of the account --
      MODIFIEDDATETIME::TIME as MODIFIEDTIME,  -- Time of the last modification of the account --
      MODIFIEDBY, -- User who last modified the account --
      CREATEDDATETIME::DATE as CREATEDDATE, -- Date the account was created --
      CREATEDDATETIME::DATE as CREATEDTIME, -- Time the account was created --
      CREATEDBY, -- User who created the account --
      DATAAREAID, -- Legal entity --
      RECID -- Record ID --
      from
      analytics.microsoft_dynamics_365_fno.mainaccount
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

      , purchase_order_headers_mby_int as (
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

      , purchase_order_lines_mby_int as (
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

      , sum_purchase_order_lines_mby_int as (
      select
      PO_NUMBER,
      SUM(NET_AMOUNT) as SUM_NET_AMOUNT
      from
      purchase_order_lines_mby_int
      where
      PURCHASE_ORDER_LINE_STATUS in ('Open order', 'Received', 'Invoiced')
      group by
      PO_NUMBER
      )

      , purchase_order_lines_mby_mart as (
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
      purchase_order_lines_mby_int
      where
      PURCHASE_ORDER_LINE_STATUS in ('Open order', 'Received', 'Invoiced')
      order by
      PO_NUMBER
      )

      select * from purchase_order_lines_mby_mart
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
