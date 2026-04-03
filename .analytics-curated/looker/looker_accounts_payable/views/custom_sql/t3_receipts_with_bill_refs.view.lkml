view: t3_receipts_with_bill_refs {
  derived_table: {
    sql: SELECT
          POH.CUSTVENDID AS "PO_Vendor_ID",
          VEND1.NAME AS "PO_Vendor_Name",
          POH.DOCNO AS "PO_Number",
          CAST(POH.WHENCREATED AS DATE) AS "PO_Date",
          POH.STATE AS "PO_State",
          POH.TRX_TOTAL AS "PO_Amount",
          APBH.VENDORID AS "Bill_Vendor_ID",
          VEND2.NAME AS "Bill_Vendor_Name",
          APBH.RECORDID AS "Bill_Number",
          APBH.WHENCREATED AS "Bill_Date",
          APBH.STATE AS "Bill_State",
          APBH.WHENPOSTED AS "Bill_Posting_Date",
          APBH.TRX_TOTALENTERED AS "Bill_Amount",
          APBH.DOCNUMBER AS "Bill_Ref_Number",
          CASE WHEN POH.CUSTVENDID != APBH.VENDORID THEN 'Different Vendor' ELSE '-' END AS "Vendor_Check"
      FROM
          "ANALYTICS"."SAGE_INTACCT"."PO_DOCUMENT" POH
          LEFT JOIN "ANALYTICS"."SAGE_INTACCT"."VENDOR" VEND1 ON POH.CUSTVENDID = VEND1.VENDORID
          --LEFT JOIN "ANALYTICS"."SAGE_INTACCT"."AP_BILL" APBH ON POH.DOCNO = APBH.DOCNUMBER --REPLACED WITH ROW BELOW THIS
          LEFT JOIN "ANALYTICS"."SAGE_INTACCT"."AP_BILL" APBH ON SPLIT_PART(POH.DOCNO, '-', 1) = SPLIT_PART(APBH.DOCNUMBER, '-', 1)
          LEFT JOIN "ANALYTICS"."SAGE_INTACCT"."VENDOR" VEND2 ON APBH.VENDORID = VEND2.VENDORID
      WHERE
          (POH.DOCNO LIKE('3_____%') OR POH.DOCNO LIKE('4_____%') OR POH.DOCNO LIKE('5_____%') OR POH.DOCNO LIKE('6_____%') OR POH.DOCNO LIKE('7_____%') OR POH.DOCNO LIKE('8_____%')) AND
          POH.DOCPARID = 'Purchase Order' AND
          POH.STATE IN ('Pending', 'Partially Converted')
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: po_vendor_id {
    type: string
    sql: ${TABLE}."PO_Vendor_ID" ;;
  }

  dimension: po_vendor_name {
    type: string
    sql: ${TABLE}."PO_Vendor_Name" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_Number" ;;
  }

  dimension: po_date {
    type: date
    sql: ${TABLE}."PO_Date" ;;
  }

  dimension: po_state {
    type: string
    sql: ${TABLE}."PO_State" ;;
  }

  dimension: po_amount {
    type: number
    sql: ${TABLE}."PO_Amount" ;;
  }

  dimension: bill_vendor_id {
    type: string
    sql: ${TABLE}."Bill_Vendor_ID" ;;
  }

  dimension: bill_vendor_name {
    type: string
    sql: ${TABLE}."Bill_Vendor_Name" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."Bill_Number" ;;
  }

  dimension: bill_date {
    type: string
    sql: ${TABLE}."Bill_Date" ;;
  }

  dimension: bill_state {
    type: string
    sql: ${TABLE}."Bill_State" ;;
  }

  dimension: bill_posting_date {
    type: string
    sql: ${TABLE}."Bill_Posting_Date" ;;
  }

  dimension: bill_amount {
    type: number
    sql: ${TABLE}."Bill_Amount" ;;
  }

  dimension: bill_ref_number {
    type: string
    sql: ${TABLE}."Bill_Ref_Number" ;;
  }

  dimension: vendor_check {
    type: string
    sql: ${TABLE}."Vendor_Check" ;;
  }

  set: detail {
    fields: [
      po_vendor_id,
      po_vendor_name,
      po_number,
      po_date,
      po_state,
      po_amount,
      bill_vendor_id,
      bill_vendor_name,
      bill_number,
      bill_date,
      bill_state,
      bill_posting_date,
      bill_amount,
      bill_ref_number,
      vendor_check
    ]
  }
}
