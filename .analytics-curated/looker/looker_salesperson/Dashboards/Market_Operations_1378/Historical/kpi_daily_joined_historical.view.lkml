
view: kpi_daily_joined_historical {
  sql_table_name: analytics.bi_ops.daily_sp_market_rollup ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: home_market_id {
    type:  string
    sql:  ${TABLE}."HOME_MARKET_ID" ;;
    description: "Final home market id listed at the end of each month"
  }

  dimension: home_market_name {
    type:  string
    sql:  ${TABLE}."HOME_MARKET_NAME" ;;
    description: "Current Home Market"
  }


  dimension: pk {
    type: string
    primary_key: yes
    sql:  concat( ${TABLE}."DATE" ,  ${TABLE}."MARKET_ID",  ${TABLE}."SALESPERSON_USER_ID")  ;;
  }

  dimension_group: date {
    type: time
    sql: ${TABLE}."DATE" ;;
    timeframes: [date, month, month_name, year, quarter, day_of_month]
  }

  dimension: date_formatted {
    group_label: "HTML Formatted Date"
    label: "Date"
    type: date
    sql: ${date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: month_formatted {
    group_label: "HTML Formatted Date"
    label: "Month"
    type: date
    sql: DATE_TRUNC(month, ${date_date}::DATE) ;;
    html: {{ rendered_value | date: "%b %Y" }};;
  }

  dimension: formatted_date {
    type: string
    sql:
    TO_CHAR(${TABLE}."DATE" , 'MMMM') || ' ' ||
    TO_CHAR(${TABLE}."DATE" , 'DD') ||
    CASE
      WHEN TO_CHAR(${TABLE}."DATE" , 'DD')::int % 10 = 1 AND TO_CHAR(${TABLE}."DATE" , 'DD')::int != 11 THEN 'st'
      WHEN TO_CHAR(${TABLE}."DATE" , 'DD')::int % 10 = 2 AND TO_CHAR(${TABLE}."DATE" , 'DD')::int != 12 THEN 'nd'
      WHEN TO_CHAR(${TABLE}."DATE" , 'DD')::int % 10 = 3 AND TO_CHAR(${TABLE}."DATE" , 'DD')::int != 13 THEN 'rd'
      ELSE 'th'
    END || ', ' || ;;
  }


  dimension: market_id {
    group_label: "Market Info"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: salesperson_user_id {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: current_home_market {
    type: string
    sql: ${TABLE}."CURRENT_HOME_MARKET" ;;
  }

  dimension: current_home_market_id {
    type: string
    sql: ${TABLE}."CURRENT_HOME_MARKET_ID" ;;
  }

  dimension: assets_on_rent {
    group_label: "Assets on Rent"
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  dimension: rerent_assets_on_rent {
    group_label: "Assets on Rent"
    type: number
    sql:  ${TABLE}."RERENT_ASSETS_ON_RENT" ;;
  }

  dimension: max_assets_on_rent {
    type: number
    sql: ${TABLE}."MAX_ASSETS_ON_RENT" ;;
  }

  measure: max_assets_on_rent_max {
    label: "Assets On Rent"
    type:  max
    sql: ${max_assets_on_rent} ;;
  }

  dimension: max_oec_on_rent {
    type: number
    sql: ${TABLE}."MAX_OEC_ON_RENT" ;;
    value_format_name: usd_0
  }

  measure: max_oec_on_rent_max {
    label: "Max Assets on Rent"
    type: max
    sql: ${max_oec_on_rent} ;;
    value_format_name: usd_0
  }

  dimension: max_bulk_parts_on_rent {
    type: number
    sql: ${TABLE}."MAX_BULK_PARTS_ON_RENT" ;;
  }

  measure:  max_bulk_parts_on_rent_max {
    type: max
    sql: ${max_bulk_parts_on_rent} ;;
  }

  dimension: max_bulk_cost_on_rent {
    type: number
    sql: ${TABLE}."MAX_BULK_COST_ON_RENT" ;;
    value_format_name: usd_0
  }

  measure:  max_bulk_cost_on_rent_max {
    type: max
    sql: ${max_bulk_cost_on_rent} ;;
    value_format_name: usd_0
    }

  measure: assets_on_rent_sum {
    group_label: "Assets on Rent Sum"
    label: "Assets on Rent"
    type: sum
    sql: ${assets_on_rent} ;;
    drill_fields: [salesperson_filter_values, market_name, assets_on_rent_sum]
    value_format: "0"
    filters: [days_flag: "YES"]
  }

  measure: assets_on_rent_sum_sp {
    group_label: "Assets on Rent"
    type: sum

    sql: ${assets_on_rent} ;;
    value_format: "0"

  }

  measure: rerent_assets_on_rent_sum {
    group_label: "Assets on Rent"
    type: sum

    sql: ${rerent_assets_on_rent} ;;
    value_format: "0"
  }

  measure: assets_on_rent_avg {
    group_label: "Assets on Rent"
    type: number
    sql: sum(${assets_on_rent}) / count(distinct ${date_date}) ;;
    value_format: "0.##"
  }

  measure: mtd_assets_on_rent {
    group_label: "Assets on Rent"
    type: average
    # sql: case when ${mtd} =1 then ${assets_on_rent} else null end;;
    sql: ${assets_on_rent} ;;
    value_format_name: decimal_0
    filters: [mtd: "1"]
  }

  measure: current_assets_on_rent {
    group_label: "Assets on Rent"
    label: "Assets On Rent"
    type: sum
    sql: ${assets_on_rent} ;;
    value_format_name: decimal_0
    filters: [today_flag: "1"]
  }

  measure: current_rerent_assets_on_rent {
    group_label: "Assets on Rent"
    label: "Current Rerent Assets On Rent"
    type: sum
    sql: ${rerent_assets_on_rent} ;;
    value_format_name: decimal_0
    filters: [today_flag: "1"]
  }

  measure: current_assets_on_rent_past_days_null {
    group_label: "Assets on Rent With Null Past Days"
    label: "Assets On Rent"
    type: number
    sql: case when ${current_assets_on_rent} = 0 then null else ${current_assets_on_rent} end ;;
    drill_fields: [salesperson_filter_values, market_name, assets_on_rent_sum]
    value_format_name: decimal_0
  }

  measure: current_rerent_assets_on_rent_with_null_days {
    group_label: "Assets on Rent With Null Past Days"
    label: "Current Rerent Assets On Rent with Null"
    type: number
    sql: case when ${current_assets_on_rent_past_days_null} IS NULL then null ELSE ${current_rerent_assets_on_rent} end ;;
    value_format_name: decimal_0
  }

  dimension: prior_month_day {
    type: yesno
    sql: ${mtd_previous} = 1 AND day(CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE) = ${date_day_of_month} ;;
  }

  measure: assets_on_rent_change {
    group_label: "Assets on Rent"
    label: "MTD vs Last MTD Assets On Rent"
    type: number
    sql: ${current_assets_on_rent} - ${last_mtd_assets_on_rent} ;;
    value_format_name: decimal_0
  }

  measure: mtd_aor_percent_change {
    group_label: "Assets on Rent"
    type: number
    sql: CASE WHEN ${last_mtd_assets_on_rent} = 0 AND ${current_assets_on_rent} = 0 THEN 0
              WHEN ${last_mtd_assets_on_rent} = 0 THEN 1
              ELSE ((${current_assets_on_rent} - ${last_mtd_assets_on_rent})/ NULLIFZERO(${last_mtd_assets_on_rent}))  END ;;
    value_format_name: percent_1
  }


  measure: last_mtd_assets_on_rent {
    group_label: "Assets on Rent"
    label: "Last MTD Assets On Rent"
    type: sum
    sql: ${assets_on_rent} ;;
    value_format_name: decimal_0
    filters: [prior_month_day: "Yes"]
  }

  measure: lmtd_assets_on_rent {
    group_label: "Assets on Rent"
    type: number
    sql: case when ${mtd_previous} = 1 then ${assets_on_rent} else null end;;
    value_format: "0.##"
  }

  measure: mtd_assets_on_rent_avg {
    group_label: "Assets on Rent"
    type: number
    sql: sum(${mtd_assets_on_rent}) / count(distinct ${date_date});;
    value_format: "0.##"
  }

  measure: lmtd_assets_on_rent_avg {
    group_label: "Assets on Rent"
    type: number
    sql: sum(${lmtd_assets_on_rent}) / count(distinct ${date_date});;
    value_format: "0.##"
  }

  measure: mtd_assets_on_rent_change {
    group_label: "Assets on Rent"
    type: number
    sql: ${mtd_assets_on_rent_avg} - ${lmtd_assets_on_rent_avg} ;;
    value_format_name: decimal_0
  }

  measure: mtd_assets_on_rent_percent_change {
    group_label: "Assets on Rent"
    type: number
    sql: CASE WHEN ${last_mtd_assets_on_rent} = 0 AND ${current_assets_on_rent} = 0 THEN 0
              WHEN ${last_mtd_assets_on_rent} = 0 THEN 1
              ELSE ((${current_assets_on_rent} - ${last_mtd_assets_on_rent})/ NULLIFZERO(${last_mtd_assets_on_rent}))  END;;
    value_format_name: percent_1
  }

  dimension: actively_renting_customers {
    group_label: "Renting Customers"
    type: number
    sql: ${TABLE}."ACTIVELY_RENTING_CUSTOMERS" ;;
  }

  measure: actively_renting_customers_sum {
    group_label: "Renting Customers"
    description: "Do not use this.. you cannot sum this in this rollup table.  Reps can be doing business with the same company in different markets."
    type: sum

    sql: ${actively_renting_customers} ;;
  }

  measure: current_actively_renting_customers {
    group_label: "Renting Customers"
    label: "Actively Renting Customers"
    description: "Do not use this.. you cannot sum this in this rollup table.  Reps can be doing business with the same company in different markets."
    type: sum
    sql: ${actively_renting_customers} ;;
    value_format_name: decimal_0
    filters: [today_flag: "1"]
  }

  measure: current_actively_renting_customers_with_null_days {
    group_label: "Renting Customers With Past Null Days"
    label: "Actively Renting Customers"
    description: "Do not use this.. you cannot sum this in this rollup table.  Reps can be doing business with the same company in different markets."
    type: number
    sql: case when ${current_actively_renting_customers} = 0 then null else ${current_actively_renting_customers} end ;;
    value_format_name: decimal_0
  }

  measure: last_mtd_actively_renting_customers {
    group_label: "Renting Customers"
    label: "Last MTD Actively Renting Customers"
    description: "Do not use this.. you cannot sum this in this rollup table.  Reps can be doing business with the same company in different markets."
    type: sum
    sql: ${actively_renting_customers} ;;
    value_format_name: decimal_0
    filters: [prior_month_day: "Yes"]
  }

  measure: last_90_actively_renting_customers {
    group_label: "Rep Rental History"
    label: "Actively Renting Customers"
    description: "Do not use this.. you cannot sum this in this rollup table.  Reps can be doing business with the same company in different markets."
    type: sum
    sql: ${actively_renting_customers} ;;
    value_format_name: decimal_0
    filters: [past_90_day: "1"]
  }

  measure: actively_renting_customers_change {
    group_label: "Renting Customers"
    label: "MTD vs Last MTD Actively Renting Customers"
    type: number
    description: "Do not use this.. you cannot sum this in this rollup table.  Reps can be doing business with the same company in different markets."
    sql: ${current_actively_renting_customers} - ${last_mtd_actively_renting_customers} ;;
    value_format_name: decimal_0
  }

  measure: mtd_actively_renting_customers_percent_change {
    group_label: "Renting Customers"
    type: number
    description: "Do not use this.. you cannot sum this in this rollup table.  Reps can be doing business with the same company in different markets."
    sql: CASE WHEN ${last_mtd_actively_renting_customers} = 0 AND ${current_actively_renting_customers} = 0 THEN 0
              WHEN ${last_mtd_actively_renting_customers} = 0 THEN 1
              ELSE ((${current_actively_renting_customers} - ${last_mtd_actively_renting_customers})/ NULLIFZERO(${last_mtd_actively_renting_customers})) END ;;
    value_format_name: percent_1
  }

  dimension: oec_on_rent {
    group_label: "OEC"
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
    value_format_name:  usd_0
  }

  measure: oec_on_rent_sum {
    group_label: "OEC"
    label: "OEC On Rent"
    type: sum
    sql: ${oec_on_rent} ;;
    drill_fields: [salesperson_filter_values, market_name, oec_on_rent_sum]
    value_format_name:  usd_0

  }








  measure: oec_on_rent_avg {
    group_label: "OEC"
    type: number
    sql: sum(${oec_on_rent}) / count(distinct ${date_date}) ;;
    value_format_name:  usd_0
  }

  measure: mtd_oec {
    group_label: "OEC"
    type: number
    sql: case when ${mtd} =1 then ${oec_on_rent} else null end;;
    value_format_name:  usd_0
  }

  measure: lmtd_oec {
    group_label: "OEC"
    type: number
    sql: case when ${mtd_previous} = 1 then ${oec_on_rent} else null end;;
    value_format_name:  usd_0
  }

  measure: mtd_oec_avg {
    group_label: "OEC"
    type: number
    sql: sum(${mtd_oec}) / count(distinct ${date_date});;
    value_format_name:  usd_0
  }

  measure: lmtd_oec_avg {
    group_label: "OEC"
    type: number
    sql: sum(${lmtd_oec}) / count(distinct ${date_date});;
    value_format_name:  usd_0
  }

  measure: mtd_oec_change {
    group_label: "OEC"
    type: number
    sql: ${mtd_oec_avg} - ${lmtd_oec_avg} ;;
    value_format_name:  usd_0
  }

  measure: current_oec_on_rent {
    group_label: "OEC"
    label: "OEC On Rent"
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd_0
    filters: [today_flag: "1"]
  }

  measure: current_oec_on_rent_with_null_days {
    group_label: "OEC With Past Days Null"
    label: "OEC On Rent"
    type: number
    drill_fields: [salesperson_filter_values, market_name, oec_on_rent_sum]
    sql: case when ${current_oec_on_rent} = 0 then null else ${current_oec_on_rent} end ;;
    value_format_name: usd_0
  }

  measure: last_90_oec_on_rent {
    group_label: "Rep Rental History"
    label: "OEC On Rent"
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd_0
    drill_fields: [salesperson_filter_values, market_name, oec_on_rent_sum]
    filters: [days_flag: "YES"]
  }

  measure: last_mtd_oec_on_rent {
    group_label: "OEC"
    label: "Last MTD OEC On Rent"
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd_0
    filters: [prior_month_day: "Yes"]
  }

  measure: oec_on_rent_change {
    group_label: "OEC"
    label: "MTD vs Last MTD OEC On Rent"
    type: number
    sql: ${current_oec_on_rent} - ${last_mtd_oec_on_rent} ;;
    value_format_name: usd_0
  }

  measure: mtd_oec_percent_change {
    group_label: "OEC"
    type: number
    sql: CASE WHEN ${last_mtd_oec_on_rent} = 0 AND ${current_oec_on_rent} = 0 THEN 0
          WHEN ${last_mtd_oec_on_rent} = 0 AND ${current_oec_on_rent} > 0 THEN 1
          WHEN ${last_mtd_oec_on_rent} = 0 AND ${current_oec_on_rent} < 0 THEN -1
          ELSE ((${current_oec_on_rent} - ${last_mtd_oec_on_rent})/ NULLIFZERO(${last_mtd_oec_on_rent})) END ;;
    value_format_name: percent_1
  }

  dimension: total_market_OEC {
    group_label: "Total Market KPIs"
    type: number
    sql: ${TABLE}."TOTAL_MARKET_OEC" ;;
    value_format_name:  usd_0
  }

  measure: total_market_OEC_sum {
    group_label: "Total Market KPIs"
    type: sum
    sql: ${total_market_OEC} ;;
    value_format_name:  usd_0
  }

  measure: total_market_OEC_avg {
    group_label: "Total Market KPIs"
    type: number
    sql: sum(${total_market_OEC}) / count(distinct ${date_date}) ;;
    value_format_name:  usd_0
  }

  dimension: total_market_asset_count {
    group_label: "Total Market KPIs"
    type: number
    sql: ${TABLE}."TOTAL_MARKET_ASSET_COUNT" ;;
  }

  measure: total_market_asset_count_sum {
    group_label: "Total Market KPIs"
    type: sum
    sql: ${total_market_asset_count} ;;
  }

  measure: total_market_asset_count_avg {
    group_label: "Total Market KPIs"
    type: average
    sql: ${total_market_asset_count} ;;
  }

  dimension: in_market_gen_rental {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."IN_MARKET_GEN_RENTAL" ;;
    value_format: "$#,##0"
  }

  measure: in_market_gen_rental_sum {
    group_label: "Revenue"
    type: sum
    sql: ${in_market_gen_rental} ;;
    value_format: "$#,##0"
  }

  dimension: in_market_advanced_rentals {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."IN_MARKET_ADVANCED_RENTALS" ;;
    value_format: "$#,##0"
  }

  measure: in_market_advanced_rentals_sum {
    group_label: "Revenue"
    type: sum
    sql: ${in_market_advanced_rentals} ;;
    value_format: "$#,##0"
  }

  dimension: in_market_itl {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."IN_MARKET_ITL" ;;
    value_format: "$#,##0"
  }

  measure: in_market_itl_sum {
    group_label: "Revenue"
    type: sum
    sql: ${in_market_itl} ;;
    value_format: "$#,##0"
  }

  dimension: in_market_no_class {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."IN_MARKET_NO_CLASS" ;;
    value_format: "$#,##0"
  }

  measure: in_market_no_class_sum {
    group_label: "Revenue"
    type: sum
    sql: ${in_market_no_class} ;;
    value_format: "$#,##0"
  }

  dimension: out_market_gen_rental {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."OUT_MARKET_GEN_RENTAL" ;;
    value_format: "$#,##0"
  }

  measure: out_market_gen_rental_sum {
    group_label: "Revenue"
    type: sum
    sql: ${out_market_gen_rental} ;;
    value_format: "$#,##0"
  }

  dimension: out_market_advanced_rentals {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."OUT_MARKET_ADVANCED_RENTALS" ;;
    value_format_name: usd_0
  }

  measure: out_market_advanced_rentals_sum {
    group_label: "Revenue"
    type: sum
    sql: ${out_market_advanced_rentals} ;;
    value_format_name: usd_0
  }

  dimension: out_market_itl {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."OUT_MARKET_ITL" ;;
    value_format_name: usd_0
  }

  measure: out_market_itl_sum {
    group_label: "Revenue"
    type: sum
    sql: ${out_market_itl} ;;
    value_format_name: usd_0
  }

  dimension: out_market_no_class {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."OUT_MARKET_NO_CLASS" ;;
    value_format_name: usd_0
  }

  measure: out_market_no_class_sum {
    group_label: "Revenue"
    type: sum
    sql: ${out_market_no_class} ;;
    value_format_name: usd_0
  }


  measure: in_market_rev_sum {
    group_label: "Revenue"
    label: "In Market Revenue Overall"
    type: sum
    sql: CASE WHEN ${in_market_rev} <> 0 THEN ${in_market_rev} ELSE NULL END;;
    value_format_name: usd_0
    drill_fields: [rep_company_in_market_drill*]

  }

  measure: in_market_rev_sum_cm {
    group_label: "Revenue"
    label: "In Market Revenue Overall - Current Month"
    type: sum
    sql: CASE WHEN ${in_market_rev} <> 0 and ${mtd} = 1 THEN ${in_market_rev} ELSE NULL END;;
    html: <a style="color:#0063f3;" href="https://equipmentshare.looker.com/dashboards/2558?Rep={{ sales_manager_permissions.rep_home_market._value | url_encode }}&Home+Market={{ sales_manager_permissions.employee_location._value | url_encode }}" target="_blank" rel="noopener">
    {{ rendered_value }} ➔
    </a>;;
    value_format_name: usd_0

  }

  measure: in_market_rev_sum_no_drill {
    group_label: "Revenue"
    label: "In Market Rev Overall"
    type: sum
    sql: CASE WHEN ${in_market_rev} <> 0 THEN ${in_market_rev} ELSE NULL END;;
    value_format_name: usd_0
  }

  dimension: no_sp_market_rev {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."NO_SP_MARKET_REV" ;;
    value_format_name: usd_0
  }

  measure: no_sp_market_rev_sum {
    group_label: "Revenue"
    label: "Revenue For District Level Tam"
    type: sum
    sql: CASE WHEN ${no_sp_market_rev} <> 0 THEN ${no_sp_market_rev} ELSE NULL END;;
    value_format_name: usd_0
    drill_fields: [rep_company_in_market_drill*]
  }

  set: revenue_in_drill {
    fields: [salesperson, total_rev_sum, mtd_in_market_revenue]
  }

  set: revenue_out_drill {
    fields: [salesperson, total_rev_sum, mtd_out_market_revenue]
  }
  set: rep_company_drill {
    fields: [current_month_rev_by_company.sp_name, current_month_rev_by_company.rental_company, current_month_rev_by_company.total_rev_sum, current_month_rev_by_company.perc_total ]
  }

  set: rep_company_in_market_drill {
    fields: [current_month_rev_by_company.sp_name, current_month_rev_by_company.rental_company, current_month_rev_by_company.in_market_rev_sum , current_month_rev_by_company.in_market_perc_total ]
  }
  set: rep_company_out_market_drill {
    fields: [current_month_rev_by_company.sp_name, current_month_rev_by_company.rental_company, current_month_rev_by_company.out_market_rev_sum, current_month_rev_by_company.out_market_perc_total ]
  }


  measure: mtd_in_market_revenue {
    group_label: "Revenue"
    label: "In Market Revenue"
    type: sum
    sql: ${in_market_rev} ;;
    value_format_name: usd_0
    filters: [mtd: "1"]
  }

  measure: mtd_prior_in_market_revenue {
    group_label: "Revenue"
    label: "Prior MTD In Market Revenue"
    type: sum
    sql: ${in_market_rev};;
    value_format_name: usd_0
    filters: [mtd_previous: "1"]
  }

    measure: mtd_prior_out_market_revenue {
    group_label: "Revenue"
    label: "Prior MTD Out Market Revenue"
    type: sum
    sql: ${out_market_rev} ;;
    value_format_name: usd_0
    filters: [mtd_previous: "1"]
  }

  dimension: market_type {
    label: "Market Type"
    sql:
    CASE
      WHEN ${home_market_name} = ${market_name} THEN 'In Market'
      ELSE 'Out of Market'
    END ;;
  }


  measure: in_market_percent {
    group_label: "Revenue"
    type: number
    sql: div0null(${in_market_rev_sum}, ${total_rev_sum})  ;;
    value_format_name: percent_1
  }

  measure: out_market_percent {
    group_label: "Revenue"
    type: number
    sql: div0null(${out_market_rev_sum}, ${total_rev_sum})  ;;
    value_format_name: percent_1
  }


  dimension: parent_market_id {
    type: string
    sql: ${branch_earnings_market.market_id} ;;
  }

  dimension: child_market_id {
    type: string
    sql: ${branch_earnings_market.child_market_id} ;;
  }


  dimension: in_market_rev {
    type: number
    sql: case when ${home_market_id} = ${parent_market_id} then ${total_rev} else 0 end ;;
  }

  dimension: out_market_rev {
    type: number
    sql: case when ${home_market_id} != ${parent_market_id} then ${total_rev} else 0 end ;;
  }



  measure: out_market_rev_sum {
    group_label: "Revenue"
    label: "Out of Market Revenue Overall"
    type: sum
    sql: CASE WHEN ${out_market_rev} <> 0 THEN ${out_market_rev} ELSE NULL END;;
    value_format_name: usd_0
    drill_fields: [rep_company_out_market_drill*]
  }

  measure: out_market_rev_sum_cm {
    group_label: "Revenue"
    label: "Out of Market Revenue Overall - Current Month"
    type: sum
    sql: CASE WHEN ${out_market_rev} <> 0 and ${mtd} = 1 THEN ${out_market_rev} ELSE NULL END;;
    value_format_name: usd_0
    drill_fields: [rep_company_out_market_drill*]
  }

  measure: out_market_rev_sum_no_drill {
    group_label: "Revenue"
    label: "Out of Market Rev Overall"
    type: sum
    sql: CASE WHEN ${out_market_rev} <> 0 THEN ${out_market_rev} ELSE NULL END;;
    value_format_name: usd_0
  }

  measure: mtd_out_market_revenue {
    group_label: "Revenue"
    label: "Out of Market Revenue"
    type: sum
    sql: ${out_market_rev} ;;
    value_format_name: usd_0
    filters: [mtd: "1"]
  }

  measure: mtd_current_revenue {
    group_label: "Revenue"
    label: "Current MTD Revenue"
    type: sum
    sql: case when ${home_market_name} = ${market_name}
              then ${in_market_rev}
              else ${out_market_rev}
              end;;
    value_format_name: usd_0
    filters: [mtd: "1"]
  }

  dimension: gen_rental_total {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."GEN_RENTAL_TOTAL" ;;
    value_format_name: usd_0
  }

  measure: gen_rental_total_sum {
    group_label: "Revenue"
    label: "Gen. Rental"
    type: sum
    sql: ${gen_rental_total} ;;
    value_format_name: usd_0

  }

  dimension: adv_rentals_total {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."ADV_RENTALS_TOTAL" ;;
    value_format_name: usd_0
  }

  measure: adv_rentals_total_sum {
    group_label: "Revenue"
    label: "Adv. Solutions"
    type: sum
    sql: ${adv_rentals_total} ;;
    value_format_name: usd_0

  }

  dimension: itl_total {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."ITL_TOTAL" ;;
    value_format_name: usd_0
  }

  measure: itl_total_sum {
    group_label: "Revenue"
    label: "ITL"
    type: sum
    sql: ${itl_total} ;;
    value_format_name: usd_0


  }

  dimension: no_class_total {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."NO_CLASS_TOTAL" ;;
    value_format_name: usd_0
  }

  measure: no_class_total_sum {
    group_label: "Revenue"
    label: "No Class"
    type: sum
    sql: ${no_class_total} ;;
    value_format_name: usd_0


  }

  measure: adv_rentals_total_sum_mtd {
    group_label: "Revenue"
    label: "Adv. Solutions MTD"
    type: sum
    sql: case when ${mtd} = '1' THEN ${adv_rentals_total} ELSE NULL END;;
    value_format_name: usd_0

  }

  measure: adv_rentals_total_sum_lmtd {
    group_label: "Revenue"
    label: "Adv. Solutions LMTD"
    type: sum
    sql: case when ${mtd_previous} = '1' THEN ${adv_rentals_total} ELSE NULL END;;
    filters: [mtd_previous: "1"]
    value_format_name: usd_0

  }

  measure: gen_rental_total_sum_mtd {
    group_label: "Revenue"
    label: "Gen. Rental MTD"
    type: sum
    sql: case when ${mtd} = '1' THEN ${gen_rental_total} ELSE NULL END;;
    value_format_name: usd_0

  }

  measure: gen_rental_total_sum_lmtd {
    group_label: "Revenue"
    label: "Gen. Rental LMTD"
    type: sum
    sql: case when ${mtd_previous} = '1' THEN ${gen_rental_total} ELSE NULL END;;
    value_format_name: usd_0
  }

  measure: itl_total_sum_mtd {
    group_label: "Revenue"
    label: "ITL MTD"
    type: sum
    sql: case when ${mtd} = '1' THEN ${itl_total} ELSE NULL END;;
    value_format_name: usd_0

  }

  measure: itl_total_sum_lmtd {
    group_label: "Revenue"
    label: "ITL LMTD"
    type: sum
    sql: case when ${mtd_previous} = '1' THEN ${itl_total} ELSE NULL END;;
    value_format_name: usd_0
  }

  measure: no_class_total_sum_mtd {
    group_label: "Revenue"
    label: "No Class MTD"
    type: sum
    sql: case when ${mtd} = '1' THEN ${no_class_total} ELSE NULL END;;
    value_format_name: usd_0

  }

  measure: no_class_total_sum_lmtd {
    group_label: "Revenue"
    label: "No Class LMTD"
    type: sum
    sql: case when ${mtd_previous} = '1' THEN ${no_class_total} ELSE NULL END;;
    value_format_name: usd_0
  }



  dimension: total_rev {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."TOTAL_REV" ;;
    value_format_name: usd_0
  }

  measure: total_rev_sum {
    group_label: "Revenue"
    label: "Total Rental Revenue"
    type: sum
    sql: ${total_rev} ;;
    value_format_name: usd_0
    drill_fields: [rep_company_drill*]
  }

  dimension: total_secondary_rev {
    group_label: "Secondary Revenue"
    type: number
    sql: ${TABLE}."TOTAL_SECONDARY_REV" ;;
    value_format_name: usd_0
  }

  measure: total_secondary_rev_sum {
    group_label: "Secondary Revenue"
    label: "Total Secondary Revenue"
    type: sum
    sql: ${total_secondary_rev} ;;
    value_format_name: usd_0
  }

  measure: total_secondary_rev_mtd {
    group_label: "Secondary Revenue"
    type: sum
    sql:CASE WHEN ${mtd} = 1 THEN ${total_secondary_rev} ELSE NULL END;;
    value_format_name: usd_0
  }

  measure: total_secondary_rev_last_mtd {
    group_label: "Secondary Revenue"
    type: sum
    sql: CASE WHEN ${mtd_previous} = 1 THEN ${total_secondary_rev} ELSE NULL END;;
    value_format_name: usd_0
  }

  measure: mtd_change_secondary_rev_arrows {
    group_label: "Secondary Revenue"
    type: number
    sql: ${total_secondary_rev_mtd} - ${total_secondary_rev_last_mtd};;
    value_format_name:  usd_0
    html:
      {% if value > 0 %}
        <font color="#00CB86">
        <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
        <font color="#DA344D">
        <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% endif %}
       ;;
  }



  dimension: rolling_total_revenue {
    group_label: "Revenue"
    type: number
    sql: ${TABLE}."ROLLING_TOTAL_REVENUE" ;;
    value_format_name: usd_0
  }

  measure: rolling_total_revenue_sum {
    group_label: "Revenue"
    type: number
    sql: DIV0NULL(sum(${rolling_total_revenue}) , count(distinct ${date_date})) ;;
    value_format_name: usd_0
  }

  dimension: total_monthly_revenue_goal {
    group_label: "Revenue Goal"
    type: number
    sql: ${TABLE}."TOTAL_MONTHLY_REVENUE_GOAL" ;;
    value_format_name: usd_0
  }

  measure: total_monthly_revenue_goal_sum {
    group_label: "Revenue Goal"
    label: "Current Month Goal"
    type: number
    sql: coalesce(sum(${total_monthly_revenue_goal}) / count(${total_monthly_revenue_goal}),0) ;;
    html:
    {% if value == 0 %}
    <font color="#DA344D "><a href="https://equipmentshare.retool-hosted.com/apps/64df94f4-7f36-11ee-b9e5-ebd6931f6d5a/DSM%20Sales%20Rep%20Goals/DSM%20Sales%20Rep%20Goal%20Entry"target="_blank"><b>No Goal Set ➔</b>
    {% else %}
    {{ rendered_value }}
    {% endif %};;
    value_format_name: usd_0
  }

  measure: max_date {
    type: date
    sql: max(${date_date}) ;;
  }


  measure: revenue_mtd_on_track {
    group_label: "Revenue Insights"
    label: "Goal Tracking"
    type: string
    sql: case
          when ${total_monthly_revenue_goal_sum} is null OR ${total_monthly_revenue_goal_sum} = 0 then 'No Goal Exists'
          when ${mtd_total_rev} >= ${total_monthly_revenue_goal_sum} then 'Goal Achieved'
          when DAYOFMONTH(${max_date}::date) / DAYOFMONTH(LAST_DAY(${max_date}::date)) <= ${mtd_total_rev} / ${total_monthly_revenue_goal_sum}
          then 'On Track for Goal'
          else 'Not On Track for Goal'
          end ;;
    html:
    {% if value == "On Track for Goal" %}
    <font color="#00CB86 ">{{rendered_value}} ↑</font>

    {% elsif value == 'Goal Achieved' %}
    <font color="#00ad73 "><b>{{rendered_value}} ◉</b></font>

    {% elsif value == 'Not On Track for Goal' %}
    <font color="#C49102 ">{{rendered_value}} ↓</font>

    {% else %}
    <font color="#DA344D "><a href="https://equipmentshare.retool-hosted.com/apps/64df94f4-7f36-11ee-b9e5-ebd6931f6d5a/DSM%20Sales%20Rep%20Goals/DSM%20Sales%20Rep%20Goal%20Entry"target="_blank"><b>Set Goal Here ➔</b><br />
    {% endif %};;
  }

  measure: no_goal_reps {
    group_label: "Goal Insights"
    label: "Reps With No Goal"
    type: sum
    sql: case when ${total_monthly_revenue_goal} is null then 1 end;;
    value_format_name: decimal_0
    filters: [today_flag: "1"]
    drill_fields: [no_goal_set_for_rep*]
  }

  measure: remaining_to_goal {
    group_label: "Goal Graph"
    type: number
    value_format_name: usd_0
    sql: case when ${total_monthly_revenue_goal_sum} - ${total_rev_sum} < 0 then null
      else ${total_monthly_revenue_goal_sum} - ${total_rev_sum} end;;
  }

  measure: remaining_to_goal_current_mtd {
    group_label: "Goal Graph"
    label: "MTD $ Left to Goal"
    type: number
    value_format_name: usd_0
    sql: coalesce(case when ${total_monthly_revenue_goal_sum} - ${mtd_total_rev} < 0 then null
      else ${total_monthly_revenue_goal_sum} - ${mtd_total_rev} end,0);;
    html:
    {% if mtd_total_rev._value >= total_monthly_revenue_goal_sum._value and total_monthly_revenue_goal_sum._value > 0 %}
    <font color="#00ad73 "><b>✓</b></font>
    {% elsif value == 0 %}
    <font color="#DA344D "><a href="https://equipmentshare.retool-hosted.com/apps/64df94f4-7f36-11ee-b9e5-ebd6931f6d5a/DSM%20Sales%20Rep%20Goals/DSM%20Sales%20Rep%20Goal%20Entry"target="_blank"><b>No Goal Set ➔</b>
    {% else %}
    {{ rendered_value }}
    {% endif %};;

    # {% if value == "On Track for Goal" %}
    # <font color="#00CB86 ">{{rendered_value}} ↑</font>

    # {% elsif value == 'Goal Achieved' %}
    # <font color="#00ad73 "><b>{{rendered_value}} ◉</b></font>

    # {% elsif value == 'Not On Track for Goal' %}
    # <font color="#C49102 ">{{rendered_value}} ↓</font>

    # {% else %}
    # <font color="#DA344D "><a href="https://equipmentshare.retool-hosted.com/apps/64df94f4-7f36-11ee-b9e5-ebd6931f6d5a/DSM%20Sales%20Rep%20Goals/DSM%20Sales%20Rep%20Goal%20Entry"target="_blank"><b>Set Goal Here ➔</b><br />
    # {% endif %};;

  }

  measure: rental_revenue_goal_met {
    group_label: "Goal Graph"
    type: number
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when ${total_monthly_revenue_goal_sum} IS NULL then null
                 when ${total_monthly_revenue_goal_sum} - ${total_rev_sum} <= 0 then ${total_rev_sum}
                 else null end;;
  }

  measure: rental_revenue_goal_unmet {
    group_label: "Goal Graph"
    type: number
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql:  case when ${total_monthly_revenue_goal_sum} IS NULL then null
                 when  ${total_monthly_revenue_goal_sum} - ${total_rev_sum} > 0 then ${total_rev_sum}
                 else null end;;
  }

  measure: rental_revenue_no_goal {
    group_label: "Goal Graph"
    type: number
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: case when ${total_monthly_revenue_goal_sum} IS NULL then ${total_rev_sum}
      else null end ;;
  }

  dimension: in_market_monthly_revenue_goal {
    group_label: "Revenue Goal"
    type: number
    sql: ${TABLE}."IN_MARKET_MONTHLY_REVENUE_GOAL" ;;
    value_format: "$#,##0"
  }

  measure: in_market_monthly_revenue_goal_sum {
    group_label: "Revenue Goal"
    type: sum
    sql: ${in_market_monthly_revenue_goal} ;;
    value_format: "$#,##0"
  }

  dimension: out_market_monthly_revenue_goal {
    group_label: "Revenue Goal"
    type: number
    sql: ${TABLE}."OUT_MARKET_MONTHLY_REVENUE_GOAL" ;;
    value_format: "$#,##0"
  }

  measure: out_market_monthly_revenue_goal_sum {
    group_label: "Revenue Goal"
    type: sum
    sql: ${out_market_monthly_revenue_goal} ;;
    value_format: "$#,##0"
  }

  dimension_group: date_goal_created {
    type: time
    sql: ${TABLE}."DATE_GOAL_CREATED" ;;
  }

  dimension: today_flag {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."TODAY_FLAG" ;;
  }

  dimension: past_7_day {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_7_DAY" ;;
  }

  dimension: past_7_day_previous {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_7_DAY_PREVIOUS" ;;
  }

  dimension: past_30_day {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_30_DAY" ;;
  }

  dimension: past_30_day_previous {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_30_DAY_PREVIOUS" ;;
  }



  dimension: past_90_day {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_90_DAY" ;;
  }

  dimension: past_90_day_previous {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_90_DAY_PREVIOUS" ;;
  }

  dimension: past_180_day {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_180_DAY" ;;
  }

  dimension: past_180_day_previous {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_180_DAY_PREVIOUS" ;;
  }

  dimension: past_365_day {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_365_DAY" ;;
  }

  dimension: past_365_day_previous {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PAST_365_DAY_PREVIOUS" ;;
  }

  dimension: wtd {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."WTD" ;;
  }

  dimension: wtd_previous {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."WTD_PREVIOUS" ;;
  }

  dimension: mtd {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."MTD" ;;
  }

  dimension: mtd_previous {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."MTD_PREVIOUS" ;;
  }

  dimension: mtd_current_and_previous {
    group_label: "Time Period Flags"
    type: string
    sql:
    CASE
      WHEN ${mtd} = 1 THEN 'Current Month'
      WHEN ${mtd_previous} = 1 THEN 'Prior Month'
      ELSE 'Other'
    END
  ;;
  }

  dimension: in_out_rev_current_month {

  }


  dimension: previous_full_month_flag {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."PREVIOUS_FULL_MONTH_FLAG" ;;
  }

  dimension: ytd {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."YTD" ;;
  }

  dimension: ytd_previous {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."YTD_PREVIOUS" ;;
  }

  dimension: one_row_per_month_per_rep_flag {
    type: number
    sql: ${TABLE}."ONE_ROW_PER_MONTH_PER_REP_FLAG" ;;
  }

  dimension: one_row_per_date_per_rep_flag {
    type: number
    sql: ${TABLE}."ONE_ROW_PER_DATE_PER_REP_FLAG" ;;
  }

  dimension: sp_full_name {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SP_FULL_NAME" ;;
  }

  dimension: sp_email {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."TAM_EMAIL" ;;
  }

  dimension: direct_manager {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."MANAGER_NAME_PRESENT" ;;
  }

  dimension: direct_manager_user_id {
    group_label: "Sales Person Info"
    type: number
    sql: ${TABLE}."DIRECT_MANAGER_USER_ID" ;;
  }

  dimension: direct_manager_email {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_EMAIL" ;;
  }

  dimension: new_sp_flag {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."NEW_SP_FLAG" ;;
  }

  dimension_group: first_date_as_TAM {
    group_label: "Sales Person Info"
    type: time
    sql: ${TABLE}."FIRST_DATE_AS_TAM" ;;
  }

  dimension: new_sp_flag_current {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."NEW_SP_FLAG_CURRENT" ;;
  }

  dimension: market_name {
    group_label: "Market Info"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    group_label: "Market Info"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region_name {
    group_label: "Market Info"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  filter: date_period {
    type:  string
  }

  dimension: selected_period_flag {
    type: string
    sql:  CASE
    WHEN {% parameter date_period %} = 'Past 7 Days' THEN ${past_7_day}
    WHEN {% parameter date_period %} = 'Past 30 Days' THEN ${past_30_day}
    WHEN {% parameter date_period %} = 'MTD' THEN ${mtd}
    end ;;
  }

  dimension: selected_previous_period_flag {
    type: string
    sql: CASE
    WHEN {% parameter date_period %} = 'Past 7 Days' THEN ${past_7_day_previous}
    WHEN {% parameter date_period %} = 'Past 30 Days' THEN ${past_30_day_previous}
    WHEN {% parameter date_period %} = 'MTD' THEN ${mtd_previous}
    end  ;;
  }

  measure: selected_oec_on_rent {
    group_label: "Timeframes"
    type: average
    sql: case when ${selected_period_flag} = 1 then ${oec_on_rent} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: selected_previous_oec_on_rent {
    group_label: "Timeframes Previous"
    type: average
    sql: case when ${selected_previous_period_flag} = 1 then ${oec_on_rent} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: selected_change_oec_on_rent {
    group_label: "Timeframes Change"
    type: number
    sql: DIV0NULL(${selected_oec_on_rent} - ${selected_previous_oec_on_rent}, ${selected_previous_oec_on_rent});;
    value_format: "0.00\%"
  }
#################################################################################################################################
  measure: selected_total_rev {
    group_label: "Timeframes"
    type: sum
    sql: case when ${selected_period_flag} = 1 then ${total_rev} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: selected_previous_total_rev {
    group_label: "Timeframes Previous"
    type: sum
    sql: case when ${selected_previous_period_flag} = 1 then ${total_rev} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: selected_change_total_rev {
    group_label: "Timeframes Change"
    type: number
    sql: DIV0NULL(${selected_total_rev} - ${selected_previous_total_rev}, ${selected_previous_total_rev}) * 100;;
    value_format: "0.00\%"
  }

  measure: past_7_day_total_rev {
    group_label: "Fixed Timeframes"
    type: sum
    sql: case when ${past_7_day} = 1 then ${total_rev} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: past_7_day_previous_total_rev {
    group_label: "Fixed Timeframes Previous"
    type: sum
    sql: case when ${past_7_day_previous} = 1 then ${total_rev} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: past_7_day_change_total_rev {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: DIV0NULL(${past_7_day_total_rev} - ${past_7_day_previous_total_rev}, ${past_7_day_previous_total_rev}) * 100;;
    value_format: "0.00\%"
  }

  measure: past_30_day_total_rev {
    group_label: "Fixed Timeframes"
    type: sum
    sql: case when ${past_30_day} = 1 then ${total_rev} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: past_30_day_previous_total_rev {
    group_label: "Fixed Timeframes Previous"
    type: sum
    sql: case when ${past_30_day_previous} = 1 then ${total_rev} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: past_30_day_change_total_rev {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: DIV0NULL(${past_30_day_total_rev} - ${past_30_day_previous_total_rev}, ${past_30_day_previous_total_rev}) * 100;;
    value_format: "0.00\%"
  }

  measure: mtd_total_rev {
    group_label: "Fixed Timeframes"
    label: "MTD Rental Revenue"
    type: sum
    # sql: case when ${mtd} = 1 then ${total_rev} else 0 end ;;
    sql: ZEROIFNULL(${total_rev}) ;;
    value_format_name:  usd_0
    filters: [mtd: "1"]
  }

  measure: mtd_prior_total_rev {
    group_label: "Fixed Timeframes"
    label: "Prior MTD Rental Revenue"
    type: sum
    # sql: case when ${mtd} = 1 then ${total_rev} else 0 end ;;
    sql: ZEROIFNULL(${total_rev}) ;;
    value_format_name:  usd_0
    filters: [mtd_previous: "1"]
  }

  measure: mtd_total_rev2 {
    group_label: "Fixed Timeframes"
    label: "MTD Total Revenue"
    type: sum
    drill_fields: [rep_company_drill*]
    sql: case when ${mtd} = 1 then ${total_rev} else 0 end ;;
    value_format_name:  usd_0
  }

  measure: prior_month_rental_revenue {
    group_label: "Fixed Timeframes"
    label: "Prior Month Rental Revenue"
    type: max
    # sql: case when ${mtd} = 1 then ${total_rev} else 0 end ;;
    sql: ZEROIFNULL(${rolling_total_revenue}) ;;
    value_format_name:  usd_0
    filters: [previous_full_month_flag: "1"]
    html:
  {% if value < 125000 %}
  <font color="#DA344D">◉</font> {{rendered_value}}
  {% else %}
  {{rendered_value}}
  {% endif %} ;;
  }

  measure: under_prior_month_threshold_flag {
    group_label: "Revenue Threshold"
    type: yesno
    sql: IFF(${prior_month_rental_revenue} <= 125000,TRUE,FALSE) ;;
  }

  measure: reps_under_revenue_threshold {
    group_label: "Revenue Threshold"
    type: count_distinct
    sql: ${salesperson_user_id} ;;
    drill_fields: [revenue_under_125K*]
  }


  measure: past_mtd_day_previous_total_rev {
    group_label: "Fixed Timeframes Previous"
    label: "Last MTD Rental Revenue"
    type: sum
    sql: case when ${mtd_previous} = 1 then ${total_rev} else 0 end ;;
    value_format_name:  usd_0
  }


  measure: mtd_change_total_rev {
    group_label: "Fixed Timeframes Change"
    label: "MTD Change %"
    type: number
    sql: CASE WHEN  ${past_mtd_day_previous_total_rev} = 0 AND ${mtd_total_rev} = 0 THEN 0
              WHEN  ${past_mtd_day_previous_total_rev} = 0 AND ${mtd_total_rev} > 0 THEN 1
              WHEN  ${past_mtd_day_previous_total_rev} = 0 AND ${mtd_total_rev} < 0 THEN -1
              ELSE DIV0NULL(${mtd_total_rev} - ${past_mtd_day_previous_total_rev}, ${past_mtd_day_previous_total_rev}) END;;
    value_format_name: percent_1
  }

  measure: mtd_change_total_rev_total {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: ${mtd_total_rev} - ${past_mtd_day_previous_total_rev};;
    value_format_name:  usd_0
  }

  measure: mtd_change_total_rev_total_arrows {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: ${mtd_total_rev} - ${past_mtd_day_previous_total_rev};;
    value_format_name:  usd_0
    html:
  {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
{% elsif value == 0 %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
{% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
{% else %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
{% endif %}
   ;;
  }

  measure: mtd_rolling_rev_fitler {
    group_label: "Fixed Timeframes"
    type: number
    sql: case when ${mtd} = 1 then ${rolling_total_revenue} else null end ;;
    value_format_name:  usd_0
  }

  measure: mtd_rolling_rev {
    group_label: "Fixed Timeframes"
    type: number
    sql: sum(${mtd_rolling_rev_fitler}) / sum(${mtd}) ;;
    value_format_name:  usd_0
  }

  measure: mtd_rolling_rental_revenue {
    group_label: "Fixed Timeframes"
    type: sum
    sql: ${rolling_total_revenue} ;;
    value_format_name: usd_0
    filters: [mtd: "1"]
  }

  measure: mtd_previous_day_rolling_rental_revenue {
    group_label: "Fixed Timeframes"
    type: sum
    sql: ${rolling_total_revenue} ;;
    value_format_name: usd_0
    filters: [previous_day: "Yes", mtd: "1"]
  }

  measure: mtd_current_day_rolling_rental_revenue_filter {
    group_label: "Fixed Timeframes"
    type: number
    sql: case when ${today_flag} = 1 then ${rolling_total_revenue} else null end ;;
    value_format: "$#,##0"
  }

  measure: mtd_current_day_rolling_rental_revenue {
    group_label: "Fixed Timeframes"
    type: number
    sql: DIV0NULL(sum(${mtd_current_day_rolling_rental_revenue_filter}) , sum( ${today_flag}));;
    value_format: "$#,##0"
  }

  dimension: bulk_parts_on_rent {
    type: number
    sql: ${TABLE}."BULK_PARTS_ON_RENT" ;;
  }

  measure: bulk_parts_on_rent_sum {
    label: "Bulk Parts On Rent"
    type: sum
    sql:  ${bulk_parts_on_rent} ;;
  }

  measure: current_bulk_parts_on_rent {
    group_label: "Bulk"
    label: "Bulk Quantity On Rent"
    type: sum
    sql: ${bulk_parts_on_rent} ;;
    value_format_name: decimal_0
    filters: [today_flag: "1"]
  }

  measure: current_bulk_parts_on_rent_with_null_days {
    group_label: "Bulk With Past Days Null"
    label: "Bulk Quantity On Rent"
    type: number
    sql: case when ${current_bulk_parts_on_rent} = 0 then null else ${current_bulk_parts_on_rent} end ;;
    value_format_name: decimal_0
  }

  measure: last_90_bulk_parts_on_rent {
    group_label: "Rep Rental History"
    label: "Bulk Quantity On Rent"
    type: sum
    sql: ${bulk_parts_on_rent} ;;
    value_format_name: decimal_0
    filters: [days_flag: "YES"]
  }

  measure: last_mtd_bulk_parts_on_rent {
    group_label: "Bulk"
    label: "Last MTD Bulk Quantity On Rent"
    type: sum
    sql: ${bulk_parts_on_rent} ;;
    value_format_name: decimal_0
    filters: [prior_month_day: "Yes"]
  }

  measure: bulk_parts_on_rent_change {
    group_label: "Bulk"
    label: "MTD vs Last MTD Bulk Quantity On Rent"
    type: number
    sql: ${current_bulk_parts_on_rent} - ${last_mtd_bulk_parts_on_rent} ;;
    value_format_name: decimal_0
  }

  measure: mtd_bulk_parts_percent_change {
    group_label: "Bulk"
    type: number
    sql: CASE WHEN ${last_mtd_bulk_parts_on_rent} = 0 AND ${current_bulk_parts_on_rent} = 0 THEN 0
          WHEN ${last_mtd_bulk_parts_on_rent} = 0 THEN 1
          ELSE ((${current_bulk_parts_on_rent} - ${last_mtd_bulk_parts_on_rent})/ NULLIFZERO(${last_mtd_bulk_parts_on_rent})) END ;;
    value_format_name: percent_1
  }

  dimension: bulk_cost_on_rent {
    type: number
    sql: ${TABLE}."BULK_COST_ON_RENT" ;;
  }

  measure: bulk_cost_on_rent_sum {
    label: "Bulk Cost On Rent"
    type: sum
    sql:  ${bulk_cost_on_rent} ;;
  }

  measure: current_bulk_cost_on_rent {
    group_label: "Bulk"
    label: "Bulk Cost On Rent"
    type: sum
    sql: ${bulk_cost_on_rent} ;;
    value_format_name: usd_0
    filters: [today_flag: "1"]
  }

  measure: current_bulk_cost_on_rent_with_null_days {
    group_label: "Bulk With Past Days Null"
    label: "Bulk Cost On Rent"
    type: number
    sql: case when ${current_bulk_cost_on_rent} = 0 then null else ${current_bulk_cost_on_rent} end ;;
    value_format_name: usd_0
  }

  measure: last_90_bulk_cost_on_rent {
    group_label: "Rep Rental History"
    label: "Bulk Cost On Rent"
    type: sum
    sql: ${bulk_cost_on_rent} ;;
    value_format_name: usd_0
    filters: [days_flag: "YES"]
  }

  measure: last_mtd_bulk_cost_on_rent {
    group_label: "Bulk"
    label: "Last MTD Bulk Cost On Rent"
    type: sum
    sql: ${bulk_cost_on_rent} ;;
    value_format_name: usd_0
    filters: [prior_month_day: "Yes"]
  }

  measure: bulk_cost_on_rent_change {
    group_label: "Bulk"
    label: "MTD vs Last MTD Bulk Cost On Rent"
    type: number
    sql: ${current_bulk_cost_on_rent} - ${last_mtd_bulk_cost_on_rent} ;;
    value_format_name: usd_0
  }

  measure: mtd_bulk_cost_percent_change {
    group_label: "Bulk"
    type: number
    sql: CASE WHEN ${last_mtd_bulk_cost_on_rent} = 0 AND ${current_bulk_cost_on_rent} = 0 THEN 0
              WHEN ${last_mtd_bulk_cost_on_rent} = 0 AND ${current_bulk_cost_on_rent} > 0 THEN 1
              WHEN ${last_mtd_bulk_cost_on_rent} = 0 AND ${current_bulk_cost_on_rent} < 0 THEN -1
              ELSE ((${current_bulk_cost_on_rent} - ${last_mtd_bulk_cost_on_rent})/ NULLIFZERO(${last_mtd_bulk_cost_on_rent}))  END;;
    value_format_name: percent_1
  }

  dimension: previous_day {
    type: yesno
    sql: dateadd('day',-1,CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE) = ${date_date} ;;
  }

  measure: mtd_rolling_rental_revenue_by_day {
    group_label: "Fixed Timeframes"
    type: number
    sql: case when ${mtd_rolling_rev} = 0 then null
    when  ${mtd_rolling_rev} <> 0 then ${mtd_rolling_rev}
    else null end ;;
    value_format_name: usd_0
  }

  measure: current_day_mtd_rolling_rev {
    group_label: "Fixed Timeframes"
    type: number
    sql: case when ${mtd_current_day_rolling_rental_revenue} = 0 then null
          when  ${mtd_current_day_rolling_rental_revenue} <> 0 then ${mtd_current_day_rolling_rental_revenue}
          else null end ;;
    value_format_name: usd_0
  }

  measure: previous_day_mtd_rolling_rev {
    group_label: "Fixed Timeframes"
    type: number
    sql: case when ${mtd_previous_day_rolling_rental_revenue} = 0 then null
    when  ${mtd_previous_day_rolling_rental_revenue} <> 0 then ${mtd_previous_day_rolling_rental_revenue}
    else null end ;;
    value_format_name: usd_0
  }

  measure: previous_month_rolling_rev_filter {
    group_label: "Fixed Timeframes"
    type: number
    sql: case when ${previous_full_month_flag} = 1 then ${rolling_total_revenue} else null end ;;
    value_format_name: usd_0
  }

  measure: previous_month_rolling_rev {
    group_label: "Fixed Timeframes"
    type: number
    sql: DIV0NULL(sum(${previous_month_rolling_rev_filter}) , sum( ${previous_full_month_flag}));;
    value_format_name: usd_0
  }

  measure: ytd_total_rev {
    group_label: "Fixed Timeframes"
    type: sum
    sql: case when ${ytd} = 1 then ${total_rev} else 0 end ;;
    value_format_name: usd_0
  }

  measure: past_ytd_day_previous_total_rev {
    group_label: "Fixed Timeframes Previous"
    type: sum
    sql: case when ${ytd_previous} = 1 then ${total_rev} else 0 end ;;
    value_format_name: usd_0
  }

  measure: ytd_change_total_rev {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: DIV0NULL(${ytd_total_rev} - ${past_ytd_day_previous_total_rev}, ${past_ytd_day_previous_total_rev}) * 100;;
    value_format_name: percent_1
  }

  measure: total_rental_revenue {
    group_label: "Rep Rental History"
    label: "Rental Revenue"
    type: sum
    sql: ${total_rev} ;;
    value_format_name: usd_0
  }

  #################################################################################################################################

  measure: selected_aor {
    group_label: "Timeframes"
    type: average
    sql: case when ${selected_period_flag} = 1 then ${assets_on_rent} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: selected_previous_aor {
    group_label: "Timeframes Previous"
    type: average
    sql: case when ${selected_previous_period_flag} = 1 then ${assets_on_rent} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: selected_change_aor {
    group_label: "Timeframes Change"
    type: number
    sql: DIV0NULL(${selected_aor} - ${selected_previous_aor}, ${selected_previous_aor}) * 100;;
    value_format: "0.00\%"
  }

  measure: past_7_day_aor {
    group_label: "Fixed Timeframes"
    type: average
    sql: case when ${past_7_day} = 1 then ${assets_on_rent} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: past_7_day_previous_aor {
    group_label: "Fixed Timeframes Previous"
    type: average
    sql: case when ${past_7_day_previous} = 1 then ${assets_on_rent} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: past_7_day_change_aor {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: DIV0NULL(${past_7_day_aor} - ${past_7_day_previous_aor}, ${past_7_day_previous_aor}) * 100;;
    value_format: "0.00\%"
  }

  measure: past_30_day_aor {
    group_label: "Fixed Timeframes"
    type: average
    sql: case when ${past_30_day} = 1 then ${assets_on_rent} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: past_30_day_previous_aor {
    group_label: "Fixed Timeframes Previous"
    type: average
    sql: case when ${past_30_day_previous} = 1 then ${assets_on_rent} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: past_30_day_change_aor {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: DIV0NULL(${past_30_day_aor} - ${past_30_day_previous_aor}, ${past_30_day_previous_aor}) * 100;;
    value_format: "0.00\%"
  }

  measure: mtd_aor {
    group_label: "Fixed Timeframes"
    type: average
    sql: case when ${mtd} = 1 then ${assets_on_rent} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: past_mtd_day_previous_aor {
    group_label: "Fixed Timeframes Previous"
    type: average
    sql: case when ${mtd_previous} = 1 then ${assets_on_rent} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: mtd_change_aor {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: DIV0NULL(${mtd_aor} - ${past_mtd_day_previous_aor}, ${past_mtd_day_previous_aor}) * 100;;
    value_format: "0.00\%"
  }

  measure: ytd_aor {
    group_label: "Fixed Timeframes"
    type: average
    sql: case when ${ytd} = 1 then ${assets_on_rent} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: past_ytd_day_previous_aor {
    group_label: "Fixed Timeframes Previous"
    type: average
    sql: case when ${ytd_previous} = 1 then ${assets_on_rent} else 0 end ;;
    value_format: "$#,##0"
  }

  measure: ytd_change_aor {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: DIV0NULL(${ytd_aor} - ${past_ytd_day_previous_aor}, ${past_ytd_day_previous_aor}) * 100;;
    value_format: "0.00\%"
  }

  #################################################################################################################################

# Change the grouping on measures to be sttat focues first then label them by period

# OEC

  #################################################################################################################################

# Renting Customers

  #################################################################################################################################

  measure: title_card {
    group_label: "Title Card"
    label: " "
    type: sum
    sql: ${total_rev} ;;
    html: <td colspan="1" style="font-size: 40px;">{{sp_full_name._rendered_value }} - {{ salesperson_user_id._rendered_value}}</td> ;;
  }

  measure: mtd_day_card {
    group_label: "Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: sum
    sql: ${assets_on_rent} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD Rental Revenue</td>
  </tr>


  {% if mtd_change_total_rev._value >= 0 %}
   <tr style="background-color: #c1ecd4;">
    {% else %}
     <tr style="background-color: #ffcfcf;">
    {% endif %}


    <td colspan="3" style="text-align: left;">
    {% if mtd_change_total_rev._value >= 0 %}
    <font style="color: #00ad73"><h4>◉ Ahead of Last Month</h4></font>
    {% else %}
    <font style="color: #DA344D"><h4>◉ Behind Last Month</h4></font>
    {% endif %}
    </td>
  </tr>
  <tr>
    <td colspan="3"><font style="color: #C0C0C0"><br /></font></td>
  </tr>

    <tr>
    <td>MTD Rental Revenue: </td>
    <td>
    {% if mtd_change_total_rev._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank">{{ mtd_total_rev._rendered_value }}</a>
      {% if mtd_change_total_rev._value == 0 %}
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"></a>
      {% endif %}
      </td>
      </tr>

      <tr>
      <td>Last MTD Rental Revenue: </td>
      <td>

      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank">{{ past_mtd_day_previous_total_rev._rendered_value }}</a>
      </td>
      </tr>


      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <tr>
      <td> </td>
      <td>
      {% if mtd_change_total_rev._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if mtd_change_total_rev._value >= 0 %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"><font style="color: #00CB86; font-weight: bold;">{{ mtd_change_total_rev_total_arrows._rendered_value }} </font><font size="2px;">({{ mtd_change_total_rev._rendered_value }})</font></a>
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"><font style="color: #DA344D; font-weight: bold;">{{ mtd_change_total_rev_total_arrows._rendered_value }} </font><font size="2px;">({{ mtd_change_total_rev._rendered_value }})</font></a>
      {% endif %}
      </td>
      </tr>

      </table> ;;
  }



  measure: mtd_aor_day_card {
    group_label: "Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: number
    sql: ${assets_on_rent_change} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD Assets On Rent</td>
  </tr>


      {% if mtd_oec_change._value >= 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if assets_on_rent_change._value >= 0 %}
      <font style="color: #00ad73"><h4>◉ Ahead of Last Month</h4></font>
      {% else %}
      <font style="color: #DA344D"><h4>◉ Behind Last Month</h4></font>
      {% endif %}
      </td>
      </tr>
      <tr>
      <td colspan="3"><font style="color: #C0C0C0"><br /></font></td>
      </tr>

      <tr>
      <td>Current Assets On Rent: </td>
      <td>
      {% if assets_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1405?Market+Name={{ current_assets_on_rent._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank">{{ current_assets_on_rent._rendered_value }}</a>
      {% if assets_on_rent_change._value == 0 %}
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1405?Market+Name={{ current_assets_on_rent._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank"></a>
      {% endif %}
      </td>
      </tr>

      <tr>
      <td>Last MTD Assets On Rent: </td>
      <td>

      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{ lmtd_assets_on_rent_avg._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank">{{ lmtd_assets_on_rent_avg._rendered_value }}</a>
      </td>
      </tr>


      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <tr>
      <td> </td>
      <td>
      {% if assets_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if assets_on_rent_change._value >= 0 %}
      <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{ assets_on_rent_change._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank"><font style="color: #00CB86; font-weight: bold;">{{ assets_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_assets_on_rent_percent_change._rendered_value }})</font></a>
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{ assets_on_rent_change._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank"><font style="color: #DA344D; font-weight: bold;">{{ assets_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_assets_on_rent_percent_change._rendered_value }})</font></a>
      {% endif %}
      </td>
      </tr>

      </table> ;;
  }

  measure: mtd_oec_day_card {
    group_label: "Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: number
    sql: ${current_oec_on_rent} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD OEC On Rent</td>
  </tr>


      {% if oec_on_rent_change._value >= 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if oec_on_rent_change._value >= 0 %}
      <font style="color: #00ad73"><h4>◉ Ahead of Last Month</h4></font>
      {% else %}
      <font style="color: #DA344D"><h4>◉ Behind Last Month</h4></font>
      {% endif %}
      </td>
      </tr>
      <tr>
      <td colspan="3"><font style="color: #C0C0C0"><br /></font></td>
      </tr>

      <tr>
      <td>OEC On Rent: </td>
      <td>
      {% if oec_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {{ current_oec_on_rent._rendered_value }}</a>
      {% if oec_on_rent_change._value == 0 %}
      {% else %}
      {% endif %}
      </td>
      </tr>

      <tr>
      <td>Last MTD OEC On Rent: </td>
      <td>

      </td>
      <td>
   {{ last_mtd_oec_on_rent._rendered_value }}
      </td>
      </tr>


      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <tr>
      <td> </td>
      <td>
      {% if oec_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if oec_on_rent_change._value >= 0 %}
     <font style="color: #00CB86; font-weight: bold;">{{ oec_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_oec_percent_change._rendered_value }})</font></a>
      {% else %}
      <font size="2px;">({{ mtd_oec_percent_change._rendered_value }})</font></a>
      {% endif %}
      </td>
      </tr>

      </table> ;;
  }

  measure: mtd_bulk_parts_day_card {
    group_label: "Bulk Parts Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: number
    sql: ${current_bulk_parts_on_rent} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD Bulk Quantity On Rent</td>
  </tr>


      {% if bulk_parts_on_rent_change._value >= 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if bulk_parts_on_rent_change._value >= 0 %}
      <font style="color: #00ad73"><h4>◉ Ahead of Last Month</h4></font>
      {% else %}
      <font style="color: #DA344D"><h4>◉ Behind Last Month</h4></font>
      {% endif %}
      </td>
      </tr>
      <tr>
      <td colspan="3"><font style="color: #C0C0C0"><br /></font></td>
      </tr>

      <tr>
      <td>Bulk Quantity On Rent: </td>
      <td>
      {% if bulk_parts_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1405?Market+Name={{ current_oec_on_rent._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank">{{ current_bulk_parts_on_rent._rendered_value }}</a>
      {% if bulk_parts_on_rent_change._value == 0 %}
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1405?Market+Name={{ current_oec_on_rent._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank"></a>
      {% endif %}
      </td>
      </tr>

      <tr>
      <td>Last MTD Bulk Quantity On Rent: </td>
      <td>

      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{ last_mtd_oec_on_rent._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank">{{ last_mtd_bulk_parts_on_rent._rendered_value }}</a>
      </td>
      </tr>


      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <tr>
      <td> </td>
      <td>
      {% if bulk_parts_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if bulk_parts_on_rent_change._value >= 0 %}
      <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{ bulk_parts_on_rent_change._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank"><font style="color: #00CB86; font-weight: bold;">{{ bulk_parts_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_bulk_parts_percent_change._rendered_value }})</font></a>
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{ bulk_parts_on_rent_change._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank"><font style="color: #DA344D; font-weight: bold;">{{ bulk_parts_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_bulk_parts_percent_change._rendered_value }})</font></a>
      {% endif %}
      </td>
      </tr>

      </table> ;;
  }

  measure: mtd_bulk_cost_day_card {
    group_label: "Bulk Cost Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: number
    sql: ${current_bulk_cost_on_rent} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD Bulk Cost On Rent</td>
  </tr>


      {% if bulk_cost_on_rent_change._value >= 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if bulk_cost_on_rent_change._value >= 0 %}
      <font style="color: #00ad73"><h4>◉ Ahead of Last Month</h4></font>
      {% else %}
      <font style="color: #DA344D"><h4>◉ Behind Last Month</h4></font>
      {% endif %}
      </td>
      </tr>
      <tr>
      <td colspan="3"><font style="color: #C0C0C0"><br /></font></td>
      </tr>

      <tr>
      <td>Bulk Cost On Rent: </td>
      <td>
      {% if bulk_cost_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1405?Market+Name={{ current_oec_on_rent._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank">{{ current_bulk_cost_on_rent._rendered_value }}</a>
      {% if bulk_cost_on_rent_change._value == 0 %}
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1405?Market+Name={{ current_oec_on_rent._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank"></a>
      {% endif %}
      </td>
      </tr>

      <tr>
      <td>Last MTD Bulk Cost On Rent: </td>
      <td>

      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{ last_mtd_oec_on_rent._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank">{{ last_mtd_bulk_cost_on_rent._rendered_value }}</a>
      </td>
      </tr>


      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <tr>
      <td> </td>
      <td>
      {% if bulk_cost_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if bulk_cost_on_rent_change._value >= 0 %}
      <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{ bulk_cost_on_rent_change._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank"><font style="color: #00CB86; font-weight: bold;">{{ bulk_cost_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_bulk_parts_percent_change._rendered_value }})</font></a>
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{ bulk_cost_on_rent_change._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank"><font style="color: #DA344D; font-weight: bold;">{{ bulk_cost_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_bulk_parts_percent_change._rendered_value }})</font></a>
      {% endif %}
      </td>
      </tr>

      </table> ;;
  }

  measure: max_aor_oec_bulk_card {
    group_label: "Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: number
    sql: ${max_assets_on_rent_max} ;;
    html:

       <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">Largest Results in Past 90 Days</td>
  </tr>


      {% if max_assets_on_rent._value > 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if max_assets_on_rent._value >  0 %}
      <font style="color: #00ad73"><h4></h4></font>
      {% else %}
      <font style="color: #DA344D"><h4></h4></font>
      {% endif %}
      </td>
      </tr>
      <tr>
      <td colspan="3"><font style="color: #C0C0C0"><br /></font></td>
      </tr>


      <tr>
      <td>Max Assets On Rent: </td>
      <td>

     </td>
      <td>
      <a target="_blank">{{ max_assets_on_rent_max._rendered_value }}</a>
      </td>
      </tr>

      <tr>
      <td>Max OEC On Rent: </td>
      <td>

      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{  max_oec_on_rent_max._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank">{{ max_oec_on_rent_max._rendered_value }}</a>
      </td>
      </tr>

      <tr>
      <td>Max Bulk Parts On Rent: </td>
      <td>

      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{  max_bulk_parts_on_rent_max._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank">{{ max_bulk_parts_on_rent_max._rendered_value }}</a>
      </td>
      </tr>

      <tr>
      <td>Max Bulk Cost On Rent: </td>
      <td>

      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{ max_bulk_cost_on_rent_max._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank">{{ max_bulk_cost_on_rent_max._rendered_value }}</a>
      </td>
      </tr>


      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>


      </table> ;;
  }

  dimension: salesperson {
    group_label: "Sales Person Info"
    label: "Rep"
    type: string
    sql: ${sp_full_name} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/1409?Rep={{salesperson_filter_values._filterable_value}}"target="_blank">
    {{rendered_value}} ➔</a>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Home: {{current_home_market._rendered_value }} </font>
    ;;
  }




  dimension: home_market {
    group_label: "Sales Person Info"
    label: "Home Market"
    type: string
    sql: IFF(${home_market_id} = ${market_id},${market_name},'Unknown') ;;
  }

  dimension: salesperson_filter_values {
    group_label: "Sales Person Info"
    label: "Rep - Home Market"
    type: string
    sql: concat(${sp_full_name},' - ',${current_home_market});;
  }

  measure: assets_on_rent_card {
    group_label: "Assets Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: number
    sql: ${current_assets_on_rent} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD Assets On Rent</td>
  </tr>


      {% if assets_on_rent_change._value >= 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if assets_on_rent_change._value >= 0 %}
      <font style="color: #00ad73"><h4>◉ Ahead of Last Month</h4></font>
      {% else %}
      <font style="color: #DA344D"><h4>◉ Behind Last Month</h4></font>
      {% endif %}
      </td>
      </tr>
      <tr>
      <td colspan="3"><font style="color: #C0C0C0"><br /></font></td>
      </tr>

      <tr>
      <td>Assets On Rent: </td>
      <td>
      {% if assets_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank">{{ current_assets_on_rent._rendered_value }}</a>
      {% if assets_on_rent_change._value == 0 %}
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"></a>
      {% endif %}
      </td>
      </tr>

      <tr>
      <td>Last MTD Assets On Rent: </td>
      <td>

      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank">{{ last_mtd_assets_on_rent._rendered_value }}</a>
      </td>
      </tr>


      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <tr>
      <td> </td>
      <td>
      {% if assets_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if assets_on_rent_change._value >= 0 %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"><font style="color: #00CB86; font-weight: bold;">{{ assets_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_aor_percent_change._rendered_value }})</font></a>
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"><font style="color: #DA344D; font-weight: bold;">{{ assets_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_aor_percent_change._rendered_value }})</font></a>
      {% endif %}
      </td>
      </tr>

      </table> ;;
  }

  measure: actively_renting_customers_card {
    group_label: "Actively Renting Customer Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: number
    sql: ${current_actively_renting_customers} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD Actively Renting Customers</td>
  </tr>


      {% if actively_renting_customers_change._value >= 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if actively_renting_customers_change._value >= 0 %}
      <font style="color: #00ad73"><h4>◉ Ahead of Last Month</h4></font>
      {% else %}
      <font style="color: #DA344D"><h4>◉ Behind Last Month</h4></font>
      {% endif %}
      </td>
      </tr>
      <tr>
      <td colspan="3"><font style="color: #C0C0C0"><br /></font></td>
      </tr>

      <tr>
      <td>Actively Renting Customers: </td>
      <td>
      {% if actively_renting_customers_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank">{{ current_actively_renting_customers._rendered_value }}</a>
      {% if actively_renting_customers_change._value == 0 %}
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"></a>
      {% endif %}
      </td>
      </tr>

      <tr>
      <td>Last MTD Actively Renting Customers: </td>
      <td>

      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank">{{ last_mtd_actively_renting_customers._rendered_value }}</a>
      </td>
      </tr>


      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <tr>
      <td> </td>
      <td>
      {% if actively_renting_customers_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if actively_renting_customers_change._value >= 0 %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"><font style="color: #00CB86; font-weight: bold;">{{ actively_renting_customers_change._rendered_value }} </font><font size="2px;">({{ mtd_actively_renting_customers_percent_change._rendered_value }})</font></a>
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"><font style="color: #DA344D; font-weight: bold;">{{ actively_renting_customers_change._rendered_value }} </font><font size="2px;">({{ mtd_actively_renting_customers_percent_change._rendered_value }})</font></a>
      {% endif %}
      </td>
      </tr>

      </table> ;;
  }

  measure: total_employees {
    label: "Total Reps"
    type: count_distinct
    sql: ${salesperson_user_id}  ;;
    filters: [mtd: "1"]
    drill_fields: [general_info*]
  }


  dimension: employee_title_dated {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE_DATED" ;;
  }

  dimension: employee_status_present {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS_PRESENT" ;;
  }

  parameter: days_timeframe {
    type: string
    default_value: "90"
    allowed_value: {
      label: "7 Days"
      value: "7"
      }
    allowed_value: {
      label: "30 Days"
      value: "30"
      }
    allowed_value: {
      label: "90 Days"
      value: "90"
      }
    allowed_value: {
      label: "180 Days"
      value: "180"}
    allowed_value: {
      label: "365 Days"
      value: "365"
      }
  }

  dimension: days_flag  {
    type: yesno
    sql:
    case
    when {{ days_timeframe._parameter_value }} = 7 then ${past_7_day} = 1
    when {{ days_timeframe._parameter_value }} = 30 then ${past_30_day} = 1
    when {{ days_timeframe._parameter_value }} = 90 then ${past_90_day} = 1
    when {{ days_timeframe._parameter_value }} = 180 then ${past_180_day} = 1
    when {{ days_timeframe._parameter_value }} = 365 then ${past_365_day} = 1
    end
    ;;
  }

  set: revenue_under_125K {
    fields: [
      salesperson,
      prior_month_rental_revenue,
      mtd_total_rev,
      past_mtd_day_previous_total_rev,
      mtd_change_total_rev_total_arrows,
      current_assets_on_rent,
      current_oec_on_rent,
      current_actively_renting_customers
    ]
  }

  set: general_info {
    fields: [
      salesperson,
      mtd_total_rev,
      current_assets_on_rent,
      current_oec_on_rent,
      current_actively_renting_customers,
      revenue_mtd_on_track
    ]
  }


  set: no_goal_set_for_rep {
    fields: [
      salesperson,
      revenue_mtd_on_track,
      mtd_total_rev,
      current_assets_on_rent,
      current_oec_on_rent,
      current_actively_renting_customers,
      ]
  }

  set: detail {
    fields: [
      market_id,
      salesperson_user_id,
      assets_on_rent,
      actively_renting_customers,
      oec_on_rent,
      total_market_OEC,
      total_market_asset_count,
      in_market_gen_rental,
      in_market_advanced_rentals,
      in_market_itl,
      in_market_no_class,
      out_market_gen_rental,
      out_market_advanced_rentals,
      out_market_itl,
      out_market_no_class,
      in_market_rev,
      out_market_rev,
      gen_rental_total,
      adv_rentals_total,
      itl_total,
      total_rev,
      total_monthly_revenue_goal,
      in_market_monthly_revenue_goal,
      out_market_monthly_revenue_goal,
      date_goal_created_time,
      past_7_day,
      past_7_day_previous,
      past_30_day,
      past_30_day_previous,
      past_90_day,
      past_90_day_previous,
      past_180_day,
      past_180_day_previous,
      past_365_day,
      past_365_day_previous,
      wtd,
      wtd_previous,
      mtd,
      mtd_previous,
      ytd,
      ytd_previous,
      sp_full_name,
      direct_manager,
      direct_manager_user_id,
      direct_manager_email,
      new_sp_flag,
      market_name,
      district,
      region_name
    ]
  }
}
