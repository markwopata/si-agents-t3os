view: collection_target_dashboard {
  sql_table_name: ANALYTICS.TREASURY.COLLECTION_TARGET_DASHBOARD ;;

  ######## DIMENSIONS ########

  dimension: age {
    type: number
    sql: ${TABLE}."AGE" ;;
  }

  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

  dimension: customer_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  #dimension: due_date {
  #  type: date
  #  sql: ${TABLE}."DUE_DATE" ;;
  #}

  dimension: invoice_no {
    type: string
    html:<font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}" target="_blank">{{value}}</a></font></u>;;
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: legal_flag {
    type: number
    sql: ${TABLE}."LEGAL_FLAG" ;;
  }

  dimension: manager {
    type: string
    sql: ${TABLE}."MANAGER" ;;
  }

  dimension: month {
    type: date
    sql: ${TABLE}."MONTH_" ;;
  }

  dimension: quarter {
    type: string
    #suggest_persist_for: "1 minute"
    sql: ${TABLE}."QUARTER" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: returned_from_legal_month {
    type: date
    sql: ${TABLE}."RETURNED_FROM_LEGAL_MONTH" ;;
  }

  dimension: salesperson_name {
    type: string
    sql: ${TABLE}."SALESPERSON_NAME" ;;
  }

  dimension: salesperson_user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: sent_to_legal_month {
    type: date
    sql: ${TABLE}."SENT_TO_LEGAL_MONTH" ;;
  }


  dimension: month_num {
    type: number
    sql: month(${TABLE}."MONTH_") ;;
  }

  dimension: ar_status   {
    type:  string
    sql: iff(${age}<0,'Past Due A/R','Current A/R') ;;
  }



  dimension: days_in_quarter {
    type:  number
    sql: case when ${quarter} = '2023-Q1' then 90
              when ${quarter} = '2023-Q2' then 91
              when ${quarter} = '2023-Q3' then 92
              when ${quarter} = '2023-Q4' then 92
              when ${quarter} = '2024-Q1' then 91
              when ${quarter} = '2024-Q2' then 91
              when ${quarter} = '2024-Q3' then 92
              when ${quarter} = '2024-Q4' then 92
              when ${quarter} = '2025-Q1' then 90
              when ${quarter} = '2025-Q2' then 91
              when ${quarter} = '2025-Q3' then 92
              when ${quarter} = '2025-Q4' then 92
              when ${quarter} = '2026-Q1' then datediff(day,'2025-12-31',current_date)
              else 90 end ;;
  }

  dimension: month_to_use {
    type: number
    sql: case when ${TABLE}."MONTH_" in ('2023-03-31','2023-06-30', '2023-09-30', '2023-12-31', '2024-03-31', '2024-06-30', '2024-09-30', '2024-12-31','2025-03-31','2025-06-30','2025-09-30','2025-12-31','2026-03-31') then 1 else 0 end ;;
  }

  dimension_group: due {
    type: time
    view_label: "period"
    timeframes: [date , month, quarter, year]
    sql: ${TABLE}."DUE_DATE" ;;
  }


  dimension_group: eom {
    type: time
    view_label: "Month"
    timeframes: [date , month, quarter, year]
    sql: ${TABLE}."MONTH_" ;;
  }

  dimension: collections_dim {
    type: number
    sql: ${TABLE}."COLLECTIONS" ;;
  }

  dimension: customer_manager {
    type: string
    sql: ${TABLE}."CUSTOMER_MANAGER" ;;
  }

  #dimension: paid_status {
  #  type: string
  #  sql: iff(${total_ar}>0,'Unpaid','Paid') ;;
  #}



  ######## MEASURES ########

  measure: collections {
    type: sum
    value_format_name: usd
    drill_fields: [collector_details*]
    sql: ${TABLE}."COLLECTIONS" ;;
  }

  measure: past_due_collections {
    type: sum
    value_format_name: usd
    drill_fields: [collector_details*]
    sql: case when (${month}>last_day(${due_date}::date)) and (${TABLE}."COLLECTIONS"<>0)  then ${TABLE}."COLLECTIONS"/1000000 else 0 end ;;
    filters: [collections_dim:"<>0"]
  }

  measure: collections_per_day {
    type: sum
    value_format_name: usd
    drill_fields: [collector_details*]
    sql: ${TABLE}."COLLECTIONS"/${days_in_quarter} ;;
  }

  measure: total_ar {
    label: "Total A/R"
    type: sum
    value_format_name: usd
    drill_fields: [collector_details*]
    sql: ${TABLE}."TOTAL_AR" ;;
    filters: [month_to_use: "1"]
  }

  measure: total_ar_calc {
    label: "Total A/R"
    type: sum
    value_format_name: usd
    drill_fields: [collector_details*]
    sql: ${TABLE}."CURRENT_AR" + ${TABLE}."PAST_DUE_AR_NON_LEGAL" ;;
    filters: [month_to_use: "1"]
  }

  measure: current_ar {
    label: "Current A/R"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."CURRENT_AR" ;;
    filters: [month_to_use: "1"]
  }

  measure: past_due_ar {
    label: "Past Due A/R"
    type: sum
    value_format_name: usd
    drill_fields: [collector_details*]
    sql: ${TABLE}."PAST_DUE_AR" ;;
    filters: [month_to_use: "1"]
  }

  measure: past_due_ar_legal {
    label: "Past Due A/R Legal"
    type: sum
    value_format_name: usd
    drill_fields: [collector_details*]
    sql: ${TABLE}."PAST_DUE_AR_LEGAL" ;;
    filters: [month_to_use: "1"]
  }

  measure: past_due_ar_non_legal {
    label: "Past Due A/R Non-Legal"
    type: sum
    value_format_name: usd
    drill_fields: [collector_details*]
    sql: ${TABLE}."PAST_DUE_AR_NON_LEGAL" ;;
    filters: [month_to_use: "1"]
  }

  measure: prior_total_ar {
    type: sum
    value_format_name: usd
    drill_fields: [collector_details*]
    sql: ${TABLE}."PRIOR_TOTAL_AR" ;;
    filters: [month_to_use: "1"]
  }

  measure: revenue {
    type: sum
    value_format_name: usd
    drill_fields: [collector_details*]
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: billed_amount {
    type: sum
    value_format_name: usd
    drill_fields: [collector_details*]
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  measure: collections_mm {
    type: sum
    value_format_name: usd_0
    drill_fields: [collector_details*]
    sql: ${TABLE}."COLLECTIONS"/1000000 ;;
  }



  measure: total_ar_mm {
    type: sum
    value_format_name: usd_0
    drill_fields: [collector_details*]
    sql: ${TABLE}."TOTAL_AR"/1000000 ;;
    filters: [month_to_use: "1"]
  }

  measure: current_ar_mm {
    type: sum
    value_format_name: usd_0
    drill_fields: [collector_details*]
    sql: ${TABLE}."CURRENT_AR"/1000000 ;;
    filters: [month_to_use: "1"]
  }

  measure: past_due_ar_mm {
    type: sum
    value_format_name: usd_0
    drill_fields: [collector_details*]
    sql: ${TABLE}."PAST_DUE_AR"/1000000 ;;
    filters: [month_to_use: "1"]
  }

  measure: past_due_ar_legal_mm {
    type: sum
    value_format_name: usd_0
    drill_fields: [collector_details*]
    sql: ${TABLE}."PAST_DUE_AR_LEGAL"/1000000 ;;
    filters: [month_to_use: "1"]
  }

  measure: past_due_ar_non_legal_mm {
    type: sum
    value_format_name: usd_0
    drill_fields: [collector_details*]
    sql: ${TABLE}."PAST_DUE_AR_NON_LEGAL"/1000000 ;;
    filters: [month_to_use: "1"]
  }

  measure: prior_total_ar_mm {
    type: sum
    value_format_name: usd_0
    drill_fields: [collector_details*]
    sql: ${TABLE}."PRIOR_TOTAL_AR"/1000000 ;;
    filters: [month_to_use: "1"]
  }

  measure: revenue_mm {
    type: sum
    value_format_name: usd_0
    drill_fields: [collector_details*]
    sql: ${TABLE}."REVENUE"/1000000 ;;
  }

  measure: dso {
    type: number
    value_format_name: decimal_1
    sql: iff(${revenue_mm}=0,0,((${current_ar_mm}+${past_due_ar_non_legal_mm})/${revenue_mm})*${days_in_quarter}) ;;
  }

  measure: total_dso {
    type: number
    value_format_name: decimal_1
    sql: iff(${revenue_mm}=0,0,(${total_ar_mm}/${revenue_mm})*${days_in_quarter});;
  }


  measure: dso_70 {
    label: "Opportunity 70 DSO"
    type: number
    value_format_name: usd
    drill_fields: [collector_details*]
    sql: iff(${dso}>70,${total_ar_calc}-(70*(${revenue}/90)),0)  ;;
  }

  measure: dso_60 {
    label: "Opportunity 60 DSO"
    type: number
    value_format_name: usd
    drill_fields: [collector_details*]
    sql: iff(${dso}>60,${total_ar_calc}-(60*(${revenue}/90)),0)  ;;
  }

  measure: run_rate_revenue {
    label: "Run Rate Revenue"
    type: number
    drill_fields: [collector_details*]
    sql: iff(${quarter}='2026-Q1', (${revenue} / (datediff(day,'2025-12-31',current_date))) * 90,${revenue}) ;;
    value_format_name: usd_0
  }

  measure: collection_effectiveness_index {
    type:  number
    value_format_name: decimal_2
    drill_fields: [collector_details*]
    sql: (${prior_total_ar} + ${run_rate_revenue} - ${total_ar_calc})/(${prior_total_ar} + ${run_rate_revenue} - ${current_ar}) ;;
  }



  measure: past_due_paid {
    type: string
    sql: case when (${month} > last_day(${due_date}::date)) and (${collections}>0) then 'Yes' else 'No' end ;;
  }


  ######## DRILL FIELDS ########

  set: collector_details {
    fields: [quarter,month,due_date,age,invoice_no,salesperson_user_id,salesperson_name,customer_id,customer_name,branch_id,branch_name,region_district,
       collector,manager,collections,revenue,current_ar,past_due_ar_non_legal]
  }


}
