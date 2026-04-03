view: apbill_to_po_walk {
  derived_table: {
    sql: SELECT
          APBH.VENDORID     AS VENDOR_ID,
          APBH.RECORDID     AS BILL_NUMBER,
          APBH.WHENCREATED  AS BILL_DATE,
          APBH.WHENPOSTED   AS POST_DATE,
          APBH.DOCNUMBER    AS REFERENCE,
          APBD.LINE_NO      AS LINE_NO,
          APBD.ACCOUNTNO    AS ACCOUNT,
          APBD.DEPARTMENTID AS BRANCH,
          APBD.AMOUNT       AS BILL_AMOUNT,
          VIH.DOCNO         AS VI_NUMBER,
          VID.RECORDNO      AS VI_LINE_RECORDNO,
          VID.UIQTY         AS VI_LINE_QUANTITY,
          VID.UIPRICE       AS VI_LINE_UNIT_PRICE,
          POH.CUSTVENDID    AS PO_VENDOR_ID,
          POH.DOCNO         AS PO_NUMBER,
          POD.RECORDNO      AS PO_LINE_RECORDNO,
          POD.ITEMID        AS PO_LINE_ITEM_ID,
          IT_TO_GL.ACCOUNT  AS PO_LINE_ACCOUNT,
          POD.DEPARTMENTID  AS PO_LINE_BRANCH,
          POD.UIQTY         AS PO_LINE_QUANTITY,
          POD.UIPRICE       AS PO_LINE_UNIT_PRICE
      FROM
          ANALYTICS.INTACCT.APRECORD APBH
              LEFT JOIN ANALYTICS.INTACCT.APDETAIL APBD ON APBH.RECORDNO = APBD.RECORDKEY
              LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON APBH.VENDORID = VEND.VENDORID
              LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON APBD.ACCOUNTNO = GLA.ACCOUNTNO
              LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT VIH ON APBH.DESCRIPTION2 = VIH.DOCID AND VIH.DOCPARID = 'Vendor Invoice'
              LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY VID
                        ON APBH.DESCRIPTION2 = VID.DOCHDRID AND VID.DOCPARID = 'Vendor Invoice' AND
                           APBD.LINE_NO - 1 = VID.LINE_NO
              LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY POD
                        ON VID.SOURCE_DOCLINEKEY = POD.RECORDNO AND POD.DOCPARID = 'Purchase Order'
              LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT POH ON POD.DOCHDRID = POH.DOCID AND POH.DOCPARID = 'Purchase Order'
              LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.ITEMID_TO_GL_ACCOUNT IT_TO_GL ON POD.ITEMID = IT_TO_GL.ITEM_ID
      WHERE
            APBH.RECORDTYPE = 'apbill'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: bill_date {
    type: date
    sql: ${TABLE}."BILL_DATE" ;;
  }

  dimension: post_date {
    type: date
    sql: ${TABLE}."POST_DATE" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: line_no {
    type: string
    sql: ${TABLE}."LINE_NO" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: bill_amount {
    type: number
    sql: ${TABLE}."BILL_AMOUNT" ;;
  }

  dimension: vi_number {
    type: string
    sql: ${TABLE}."VI_NUMBER" ;;
  }

  dimension: vi_line_recordno {
    type: number
    sql: ${TABLE}."VI_LINE_RECORDNO" ;;
  }

  dimension: vi_line_quantity {
    type: number
    sql: ${TABLE}."VI_LINE_QUANTITY" ;;
  }

  dimension: vi_line_unit_price {
    type: number
    sql: ${TABLE}."VI_LINE_UNIT_PRICE" ;;
  }

  dimension: po_vendor_id {
    type: string
    sql: ${TABLE}."PO_VENDOR_ID" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: po_line_recordno {
    type: number
    sql: ${TABLE}."PO_LINE_RECORDNO" ;;
  }

  dimension: po_line_item_id {
    type: string
    sql: ${TABLE}."PO_LINE_ITEM_ID" ;;
  }

  dimension: po_line_account {
    type: string
    sql: ${TABLE}."PO_LINE_ACCOUNT" ;;
  }

  dimension: po_line_branch {
    type: string
    sql: ${TABLE}."PO_LINE_BRANCH" ;;
  }

  dimension: po_line_quantity {
    type: number
    sql: ${TABLE}."PO_LINE_QUANTITY" ;;
  }

  dimension: po_line_unit_price {
    type: number
    sql: ${TABLE}."PO_LINE_UNIT_PRICE" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      bill_number,
      bill_date,
      post_date,
      reference,
      line_no,
      account,
      branch,
      bill_amount,
      vi_number,
      vi_line_recordno,
      vi_line_quantity,
      vi_line_unit_price,
      po_vendor_id,
      po_number,
      po_line_recordno,
      po_line_item_id,
      po_line_account,
      po_line_branch,
      po_line_quantity,
      po_line_unit_price
    ]
  }
}
