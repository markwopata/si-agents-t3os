view: book_of_business_april_24 {
  sql_table_name: "FLEET"."BOOK_OF_BUSINESS_APRIL_24" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: _vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }
  dimension: asset {
    type: number
    sql: ${TABLE}."ASSET" ;;
  }
  dimension: bo_b {
    type: string
    sql: ${TABLE}."BO_B" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: core_vs_non_core {
    type: string
    sql: ${TABLE}."CORE_VS_NON_CORE" ;;
  }
  dimension: date_to_check_payment {
    type: string
    sql: ${TABLE}."DATE_TO_CHECK_PAYMENT" ;;
  }
  dimension: factory_build_specs {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECS" ;;
  }
  dimension: finance_category {
    type: string
    sql: ${TABLE}."FINANCE_CATEGORY" ;;
  }
  dimension: invoice_date {
    type: string
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: month {
    type: string
    sql: ${TABLE}."MONTH" ;;
  }
  dimension: order_number {
    type: string
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }
  dimension: paid_by_es {
    type: string
    sql: ${TABLE}."PAID_BY_ES" ;;
  }
  dimension: paid_vs_nonpaid_own {
    type: string
    sql: ${TABLE}."CUSTOMER_PAID_" ;;
  }
  dimension: paid_vs_nonpaid_own_i {
    type: string
    sql: ${TABLE}."CUSTOMER_PAID" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: title_status {
    type: string
    sql: ${TABLE}."VEHICLE_TITLE" ;;
  }
  dimension: payment_date {
    type: string
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }


  measure: total_oec {
    type: sum
    drill_fields: [

      _row,
      _vendor,
      asset,
      bo_b,
      class,
      core_vs_non_core,
      date_to_check_payment,
      factory_build_specs,
      finance_category,
      invoice_date,
      invoice_number,
      make,
      market,
      market_id,
      model,
      month,
      order_number,
      paid_by_es,
      paid_vs_nonpaid_own,
      serial_number,
      title_status,
      payment_date,
      week,
      year,
      total_oec

    ]
    sql: ${TABLE}."TOTAL_OEC" ;;
  }
  dimension: week {
    type: string
    sql: ${TABLE}."WEEK" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: fleet_core_mapping {
    type: string
    sql: case when ${core_vs_non_core} = 'Non-Core'  then 'Non-Core Equipment Purchases'
          when ${core_vs_non_core} = 'Vehicles-Upfit'  then 'Upfits'
          when ${core_vs_non_core} = 'Core 5'  then 'Core Equipment Purchases'
          when ${core_vs_non_core} = 'OEC Addition'  then 'OEC Addition'
          when ${core_vs_non_core} = 'Sany'  then 'IES'
          when ${core_vs_non_core} = 'Vehicles'  then 'Vehicles / Trailers'
          else 'Research'
          end ;;
  }

  dimension: month_date  {
    type:  date
    sql: case when left(${month},1) = '1' then '2024-01-01'
    when left(${month},1) = '2'  then '2024-02-01'
    when left(${month},1) = '3'  then '2024-03-01'
    when left(${month},1) = '4'  then '2024-04-01'
    when left(${month},1) = '5'  then '2024-05-01'
    when left(${month},1) = '6'  then '2024-06-01'
    when left(${month},1) = '7'  then '2024-07-01'
    when left(${month},1) = '8'  then '2024-08-01'
    when left(${month},1) = '9'  then '2024-09-01'
    when left(${month},2) = '10' then '2024-10-01'
    when left(${month},2) = '11' then '2024-11-01'
    when left(${month},2) = '12' then '2024-12-01'
    end
    ;;
  }

  dimension_group: submit {
    type: time
    convert_tz: no
    sql: IFF(${TABLE}."PAYMENT_DATE" = '16 - December' , TO_DATE('12-16-2022','MM-DD-YYYY') , TO_DATE(${TABLE}."PAYMENT_DATE",'MM-DD-YYYY')) ;;
  }


  dimension: is_current_week {
    type: yesno
    sql:
      CASE
        WHEN DATE_TRUNC('week', ${submit_date}::DATE) = DATE_TRUNC('week', CURRENT_DATE::DATE)
        THEN TRUE
        ELSE FALSE
      END ;;
  }

  dimension: is_current_week_last_year {
    type: yesno
    sql:
      CASE
        WHEN DATE_TRUNC('week', ${submit_date}::DATE) = DATE_TRUNC('week', CURRENT_DATE::DATE - INTERVAL '1 year')
        THEN TRUE
        ELSE FALSE
      END ;;
  }



  dimension_group: month_group {
    type: time
    sql: ${month_date} ;;
  }

  measure: ytd {
    label: "2024 YTD"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
    drill_fields: [trx_details*]
    filters: [submit_date: "this year",
      is_current_week: "no",
      is_current_week_last_year: "no"]
  }

  measure: qtd {
    label: "QTD"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
    drill_fields: [trx_details*]
    filters: [submit_date: "this quarter",
      is_current_week: "no",
      is_current_week_last_year: "no"]
  }

  measure: mtd {
    label: "MTD"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
    drill_fields: [trx_details*]
    filters: [submit_date: "this month",
      is_current_week: "no",
      is_current_week_last_year: "no"]
  }

  measure: current_week {
    label: "Current Wk"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
    drill_fields: [trx_details*]
    filters: [submit_date: "this week",
      is_current_week: "no",
      is_current_week_last_year: "no"]
  }

  measure: prior_week {
    label: "Prior Wk"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
    drill_fields: [trx_details*]
    filters: [submit_date: "last week",
      is_current_week: "no",
      is_current_week_last_year: "no"]
  }

  measure: prior_year {
    label: "Prior Yr Total"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
    drill_fields: [trx_details*]
    filters: [submit_date: "last year",
      is_current_week: "no",
      is_current_week_last_year: "no"]
  }


  measure: run_rate_2024 {
    label: "2024 Run Rate"
    value_format_name: usd_0
    type: sum
    sql: (${TABLE}."TOTAL_OEC"/(datediff(day,'2024-01-01',current_date)))*366 ;;
    filters: [submit_date: "this year",
      is_current_week: "no",
      is_current_week_last_year: "no"]
  }



  measure: count {
    type: count
  }


set: trx_details {
  fields: [
    _row,
    fleet_core_mapping,
    _vendor,
    asset,
    bo_b,
    class,
    core_vs_non_core,
    date_to_check_payment,
    factory_build_specs,
    finance_category,
    invoice_date,
    invoice_number,
    make,
    market,
    market_id,
    model,
    month,
    order_number,
    paid_by_es,
    paid_vs_nonpaid_own,
    serial_number,
    title_status,
    week,
    year,
    total_oec
  ]
}







}
