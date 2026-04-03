
view: intacct_ap_p2p_master {
  derived_table: {
    sql: SELECT * FROM "INTACCT"."AP_P2P_MASTER" ORDER BY PO_NUMBER,LINENO ;;
  }




  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: receipt_date {
    type: date
    sql: ${TABLE}."RECEIPT_DATE" ;;
  }

  dimension: days_old {
    type: number
    sql: ${TABLE}."DAYS_OLD" ;;
  }

  dimension: last_day_of_current_month {
    type: date
    sql: ${TABLE}."LAST_DAY_OF_CURRENT_MONTH" ;;
  }

  dimension: age_on_last_day_of_current_month {
    type: number
    sql: ${TABLE}."AGE_ON_LAST_DAY_OF_CURRENT_MONTH" ;;
  }

  dimension: last_day_of_previous_month {
    type: date
    sql: ${TABLE}."LAST_DAY_OF_PREVIOUS_MONTH" ;;
  }

  dimension: age_on_last_day_of_previous_month {
    type: number
    sql: ${TABLE}."AGE_ON_LAST_DAY_OF_PREVIOUS_MONTH" ;;
  }

  dimension: flag {
    type: string
    sql: ${TABLE}."FLAG" ;;
  }

  dimension: removed_hyhen_for_count_of_original {
    type: string
    sql: ${TABLE}."REMOVED_HYHEN_FOR_COUNT_OF_ORIGINAL" ;;
  }

  dimension: num_receipts_on_original_po {
    type: number
    sql: ${TABLE}."NUM_RECEIPTS_ON_ORIGINAL_PO" ;;
  }

  dimension: original_po_created_on {
    type: date
    sql: ${TABLE}."ORIGINAL_PO_CREATED_ON" ;;
  }

  dimension: pd_docid {
    type: string
    sql: ${TABLE}."PD_DOCID" ;;
  }

  dimension: object_type {
    type: string
    sql: ${TABLE}."OBJECT_TYPE" ;;
  }

  dimension: createdfrom {
    type: string
    sql: ${TABLE}."CREATEDFROM" ;;
  }

  dimension: t3_pr_created_by {
    type: string
    sql: ${TABLE}."T3_PR_CREATED_BY" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;

  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: accounts_excluded_accrual {
    type: string
    sql: ${TABLE}."ACCOUNTS_EXCLUDED_ACCRUAL" ;;
  }

  dimension: lineno {
    type: number
    sql: ${TABLE}."LINENO" ;;
    order_by_field: po_number
  }

  dimension: po_line_qty_orig {
    type: number
    sql: ${TABLE}."PO_LINE_QTY_ORIG" ;;
  }

  dimension: po_line_qty_conv {
    type: number
    sql: ${TABLE}."PO_LINE_QTY_CONV" ;;
  }

  dimension: po_line_qty_remain {
    type: number
    sql: ${TABLE}."PO_LINE_QTY_REMAIN" ;;
  }

  dimension: po_line_unit_price {
    type: number
    sql: ${TABLE}."PO_LINE_UNIT_PRICE" ;;
  }

  dimension: ext_cost_remain {
    type: number
    sql: ${TABLE}."EXT_COST_REMAIN" ;;
  }

  dimension: inventory {
    type: string
    sql: ${TABLE}."INVENTORY" ;;
  }

  dimension: in_pending_branch_approval {
    type: string
    sql: ${TABLE}."IN_PENDING_BRANCH_APPROVAL" ;;
  }

  dimension: in_pending_hq_approval {
    type: string
    sql: ${TABLE}."IN_PENDING_HQ_APPROVAL" ;;
  }

  dimension: concur_exceptions {
    type: string
    sql: ${TABLE}."CONCUR_EXCEPTIONS" ;;
  }

  dimension: source_docid {
    type: string
    sql: ${TABLE}."SOURCE_DOCID" ;;
  }

  dimension: source_doclinekey {
    type: string
    sql: ${TABLE}."SOURCE_DOCLINEKEY" ;;
  }

  dimension: dochdrid {
    type: string
    sql: ${TABLE}."DOCHDRID" ;;
  }

  dimension: docparid {
    type: string
    sql: ${TABLE}."DOCPARID" ;;
  }

  dimension: line_no {
    type: number
    sql: ${TABLE}."LINE_NO" ;;
  }

  dimension: itemid {
    type: string
    sql: ${TABLE}."ITEMID" ;;
  }

  dimension: itemname {
    type: string
    sql: ${TABLE}."ITEMNAME" ;;
  }

  dimension: itemdesc {
    type: string
    sql: ${TABLE}."ITEMDESC" ;;
  }

  dimension: total {
    type: number
    sql: ${TABLE}."TOTAL" ;;
  }

  dimension: uiqty {
    type: number
    sql: ${TABLE}."UIQTY" ;;
  }

  dimension: qty_converted {
    type: number
    sql: ${TABLE}."QTY_CONVERTED" ;;
  }

  dimension: uiprice {
    type: number
    sql: ${TABLE}."UIPRICE" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: price {
    type: number
    sql: ${TABLE}."PRICE" ;;
  }

  dimension: total_amount_remaining {
    type: number
    sql: ${TABLE}."TOTAL_AMOUNT_REMAINING" ;;
  }

  dimension: qty_remaining {
    type: number
    sql: ${TABLE}."QTY_REMAINING" ;;
  }

  dimension: departmentid {
    type: string
    sql: ${TABLE}."DEPARTMENTID" ;;
  }

  dimension: locationid {
    type: string
    sql: ${TABLE}."LOCATIONID" ;;
  }

  dimension: itemglgroup {
    type: number
    sql: ${TABLE}."ITEMGLGROUP" ;;
  }

  dimension: locationname {
    type: string
    sql: ${TABLE}."LOCATIONNAME" ;;
  }

  dimension: departmentname {
    type: string
    sql: ${TABLE}."DEPARTMENTNAME" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }
  dimension: BILLTO_MAILADDRESS_ADDRESS1 {
    type: string
    sql: ${TABLE}."BILLTO_MAILADDRESS_ADDRESS1" ;;
  }
  dimension: BILLTO_MAILADDRESS_ADDRESS2 {
    type: string
    sql: ${TABLE}."BILLTO_MAILADDRESS_ADDRESS2" ;;
  }
  dimension: BILLTO_MAILADDRESS_CITY {
    type: string
    sql: ${TABLE}."BILLTO_MAILADDRESS_CITY" ;;
  }
  dimension: BILLTO_MAILADDRESS_STATE {
    type: string
    sql: ${TABLE}."BILLTO_MAILADDRESS_STATE" ;;
  }
  dimension: BILLTO_MAILADDRESS_ZIP {
    type: string
    sql: ${TABLE}."BILLTO_MAILADDRESS_ZIP" ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  set: detail {
    fields: [
        receipt_date,
  days_old,
  last_day_of_current_month,
  age_on_last_day_of_current_month,
  last_day_of_previous_month,
  age_on_last_day_of_previous_month,
  flag,
  removed_hyhen_for_count_of_original,
  num_receipts_on_original_po,
  original_po_created_on,
  pd_docid,
  object_type,
  createdfrom,
  t3_pr_created_by,
  vendor_id,
  vendor_name,
  po_number,
  status,
  accounts_excluded_accrual,
  lineno,
  po_line_qty_orig,
  po_line_qty_conv,
  po_line_qty_remain,
  po_line_unit_price,
  ext_cost_remain,
  inventory,
  in_pending_branch_approval,
  in_pending_hq_approval,
  concur_exceptions,
  source_docid,
  source_doclinekey,
  dochdrid,
  docparid,
  line_no,
  itemid,
  itemname,
  itemdesc,
  total,
  uiqty,
  qty_converted,
  uiprice,
  quantity,
  price,
  total_amount_remaining,
  qty_remaining,
  departmentid,
  locationid,
  itemglgroup,
  locationname,
  departmentname,
  memo,
  source
    ]
  }
}
