view: concur_update_pos_select {
  derived_table: {
    sql: SELECT
          CAST(API_DETAIL.ORDERDATE AS DATE)                                        AS PO_DATE,
          API_DETAIL.PURCHASEORDERNUMBER                                            AS PO_NUMBER,
          API_DETAIL.VENDORCODE                                                     AS VENDOR_ID,
          VEND_INT.NAME                                                             AS VENDOR_NAME,
          API_DETAIL.STATE                                                          AS PO_STATE,
          LISTAGG(API_DETAIL.FULL, '') WITHIN GROUP ( ORDER BY API_DETAIL.LINE_NO ) AS IMPORT_THIS
      FROM
          (SELECT
               TO_DATE(POH.WHENCREATED)                                                                           AS ORDERDATE,
               POH.DOCNO                                                                                          AS PURCHASEORDERNUMBER,
               POH.CUSTVENDID                                                                                     AS VENDORCODE,
               POH.STATE                                                                                          AS STATE,
               POL.LINE_NO,
               CONCAT(IFNULL(CASE
                                 WHEN RANK()
                                              OVER (PARTITION BY POH.DOCNO ORDER BY POL.LINE_NO ASC) = 1 THEN CONCAT(
                                         '<?xml version="1.0" encoding="UTF-8"?><PurchaseOrder><CurrencyCode>USD</CurrencyCode><Custom1>-</Custom1><Description></Description><Name>ES - Corporate</Name><OrderDate>',
                                         CAST(POH.WHENCREATED AS DATE),
                                         '</OrderDate><PolicyExternalID>PO</PolicyExternalID><PurchaseOrderNumber>', REPLACE(
                                                 REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IFNULL(POH.DOCNO, ''), CHAR(9), '')),
                                                                         '&',
                                                                         '&amp;'), '''', '&apos;'), '"', '&quot;'), '<',
                                                 '&lt;'),
                                         '</PurchaseOrderNumber><Status>Transmitted</Status><VendorAddressCode>',
                                         POH.CUSTVENDID,
                                         '</VendorAddressCode><VendorCode>', POH.CUSTVENDID, '</VendorCode>')
                                 ELSE NULL END, ''), IFNULL(CONCAT('<LineItem><Custom1>', REPLACE(REPLACE(REPLACE(REPLACE(
                                                                                                                          TRIM(REPLACE(IFNULL(POL.DEPARTMENTID, ''), CHAR(9), '')),
                                                                                                                          '&',
                                                                                                                          '&amp;'),
                                                                                                                  '''',
                                                                                                                  '&apos;'),
                                                                                                          '"', '&quot;'), '<',
                                                                                                  '&lt;'),
                                                                   '</Custom1><Custom20>',POL.GLDIMEXPENSE_LINE,'</Custom20><Description>', REPLACE(REPLACE(REPLACE(REPLACE(
                                                                                                                              TRIM(REPLACE(IFNULL(POL.MEMO, ''), CHAR(9), '')),
                                                                                                                              '&',
                                                                                                                              '&amp;'),
                                                                                                                      '''',
                                                                                                                      '&apos;'),
                                                                                                              '"', '&quot;'),
                                                                                                      '<',
                                                                                                      '&lt;'),
                                                                   '</Description><ExternalID>', POL.RECORDNO,
                                                                   '</ExternalID><LineNumber>', POL.LINE_NO + 1,
                                                                   '</LineNumber><Quantity>', POL.QTY_REMAINING,
                                                                   '</Quantity><ReceivedQuantity>', POL.QTY_REMAINING,
                                                                   '</ReceivedQuantity><SupplierPartID>',
                                                                   REPLACE(REPLACE(REPLACE(REPLACE(
                                                                                                   TRIM(REPLACE(IFNULL(POL.ITEMDESC, ''), CHAR(9), '')),
                                                                                                   '&', '&amp;'), '''',
                                                                                           '&apos;'),
                                                                                   '"',
                                                                                   '&quot;'), '<', '&lt;'),
                                                                   '</SupplierPartID><UnitPrice>', POL.UIPRICE,
                                                                   '</UnitPrice><UnitofMeasureCode>EA</UnitofMeasureCode><AccountCode>',
                                                                   REPLACE(REPLACE(REPLACE(REPLACE(
                                                                                                   TRIM(REPLACE(IFNULL(POL.ITEMID, ''), CHAR(9), '')),
                                                                                                   '&',
                                                                                                   '&amp;'),
                                                                                           '''',
                                                                                           '&apos;'), '"',
                                                                                   '&quot;'), '<',
                                                                           '&lt;'),
                                                                   '</AccountCode></LineItem>'), ''), IFNULL(CASE
                                                                                                                 WHEN RANK()
                                                                                                                              OVER (PARTITION BY POH.DOCNO ORDER BY POL.LINE_NO DESC) =
                                                                                                                      1
                                                                                                                     THEN CONCAT(
                                                                                                                         '<BillToAddress><Address1>',
                                                                                                                         REPLACE(
                                                                                                                                 REPLACE(
                                                                                                                                         REPLACE(
                                                                                                                                                 REPLACE(
                                                                                                                                                         TRIM(REPLACE(IFNULL(BILLTO.MAILADDRESS_ADDRESS1, ''), CHAR(9), '')),
                                                                                                                                                         '&',
                                                                                                                                                         '&amp;'),
                                                                                                                                                 '''',
                                                                                                                                                 '&apos;'),
                                                                                                                                         '"',
                                                                                                                                         '&quot;'),
                                                                                                                                 '<',
                                                                                                                                 '&lt;'),
                                                                                                                         '</Address1><City>',
                                                                                                                         REPLACE(
                                                                                                                                 REPLACE(
                                                                                                                                         REPLACE(
                                                                                                                                                 REPLACE(
                                                                                                                                                         TRIM(REPLACE(IFNULL(BILLTO.MAILADDRESS_CITY, ''), CHAR(9), '')),
                                                                                                                                                         '&',
                                                                                                                                                         '&amp;'),
                                                                                                                                                 '''',
                                                                                                                                                 '&apos;'),
                                                                                                                                         '"',
                                                                                                                                         '&quot;'),
                                                                                                                                 '<',
                                                                                                                                 '&lt;'),
                                                                                                                         '</City><CountryCode>',
                                                                                                                         REPLACE(
                                                                                                                                 REPLACE(
                                                                                                                                         REPLACE(
                                                                                                                                                 REPLACE(
                                                                                                                                                         TRIM(REPLACE(IFNULL(BILLTO.MAILADDRESS_COUNTRYCODE, ''), CHAR(9), '')),
                                                                                                                                                         '&',
                                                                                                                                                         '&amp;'),
                                                                                                                                                 '''',
                                                                                                                                                 '&apos;'),
                                                                                                                                         '"',
                                                                                                                                         '&quot;'),
                                                                                                                                 '<',
                                                                                                                                 '&lt;'),
                                                                                                                         '</CountryCode><ExternalID>',
                                                                                                                         BILLTO.RECORDNO,
                                                                                                                         '</ExternalID><PostalCode>',
                                                                                                                         REPLACE(
                                                                                                                                 REPLACE(
                                                                                                                                         REPLACE(
                                                                                                                                                 REPLACE(
                                                                                                                                                         TRIM(REPLACE(IFNULL(BILLTO.MAILADDRESS_ZIP, ''), CHAR(9), '')),
                                                                                                                                                         '&',
                                                                                                                                                         '&amp;'),
                                                                                                                                                 '''',
                                                                                                                                                 '&apos;'),
                                                                                                                                         '"',
                                                                                                                                         '&quot;'),
                                                                                                                                 '<',
                                                                                                                                 '&lt;'),
                                                                                                                         '</PostalCode><StateProvince>',
                                                                                                                         REPLACE(
                                                                                                                                 REPLACE(
                                                                                                                                         REPLACE(
                                                                                                                                                 REPLACE(
                                                                                                                                                         TRIM(REPLACE(IFNULL(BILLTO.MAILADDRESS_STATE, ''), CHAR(9), '')),
                                                                                                                                                         '&',
                                                                                                                                                         '&amp;'),
                                                                                                                                                 '''',
                                                                                                                                                 '&apos;'),
                                                                                                                                         '"',
                                                                                                                                         '&quot;'),
                                                                                                                                 '<',
                                                                                                                                 '&lt;'),
                                                                                                                         '</StateProvince></BillToAddress><ShipToAddress><Address1>',
                                                                                                                         REPLACE(
                                                                                                                                 REPLACE(
                                                                                                                                         REPLACE(
                                                                                                                                                 REPLACE(
                                                                                                                                                         TRIM(REPLACE(IFNULL(SHIPTO.MAILADDRESS_ADDRESS1, ''), CHAR(9), '')),
                                                                                                                                                         '&',
                                                                                                                                                         '&amp;'),
                                                                                                                                                 '''',
                                                                                                                                                 '&apos;'),
                                                                                                                                         '"',
                                                                                                                                         '&quot;'),
                                                                                                                                 '<',
                                                                                                                                 '&lt;'),
                                                                                                                         '</Address1><City>',
                                                                                                                         REPLACE(
                                                                                                                                 REPLACE(
                                                                                                                                         REPLACE(
                                                                                                                                                 REPLACE(
                                                                                                                                                         TRIM(REPLACE(IFNULL(SHIPTO.MAILADDRESS_CITY, ''), CHAR(9), '')),
                                                                                                                                                         '&',
                                                                                                                                                         '&amp;'),
                                                                                                                                                 '''',
                                                                                                                                                 '&apos;'),
                                                                                                                                         '"',
                                                                                                                                         '&quot;'),
                                                                                                                                 '<',
                                                                                                                                 '&lt;'),
                                                                                                                         '</City><CountryCode>',
                                                                                                                         REPLACE(
                                                                                                                                 REPLACE(
                                                                                                                                         REPLACE(
                                                                                                                                                 REPLACE(
                                                                                                                                                         TRIM(REPLACE(IFNULL(SHIPTO.MAILADDRESS_COUNTRYCODE, ''), CHAR(9), '')),
                                                                                                                                                         '&',
                                                                                                                                                         '&amp;'),
                                                                                                                                                 '''',
                                                                                                                                                 '&apos;'),
                                                                                                                                         '"',
                                                                                                                                         '&quot;'),
                                                                                                                                 '<',
                                                                                                                                 '&lt;'),
                                                                                                                         '</CountryCode><ExternalID>',
                                                                                                                         SHIPTO.RECORDNO,
                                                                                                                         '</ExternalID><PostalCode>',
                                                                                                                         REPLACE(
                                                                                                                                 REPLACE(
                                                                                                                                         REPLACE(
                                                                                                                                                 REPLACE(
                                                                                                                                                         TRIM(REPLACE(IFNULL(SHIPTO.MAILADDRESS_ZIP, ''), CHAR(9), '')),
                                                                                                                                                         '&',
                                                                                                                                                         '&amp;'),
                                                                                                                                                 '''',
                                                                                                                                                 '&apos;'),
                                                                                                                                         '"',
                                                                                                                                         '&quot;'),
                                                                                                                                 '<',
                                                                                                                                 '&lt;'),
                                                                                                                         '</PostalCode><StateProvince>',
                                                                                                                         REPLACE(
                                                                                                                                 REPLACE(
                                                                                                                                         REPLACE(
                                                                                                                                                 REPLACE(
                                                                                                                                                         TRIM(REPLACE(IFNULL(SHIPTO.MAILADDRESS_STATE, ''), CHAR(9), '')),
                                                                                                                                                         '&',
                                                                                                                                                         '&amp;'),
                                                                                                                                                 '''',
                                                                                                                                                 '&apos;'),
                                                                                                                                         '"',
                                                                                                                                         '&quot;'),
                                                                                                                                 '<',
                                                                                                                                 '&lt;'),
                                                                                                                         '</StateProvince></ShipToAddress></PurchaseOrder>')
                                                                                                                 ELSE NULL END,
                                                                                                             '')) AS FULL
      //TO_VARCHAR(POH.WHENCREATED ::timestamp, 'yyyy-mm-dd'),
           FROM
               ANALYTICS.INTACCT.PODOCUMENT POH
                   LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY POL
                             ON POH.DOCID = POL.DOCHDRID
                   LEFT JOIN ANALYTICS.INTACCT.CONTACT BILLTO ON POH.BILLTO_CONTACTNAME = BILLTO.CONTACTNAME
                   LEFT JOIN ANALYTICS.INTACCT.CONTACT SHIPTO ON POH.SHIPTO_CONTACTNAME = SHIPTO.CONTACTNAME
                   LEFT JOIN ANALYTICS.CONCUR.SYNC_LOG_PO SLPO ON POH.DOCNO = SLPO.PO_NUMBER
           WHERE
                 POH.DOCPARID = 'Purchase Order'
             AND POH.STATE IN (
                               'Pending')
             AND POL.QTY_REMAINING != 0
             AND LEFT(
                         POL.ITEMID
                     , 1) IN (
                              '1', '2', 'A')
      --   AND CONVERT_TIMEZONE('America/Chicago', POH._ES_UPDATE_TIMESTAMP) <
      --       DATEADD(MINUTE, -30, CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP(0)))
      --        AND POH.DOCNO IN ('240052', '240055')
           ORDER BY
               POH.CUSTVENDID,
               POH.DOCNO,
               POL.LINE_NO) API_DETAIL
              LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND_INT ON API_DETAIL.VENDORCODE = VEND_INT.VENDORID
      GROUP BY
          API_DETAIL.ORDERDATE,
          API_DETAIL.VENDORCODE,
          VEND_INT.NAME,
          API_DETAIL.PURCHASEORDERNUMBER,
          API_DETAIL.STATE
      ORDER BY
          API_DETAIL.VENDORCODE,
          API_DETAIL.PURCHASEORDERNUMBER
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: po_date {
    type: date
    sql: ${TABLE}."PO_DATE"
    ;;
    convert_tz: no
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: po_state {
    type: string
    sql: ${TABLE}."PO_STATE" ;;
  }

  dimension: import_this {
    type: string
    sql: ${TABLE}."IMPORT_THIS" ;;
  }

  set: detail {
    fields: [
      po_date,
      po_number,
      vendor_id,
      vendor_name,
      po_state,
      import_this
    ]
  }
}
