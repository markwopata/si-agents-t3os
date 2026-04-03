view: FACT_LIVE_TRANSACTIONS {
  sql_table_name: "BRANCH_EARNINGS"."FACT_LIVE_TRANSACTIONS";;

  filter: PERIOD_FILTER {
    type: string
    suggest_dimension: FILTER_DATE.FILTER_PERIOD
  }

  dimension: PERIOD_SATISFIES_FILTER {
    type: yesno
    hidden: no
    sql: {% condition PERIOD_FILTER %} DIM_DATE_LIVE_BE.PERIOD {% endcondition %} ;;
  }

  dimension: NEXT_PERIOD_SATISFIES_FILTER {
    type: yesno
    hidden: no
    sql: {% condition PERIOD_FILTER %} DIM_DATE_LIVE_BE.NEXT_PERIOD {% endcondition %} ;;
  }

  dimension: AMOUNT {
    type: number
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: DESCRIPTION {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: DOCUMENT_NUMBER {
    type: string
    sql: ${TABLE}."DOCUMENT_NUMBER" ;;
  }

  dimension: DOCUMENT_TYPE {
    type: string
    sql: ${TABLE}."DOCUMENT_TYPE" ;;
  }

  dimension: FK_ASSET {
    type: string
    hidden: yes
    sql: ${TABLE}."FK_ASSET" ;;
  }

  dimension: FK_ACCOUNT {
    type: string
    hidden: yes
    sql: ${TABLE}."FK_ACCOUNT" ;;
  }

  dimension: FK_VENDOR {
    type: string
    hidden: yes
    sql: ${TABLE}."FK_VENDOR" ;;
  }

  dimension: FK_MARKET {
    type: string
    hidden: yes
    sql: ${TABLE}."FK_MARKET" ;;
  }

  dimension: FK_MARKET_MANAGER_EMPLOYEE {
    type: string
    hidden: yes
    sql: ${TABLE}."FK_MARKET_MANAGER_EMPLOYEE" ;;
  }

  dimension: GL_DATE {
    type: date
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: PK_FACT_LIVE_TRANSACTIONS {
    type: string
    hidden: yes
    primary_key: yes
    sql: ${TABLE}."PK_FACT_LIVE_TRANSACTIONS" ;;
  }

  dimension: TRANSACTION_NUMBER {
    type: string
    sql: ${TABLE}."TRANSACTION_NUMBER" ;;
  }

  dimension: TRANSACTION_NUMBER_FORMAT {
    type: string
    sql: ${TABLE}."TRANSACTION_NUMBER_FORMAT" ;;
  }

  dimension: URL_ADMIN {
    type: string
    sql: ${TABLE}."URL_ADMIN" ;;
    html: <a style="color:rgb(26, 115, 232)" href="{{value}}">Link to Admin</a> ;;
  }

  dimension: URL_SAGE {
    type: string
    sql: ${TABLE}."URL_SAGE" ;;
    html: <a style="color:rgb(26, 115, 232)" href="{{value}}">Link to Sage</a> ;;
  }

  dimension: URL_TRACK {
    type: string
    sql: ${TABLE}."URL_TRACK" ;;
    html: <a style="color:rgb(26, 115, 232)" href="{{value}}">Link to Track</a> ;;
  }

  dimension: URL_YOOZ {
    type: string
    sql: ${TABLE}."URL_YOOZ" ;;
    html: <a style="color:rgb(26, 115, 232)" href="{{value}}">Link to Yooz</a> ;;
  }

  dimension: RECORD_CREATED_TIMESTAMP {
    type: date_time
    hidden: yes
    sql: ${TABLE}."RECORD_CREATED_TIMESTAMP" ;;
  }

  dimension: RECORD_MODIFIED_TIMESTAMP {
    type: date_time
    hidden: yes
    sql: ${TABLE}."RECORD_MODIFIED_TIMESTAMP" ;;
  }

  dimension: SOURCE {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  dimension: LOAD_SECTION {
    type: string
    suggest_persist_for: "15 minutes"
    sql: ${TABLE}."LOAD_SECTION" ;;
  }

  dimension: RENTAL_REVENUE_AMOUNT {
    type: number
    hidden: yes
    sql: ${TABLE}."RENTAL_REVENUE_AMOUNT" ;;
  }

  dimension: REVENUE_AMOUNT {
    type: number
    hidden: yes
    sql: ${TABLE}."REVENUE_AMOUNT" ;;
  }

  dimension: EXPENSE_AMOUNT {
    type: number
    hidden: yes
    sql: ${TABLE}."EXPENSE_AMOUNT" ;;
  }

  dimension: DELIVERY_REVENUE_AMOUNT {
    type: number
    hidden: yes
    sql: ${TABLE}."DELIVERY_REVENUE_AMOUNT" ;;
  }

  dimension: PAID_DELIVERY_REVENUE_AMOUNT {
    type: number
    hidden: yes
    sql: ${TABLE}."PAID_DELIVERY_REVENUE_AMOUNT" ;;
  }

  dimension: DELIVERY_EXPENSE_AMOUNT {
    type: number
    hidden: yes
    sql: ${TABLE}."DELIVERY_EXPENSE_AMOUNT" ;;
  }

  dimension: COMPENSATION_AMOUNT {
    type: number
    hidden: yes
    sql: ${TABLE}."COMPENSATION_AMOUNT" ;;
  }

  dimension: WAGES_AMOUNT {
    type: number
    hidden: yes
    sql: ${TABLE}."WAGES_AMOUNT" ;;
  }

  dimension: OVERTIME_AMOUNT {
    type: number
    hidden: yes
    sql: ${TABLE}."OVERTIME_AMOUNT" ;;
  }

  dimension: HAULING_AMOUNT {
    type: number
    hidden: yes
    sql: ${TABLE}."HAULING_AMOUNT" ;;
  }

  dimension: INVENTORY_BULK_PART_EXPENSE_AMOUNT {
    type: number
    hidden: yes
    sql: ${TABLE}."INVENTORY_BULK_PART_EXPENSE_AMOUNT" ;;
  }

  measure: count {
    type: count
    label: "NUMBER OF FACT RECORDS"
    drill_fields: [drill_detail*]
  }

  measure: TOTAL_AMOUNT {
    type: sum
    label: "TOTAL AMOUNT"
    sql: ${AMOUNT};;
    filters: [AMOUNT: "<>0"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*]
  }

  measure: PERIOD_PARAMETER_TOTAL_AMOUNT {
    type: sum
    label: "SELECTED PERIOD AMOUNT"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${AMOUNT};;
    filters: [PERIOD_SATISFIES_FILTER: "yes", AMOUNT: "<>0"]
    value_format: "$#,##0;($#,##0)"
    drill_fields: [drill_detail*]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_AMOUNT {
    type: sum
    label: "PRIOR PERIOD AMOUNT"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${AMOUNT};;
    filters: [NEXT_PERIOD_SATISFIES_FILTER: "yes", AMOUNT: "<>0"]
    value_format: "$#,##0;($#,##0)"
    drill_fields: [drill_detail*]
  }

  measure: PERIOD_PARAMETER_TOTAL_CHANGE_AMOUNT{
    type: number
    label: "CHANGE FROM PRIOR PERIOD"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${PERIOD_PARAMETER_TOTAL_AMOUNT} - ${PRIOR_PERIOD_PARAMETER_TOTAL_AMOUNT};;
    value_format: "$#,##0;($#,##0)"
    drill_fields: [drill_detail*]
  }

  measure: TOTAL_RENTAL_REVENUE {
    type: sum
    label: "TOTAL RENTAL REVENUE"
    sql: ${RENTAL_REVENUE_AMOUNT};;
    filters: [RENTAL_REVENUE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, RENTAL_REVENUE_AMOUNT]
  }

  measure: PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE {
    type: sum
    label: "SELECTED PERIOD RENTAL REVENUE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${RENTAL_REVENUE_AMOUNT};;
    filters: [PERIOD_SATISFIES_FILTER: "yes", RENTAL_REVENUE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, RENTAL_REVENUE_AMOUNT]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE {
    type: sum
    label: "PRIOR PERIOD RENTAL REVENUE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${RENTAL_REVENUE_AMOUNT};;
    filters: [NEXT_PERIOD_SATISFIES_FILTER: "yes", RENTAL_REVENUE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, RENTAL_REVENUE_AMOUNT]
  }

  measure: TOTAL_REVENUE {
    type: sum
    label: "TOTAL REVENUE"
    sql: ${REVENUE_AMOUNT};;
    filters: [REVENUE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, REVENUE_AMOUNT]
  }

  measure: PERIOD_PARAMETER_TOTAL_REVENUE {
    type: sum
    label: "SELECTED PERIOD REVENUE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${REVENUE_AMOUNT};;
    filters: [PERIOD_SATISFIES_FILTER: "yes", REVENUE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, REVENUE_AMOUNT]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_REVENUE {
    type: sum
    label: "PRIOR PERIOD REVENUE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${REVENUE_AMOUNT};;
    filters: [NEXT_PERIOD_SATISFIES_FILTER: "yes", REVENUE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, REVENUE_AMOUNT]
  }

  measure: TOTAL_EXPENSE {
    type: sum
    label: "TOTAL EXPENSE"
    sql: ${EXPENSE_AMOUNT};;
    filters: [EXPENSE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, EXPENSE_AMOUNT]
  }

  measure: PERIOD_PARAMETER_TOTAL_EXPENSE {
    type: sum
    label: "SELECTED PERIOD EXPENSE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${EXPENSE_AMOUNT};;
    filters: [PERIOD_SATISFIES_FILTER: "yes", EXPENSE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, EXPENSE_AMOUNT]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_EXPENSE {
    type: sum
    label: "PRIOR PERIOD EXPENSE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${EXPENSE_AMOUNT};;
    filters: [NEXT_PERIOD_SATISFIES_FILTER: "yes", EXPENSE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, EXPENSE_AMOUNT]
  }

  measure: TOTAL_DELIVERY_REVENUE {
    type: sum
    label: "TOTAL DELIVERY RENTAL REVENUE"
    sql: ${DELIVERY_REVENUE_AMOUNT};;
    filters: [DELIVERY_REVENUE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, DELIVERY_REVENUE_AMOUNT]
  }

  measure: PERIOD_PARAMETER_TOTAL_DELIVERY_REVENUE {
    type: sum
    label: "SELECTED PERIOD DELIVERY RENTAL REVENUE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${DELIVERY_REVENUE_AMOUNT};;
    filters: [PERIOD_SATISFIES_FILTER: "yes", DELIVERY_REVENUE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, DELIVERY_REVENUE_AMOUNT]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_DELIVERY_REVENUE {
    type: sum
    label: "PRIOR PERIOD DELIVERY RENTAL REVENUE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${DELIVERY_REVENUE_AMOUNT};;
    filters: [NEXT_PERIOD_SATISFIES_FILTER: "yes", DELIVERY_REVENUE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, DELIVERY_REVENUE_AMOUNT]
  }

  measure: TOTAL_PAID_DELIVERY_REVENUE {
    type: sum
    label: "TOTAL PAID DELIVERY RENTAL REVENUE"
    sql: ${PAID_DELIVERY_REVENUE_AMOUNT};;
    filters: [PAID_DELIVERY_REVENUE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, PAID_DELIVERY_REVENUE_AMOUNT]
  }

  measure: PERIOD_PARAMETER_TOTAL_PAID_DELIVERY_REVENUE {
    type: sum
    label: "SELECTED PERIOD PAID DELIVERY RENTAL REVENUE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${PAID_DELIVERY_REVENUE_AMOUNT};;
    filters: [PERIOD_SATISFIES_FILTER: "yes", PAID_DELIVERY_REVENUE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, PAID_DELIVERY_REVENUE_AMOUNT]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_PAID_DELIVERY_REVENUE {
    type: sum
    label: "PRIOR PERIOD PAID DELIVERY RENTAL REVENUE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${PAID_DELIVERY_REVENUE_AMOUNT};;
    filters: [NEXT_PERIOD_SATISFIES_FILTER: "yes", PAID_DELIVERY_REVENUE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, PAID_DELIVERY_REVENUE_AMOUNT]
  }

  measure: TOTAL_DELIVERY_EXPENSE {
    type: sum
    label: "TOTAL DELIVERY EXPENSE"
    sql: ${DELIVERY_EXPENSE_AMOUNT};;
    filters: [DELIVERY_EXPENSE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, DELIVERY_EXPENSE_AMOUNT]
  }

  measure: PERIOD_PARAMETER_TOTAL_DELIVERY_EXPENSE {
    type: sum
    label: "SELECTED PERIOD DELIVERY EXPENSE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${DELIVERY_EXPENSE_AMOUNT};;
    filters: [PERIOD_SATISFIES_FILTER: "yes", DELIVERY_EXPENSE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, DELIVERY_EXPENSE_AMOUNT]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_DELIVERY_EXPENSE {
    type: sum
    label: "PRIOR PERIOD DELIVERY EXPENSE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${DELIVERY_EXPENSE_AMOUNT};;
    filters: [NEXT_PERIOD_SATISFIES_FILTER: "yes", DELIVERY_EXPENSE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, DELIVERY_EXPENSE_AMOUNT]
  }

  measure: TOTAL_COMPENSATION{
    type: sum
    label: "TOTAL COMPENSATION"
    sql: ${COMPENSATION_AMOUNT};;
    filters: [COMPENSATION_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, COMPENSATION_AMOUNT]
  }

  measure: PERIOD_PARAMETER_TOTAL_COMPENSATION{
    type: sum
    label: "SELECTED PERIOD COMPENSATION"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${COMPENSATION_AMOUNT};;
    filters: [PERIOD_SATISFIES_FILTER: "yes", COMPENSATION_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, COMPENSATION_AMOUNT]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_COMPENSATION{
    type: sum
    label: "PRIOR PERIOD COMPENSATION"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${COMPENSATION_AMOUNT};;
    filters: [NEXT_PERIOD_SATISFIES_FILTER: "yes", COMPENSATION_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, COMPENSATION_AMOUNT]
  }

  measure: TOTAL_WAGES{
    type: sum
    label: "TOTAL WAGES"
    sql: ${WAGES_AMOUNT};;
    filters: [WAGES_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, WAGES_AMOUNT]
  }

  measure: PERIOD_PARAMETER_TOTAL_WAGES{
    type: sum
    label: "SELECTED PERIOD WAGES"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${WAGES_AMOUNT};;
    filters: [PERIOD_SATISFIES_FILTER: "yes", WAGES_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, WAGES_AMOUNT]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_WAGES{
    type: sum
    label: "PRIOR PERIOD WAGES"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${WAGES_AMOUNT};;
    filters: [NEXT_PERIOD_SATISFIES_FILTER: "yes", WAGES_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, WAGES_AMOUNT]
  }

  measure: TOTAL_OVERTIME{
    type: sum
    label: "TOTAL OVERTIME"
    sql: ${OVERTIME_AMOUNT};;
    filters: [OVERTIME_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, OVERTIME_AMOUNT]
  }

  measure: PERIOD_PARAMETER_TOTAL_OVERTIME{
    type: sum
    label: "SELECTED PERIOD OVERTIME"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${OVERTIME_AMOUNT};;
    filters: [PERIOD_SATISFIES_FILTER: "yes", OVERTIME_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, OVERTIME_AMOUNT]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_OVERTIME{
    type: sum
    label: "PRIOR PERIOD OVERTIME"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${OVERTIME_AMOUNT};;
    filters: [NEXT_PERIOD_SATISFIES_FILTER: "yes", OVERTIME_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, OVERTIME_AMOUNT]
  }

  measure: TOTAL_HAULING{
    type: sum
    label: "TOTAL HAULING"
    sql: ${HAULING_AMOUNT};;
    filters: [HAULING_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, HAULING_AMOUNT]
  }

  measure: PERIOD_PARAMETER_TOTAL_HAULING{
    type: sum
    label: "SELECTED PERIOD HAULING"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${HAULING_AMOUNT};;
    filters: [PERIOD_SATISFIES_FILTER: "yes", HAULING_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, HAULING_AMOUNT]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_HAULING{
    type: sum
    label: "PRIOR PERIOD HAULING"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${HAULING_AMOUNT};;
    filters: [NEXT_PERIOD_SATISFIES_FILTER: "yes", HAULING_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, HAULING_AMOUNT]
  }

  measure: TOTAL_INVENTORY_BULK_PART_EXPENSE{
    type: sum
    label: "TOTAL INVENTORY/BULK PART EXPENSE"
    sql: ${INVENTORY_BULK_PART_EXPENSE_AMOUNT};;
    filters: [INVENTORY_BULK_PART_EXPENSE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, INVENTORY_BULK_PART_EXPENSE_AMOUNT]
  }

  measure: PERIOD_PARAMETER_TOTAL_INVENTORY_BULK_PART_EXPENSE{
    type: sum
    label: "SELECTED PERIOD INVENTORY/BULK PART EXPENSE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${INVENTORY_BULK_PART_EXPENSE_AMOUNT};;
    filters: [PERIOD_SATISFIES_FILTER: "yes", INVENTORY_BULK_PART_EXPENSE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, INVENTORY_BULK_PART_EXPENSE_AMOUNT]
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_INVENTORY_BULK_PART_EXPENSE{
    type: sum
    label: "PRIOR PERIOD INVENTORY/BULK PART EXPENSE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${INVENTORY_BULK_PART_EXPENSE_AMOUNT};;
    filters: [NEXT_PERIOD_SATISFIES_FILTER: "yes", INVENTORY_BULK_PART_EXPENSE_AMOUNT: "<>0", DIM_ACCOUNT.ACCOUNT_TYPE: "-OEC"]
    value_format: "$#,##0.00;($#,##0.00)"
    drill_fields: [drill_detail*, INVENTORY_BULK_PART_EXPENSE_AMOUNT]
  }

  measure: TOTAL_OEC{
    type: sum
    label: "TOTAL ORIGINAL EQUIPMENT COST"
    sql: ${AMOUNT};;
    filters: [DIM_ACCOUNT.ACCOUNT_TYPE: "OEC", AMOUNT: "<>0"]
    value_format: "$#,##0;($#,##0)"
    drill_fields: [drill_detail*]
  }

  measure: PERIOD_PARAMETER_TOTAL_OEC{
    type: sum
    label: "SELECTED PERIOD ORIGINAL EQUIPMENT COST"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${AMOUNT};;
    filters: [DIM_ACCOUNT.ACCOUNT_TYPE: "OEC", PERIOD_SATISFIES_FILTER: "yes", AMOUNT: "<>0"]
    value_format: "$#,##0;($#,##0)"
    html: <a style="color:black" href = "@{db_oec_detail}?SourceDashboard=Trending&Period={{ _filters['LIVE_TRANSACTIONS.PERIOD_FILTER'] | url_encode }}&Market+Name={{ _filters['DIM_MARKET.PARENT_CHILD_MARKET_NAME'] | url_encode }}&amp;Region+Name={{ _filters['DIM_MARKET.REGION_NAME'] | url_encode }}&amp;District+Number={{ _filters['DIM_MARKET.DISTRICT'] | url_encode }}&amp;Market+Type={{ _filters['DIM_MARKET.MARKET_TYPE'] | url_encode }}&toggle=det">{{rendered_value}}</a>;;
  }

  measure: PRIOR_PERIOD_PARAMETER_TOTAL_OEC{
    type: sum
    label: "PRIOR PERIOD ORIGINAL EQUIPMENT COST"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ${AMOUNT};;
    filters: [DIM_ACCOUNT.ACCOUNT_TYPE: "OEC", NEXT_PERIOD_SATISFIES_FILTER: "yes", AMOUNT: "<>0"]
    value_format: "$#,##0;($#,##0)"
    drill_fields: [drill_detail*]
  }

  measure: RENTAL_REVENUE_TO_OEC{
    type: number
    label: "RENTAL REVENUE TO OEC"
    sql: ABS(${TOTAL_RENTAL_REVENUE} / NULLIF(${TOTAL_OEC}, 0));;
    value_format: "0.00%"
    drill_fields: [DIM_ASSET.ASSET_ID, DIM_ASSET.EQUIPMENT_TYPE, DIM_ASSET.EQUIPMENT_CLASS_NAME, DIM_ASSET.EQUIPMENT_CATEGORY_NAME, DIM_ASSET.EQUIPMENT_SUBCATEGORY_NAME, DIM_ASSET.EQUIPMENT_MAKE, DIM_ASSET.EQUIPMENT_MODEL_NAME, DIM_DATE_LIVE_BE.DATE, TOTAL_RENTAL_REVENUE, TOTAL_OEC, RENTAL_REVENUE_TO_OEC]
  }

  measure: PERIOD_PARAMETER_RENTAL_REVENUE_TO_OEC{
    type: number
    label: "SELECTED PERIOD RENTAL REVENUE TO OEC"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ABS(${PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE} / NULLIF(${PERIOD_PARAMETER_TOTAL_OEC}, 0));;
    value_format: "0.00%"
    drill_fields: [DIM_ASSET.ASSET_ID, DIM_ASSET.EQUIPMENT_TYPE, DIM_ASSET.EQUIPMENT_CLASS_NAME, DIM_ASSET.EQUIPMENT_CATEGORY_NAME, DIM_ASSET.EQUIPMENT_SUBCATEGORY_NAME, DIM_ASSET.EQUIPMENT_MAKE, DIM_ASSET.EQUIPMENT_MODEL_NAME, DIM_DATE_LIVE_BE.DATE, PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE, PERIOD_PARAMETER_TOTAL_OEC, PERIOD_PARAMETER_RENTAL_REVENUE_TO_OEC]
  }

  measure: PRIOR_PERIOD_PARAMETER_RENTAL_REVENUE_TO_OEC{
    type: number
    label: "PRIOR PERIOD RENTAL REVENUE TO OEC"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ABS(${PRIOR_PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE} / NULLIF(${PRIOR_PERIOD_PARAMETER_TOTAL_OEC}, 0));;
    value_format: "0.00%"
    drill_fields: [DIM_ASSET.ASSET_ID, DIM_ASSET.EQUIPMENT_TYPE, DIM_ASSET.EQUIPMENT_CLASS_NAME, DIM_ASSET.EQUIPMENT_CATEGORY_NAME, DIM_ASSET.EQUIPMENT_SUBCATEGORY_NAME, DIM_ASSET.EQUIPMENT_MAKE, DIM_ASSET.EQUIPMENT_MODEL_NAME, DIM_DATE_LIVE_BE.DATE, PRIOR_PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE, PRIOR_PERIOD_PARAMETER_TOTAL_OEC, PRIOR_PERIOD_PARAMETER_RENTAL_REVENUE_TO_OEC]
  }

  measure: OVERTIME_TO_TOTAL_WAGES{
    type: number
    label: "OVERTIME TO TOTAL WAGES"
    sql: ABS(${TOTAL_OVERTIME} / NULLIF(${TOTAL_WAGES}, 0));;
    value_format: "0.00%"
    drill_fields: [drill_detail*, TOTAL_OVERTIME, TOTAL_WAGES]
  }

  measure: PERIOD_PARAMETER_OVERTIME_TO_TOTAL_WAGES{
    type: number
    label: "SELECTED PERIOD OVERTIME TO TOTAL WAGES"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ABS(${PERIOD_PARAMETER_TOTAL_OVERTIME} / NULLIF(${PERIOD_PARAMETER_TOTAL_WAGES}, 0));;
    value_format: "0.00%"
    drill_fields: [drill_detail*, PERIOD_PARAMETER_TOTAL_OVERTIME, PERIOD_PARAMETER_TOTAL_WAGES, PERIOD_PARAMETER_OVERTIME_TO_TOTAL_WAGES]
  }

  measure: PRIOR_PERIOD_PARAMETER_OVERTIME_TO_TOTAL_WAGES{
    type: number
    label: "PRIOR PERIOD OVERTIME TO TOTAL WAGES"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ABS(${PRIOR_PERIOD_PARAMETER_TOTAL_OVERTIME} / NULLIF(${PRIOR_PERIOD_PARAMETER_TOTAL_WAGES}, 0));;
    value_format: "0.00%"
    drill_fields: [drill_detail*, PRIOR_PERIOD_PARAMETER_TOTAL_OVERTIME, PRIOR_PERIOD_PARAMETER_TOTAL_WAGES, PRIOR_PERIOD_PARAMETER_OVERTIME_TO_TOTAL_WAGES]
  }

  measure: DELIVERY_REVENUE_RECOVERY{
    type: number
    label: "DELIVERY REVENUE RECOVERY"
    sql: ABS(${TOTAL_PAID_DELIVERY_REVENUE} / NULLIF(${TOTAL_DELIVERY_EXPENSE}, 0));;
    value_format: "0.00%"
    drill_fields: [drill_detail*, TOTAL_PAID_DELIVERY_REVENUE, TOTAL_DELIVERY_EXPENSE, DELIVERY_REVENUE_RECOVERY]
  }

  measure: PERIOD_PARAMETER_DELIVERY_REVENUE_RECOVERY{
    type: number
    label: "SELECTED PERIOD DELIVERY REVENUE RECOVERY"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ABS(${PERIOD_PARAMETER_TOTAL_PAID_DELIVERY_REVENUE} / NULLIF(${PERIOD_PARAMETER_TOTAL_DELIVERY_EXPENSE}, 0));;
    value_format: "0.00%"
    drill_fields: [drill_detail*, PERIOD_PARAMETER_TOTAL_PAID_DELIVERY_REVENUE, PERIOD_PARAMETER_TOTAL_DELIVERY_EXPENSE, PERIOD_PARAMETER_DELIVERY_REVENUE_RECOVERY]
  }

  measure: PRIOR_PERIOD_PARAMETER_DELIVERY_REVENUE_RECOVERY{
    type: number
    label: "PRIOR PERIOD DELIVERY REVENUE RECOVERY"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ABS(${PRIOR_PERIOD_PARAMETER_TOTAL_PAID_DELIVERY_REVENUE} / NULLIF(${PRIOR_PERIOD_PARAMETER_TOTAL_DELIVERY_EXPENSE}, 0));;
    value_format: "0.00%"
    drill_fields: [drill_detail*, PRIOR_PERIOD_PARAMETER_TOTAL_PAID_DELIVERY_REVENUE, PRIOR_PERIOD_PARAMETER_TOTAL_DELIVERY_EXPENSE, PRIOR_PERIOD_PARAMETER_DELIVERY_REVENUE_RECOVERY]
  }

  measure: OUTSIDE_HAULING_TO_RENTAL_REVENUE{
    type: number
    label: "OUTSIDE HAULING TO RENTAL REVENUE"
    sql: ABS(${TOTAL_HAULING} / NULLIF(${TOTAL_RENTAL_REVENUE}, 0));;
    value_format: "0.00%"
    drill_fields: [drill_detail*, TOTAL_HAULING, TOTAL_RENTAL_REVENUE, OUTSIDE_HAULING_TO_RENTAL_REVENUE]
  }

  measure: PERIOD_PARAMETER_OUTSIDE_HAULING_TO_RENTAL_REVENUE{
    type: number
    label: "SELECTED PERIOD OUTSIDE HAULING TO RENTAL REVENUE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ABS(${PERIOD_PARAMETER_TOTAL_HAULING} / NULLIF(${PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE}, 0));;
    value_format: "0.00%"
    drill_fields: [drill_detail*, PERIOD_PARAMETER_TOTAL_HAULING, PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE, PERIOD_PARAMETER_OUTSIDE_HAULING_TO_RENTAL_REVENUE]
  }

  measure: PRIOR_PERIOD_PARAMETER_OUTSIDE_HAULING_TO_RENTAL_REVENUE{
    type: number
    label: "PRIOR PERIOD OUTSIDE HAULING TO RENTAL REVENUE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ABS(${PRIOR_PERIOD_PARAMETER_TOTAL_HAULING} / NULLIF(${PRIOR_PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE}, 0));;
    value_format: "0.00%"
    drill_fields: [drill_detail*, PRIOR_PERIOD_PARAMETER_TOTAL_HAULING, PRIOR_PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE, PRIOR_PERIOD_PARAMETER_OUTSIDE_HAULING_TO_RENTAL_REVENUE]
  }

  measure: PAYROLL_TO_RENTAL_REVENUE{
    type: number
    label: "PAYROLL TO RENTAL REVENUE"
    sql: ABS(${TOTAL_COMPENSATION} / NULLIF(${TOTAL_RENTAL_REVENUE}, 0));;
    value_format: "0.00%"
    drill_fields: [drill_detail*, PAYROLL_TO_RENTAL_REVENUE]
  }

  measure: PERIOD_PARAMETER_PAYROLL_TO_RENTAL_REVENUE{
    type: number
    label: "SELECTED PERIOD PAYROLL TO RENTAL REVENUE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ABS(${PERIOD_PARAMETER_TOTAL_COMPENSATION} / NULLIF(${PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE}, 0));;
    value_format: "0.00%"
    drill_fields: [drill_detail*, PERIOD_PARAMETER_TOTAL_COMPENSATION, PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE, PERIOD_PARAMETER_PAYROLL_TO_RENTAL_REVENUE]
  }

  measure: PRIOR_PERIOD_PARAMETER_PAYROLL_TO_RENTAL_REVENUE{
    type: number
    label: "PRIOR PERIOD PAYROLL TO RENTAL REVENUE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ABS(${PRIOR_PERIOD_PARAMETER_TOTAL_COMPENSATION} / NULLIF(${PRIOR_PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE}, 0));;
    value_format: "0.00%"
    drill_fields: [drill_detail*, PRIOR_PERIOD_PARAMETER_TOTAL_COMPENSATION, PRIOR_PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE, PRIOR_PERIOD_PARAMETER_PAYROLL_TO_RENTAL_REVENUE]
  }

  measure: INVENTORY_BULK_PART_EXPENSE_TO_RENTAL_REVENUE{
    type: number
    label: "INVENTORY/BULK PART EXPENSE TO RENTAL REVENUE"
    sql: ABS(${TOTAL_INVENTORY_BULK_PART_EXPENSE} / NULLIF(${TOTAL_RENTAL_REVENUE}, 0));;
    value_format: "0.00%"
    drill_fields: [DIM_ASSET.ASSET_ID, DIM_ASSET.EQUIPMENT_TYPE, DIM_ASSET.EQUIPMENT_CLASS_NAME, DIM_ASSET.EQUIPMENT_CATEGORY_NAME, DIM_ASSET.EQUIPMENT_SUBCATEGORY_NAME, DIM_ASSET.EQUIPMENT_MAKE, DIM_ASSET.EQUIPMENT_MODEL_NAME, DIM_DATE_LIVE_BE.DATE, TOTAL_INVENTORY_BULK_PART_EXPENSE, TOTAL_RENTAL_REVENUE, INVENTORY_BULK_PART_EXPENSE_TO_RENTAL_REVENUE]
  }

  measure: PERIOD_PARAMETER_INVENTORY_BULK_PART_EXPENSE_TO_RENTAL_REVENUE{
    type: number
    label: "SELECTED PERIOD INVENTORY/BULK PART EXPENSE TO RENTAL REVENUE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ABS(${PERIOD_PARAMETER_TOTAL_INVENTORY_BULK_PART_EXPENSE} / NULLIF(${PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE}, 0));;
    value_format: "0.00%"
    drill_fields: [DIM_ASSET.ASSET_ID, DIM_ASSET.EQUIPMENT_TYPE, DIM_ASSET.EQUIPMENT_CLASS_NAME, DIM_ASSET.EQUIPMENT_CATEGORY_NAME, DIM_ASSET.EQUIPMENT_SUBCATEGORY_NAME, DIM_ASSET.EQUIPMENT_MAKE, DIM_ASSET.EQUIPMENT_MODEL_NAME, DIM_DATE_LIVE_BE.DATE, PERIOD_PARAMETER_TOTAL_INVENTORY_BULK_PART_EXPENSE, PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE, PERIOD_PARAMETER_INVENTORY_BULK_PART_EXPENSE_TO_RENTAL_REVENUE]
  }

  measure: PRIOR_PERIOD_PARAMETER_INVENTORY_BULK_PART_EXPENSE_TO_RENTAL_REVENUE{
    type: number
    label: "PRIOR PERIOD INVENTORY/BULK PART EXPENSE TO RENTAL REVENUE"
    view_label: "PERIOD PARAMETER MEASURES"
    sql: ABS(${PRIOR_PERIOD_PARAMETER_TOTAL_INVENTORY_BULK_PART_EXPENSE} / NULLIF(${PRIOR_PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE}, 0));;
    value_format: "0.00%"
    drill_fields: [DIM_ASSET.ASSET_ID, DIM_ASSET.EQUIPMENT_TYPE, DIM_ASSET.EQUIPMENT_CLASS_NAME, DIM_ASSET.EQUIPMENT_CATEGORY_NAME, DIM_ASSET.EQUIPMENT_SUBCATEGORY_NAME, DIM_ASSET.EQUIPMENT_MAKE, DIM_ASSET.EQUIPMENT_MODEL_NAME, DIM_DATE_LIVE_BE.DATE, PRIOR_PERIOD_PARAMETER_TOTAL_RENTAL_REVENUE, PRIOR_PERIOD_PARAMETER_TOTAL_OEC, PRIOR_PERIOD_PARAMETER_RENTAL_REVENUE_TO_OEC]
  }

  set: drill_detail {
    fields: [DIM_DATE_LIVE_BE.DATE, DIM_ACCOUNT.ACCOUNT_TYPE, DIM_ACCOUNT.ACCOUNT_NUMBER, DIM_ACCOUNT.GL_ACCOUNT, DIM_VENDOR.VENDOR_NAME, DIM_MARKET.PARENT_CHILD_MARKET_NAME, DIM_MARKET.MARKET_NAME, DIM_ASSET.ASSET_ID, DIM_ASSET.EQUIPMENT_TYPE, DIM_ASSET.CURRENT_OEC, AMOUNT, DOCUMENT_TYPE, DOCUMENT_NUMBER, DESCRIPTION, URL_ADMIN, URL_TRACK, URL_YOOZ, LOAD_SECTION, TRANSACTION_NUMBER_FORMAT, TRANSACTION_NUMBER, PK_FACT_LIVE_TRANSACTIONS]
  }
}
