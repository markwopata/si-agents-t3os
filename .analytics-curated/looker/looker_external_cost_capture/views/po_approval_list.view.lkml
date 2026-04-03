view: po_approval_list {
  derived_table: {
    sql:
SELECT PURCHASE_ORDER_ID,
PURCHASE_ORDER_NUMBER,
DATE_CREATED,
REQUESTING_USER_ID,
MARKET_ID,
COST_CENTER,
REGION_NAME,
MARKET_TYPE,
DISTRICT,
CASE
  WHEN DATEDIFF(MONTH, BRANCH_EARNINGS_START_MONTH, CURRENT_DATE) > 12 THEN 'Yes'
  ELSE 'No'
END AS open_more_than_12_months,
PURCHASE_ORDER_AMOUNT,
APPROVER_ID,
VENDOR,
ENTITY_ID,
COALESCE(PREFERRED,'No') as PREFERRED,
STATUS,
COMPANY_ID,
APPROVER_GROUP,
APPROVER_SPENDING_LIMIT
FROM BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__PO_APPROVAL_LIST
    WHERE (requesting_user_id = {{ _user_attributes['user_id'] }} or company_id = {{ _user_attributes['company_id'] }})
        AND {% condition cost_center_filter %} cost_center {% endcondition %}
        AND {% condition region_filter %} region_name {% endcondition %}
        AND {% condition district_filter %} district {% endcondition %}
        AND {% condition market_open_filter %} open_more_than_12_months {% endcondition %}
        AND {% condition vendor_filter %} vendor {% endcondition %}
        AND {% condition preferred_filter %} preferred {% endcondition %}
        and status = 'NEEDS_APPROVAL'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
    value_format_name: id
  }

  dimension: purchase_order_number {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
    value_format_name: id
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: requesting_user_id {
    type: number
    sql: ${TABLE}."REQUESTING_USER_ID" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: open_more_than_12_months {
    type: yesno
    sql: ${TABLE}."OPEN_MORE_THAN_12_MONTHS" ;;
  }

  dimension: purchase_order_amount {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: approver_id {
    type: string
    sql: ${TABLE}."APPROVER_ID" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: approver_group {
    type: string
    sql: ${TABLE}."APPROVER_GROUP" ;;
  }

  dimension: approver_spending_limit {
    type: number
    sql: ${TABLE}."APPROVER_SPENDING_LIMIT" ;;
    value_format_name: usd
  }

  dimension: preferred {
    type: string
    sql: ${TABLE}."PREFERRED" ;;
  }

  measure: dummy {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [detail*]
  }

  measure: total_unique_purchase_orders {
    type: count_distinct
    sql: ${purchase_order_id} ;;
    # type: count
    # drill_fields: [detail*]
    link: {
      label: "View Purchase Orders Needing Approval"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis= '{\"show_view_names\":false,
            \"show_row_numbers\":true,
            \"transpose\":false,
            \"truncate_text\":true,
            \"hide_totals\":false,
            \"hide_row_totals\":false,
            \"size_to_fit\":true,
            \"table_theme\":\"white\",
            \"limit_displayed_rows\":false,
            \"enable_conditional_formatting\":false,
            \"header_text_alignment\":\"left\",
            \"header_font_size\":12,
            \"rows_font_size\":12,
            \"conditional_formatting_include_totals\":false,
            \"conditional_formatting_include_nulls\":false,
            \"type\":\"looker_grid\",
            \"defaults_version\":1}' %}

            {{dummy._link}}&f[markets.name]=&sorts=po_approval_list.date_created_time_formatted+desc,po_approval_list.approver_spending_limit+asc,users.approver_name+asc&vis={{vis | encode_uri}}"
    }
  }

  measure: view_approval_list {
    type: string
    sql: 'View Purchase Orders Approval List' ;;
    html: <a href="#drillmenu" target="_self"><u><font color="#0063f3"> {{rendered_value}} </ul></a>;;
    drill_fields: [detail*]
  }

  dimension: date_created_time_formatted {
    group_label: "HTML Formatted Time"
    label: "Created Date/Time"
    type: date_time
    sql: ${date_created_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${purchase_order_id},${approver_id},${date_created_raw} ;;
  }

  dimension: link_to_purchase_order {
    group_label: "Link To PO"
    label: "Link to CostCapture"
    sql: ${purchase_order_id} ;;
    html: <font color="#0063f3"><u><a href="https://costcapture.estrack.com/purchase-orders/{{rendered_value}}/detail" target="_blank">View Purchase Order</a></font></u>;;
  }

  filter: date_filter {
    type: date_time
  }

  filter: cost_center_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.cost_center
  }

  filter: region_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.region_name
  }

  filter: district_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.district_name
  }

  filter: market_open_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.open_more_than_12_months
  }

  filter: status_filter {
  }

  filter: vendor_filter {
  }

  filter: preferred_filter {
  }

  set: detail {
    fields: [
      link_to_purchase_order,
      users_created_by.created_by,
      date_created_time_formatted,
      vendor,
      markets.name,
      purchase_order_amount,
      users.approver_name,
      users.approver_email,
      preferred
    ]
  }
  #       market_id,
  # purchase_order_number,
  # approver_group,
  #     approver_spending_limit
}
