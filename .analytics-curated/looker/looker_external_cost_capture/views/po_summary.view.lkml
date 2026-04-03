view: po_summary {
  derived_table: {
    sql:
select
PO_LIST_SELECT_FLAG,
PO.PURCHASE_ORDER_ID ,
PURCHASE_ORDER_NUMBER ,
REFERENCE ,
STATUS ,
PROMISE_DATE ,
DATE_CREATED ,
CREATED_BY ,
VENDOR ,
coalesce(PREFERRED, 'No') as PREFERRED,
COST_CENTER ,
REGION_NAME ,
DISTRICT ,
MARKET_TYPE,
CASE
  WHEN DATEDIFF(MONTH, BRANCH_EARNINGS_START_MONTH, CURRENT_DATE) > 12 THEN 'Yes'
  ELSE 'No'
END AS open_more_than_12_months,
ITEM_TYPE ,
LINE_ITEM_DESCRIPTION ,
QUANTITY ,
PRICE_PER_UNIT ,
MARKET_ID ,
COMPANY_ID ,
TOTAL_PO_COST ,
ITEM_SERVICE ,
DATE_RECEIVED ,
PART_NUMBER ,
BRANCH_EARNINGS_START_MONTH,
I.MOST_RECENT_INVOICE_ID,
I.INVOICE_NO,
I.PURCHASE_ORDER_NO
FROM BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__PO_SUMMARY PO
LEFT JOIN
(
SELECT
    CAST(I.PURCHASE_ORDER_ID AS STRING) AS PURCHASE_ORDER_ID,
    CAST(INVOICE_ID AS STRING) AS MOST_RECENT_INVOICE_ID,
    INVOICE_NO,
    P.NAME AS PURCHASE_ORDER_NO
FROM ES_WAREHOUSE.PUBLIC.INVOICES I
LEFT JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS P ON I.PURCHASE_ORDER_ID = P.PURCHASE_ORDER_ID
QUALIFY ROW_NUMBER() OVER (PARTITION BY I.PURCHASE_ORDER_ID ORDER BY INVOICE_DATE DESC) = 1
) I ON CAST(PO.PURCHASE_ORDER_NUMBER AS STRING) = I.PURCHASE_ORDER_NO
      where
        {% if view_by._parameter_value == "'Date Created'" %}
        date_created BETWEEN convert_timezone('UTC', {% date_start date_filter %}::timestamp_ntz) AND convert_timezone('UTC', {% date_end date_filter %}::timestamp_ntz)
        {% else %}
        date_received BETWEEN convert_timezone('UTC', {% date_start date_filter %}::timestamp_ntz) AND convert_timezone('UTC', {% date_end date_filter %}::timestamp_ntz)
        {% endif %}
        AND {% condition cost_center_filter %} cost_center {% endcondition %}
        AND {% condition region_filter %} region_name {% endcondition %}
        AND {% condition district_filter %} district {% endcondition %}
        AND {% condition market_open_filter %} open_more_than_12_months {% endcondition %}
        AND {% condition status_filter %} status {% endcondition %}
        AND {% condition vendor_filter %} vendor {% endcondition %}
        AND company_id = {{ _user_attributes['company_id'] }}
      ;;

  }

  dimension: po_list_select_flag {
    type: string
    sql: ${TABLE}."PO_LIST_SELECT_FLAG" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."market_id" ;;
  }


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
    value_format_name: id
  }

  dimension: purchase_order_number {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
    value_format_name: id
  }

  dimension: most_recent_invoice_id {
    type: string
    sql: ${TABLE}."MOST_RECENT_INVOICE_ID" ;;
  }

  dimension: invoice_no {
    type: string
    label: "Most Recent Invoice"
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: purchase_order_no {
    type: string
    label: "Purchase Order Number"
    sql: ${TABLE}."PURCHASE_ORDER_NO" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension_group: promise_date {
    type: time
    sql: ${TABLE}."PROMISE_DATE" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: preferred {
    type: string
    sql: ${TABLE}."PREFERRED" ;;
  }

  dimension: cost_center {
    type: string
    sql: ${TABLE}."COST_CENTER" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: open_more_than_12_months {
    type: yesno
    sql: ${TABLE}."OPEN_MORE_THAN_12_MONTHS" ;;
  }

  dimension: item_type {
    type: string
    sql: ${TABLE}."ITEM_TYPE" ;;
  }

  dimension: line_item_description {
    label: "Description"
    type: string
    sql: ${TABLE}."LINE_ITEM_DESCRIPTION" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
    value_format_name: usd
  }

  dimension: total_po_cost {
    type: number
    sql: ${TABLE}."TOTAL_PO_COST" ;;
    value_format_name: usd
  }

  dimension: item_service {
    label: "Item/Service"
    type: string
    sql: ${TABLE}."ITEM_SERVICE" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }


  dimension_group: date_received {
    type: time
    sql: ${TABLE}."DATE_RECEIVED" ;;
  }

  dimension: date_received_date_html {
    group_label: "HTML Format"
    label: "Date Received"
    type: date
    sql: ${date_received_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  measure: total_purchase_order_cost {
    group_label: "Total PO Cost Filtered"
    label: "Total Amount"
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
  }

  measure: total_purchase_order_cost_30_day {
    # label: "Total Purchase Cost"
    label: "Total Amount"
    filters: [po_list_select_flag: "Open_Over_30_Days"]
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
  }

  measure: total_purchase_order_cost_60_day {
    # label: "Total Purchase Cost"
    label: "Total Amount"
    filters: [po_list_select_flag: "Open_Over_60_Days"]
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd

  }

  measure: total_purchase_order_cost_90_day {
    # label: "Total Purchase Cost"
    label: "Total Amount"
    filters: [po_list_select_flag: "Open_Over_90_Days"]
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
  }

  measure: unique_purchase_orders {
    ##filters: [po_list_select_flag: "filtered_pos"]
    label: "Count "
    type: count_distinct
    sql: ${purchase_order_number} ;;
  }

  measure: unique_purchase_orders_open_over_30days {
    filters: [po_list_select_flag: "Open_Over_30Days",status: "OPEN"]
   label: "Open (30 days)"
    type: count_distinct
    sql: ${purchase_order_number} ;;
    html:
    {% if value == 0 %}
    <P align="right"<a > <font color="black">{{rendered_value}}</font>  </a>
    {% else %}
    <a href="#drillmenu" target="_self"> {{rendered_value}} </a>
    {% endif %};;
    drill_fields: [30_day_pos*]
  }

  measure: unique_purchase_orders_open_over_60_days {
    filters: [is_over_60_by_view: "yes",status: "OPEN"]
    label: "Open (60 days)"
    type: count_distinct
    sql: ${purchase_order_number} ;;
    html:
    {% if value == 0 %}
    <a > <font color="black">{{rendered_value}}</font> </a>
    {% else %}
    <a href="#drillmenu" target="_self"> {{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"> </a>
    {% endif %} ;;
    drill_fields: [60_day_pos*]
  }

  dimension: is_over_60_by_view {
    type: yesno
    sql:
    CASE
      WHEN {% parameter view_by %} = 'Date Created'
           AND ${date_created_raw} < DATEADD('day', -59, CURRENT_DATE()) THEN TRUE
      WHEN {% parameter view_by %} = 'Date Received'
           AND ${date_received_raw} < DATEADD('day', -59, CURRENT_DATE()) THEN TRUE
      ELSE FALSE
    END ;;
  }


  measure: unique_purchase_orders_open_over_90days {
    filters: [po_list_select_flag: "Open_Over_90_Days",status: "OPEN"]
   label: "Open (90 days)"
    type: count_distinct
    sql: ${purchase_order_number} ;;
    html:
    {% if value >= 0 %}
    <a > <font color="black">{{rendered_value}}</font>  </a>
    {% else %}
    <a href="#drillmenu" target="_self"> {{rendered_value}} </a>
    {% endif %} ;;
    drill_fields: [90_day_pos*]
  }

  measure: unique_vendors {
    type: count_distinct
    sql: ${vendor} ;;
    drill_fields: [unique_vendor_drill*]
  }

  measure: total_inventory_items {
    type: sum
    sql: ${quantity} ;;
    filters: [item_type: "INVENTORY"]
    drill_fields: [inventory_counts*]
  }

  measure: total_non_inventory_items {
    type: sum
    sql: ${quantity} ;;
    filters: [item_type: "NON_INVENTORY"]
    drill_fields: [non_inventory_counts*]
  }

  measure: total_inventory_items_drill {
    group_label: "Drill Fields"
    label: "Total Inventory Items"
    type: sum
    sql: ${quantity} ;;
    filters: [item_type: "INVENTORY"]
    drill_fields: [inventory_description_info*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
  }

  measure: total_non_inventory_items_drill {
    group_label: "Drill Fields"
    label: "Total Non Inventory Items"
    type: sum
    sql: ${quantity} ;;
    filters: [item_type: "NON_INVENTORY"]
    drill_fields: [inventory_description_info*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
  }

  measure: total_inventory_cost_drill {
    group_label: "Drill Fields"
    label: "Total Inventory Cost"
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
    filters: [item_type: "INVENTORY"]
    drill_fields: [inventory_description_info*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
  }

  measure: total_non_inventory_cost_drill {
    group_label: "Drill Fields"
    label: "Total Non Inventory Cost"
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
    filters: [item_type: "NON_INVENTORY"]
    drill_fields: [inventory_description_info*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
  }

  measure: total_purchase_order_cost_vendors {
    group_label: "Vendor Drill Fields"
    # label: "Total Purchase Order Cost"
    label: "Total Amount"
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
    drill_fields: [unique_vendor_cost_drill*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
  }

  measure: unique_purchase_orders_vendors {
    group_label: "Vendor Drill Fields"
    label: "Total Purchase Orders"
    type: count_distinct
    sql: ${purchase_order_number} ;;
    drill_fields: [unique_vendor_count_drill*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
  }

  measure: total_purchase_order_cost_kpi {
    group_label: "KPI Fields"
    # label: "Total Purchase Order Cost"
    label: "Total Amount"
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
    drill_fields: [open_close_info*]
  }

  measure: unique_purchase_orders_kpi {
    group_label: "KPI Fields"
    label: "Total Purchase Orders"
    type: count_distinct
    sql: ${purchase_order_number} ;;
    drill_fields: [open_close_info*]
  }

  measure: total_purchase_order_cost_drill {
    group_label: "KPI Drill Fields"
    # label: "Total Purchase Order Cost"
    label: "Total Amount"
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
    drill_fields: [open_close_drill*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
  }

  measure: unique_purchase_orders_drill {
    group_label: "KPI Drill Fields"
    label: "Total Purchase Orders"
    type: count_distinct
    sql: ${purchase_order_number} ;;
    drill_fields: [open_close_drill*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
  }


  measure: total_purchase_order_cost_bar_chart {
    group_label: "Bottom Table Cost KPI"
    # label: "Total Purchase Cost"
    label: "Total Amount"
    type: sum
    sql: ${total_po_cost} ;;
    # sql: ${total_purchase_order_cost} ;;
    value_format_name: usd
    drill_fields: [detail*]
    html:
    {% if value == 0 %}
    <a > <font color="black">{{rendered_value}}</font> </a>
    {% else %}
    <a href="#drillmenu" target="_self"> {{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"> </a>
    {% endif %} ;;
  }
  measure: dummy_filtered {
    hidden: yes
    type: sum
    sql: 0 ;;
    # drill_fields: [detail*]
    drill_fields: [detail*]
  }

  measure: dummy_30_days {
    hidden: yes
    type: sum
    sql: 0 ;;
    # drill_fields: [detail*]
    drill_fields: [30_day_pos*]
  }

  measure: dummy_60_days {
    hidden: yes
    type: sum
    sql: 0 ;;
    # drill_fields: [detail*]
    drill_fields: [60_day_pos*]
  }


  measure: dummy_90_days {
    hidden: yes
    type: sum
    sql: 0 ;;
    # drill_fields: [detail*]
    drill_fields: [90_day_pos*]
  }

  filter: date_filter {
    type: date_time
  }

  filter: cost_center_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.cost_center
  }

  filter: region_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.region_name
  }

  filter: district_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: market_open_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.open_more_than_12_months
  }

  filter: status_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: market_id_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.cost_center
  }

  filter: vendor_filter {
  }

  filter: preferred_filter {
  }

  dimension: link_to_purchase_order {
    group_label: "Link To PO"
    label: "Purchase Order Number"
    sql: ${purchase_order_id} ;;
    html: <font color="#0063f3"><u><a href="https://costcapture.estrack.com/purchase-orders/{{purchase_order_id._value}}/detail" target="_blank">{{purchase_order_number._rendered_value}}</a></font></u>;;
  }

  dimension: link_to_invoice {
    group_label: "Link To Invoice"
    label: "Most Recent Invoice"
    sql: ${invoice_no} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/billing/{{most_recent_invoice_id._value}}" target="_blank">{{invoice_no._rendered_value}}</a></font></u>;;
  }

  dimension: date_created_date_html {
    group_label: "HTML Format"
    label: "Date Created"
    type: date
    sql: ${date_created_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  parameter: view_by {
    type: string
    allowed_value: { value: "Date Created"}
    allowed_value: { value: "Date Received"}
  }

  set: detail {
    fields: [
      date_created_date_html,
      date_received_date_html,
      link_to_purchase_order,
      link_to_invoice,
      vendor,
      reference,
      item_service,
      line_item_description,
      created_by,
      cost_center,
      total_purchase_order_cost,
      part_number
    ]
  }

  set: 30_day_pos {
    fields: [
      date_created_date_html,
      date_received_date_html,
      link_to_purchase_order,
      vendor,
      reference,
      item_service,
      line_item_description,
      created_by,
      cost_center,
      total_purchase_order_cost_30_day,
      part_number
    ]
  }

  set: 60_day_pos {
    fields: [
      date_created_date_html,
      date_received_date_html,
      link_to_purchase_order,
      vendor,
      reference,
      item_service,
      line_item_description,
      created_by,
      cost_center,
      total_purchase_order_cost_60_day,
      part_number
    ]
  }

  set: 90_day_pos {
    fields: [
      date_created_date_html,
      date_received_date_html,
      link_to_purchase_order,
      vendor,
      reference,
      item_service,
      line_item_description,
      created_by,
      cost_center,
      total_purchase_order_cost_90_day,
      part_number
    ]
  }

  set: inventory_counts {
    fields: [
      line_item_description,
      total_inventory_items_drill,
      total_inventory_cost_drill
    ]
  }

  set: non_inventory_counts {
    fields: [
      line_item_description,
      total_non_inventory_items_drill,
      total_non_inventory_cost_drill
    ]
  }

  set: inventory_description_info {
    fields: [
      date_created_date_html,
      date_received_date_html,
      link_to_purchase_order,
      vendor,
      reference,
      item_service,
      line_item_description,
      created_by,
      cost_center,
      line_item_description,
      quantity,
      price_per_unit,
      total_purchase_order_cost,
      part_number
    ]
  }

  set: unique_vendor_drill {
    fields: [
      vendor,
      total_purchase_order_cost_vendors,
      unique_purchase_orders_vendors
    ]
  }

  set: unique_vendor_cost_drill {
    fields: [
      vendor,
      date_created_date_html,
      date_received_date_html,
      link_to_purchase_order,
      vendor,
      reference,
      item_service,
      line_item_description,
      created_by,
      cost_center,
      total_purchase_order_cost_vendors,
      unique_purchase_orders_vendors,
      part_number
    ]
  }

  set: unique_vendor_count_drill {
    fields: [
      vendor,
      date_created_date_html,
      date_received_date_html,
      link_to_purchase_order,
      vendor,
      reference,
      item_service,
      line_item_description,
      created_by,
      cost_center,
      total_purchase_order_cost_vendors,
      unique_purchase_orders_vendors,
      part_number
    ]
  }

  set: open_close_info {
    fields: [
      status,
      total_purchase_order_cost_drill,
      unique_purchase_orders_drill
    ]
  }

  set: open_close_drill {
    fields: [
      date_created_date_html,
      link_to_purchase_order,
      # link_to_invoice,
      vendor,
      reference,
      item_service,
      line_item_description,
      created_by,
      cost_center,
      status,
      total_purchase_order_cost,
      unique_purchase_orders,
      part_number
    ]
  }


}
