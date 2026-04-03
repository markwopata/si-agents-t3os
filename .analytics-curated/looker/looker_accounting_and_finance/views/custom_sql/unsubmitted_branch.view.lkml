view: unsubmitted_branch {
  derived_table: {
    sql: WITH POD_CTE AS (
SELECT DISTINCT DOCNO, DELIVERTO_CONTACTNAME
FROM ANALYTICS.INTACCT.PODOCUMENT AS POD
WHERE POD.T3_PR_CREATED_BY  IS NULL
AND POD.DOCPARID = 'Purchase Order'
AND POD.PONUMBER not in ('TBD','5')
)
,
main as (
SELECT UI.*, DAYNAME(COGNOS_DATE::DATE) AS DAYOFWEEK,POH.REQUESTING_BRANCH_ID::varchar AS BRANCH_ID ,MKT.NAME AS BRANCH_NAME
FROM ANALYTICS.CONCUR.UNSUBMITTED_INVOICES_DB AS UI
--FROM ANALYTICS.CONCUR.UNSUBMITTED_INV_DB_V2 AS UI
LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDERS AS POH ON UI.PURCHASE_ORDER_NUMBER::VARCHAR = POH.PURCHASE_ORDER_NUMBER::VARCHAR
LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS MKT ON POH.REQUESTING_BRANCH_ID::varchar = MKT.MARKET_ID::varchar
WHERE UI.COGNOS_DATE IS NOT NULL
AND MKT.NAME IS NOT NULL
AND (POH.PURCHASE_ORDER_NUMBER >= 300000 OR POH.PURCHASE_ORDER_NUMBER IS NULL)
UNION ALL
SELECT UI.*, DAYNAME(COGNOS_DATE::DATE) AS DAYOFWEEK,POH.REQUESTING_BRANCH_ID::varchar AS BRANCH_ID ,MKT.NAME AS BRANCH_NAME
FROM ANALYTICS.CONCUR.UNSUBMITTED_INVOICES_DB AS UI
--FROM ANALYTICS.CONCUR.UNSUBMITTED_INV_DB_V2 AS UI
LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDERS AS POH ON UI.PURCHASE_ORDER_NUMBER::VARCHAR = POH.PURCHASE_ORDER_NUMBER::VARCHAR
LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS MKT ON POH.REQUESTING_BRANCH_ID::varchar = MKT.MARKET_ID::varchar
LEFT JOIN POD_CTE AS POD ON UI.PURCHASE_ORDER_NUMBER::VARCHAR = POD.DOCNO::VARCHAR
LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT AS D ON POD.DELIVERTO_CONTACTNAME = D.UD_ASSOCIATED_DELIVER_TO_CONTACT
LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS MKT2 ON D.DEPARTMENTID::VARCHAR = MKT2.MARKET_ID::VARCHAR
WHERE UI.COGNOS_DATE IS NOT NULL
AND MKT.NAME IS NULL
AND MKT2.NAME IS NOT NULL
AND (POH.PURCHASE_ORDER_NUMBER >= 300000 OR POH.PURCHASE_ORDER_NUMBER IS NULL)
UNION ALL
SELECT UI.*, DAYNAME(COGNOS_DATE::DATE) AS DAYOFWEEK,D.DEPARTMENTID::varchar AS BRANCH_ID ,MKT2.NAME AS BRANCH_NAME
FROM ANALYTICS.CONCUR.UNSUBMITTED_INVOICES_DB AS UI
--FROM ANALYTICS.CONCUR.UNSUBMITTED_INV_DB_V2 AS UI
LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDERS AS POH ON UI.PURCHASE_ORDER_NUMBER::VARCHAR = POH.PURCHASE_ORDER_NUMBER::VARCHAR
LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS MKT ON POH.REQUESTING_BRANCH_ID::varchar = MKT.MARKET_ID::varchar
LEFT JOIN POD_CTE AS POD ON UI.PURCHASE_ORDER_NUMBER::VARCHAR = POD.DOCNO::VARCHAR
LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT AS D ON POD.DELIVERTO_CONTACTNAME = D.UD_ASSOCIATED_DELIVER_TO_CONTACT
LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS MKT2 ON D.DEPARTMENTID::VARCHAR = MKT2.MARKET_ID::VARCHAR
WHERE UI.COGNOS_DATE IS NOT NULL
AND MKT.NAME IS NULL
AND MKT2.NAME IS NULL
AND (POH.PURCHASE_ORDER_NUMBER >= 300000 OR POH.PURCHASE_ORDER_NUMBER IS NULL)
UNION ALL
SELECT  DISTINCT UI.*, DAYNAME(COGNOS_DATE::DATE) AS DAYOFWEEK, NULL AS BRANCH_ID ,
NULL AS BRANCH_NAME
FROM ANALYTICS.CONCUR.UNSUBMITTED_INVOICES_DB AS UI
--FROM ANALYTICS.CONCUR.UNSUBMITTED_INV_DB_V2 AS UI
LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDERS AS POH ON UI.PURCHASE_ORDER_NUMBER::VARCHAR = POH.PURCHASE_ORDER_NUMBER::VARCHAR
LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS MKT ON POH.REQUESTING_BRANCH_ID::varchar = MKT.MARKET_ID::varchar
WHERE UI.COGNOS_DATE IS NOT NULL
AND MKT.NAME IS NOT NULL
AND POH.PURCHASE_ORDER_NUMBER < 300000
)
--32511
select main.*, vend.alt_pay_method, vend.credit_card_vendor from main --where cognos_date = '2025-07-01'
left join analytics.intacct.vendor vend on main.supplier_code = vend.vendorid
-- where cast(cognos_date as date) = current_date() --and purchase_order_number is null
;;
  }

  dimension: alt_pay_method {
    type: string
    sql: ${TABLE}.alt_pay_method ;;
  }

  dimension: credit_card_vendor {
    type: string
    sql: ${TABLE}.credit_card_vendor ;;
  }

  dimension: link_to_unsubmitted_db {
    type: string
    html: <font color="blue "><u><a href ="https://equipmentshare.looker.com/dashboards/750"target="_blank">Unsubmitted by Branch</a></font></u> ;;
    sql: ${TABLE}.REQUEST_NAME ;;
  }

  dimension: link_to_backlog_db {
    type: string
    html: <font color="blue "><u><a href ="https://equipmentshare.looker.com/dashboards/791"target="_blank">Backlog Master</a></font></u> ;;
    sql: ${TABLE}.REQUEST_NAME ;;
  }

  dimension: link_to_backlog_ee {
    type: string
    html: <font color="blue "><u><a href ="https://equipmentshare.looker.com/dashboards/795"target="_blank">Backlog by Employee</a></font></u> ;;
    sql: ${TABLE}.REQUEST_NAME ;;
  }

  dimension: link_to_backlog_vendor {
    type: string
    html: <font color="blue "><u><a href ="https://equipmentshare.looker.com/dashboards/794"target="_blank">Backlog by Vendor</a></font></u> ;;
    sql: ${TABLE}.REQUEST_NAME ;;
  }

  dimension: link_to_exception_report {
    type: string
    html: <font color="blue "><u><a href ="https://equipmentshare.looker.com/dashboards/807"target="_blank">Exception Code Reporting</a></font></u> ;;
    sql: ${TABLE}.REQUEST_NAME ;;
  }

  dimension: request_name {
    type: string
    sql: ${TABLE}.REQUEST_NAME ;;
  }

  dimension: employee_last_name {
    type: string
    sql: ${TABLE}.EMPLOYEE_LAST_NAME ;;
  }
  dimension: oem_vendors {
    type: string
    label: "OEM vs AP"
    sql: case
        when ${employee_last_name} in ('Durkee','Prieto', 'Davis', 'Gipson') then 'Supervisor'
         when ${employee_last_name} in ('Ferguson','Sanchez','Lawe','Romero','Davenport') then 'OEM'
        when ${employee_last_name} in ('Woodruff','Sobba') then 'CIP or Moberly'
         else 'AP'

         end ;;
  }
  dimension: supplier_name {
    type: string
    sql: ${TABLE}.SUPPLIER_NAME ;;
  }

  dimension: invoice_received {
    type: string
    sql: ${TABLE}.INVOICE_RECEIVED ;;
  }

  dimension: origin_source {
    type: string
    sql: ${TABLE}.ORIGIN_SOURCE ;;
  }

  dimension: approval_status {
    type: string
    sql: ${TABLE}.APPROVAL_STATUS ;;
  }

  dimension: payment_status {
    type: string
    sql: ${TABLE}.PAYMENT_STATUS ;;
  }

  dimension: supplier_invoice_number {
    type: string
    sql: ${TABLE}.SUPPLIER_INVOICE_NUMBER ;;
  }

  dimension: submit_date {
    type: date
    sql: ${TABLE}.SUBMIT_DATE ;;
  }

  dimension: policy {
    type: string
    sql: ${TABLE}.POLICY ;;
  }

  dimension: invoice_received_date {
    type: date
    sql: ${TABLE}.INVOICE_RECEIVED_DATE ;;
  }

  dimension: purchase_order_number {
    type: string
    sql:CASE WHEN  ${TABLE}.PURCHASE_ORDER_NUMBER = 'nan' THEN '' ELSE ${TABLE}.PURCHASE_ORDER_NUMBER END  ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}.INVOICE_DATE ;;
  }

  dimension: custom_1_name {
    type: string
    sql: ${TABLE}.CUSTOM_1_NAME ;;
  }

  dimension: non_inventory {
    type: string
    sql: CASE WHEN ${TABLE}.NON_INVENTORY = 'nan' THEN '' ELSE ${TABLE}.NON_INVENTORY END ;;
  }

  dimension: supplier_code {
    type: string
    sql: ${TABLE}.SUPPLIER_CODE ;;
  }

  dimension: custom_1_location {
    type: string
    sql: ${TABLE}.CUSTOMER_1_LOCATION ;;
  }

  dimension: payment_due_date {
    type: date
    sql: ${TABLE}.PAYMENT_DUE_DATE ;;
  }

  #dimension: misc1 {
  #  type: string
  #  sql: ${TABLE}.MISC1 ;;
  #}

  dimension: _es_update_timestamp {
    type: date_time
    sql: ${TABLE}._ES_UPDATE_TIMESTAMP ;;
  }

  dimension: cognos_date {
    type: date
    sql: ${TABLE}.COGNOS_DATE ;;
  }

  dimension_group: monthyear {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.COGNOS_DATE ;;
  }

  dimension: export_week {
    type: date
    label: "Export Date"
    sql: ${TABLE}.COGNOS_DATE ;;
  }

  dimension: dayofweek {
    type: string
    sql: ${TABLE}.DAYOFWEEK ;;
  }

  dimension: is_friday {
    type: number
    sql: case when ${dayofweek} = 'Fri' then 1 else 0 end ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.VENDOR_ID ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}.BRANCH_ID ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.VENDOR_NAME ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}.TERMS ;;
  }




  dimension: revised_terms {
    type: number
    sql:  ${TABLE}.REVISED_TERMS
              ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}.DUE_DATE ;;
  }

  dimension: days_past_due {
    type: number
    sql: ${cognos_date}::date - ${due_date}::date ;;
  }

  dimension: past_due_bucket {
    type: string
    sql: ${TABLE}.PAST_DUE_BUCKET  ;;
  }

  dimension: past_due_bucket_2 {
    type: string
    label: "Past Due Bucket"
    sql: case
         when ${past_due_bucket} = 'Current' then 'Current'
         when ${past_due_bucket} = '0-14' then '0-14'
         when ${past_due_bucket} = '15-30' then '15-30'
         when ${past_due_bucket} = '30Plus' then '30+'
         when ${past_due_bucket} = '45Plus' then '45+'
         when ${past_due_bucket} = '60Plus' then '60+'
         when ${past_due_bucket} = '90Plus' then '90+'
         when ${past_due_bucket} = '120Plus' then '120+'
         end ;;
  }

  dimension: past_due_bucket_sort {
    type: number
    sql: case
         when ${past_due_bucket_2} = 'Current' then 1
         when ${past_due_bucket_2} = '0-14' then 2
         when ${past_due_bucket_2} = '15-30' then 3
         when ${past_due_bucket_2} = '30+' then 4
         when ${past_due_bucket_2} = '45+' then 5
         when ${past_due_bucket_2} = '60+' then 6
         when ${past_due_bucket_2} = '90+' then 7
         when ${past_due_bucket_2} = '120+' then 8
         end ;;
  }

  dimension: past_due_group {
    type: string
    sql: iff(${past_due_bucket}='Current','Current','Past Due') ;;
  }

  dimension: service_type {
    type: string
    sql: ${TABLE}.SERVICE_TYPE ;;
  }

  dimension: inventory_reporting_category {
    type: string
    sql: ${TABLE}.INVENTORY_REPORTING_CATEGORY  ;;
  }

  dimension: branch_name {
    type: string
    sql: CASE WHEN ${TABLE}.BRANCH_NAME IS NULL THEN 'Unknown' ELSE ${TABLE}.BRANCH_NAME END  ;;
  }


  dimension: is_branch {
    type: number
    sql: CASE WHEN ${TABLE}.BRANCH_NAME IS NOT NULL AND ${TABLE}.BRANCH_NAME <> 'Corporate' THEN 1 ELSE 0 END  ;;
  }

  # dimension: bill_date {
  #   type: date
  #   sql: ${TABLE}.invoice_date  ;;
  # }
  dimension_group: bill {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.invoice_date ;;
  }

  measure : bill_amount {
    type: number
    drill_fields: [drill_details*]
    value_format: "$#,##0"
    sql: sum(${TABLE}.REQUEST_TOTAL) ;;
  }
  measure : request_total_detail {
    type: number
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: sum(${TABLE}.REQUEST_TOTAL) ;;
  }

  measure : request_total {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    sql: ${TABLE}.REQUEST_TOTAL ;;
  }

  measure : request_total_k {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ request_total_k._link }}&sorts=unsubmitted_branch.request_total_k+desc" }
    sql: ${TABLE}.REQUEST_TOTAL ;;
  }

  measure : past_due_request_total {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ past_due_request_total._link }}&sorts=unsubmitted_branch.request_total_k+desc" }
    sql: iff(${past_due_group}='Current',0,${TABLE}.REQUEST_TOTAL) ;;
  }

  measure: count {
    type: count
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ count._link }}&sorts=unsubmitted_branch.due_date" }
  }

  measure: current_count {
    type: number
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ current_count._link }}&f[unsubmitted_branch.past_due_bucket]=Current&sorts=unsubmitted_branch.due_date" }
    sql:  sum(iff(${past_due_bucket}='Current',1,0)) ;;
  }

  measure: 0_14_count {
    type: number
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ 0_14_count._link }}&f[unsubmitted_branch.past_due_bucket]=0-14&sorts=unsubmitted_branch.due_date" }
    sql:  sum(iff(${past_due_bucket}='0-14',1,0)) ;;
  }


  measure: 15_30_count {
    type: number
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ 15_30_count._link }}&f[unsubmitted_branch.past_due_bucket]=15-30&sorts=unsubmitted_branch.due_date" }
    sql:  sum(iff(${past_due_bucket}='15-30',1,0)) ;;
  }


  measure: 30_count {
    type: number
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ 30_count._link }}&f[unsubmitted_branch.past_due_bucket]=30Plus&sorts=unsubmitted_branch.due_date" }
    sql:  sum(iff(${past_due_bucket}='30Plus',1,0)) ;;
  }

  measure: 45_count {
    type: number
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ 45_count._link }}&f[unsubmitted_branch.past_due_bucket]=45Plus&sorts=unsubmitted_branch.due_date" }
    sql:  sum(iff(${past_due_bucket}='45Plus',1,0)) ;;
  }

  measure: 60_count {
    type: number
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ 60_count._link }}&f[unsubmitted_branch.past_due_bucket]=60Plus&sorts=unsubmitted_branch.due_date" }
    sql:  sum(iff(${past_due_bucket}='60Plus',1,0)) ;;
  }

  measure: 90_count {
    type: number
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ 90_count._link }}&f[unsubmitted_branch.past_due_bucket]=90Plus&sorts=unsubmitted_branch.due_date" }
    sql:  sum(iff(${past_due_bucket}='90Plus',1,0)) ;;
  }


  measure: 120_count {
    type: number
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ 120_count._link }}&f[unsubmitted_branch.past_due_bucket]=120Plus&sorts=unsubmitted_branch.due_date" }
    sql:  sum(iff(${past_due_bucket}='120Plus',1,0)) ;;
  }

  measure: past_due_count {
    type: number
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ past_due_count._link }}&f[unsubmitted_branch.past_due_group]=Past Due&sorts=unsubmitted_branch.due_date" }
  sql:  sum(iff(${past_due_bucket}<>'Current',1,0)) ;;
  }

  measure: current_amount {
    type: number
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ current_count._link }}&f[unsubmitted_branch.past_due_bucket]=Current&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${past_due_bucket}='Current',${TABLE}.REQUEST_TOTAL,0)) ;;
  }

  measure: 0_14_amount {
    type: number
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ 0_14_count._link }}&f[unsubmitted_branch.past_due_bucket]=0-14&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${past_due_bucket}='0-14',${TABLE}.REQUEST_TOTAL,0)) ;;
  }


  measure: 15_30_amount {
    type: number
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ 15_30_count._link }}&f[unsubmitted_branch.past_due_bucket]=15-30&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${past_due_bucket}='15-30',${TABLE}.REQUEST_TOTAL,0)) ;;
  }


  measure: 30_amount {
    type: number
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ 30_count._link }}&f[unsubmitted_branch.past_due_bucket]=30Plus&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${past_due_bucket}='30Plus',${TABLE}.REQUEST_TOTAL,0)) ;;
  }

  measure: 45_amount {
    type: number
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ 45_count._link }}&f[unsubmitted_branch.past_due_bucket]=45Plus&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${past_due_bucket}='45Plus',${TABLE}.REQUEST_TOTAL,0)) ;;
  }

  measure: 60_amount {
    type: number
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ 60_count._link }}&f[unsubmitted_branch.past_due_bucket]=60Plus&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${past_due_bucket}='60Plus',${TABLE}.REQUEST_TOTAL,0)) ;;
  }

  measure: 90_amount {
    type: number
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ 90_count._link }}&f[unsubmitted_branch.past_due_bucket]=90Plus&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${past_due_bucket}='90Plus',${TABLE}.REQUEST_TOTAL,0)) ;;
  }


  measure: 120_amount {
    type: number
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ 120_count._link }}&f[unsubmitted_branch.past_due_bucket]=120Plus&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${past_due_bucket}='120Plus',${TABLE}.REQUEST_TOTAL,0)) ;;
  }

  measure: past_due_amount {
    type: number
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    link: {label: "Drill Detail" url:"{{ past_due_count._link }}&f[unsubmitted_branch.past_due_group]=Past Due&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${past_due_bucket}<>'Current',${TABLE}.REQUEST_TOTAL,0)) ;;
  }

  measure: unknown_percent_of_total {
    type: number
    value_format: "0.0;(0.0);-"
    #drill_fields: [drill_details*]
    #link: {label: "Drill Detail" url:"{{ count._link }}&f[unsubmitted_branch.branch_name]=Unknown&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${branch_name}='Unknown',1,0)) / ${count} ;;
  }

  measure: unknown_past_due_percent_of_total {
    type: number
    value_format: "0.0;(0.0);-"
    #drill_fields: [drill_details*]
    #link: {label: "Drill Detail" url:"{{ count._link }}&f[unsubmitted_branch.branch_name]=Unknown&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${branch_name}='Unknown'and ${past_due_bucket}<>'Current',1,0)) / sum(iff(${past_due_bucket}<>'Current',1,0)) ;;
  }

  measure: branch_past_due_percent_of_total {
    type: number
    value_format: "0.#0%;(0.#0%);-"
    #drill_fields: [drill_details*]
    #link: {label: "Drill Detail" url:"{{ count._link }}&f[unsubmitted_branch.is_branch]=1&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${is_branch}=1 and ${past_due_bucket}<>'Current',1,0)) / sum(iff(${past_due_bucket}<>'Current',1,0)) ;;
  }

  measure: branch_percent_of_total {
    type: number
    value_format: "0.#0%;(0.#0%);-"
    #drill_fields: [drill_details*]
    #link: {label: "Drill Detail" url:"{{ count._link }}&f[unsubmitted_branch.is_branch]=1&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${is_branch}=1 ,1,0)) / ${count} ;;
  }

  measure: corporate_percent_of_total {
    type: number
    value_format: "0.#0%;(0.#0%);-"
    #drill_fields: [drill_details*]
    #link: {label: "Drill Detail" url:"{{ count._link }}&f[unsubmitted_branch.branch_name]=Corporate&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${branch_name}='Corporate',1,0)) / ${count} ;;
  }

  measure: corporate_past_due_percent_of_total {
    type: number
    value_format: "0.0;(0.0);-"
    #drill_fields: [drill_details*]
    #link: {label: "Drill Detail" url:"{{ count._link }}&f[unsubmitted_branch.branch_name]=Corporate&sorts=unsubmitted_branch.request_total_detail+desc" }
    sql:  sum(iff(${branch_name}='Corporate'and ${past_due_bucket}<>'Current',1,0)) / sum(iff(${past_due_bucket}<>'Current',1,0)) ;;
  }

##removed submit date from drill details for testing thur sep 7, 2023 11:09am
#submit_date,
  set: drill_details {
    fields: [ branch_id, branch_name, employee_last_name, supplier_code, supplier_name, supplier_invoice_number, invoice_received,
              origin_source, approval_status, payment_status,  invoice_received_date, purchase_order_number,
              invoice_date, inventory_reporting_category, alt_pay_method, credit_card_vendor, revised_terms,due_date,past_due_bucket_2, request_total_detail


    ]
  }

  }
