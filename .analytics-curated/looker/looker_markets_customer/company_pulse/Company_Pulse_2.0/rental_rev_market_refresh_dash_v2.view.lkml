view: rental_rev_market_refresh_dash_v2 {
  sql_table_name: analytics.intacct_models.int_admin_invoice_and_credit_line_detail ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: gl_date {
    type: time
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: gl_approved_date {
    type: date
    sql: ${TABLE}."GL_DATE"::DATE ;;
  }

  dimension: formatted_date_gl {
    group_label: "GL HTML Formatted Date"
    label: "Date"
    type: date
    sql: ${gl_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: formatted_date_as_month_gl {
    group_label: "GL HTML Formatted Date"
    label: "Month Date"
    type: date
    sql: ${gl_date_date} ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: formatted_month_gl {
    group_label: "GL HTML Formatted Date"
    label: "Month"
    type: date
    sql: DATE_TRUNC(month,${gl_date_date}::DATE) ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: line_item_id {
    type: string
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: line_item_type_id {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: is_rental_revenue {
    type: yesno
    sql: ${TABLE}."IS_RENTAL_REVENUE" ;;
  }

  dimension: intercompany {
    type: yesno
    sql: ${TABLE}."IS_INTERCOMPANY" ;;
  }

  dimension: line_item_type_name {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_NAME" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd_0
  }

  measure: amount_sum {
    label: "Rental Revenue Sum"
    type: sum
    sql: COALESCE(${amount},0);;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [company_ans_rev_detail*]
  }

  measure: amount_sum_region {
    group_label: "Region"
    label: "Rental Revenue Sum"
    type: sum
    sql: COALESCE(${amount},0);;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [region_ans_rev_detail*]
  }

  measure: amount_sum_district {
    group_label: "District"
    label: "Rental Revenue Sum"
    type: sum
    sql: COALESCE(${amount},0);;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [district_ans_rev_detail*]
  }

  measure: amount_sum_market {
    group_label: "Market"
    label: "Rental Revenue Sum"
    type: sum
    sql: COALESCE(${amount},0);;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [market_ans_rev_detail*]
  }

  measure: amount_sum_cm {
    label: "Rental Revenue - Current Month"
    type: sum
    sql: CASE WHEN date_trunc(month, ${gl_date_date}::DATE) = date_trunc(month, current_date) THEN COALESCE(${amount},0) END;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [v_dim_dates_bi.is_current_month: "yes", amount: ">0, <0"]
    drill_fields: [formatted_date_gl, market_region_xwalk.market_name, customer_name, primary_sp_name, amount_sum_cm_unformatted]
  }

  measure: amount_sum_cm_unformatted {
    hidden: yes
    label: "Current Month Rental Revenue"
    type: sum
    sql: CASE WHEN date_trunc(month, ${gl_date_date}::DATE) = date_trunc(month, current_date) THEN COALESCE(${amount},0) END;;
    value_format_name: usd
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: primary_salesperson_id {
    group_label: "Salesperson Info"
    type: string
    sql: ${TABLE}."PRIMARY_SALESPERSON_ID" ;;
  }

  dimension: user_full_name {
    hidden: yes
    sql: concat(${users.first_name}, ' ', ${users.last_name}) ;;
  }

  dimension: primary_sp_name {
    group_label: "Salesperson Info"
    label: "Primary Salesperson"
    type: string
    sql: COALESCE(
      CASE WHEN
      position(' ',COALESCE(${company_directory.nickname},${company_directory.first_name})) = 0 THEN
        concat(COALESCE(${company_directory.nickname},${company_directory.first_name}), ' ', ${company_directory.last_name})
      ELSE concat(COALESCE(${company_directory.nickname},concat(${company_directory.first_name}, ' ',${company_directory.last_name}))) END, ${user_full_name}) --coalesce in name from users table in case of House Sales
      ;;
  }

  dimension: primary_sp_name_id {
    group_label: "Salesperson Info"
    type: string
    sql: concat(${primary_sp_name}, ' - ', ${primary_salesperson_id}) ;;
  }

  dimension: secondary_salesperson_ids {
    group_label: "Salesperson Info"
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON_IDS" ;;
  }

  dimension: current_sp_market {
    group_label: "Salesperson Info"
    type: string
    sql: split_part(${company_directory.default_cost_centers_full_path} ,'/',4);;
  }

  dimension: in_out_market_flag {
    type: string
    sql: CASE WHEN ${current_sp_market} IS NULL THEN 'Not Market Level'
    WHEN ${market_region_xwalk.market_name} = ${current_sp_market} THEN 'In Market'
    WHEN ${market_region_xwalk.market_name} <> ${current_sp_market} THEN 'Out of Market' ELSE NULL END;;
  }

  dimension: primary_sp_name_id_in_out {
    label: "Primary Salesperson Name - ID"
    sql: ${primary_sp_name_id} ;;
    html: <font color="#0063f3">
    <a href="https://equipmentshare.looker.com/dashboards/5?Sales+Rep={{primary_sp_name_id._filterable_value | url_encode}}&amp;Market=&amp;District=&amp;Region=&amp;Customer+Terms+%28AR+Past+Due%29=&amp;Full+Name+with+ID+National=&amp;Do+Not+Rent+Customers=" target="_blank">
    {{rendered_value}} ➔
    </a>
    <br />
    {% if in_out_market_flag._value == "In Market" %}
    <span style="color: #1B1B1B;"><b>{{in_out_market_flag._rendered_value}}</b></span>
    {% elsif in_out_market_flag._value == "Not Market Level" %}
    <font style="color: #8C8C8C; text-align: right;">{{in_out_market_flag._rendered_value}}</font>
    {% else %}
    <font style="color: #8C8C8C; text-align: right;">Home Market: {{current_sp_market._rendered_value}}</font>
    {% endif %};;
  }

  set: company_ans_rev_detail {
    fields: [formatted_month_gl, market_region_xwalk.region_name, amount_sum]
  }

  set: region_ans_rev_detail {
    fields: [formatted_month_gl, market_region_xwalk.district,  amount_sum]
  }

  set: district_ans_rev_detail {
    fields: [formatted_month_gl, market_region_xwalk.market_name,  amount_sum]
  }

  set: market_ans_rev_detail {
    fields: [formatted_month_gl, market_region_xwalk.market_name,  amount_sum]
  }

  set: detail {
    fields: [
      gl_date_date,
      market_id,
      company_id,
      customer_name,
      line_item_id,
      line_item_type_id,
      is_rental_revenue,
      line_item_type_name,

      amount,
      asset_id,
      rental_id,
      primary_salesperson_id,
      secondary_salesperson_ids
    ]
  }
}
