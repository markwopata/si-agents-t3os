view: weekly_work_order_info {
  sql_table_name: "ANALYTICS"."SERVICE"."WEEKLY_WORK_ORDER_INFO" ;;

  dimension: age {
    type: number
    sql: iff(${generated_week_year} - ${year} < 0, 0, ${generated_week_year} - ${year}) ;;
  }
  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/history?" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: asset_ownership {
    type: string
    sql: ${TABLE}."ASSET_OWNERSHIP" ;;
  }
  dimension: best_code_explainations {
    type: string
    sql: ${TABLE}."BEST_CODE_EXPLAINATIONS" ;;
  }
  dimension: billing_type_id {
    type: number
    sql: ${TABLE}."BILLING_TYPE_ID" ;;
    value_format_name: id
  }
  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format_name: id
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: cause {
    type: string
    sql: ${TABLE}."CAUSE" ;;
  }
  dimension: cause_group {
    type: string
    sql: ${TABLE}."CAUSE_GROUP" ;;
  }
  dimension: code_descriptions {
    type: string
    sql: ${TABLE}."CODE_DESCRIPTIONS" ;;
  }
  dimension: codes {
    type: string
    sql: ${TABLE}."CODES" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }
  dimension: complaint {
    type: string
    sql: ${TABLE}."COMPLAINT" ;;
  }
  dimension: complaint_group {
    type: string
    sql: ${TABLE}."COMPLAINT_GROUP" ;;
  }
  dimension: correction {
    type: string
    sql: ${TABLE}."CORRECTION" ;;
  }
  dimension: correction_group {
    type: string
    sql: ${TABLE}."CORRECTION_GROUP" ;;
  }
  dimension_group: date_billed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_BILLED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: expense {
    type: number
    sql: ${TABLE}."EXPENSE" ;;
    value_format_name: usd
  }
  dimension: failure_modes {
    type: string
    sql: ${TABLE}."FAILURE_MODES" ;;
  }
  dimension_group: generated_week {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."GENERATED_WEEK" ;;
  }
  dimension: hours_cost {
    type: number
    sql: ${TABLE}."HOURS_COST" ;;
    value_format_name: usd
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id }}" target="_blank"> {{rendered_value}} </a></font></u> ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id }}" target="_blank"> {{rendered_value}} </a></font></u> ;;
  }
  dimension: is_dealership {
    type: yesno
    sql: ${TABLE}."IS_DEALERSHIP" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: make_model {
    type: string
    sql: concat(${make},' ',${model}) ;;
  }
  dimension: modular_identifiers {
    type: string
    sql: ${TABLE}."MODULAR_IDENTIFIERS" ;;
  }
  dimension: new_ownership {
    type: string
    sql: ${TABLE}."NEW_OWNERSHIP" ;;
  }
  dimension: originator_type {
    type: string
    sql: ${TABLE}."ORIGINATOR_TYPE" ;;
  }
  dimension: overtime_hour {
    type: number
    sql: ${TABLE}."OVERTIME_HOUR" ;;
  }
  dimension: ownership {
    type: string
    sql: ${TABLE}."OWNERSHIP" ;;
  }
  dimension: parts_cost {
    type: number
    sql: ${TABLE}."PARTS_COST" ;;
    value_format_name: usd
  }
  dimension: parts_qty {
    type: number
    sql: ${TABLE}."PARTS_QTY" ;;
  }
  dimension: problem_group {
    type: string
    sql: ${TABLE}."PROBLEM_GROUP" ;;
  }
  dimension_group: purchase {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PURCHASE_DATE" ;;
  }
  dimension: regular_hour {
    type: number
    sql: ${TABLE}."REGULAR_HOUR" ;;
  }
  dimension: suspect_parameters {
    type: string
    sql: ${TABLE}."SUSPECT_PARAMETERS" ;;
  }
  dimension: total_hours {
    type: number
    sql: ${TABLE}."TOTAL_HOURS" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id }}/updates" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: work_order_type_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_TYPE_NAME" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
    value_format_name: id
  }
  parameter: comparison_groups {
    type: string
    allowed_value: { value: "Class v Category" }
    allowed_value: { value: "Make v Category" }
    allowed_value: { value: "Make v Class" }
    allowed_value: { value: "Make Model v Class" }
  }
  dimension: dynmaic_comparison_dimension {
    label_from_parameter: comparison_groups
    type: string
    sql:
    {% if comparison_groups._parameter_value == "'Class v Category'" %}
      ${asset_class}
    {% elsif comparison_groups._parameter_value == "'Make v Category'" %}
      ${make}
    {% elsif comparison_groups._parameter_value == "'Make v Class'" %}
      ${make}
    {% elsif comparison_groups._parameter_value == "'Make Model v Class'" %}
      ${make_model}
    {% else %}
      NULL
    {% endif %} ;;
  }
  parameter: pivot_mode {
    type: string
    allowed_value: { value: "Problem Group"}
    allowed_value: { value: "Age"}
    allowed_value: { value: "Work Order Type"}
  }
  dimension: dynmaic_pivot_dimension {
    label_from_parameter: pivot_mode
    type: string
    sql:
    {% if pivot_mode._parameter_value == "'Problem Group'" %}
      ${problem_group}
    {% elsif pivot_mode._parameter_value == "'Age'" %}
      ${age}
    {% elsif pivot_mode._parameter_value == "'Work Order Type'" %}
      ${work_order_type_name}
    {% else %}
      NULL
    {% endif %} ;;
  }
  filter: comparison_make {
    type: string
    suggest_dimension: make
  }
  dimension: comparison_make_filter {
    type: yesno
    hidden: yes
    sql: {% condition comparison_make %} ${make} {% endcondition %} ;;
  }
  measure: make_count_assets {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [comparison_make_filter: "yes"]
  }
  measure: nonmake_count_assets {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [comparison_make_filter: "no"]
  }
  measure: count_assets {
    type: count_distinct
    sql: ${asset_id} ;;
  }
  measure: make_sum_expense {
    type: sum
    sql: ${expense} ;;
    value_format_name: usd
    filters: [comparison_make_filter: "yes"]
    drill_fields: [work_order_id,problem_group,asset_id,billing_type_id,generated_week_week,expense]
  }
  measure: nonmake_sum_expense {
    type: sum
    sql: ${expense} ;;
    value_format_name: usd
    filters: [comparison_make_filter: "no"]
    drill_fields: [work_order_id,problem_group,asset_id,billing_type_id,generated_week_week,expense]
  }
  measure: sum_expense {
    type: sum
    sql: ${expense} ;;
    value_format_name: usd
    drill_fields: [work_order_id,problem_group,asset_id,billing_type_id,generated_week_week,expense]
  }
  measure: make_avg {
    type: number
    sql: ${make_sum_expense} / nullifzero(${make_count_assets}) ;;
    value_format_name: usd
    drill_fields: [asset_id,make,model,year,category,asset_class,company_id,make_sum_expense]
  }
  measure: nonmake_avg {
    type: number
    sql: ${nonmake_sum_expense} / nullifzero(${nonmake_count_assets}) ;;
    value_format_name: usd
    drill_fields: [asset_id,make,model,year,category,asset_class,company_id,nonmake_sum_expense]
  }
  measure: avg {
    type: number
    sql: ${sum_expense} / nullifzero(${count_assets}) ;;
    value_format_name: usd
    drill_fields: [asset_id,make,model,year,category,asset_class,company_id,sum_expense]
  }
}
