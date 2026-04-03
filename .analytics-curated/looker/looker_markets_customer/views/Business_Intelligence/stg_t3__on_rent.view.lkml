view: stg_t3__on_rent {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__ON_RENT" ;;

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }
  dimension: benchmarked_asset_count {
    type: number
    sql: ${TABLE}."BENCHMARKED_ASSET_COUNT" ;;
  }
  dimension: benchmarked_category_asset_count {
    type: number
    sql: ${TABLE}."BENCHMARKED_CATEGORY_ASSET_COUNT" ;;
  }
  dimension: benchmarked_parent_category_asset_count {
    type: number
    sql: ${TABLE}."BENCHMARKED_PARENT_CATEGORY_ASSET_COUNT" ;;
  }
  dimension: billing_days_left {
    type: number
    sql: ${TABLE}."BILLING_DAYS_LEFT" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: category_comparable_assets {
    type: string
    sql: ${TABLE}."CATEGORY_COMPARABLE_ASSETS" ;;
  }
  dimension: category_utilization_comparison {
    type: string
    sql: ${TABLE}."CATEGORY_UTILIZATION_COMPARISON" ;;
  }
  dimension: class_comparable_assets {
    type: string
    sql: ${TABLE}."CLASS_COMPARABLE_ASSETS" ;;
  }
  dimension: class_utilization_comparison {
    type: string
    sql: ${TABLE}."CLASS_UTILIZATION_COMPARISON" ;;
  }
  dimension: class_utilization_comparison_double_shift {
    type: string
    sql: ${TABLE}."CLASS_UTILIZATION_COMPARISON_DOUBLE_SHIFT" ;;
  }
  dimension: class_utilization_comparison_triple_shift {
    type: string
    sql: ${TABLE}."CLASS_UTILIZATION_COMPARISON_TRIPLE_SHIFT" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: current_asset_location {
    type: string
    sql: ${TABLE}."CURRENT_ASSET_LOCATION" ;;
  }
  dimension: current_cycle {
    type: number
    sql: ${TABLE}."CURRENT_CYCLE" ;;
  }
  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }
  dimension_group: data_refresh_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATA_REFRESH_TIMESTAMP" ;;
  }
  dimension: filename {
    type: string
    sql: ${TABLE}."FILENAME" ;;
  }
  dimension_group: five_days_ago {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."FIVE_DAYS_AGO_DATE" ;;
  }
  dimension: five_days_utilization_cst {
    type: number
    sql: ${TABLE}."FIVE_DAYS_UTILIZATION_CST" ;;
  }
  dimension: five_days_utilization_est {
    type: number
    sql: ${TABLE}."FIVE_DAYS_UTILIZATION_EST" ;;
  }
  dimension: five_days_utilization_mnt {
    type: number
    sql: ${TABLE}."FIVE_DAYS_UTILIZATION_MNT" ;;
  }
  dimension: five_days_utilization_utc {
    type: number
    sql: ${TABLE}."FIVE_DAYS_UTILIZATION_UTC" ;;
  }
  dimension: five_days_utilization_wst {
    type: number
    sql: ${TABLE}."FIVE_DAYS_UTILIZATION_WST" ;;
  }
  dimension_group: four_days_ago {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."FOUR_DAYS_AGO_DATE" ;;
  }
  dimension: four_days_utilization_cst {
    type: number
    sql: ${TABLE}."FOUR_DAYS_UTILIZATION_CST" ;;
  }
  dimension: four_days_utilization_est {
    type: number
    sql: ${TABLE}."FOUR_DAYS_UTILIZATION_EST" ;;
  }
  dimension: four_days_utilization_mnt {
    type: number
    sql: ${TABLE}."FOUR_DAYS_UTILIZATION_MNT" ;;
  }
  dimension: four_days_utilization_utc {
    type: number
    sql: ${TABLE}."FOUR_DAYS_UTILIZATION_UTC" ;;
  }
  dimension: four_days_utilization_wst {
    type: number
    sql: ${TABLE}."FOUR_DAYS_UTILIZATION_WST" ;;
  }
  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
  }
  dimension: jobsite_city_state {
    type: string
    sql: ${TABLE}."JOBSITE_CITY_STATE" ;;
  }
  dimension: lat_lon {
    type: string
    sql: ${TABLE}."LAT_LON" ;;
  }
  dimension: make_and_model {
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }
  dimension_group: next_cycle {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."NEXT_CYCLE_DATE" ;;
  }
  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
    value_format_name: id
  }

  dimension: order_id_admin_link {
    label: "Order ID"
    type: string
    sql: ${order_id} ;;
    html: <font color="blue"><a href="https://admin.equipmentshare.com/#/home/orders/{{rendered_value}}"target="_blank"><b>{{rendered_value}} ➔</b> ;;
  }

  dimension: ordered_by {
    type: string
    sql: ${TABLE}."ORDERED_BY" ;;
  }
  dimension: parent_category {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY" ;;
  }
  dimension: parent_category_comparable_assets {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY_COMPARABLE_ASSETS" ;;
  }
  dimension: parent_category_utilization_comparison {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY_UTILIZATION_COMPARISON" ;;
  }
  dimension: parent_company_id {
    type: number
    sql: ${TABLE}."PARENT_COMPANY_ID" ;;
    value_format_name: id
  }
  dimension_group: previous_day {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PREVIOUS_DAY_DATE" ;;
  }
  dimension: previous_day_utilization_cst {
    type: number
    sql: ${TABLE}."PREVIOUS_DAY_UTILIZATION_CST" ;;
  }
  dimension: previous_day_utilization_est {
    type: number
    sql: ${TABLE}."PREVIOUS_DAY_UTILIZATION_EST" ;;
  }
  dimension: previous_day_utilization_mnt {
    type: number
    sql: ${TABLE}."PREVIOUS_DAY_UTILIZATION_MNT" ;;
  }
  dimension: previous_day_utilization_utc {
    type: number
    sql: ${TABLE}."PREVIOUS_DAY_UTILIZATION_UTC" ;;
  }
  dimension: previous_day_utilization_wst {
    type: number
    sql: ${TABLE}."PREVIOUS_DAY_UTILIZATION_WST" ;;
  }
  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd_0
  }
  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd_0
  }
  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd_0
  }

  dimension: company_name_id{
    label: "Company"
    type: string
    sql: concat(${company_name}, ' - ',${company_id}) ;;
  }

  dimension: primary_salesperson_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PRIMARY_SALESPERSON_ID" ;;
  }

  dimension: primary_salesperson_name {
    type: string
    sql: ${TABLE}."PRIMARY_SALESPERSON_NAME" ;;
  }

  dimension: primary_salesperson_name_id {
    label: "Primary Salesperson"
    type: string
    sql: concat(${primary_salesperson_name}, ' - ', ${primary_salesperson_id}) ;;
  }

  dimension: public_health_status {
    type: string
    sql: ${TABLE}."PUBLIC_HEALTH_STATUS" ;;
  }
  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }
  dimension: po_id {
    type: string
    sql: coalesce(concat(${purchase_order_id}), '') ;;

  }
  dimension: purchase_order_name {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NAME" ;;
  }

  dimension: po_highlight_check {
    type: yesno
    sql: ${po_id} <> '' AND (
      LENGTH(${purchase_order_name}) <= 20
      AND NOT REGEXP_LIKE(${purchase_order_name}, '\\b(ave|avenue|st|street|rd|road|blvd|boulevard|dr|drive|ln|lane|hwy|highway|ct|court|cir|circle|way|pl|place|trail|trl|parkway|pkwy|suite|apt|lot|#\\s*\\d+)\\b', 'i')
      AND NOT (REGEXP_LIKE(${purchase_order_name}, '\\b(n/a|na)\\b', 'i') AND LENGTH(${purchase_order_name}) > 5)
      AND NOT REGEXP_LIKE(${purchase_order_name}, '^[A-Z]{2,6}-\\d{2,}$', 'i')
      AND NOT REGEXP_LIKE(${purchase_order_name}, '^[A-Za-z]{2,}-[A-Za-z][A-Za-z0-9]*$', 'i')
      AND NOT REGEXP_LIKE(${purchase_order_name}, '\\b\\w+\\s+sample\\b', 'i')
      AND (
      REGEXP_LIKE(${purchase_order_name}, '\\b(tbd|t\\.?b\\.?d\\.?)\\b', 'i')
      OR REGEXP_LIKE(${purchase_order_name}, '\\bto\\s*be\\s*(deleted|removed|decided|defined)\\b', 'i')
      OR REGEXP_LIKE(${purchase_order_name}, '\\b(delete|deleted|deleting|purge|junk|discard)\\b', 'i')
      OR REGEXP_LIKE(${purchase_order_name}, '\\b(test(ing)?|qa|dummy|stub|mock|sandbox|dev(elopment)?|prototype|po(c|t)|exp(eriment(al)?)?)\\b', 'i')
      OR REGEXP_LIKE(${purchase_order_name}, '^(sample|example|template|boilerplate|scaffold)\\b', 'i')
      OR REGEXP_LIKE(${purchase_order_name}, '\\b(temp(orary)?|draft|wip|work\\s*in\\s*progress|hold|placeholder)\\b', 'i')
      OR REGEXP_LIKE(${purchase_order_name}, '\\b(na|n/a|null|none|unknown|untitled|no\\s*name|no\\s*data)\\b', 'i')
      OR REGEXP_LIKE(${purchase_order_name}, '\\b(do\\s*not\\s*use|dnu|dont\\s*use)\\b', 'i')
      OR REGEXP_LIKE(${purchase_order_name}, '\\bpending\\b', 'i')
      OR REGEXP_LIKE(${purchase_order_name}, '\\bupdate\\b', 'i')
      )
      ) ;;
  }

  dimension: po_id_highlighted {
    type: string
    sql: ${po_id} ;;
    html: {% if po_highlight_check._value == "Yes" %}
      <span style="background-color:#ffcccc; padding:2px 4px; border-radius:3px;">{{value}}</span>
    {% else %}
      {{value}}
    {% endif %};;
  }

  dimension: po_name_highlighted {
    type: string
    label: "Purchase Order Name"
    sql: IFF(${purchase_order_name} = ' ', 'None Listed', ${purchase_order_name}) ;;
    html:
      {% if po_highlight_check._value == "Yes" %}
        <span style="background-color:#ffcccc; padding:2px 4px; border-radius:3px;">
          {{ value }}
        </span>

      {% elsif value == "None Listed" %}
      <span style="background-color:#cce5ff; padding:2px 4px; border-radius:3px;">
      None Listed
      </span>

      {% else %}
      {{ value }}
      {% endif %};;
  }
  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
    primary_key: yes
  }


  dimension: rental_id_admin_link {
    label: "Rental ID"
    type: string
    sql: ${rental_id} ;;
    html: <font color="blue"><a href="https://admin.equipmentshare.com/#/home/rentals/{{rendered_value}}"target="_blank"><b>{{rendered_value}} ➔</b> ;;
  }


  measure: rental_count {
    type: count_distinct
    sql: ${rental_id} ;;
    drill_fields: [rental_detail*]

  }

  dimension: rental_location {
    type: string
    sql: ${TABLE}."RENTAL_LOCATION" ;;
  }
  dimension: rental_period_percent {
    type: number
    sql: ${TABLE}."RENTAL_PERIOD_PERCENT" ;;
  }
  dimension: rental_period_percent_double_shift {
    type: number
    sql: ${TABLE}."RENTAL_PERIOD_PERCENT_DOUBLE_SHIFT" ;;
  }
  dimension: rental_period_percent_triple_shift {
    type: number
    sql: ${TABLE}."RENTAL_PERIOD_PERCENT_TRIPLE_SHIFT" ;;
  }
  dimension: rental_period_utilization_cst {
    type: number
    sql: ${TABLE}."RENTAL_PERIOD_UTILIZATION_CST" ;;
  }
  dimension: rental_period_utilization_est {
    type: number
    sql: ${TABLE}."RENTAL_PERIOD_UTILIZATION_EST" ;;
  }
  dimension: rental_period_utilization_mnt {
    type: number
    sql: ${TABLE}."RENTAL_PERIOD_UTILIZATION_MNT" ;;
  }
  dimension: rental_period_utilization_utc {
    type: number
    sql: ${TABLE}."RENTAL_PERIOD_UTILIZATION_UTC" ;;
  }
  dimension: rental_period_utilization_wst {
    type: number
    sql: ${TABLE}."RENTAL_PERIOD_UTILIZATION_WST" ;;
  }
  dimension_group: rental_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }
  dimension_group: rental_start_date_and {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."RENTAL_START_DATE_AND_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: scheduled_off_rent {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SCHEDULED_OFF_RENT_DATE" ;;
  }

  dimension: scheduled_return_date_check {
    type: yesno
    sql: ${scheduled_off_rent_date} < convert_timezone('America/Chicago',current_timestamp)::DATE  ;;
  }

  dimension: scheduled_off_rent_date_highlighted {
    group_label: "Highlighted"
    label: "Scheduled Off Rent Date"
    type: date
    sql: ${TABLE}."SCHEDULED_OFF_RENT_DATE" ;;
    html:   {% if scheduled_return_date_check._value == "Yes" %}
        <span style="background-color:#ffcccc; padding:2px 4px; border-radius:3px;">
          {{ value }}
        </span>

      {% else %}
      {{ value }}
      {% endif %} ;;
  }

  dimension_group: scheduled_off_rent_date_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."SCHEDULED_OFF_RENT_DATE_AND_TIME" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: seven_days_ago {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SEVEN_DAYS_AGO_DATE" ;;
  }
  dimension: seven_days_utilization_cst {
    type: number
    sql: ${TABLE}."SEVEN_DAYS_UTILIZATION_CST" ;;
  }
  dimension: seven_days_utilization_est {
    type: number
    sql: ${TABLE}."SEVEN_DAYS_UTILIZATION_EST" ;;
  }
  dimension: seven_days_utilization_mnt {
    type: number
    sql: ${TABLE}."SEVEN_DAYS_UTILIZATION_MNT" ;;
  }
  dimension: seven_days_utilization_utc {
    type: number
    sql: ${TABLE}."SEVEN_DAYS_UTILIZATION_UTC" ;;
  }
  dimension: seven_days_utilization_wst {
    type: number
    sql: ${TABLE}."SEVEN_DAYS_UTILIZATION_WST" ;;
  }
  dimension_group: six_days_ago {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SIX_DAYS_AGO_DATE" ;;
  }
  dimension: six_days_utilization_cst {
    type: number
    sql: ${TABLE}."SIX_DAYS_UTILIZATION_CST" ;;
  }
  dimension: six_days_utilization_est {
    type: number
    sql: ${TABLE}."SIX_DAYS_UTILIZATION_EST" ;;
  }
  dimension: six_days_utilization_mnt {
    type: number
    sql: ${TABLE}."SIX_DAYS_UTILIZATION_MNT" ;;
  }
  dimension: six_days_utilization_utc {
    type: number
    sql: ${TABLE}."SIX_DAYS_UTILIZATION_UTC" ;;
  }
  dimension: six_days_utilization_wst {
    type: number
    sql: ${TABLE}."SIX_DAYS_UTILIZATION_WST" ;;
  }
  dimension_group: three_days_ago {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."THREE_DAYS_AGO_DATE" ;;
  }
  dimension: three_days_utilization_cst {
    type: number
    sql: ${TABLE}."THREE_DAYS_UTILIZATION_CST" ;;
  }
  dimension: three_days_utilization_est {
    type: number
    sql: ${TABLE}."THREE_DAYS_UTILIZATION_EST" ;;
  }
  dimension: three_days_utilization_mnt {
    type: number
    sql: ${TABLE}."THREE_DAYS_UTILIZATION_MNT" ;;
  }
  dimension: three_days_utilization_utc {
    type: number
    sql: ${TABLE}."THREE_DAYS_UTILIZATION_UTC" ;;
  }
  dimension: three_days_utilization_wst {
    type: number
    sql: ${TABLE}."THREE_DAYS_UTILIZATION_WST" ;;
  }
  dimension: to_date_rental {
    type: number
    sql: ${TABLE}."TO_DATE_RENTAL" ;;
  }
  dimension: total_days_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_DAYS_ON_RENT" ;;
  }
  dimension: total_weekdays_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_WEEKDAYS_ON_RENT" ;;
  }
  dimension_group: two_days_ago {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."TWO_DAYS_AGO_DATE" ;;
  }
  dimension: two_days_utilization_cst {
    type: number
    sql: ${TABLE}."TWO_DAYS_UTILIZATION_CST" ;;
  }
  dimension: two_days_utilization_est {
    type: number
    sql: ${TABLE}."TWO_DAYS_UTILIZATION_EST" ;;
  }
  dimension: two_days_utilization_mnt {
    type: number
    sql: ${TABLE}."TWO_DAYS_UTILIZATION_MNT" ;;
  }
  dimension: two_days_utilization_utc {
    type: number
    sql: ${TABLE}."TWO_DAYS_UTILIZATION_UTC" ;;
  }
  dimension: two_days_utilization_wst {
    type: number
    sql: ${TABLE}."TWO_DAYS_UTILIZATION_WST" ;;
  }
  dimension: utilization_30_day_category_benchmark {
    type: number
    sql: ${TABLE}."UTILIZATION_30_DAY_CATEGORY_BENCHMARK" ;;
  }
  dimension: utilization_30_day_class_benchmark {
    type: number
    sql: ${TABLE}."UTILIZATION_30_DAY_CLASS_BENCHMARK" ;;
  }
  dimension: utilization_30_day_class_benchmark_double_shift {
    type: number
    sql: ${TABLE}."UTILIZATION_30_DAY_CLASS_BENCHMARK_DOUBLE_SHIFT" ;;
  }
  dimension: utilization_30_day_class_benchmark_triple_shift {
    type: number
    sql: ${TABLE}."UTILIZATION_30_DAY_CLASS_BENCHMARK_TRIPLE_SHIFT" ;;
  }
  dimension: utilization_30_day_parent_category_benchmark {
    type: number
    sql: ${TABLE}."UTILIZATION_30_DAY_PARENT_CATEGORY_BENCHMARK" ;;
  }
  dimension: utilization_status {
    type: string
    sql: ${TABLE}."UTILIZATION_STATUS" ;;
    html:
    {% if value == 'show utilization' %}
        Utilization up to date
      {% else %}
        {{ rendered_value }}
      {% endif %}
    ;;
  }
  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: rental_start_date_formatted {
    group_label: "HTML Formatted Date"
    label: "Rental Start Date"
    type: date
    sql: ${rental_start_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }


  dimension: scheduled_off_rent_date_formatted {
    group_label: "HTML Formatted Date"
    label: "Schedueld Off Rent Date"
    type: date
    sql: ${scheduled_off_rent_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }


  measure: total_last_seven_days_utilization {
    type: sum
    sql: ${previous_day_utilization_cst} + ${two_days_utilization_cst} + ${three_days_utilization_cst} + ${four_days_utilization_cst} + ${five_days_utilization_cst} + ${six_days_utilization_cst} + ${seven_days_utilization_cst} ;;
    value_format_name: decimal_1
  }

  dimension: company_id_and_name{
    type: string
    sql: concat(${company_id}, ' - ',${company_name}) ;;
  }

  measure: count {
    type: count
    drill_fields: [company_name, custom_name, filename, purchase_order_name]
  }

set: rental_detail {
  fields: [company_name_id, rental_location, primary_salesperson_name_id, rental_id_admin_link, order_id_admin_link, asset_id, asset_class, make_and_model, ordered_by, jobsite, rental_start_date, scheduled_off_rent_date_highlighted, price_per_day, price_per_week, price_per_month, po_name_highlighted]
}

}
