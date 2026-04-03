view: retail_sales_quote_detail {
  derived_table: {
    sql:
    select qd.*
         , date_trunc(month,qd.quote_completed_at::date) as quote_completed_month
         , TO_CHAR(qd.quote_completed_at, 'MON-YY') AS month_year
         --, day(qd.quote_completed_at::date) as month_day
     from analytics.retail_sales.retail_sales_quotes qd
     where qd.is_current = TRUE;;
  }

  dimension: quote_pk_id {
    type: number
    sql: ${TABLE}."QUOTE_PK_ID" ;;
  }

  dimension: quote_id{
    type: number
    sql: ${TABLE}."QUOTE_ID" ;;
  }

  dimension: salesperson_user_id{
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson_name{
    label: "Salesperson"
    type: string
    sql: ${TABLE}."SALESPERSON_NAME" ;;
  }

  dimension: salesperson_email{
    label: "Salesperson Email"
    type: string
    sql: ${TABLE}."SALESPERSON_EMAIL" ;;
  }

  dimension: parent_market_id{
    label: "MarketID"
    type: number
    sql: ${TABLE}."PARENT_MARKET_ID" ;;
  }

  dimension: status{
    label: "Status"
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: open_closed_lost {
    label: "Quote Status"
    type: string
    sql: case
          when ${TABLE}."STATUS" = 'complete' then 'Complete'
          when ${TABLE}."STATUS" in('customer approved','draft','gm approved','pending gm approval', 'submitted for invoicing') then 'Open'
          when ${TABLE}."STATUS" in('denied','lost sale') then 'Lost'
          else 'Check'
         end;;
  }

  measure: complete_quote {
    label: "Complete Quote"
    type: sum
    sql: case
          when ${TABLE}."STATUS" = 'complete' then 1 else 0 end;;
  }

  measure: open_complete_quote {
    label: "Open or Complete Quote"
    type: sum
    sql: case
      when ${TABLE}."STATUS" in('complete','customer approved','draft','gm approved','pending gm approval', 'submitted for invoicing') then 1 else 0 end;;
  }

  dimension: quote_created_at{
    label: "Quote Created At"
    type: date_time
    sql: ${TABLE}."QUOTE_CREATED_AT" ;;
  }

  dimension: quote_completed_at{
    label: "Quote Completed At"
    type: date_time
    sql: ${TABLE}."QUOTE_COMPLETED_AT" ;;
  }

  dimension_group: quote_completed_at_group{
    label: "Day of Month"
    type: time
    sql: ${TABLE}."QUOTE_COMPLETED_AT" ;;
    timeframes: [raw,day_of_month]
  }

  dimension: quote_completed_month {
    label: "Quote Completed Month"
    type: date
    sql: ${TABLE}."QUOTE_COMPLETED_MONTH" ;;
  }

  dimension: month_year {
    label: "Month"
    type: string
    sql: ${TABLE}."MONTH_YEAR" ;;
  }

  dimension: quote_date_filter {
    label: "Quote Date Filter"
    type: date
    sql: case
          when ${TABLE}."QUOTE_COMPLETED_AT" is not null then date_trunc(month,${TABLE}."QUOTE_COMPLETED_AT"::date)
          when ${TABLE}."STATUS" in ('denied','lost sale') then date_trunc(month,${TABLE}."QUOTE_CREATED_AT"::date)
          else date_trunc(month,CURRENT_DATE)
         end ;;
  }

  measure: quote_completetion_days {
    label: "Days to Complete Quote"
    type: average
    value_format_name: decimal_2
    sql: ${TABLE}."DAYS_TO_COMPLETE" ;;
  }

  measure: quote_completion_hours{
    label: "Hours to Complete Quote"
    type: average
    value_format_name: "decimal_2"
    sql: TIMESTAMPDIFF(hour,${TABLE}."QUOTE_CREATED_AT",${TABLE}."QUOTE_COMPLETED_AT");;
  }

  measure: asset_count{
    label: "Asset Count"
    type: sum
    sql: ${TABLE}."ASSET_COUNT" ;;
  }

  measure: row_count {
    label: "Sales Count"
    type: count
  }

  measure: total_price{
    label: "Sales Revenue"
    type: sum
    sql: ${TABLE}."TOTAL_PRICE" ;;
  }

  measure: total_cost{
    label: "Sales Expense"
    type: sum
    sql: ${TABLE}."TOTAL_COST" ;;
  }

  measure: total_rebate{
    label: "Sales Rebates"
    type: sum
    sql: ${TABLE}."TOTAL_REBATE" ;;
  }

  measure: total_margin{
    label: "Sales Margin"
    type: sum
    sql: ${TABLE}."TOTAL_MARGIN" ;;
  }
}
