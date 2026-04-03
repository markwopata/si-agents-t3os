view: work_order_cost_detail {
  derived_table: {
    sql:
    with parts_cost as (
select
wo.work_order_id,
sum(ti.INVENTORY_TRANSACTION_ITEM_COST_PER_ITEM * -ti.INVENTORY_TRANSACTION_ITEM_QUANTITY_RECEIVED) as PARTS_TOTAL_COST,
sum(ti.INVENTORY_TRANSACTION_ITEM_QUANTITY_ORDERED) as PARTS_QUANTITY
from PLATFORM.GOLD.FACT_INVENTORY_TRANSACTIONS ti
join PLATFORM.GOLD.FACT_WORK_ORDER_LINES wol
    on ti.INVENTORY_TRANSACTION_WORK_ORDER_KEY = wol.WORK_ORDER_LINE_WORK_ORDER_KEY
    and ti.INVENTORY_TRANSACTION_PART_KEY = wol.WORK_ORDER_LINE_PART_KEY
join FLEET_OPTIMIZATION.GOLD.DIM_WORK_ORDERS_FLEET_OPT wo
    on ti.INVENTORY_TRANSACTION_WORK_ORDER_KEY = wo.WORK_ORDER_KEY
group by wo.work_order_id
    )
   , own_asset_ids as (
select
  al.asset_id,
  a.custom_name as asset,
  a.asset_class,
  concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type,
  a.make,
  a.model,
  concat(coalesce(a.make, ' '), concat(' ', coalesce(a.model, ' '))) as make_and_model,
  cat.name as category
from
  table(assetlist({{ _user_attributes['user_id'] }}::numeric)) al
  join assets a on al.asset_id = a.asset_id
  left join asset_types ast on ast.asset_type_id = a.asset_type_id
  left join categories cat on cat.category_id = a.category_id
where
  {% condition class_filter %} a.asset_class {% endcondition %}
  AND {% condition category_filter %} category {% endcondition %}
  AND {% condition make_filter %} a.make {% endcondition %}
  AND {% condition model_filter %} a.model {% endcondition %}
  AND {% condition asset_type_filter %} asset_type {% endcondition %}
  AND {% condition asset_filter %} asset {% endcondition %}
)
, selection_utilization as (
select
  al.asset_id,
  sum(on_time + idle_time)/3600 as selected_on_time
from
  own_asset_ids al
  left join es_warehouse.public.hourly_asset_usage hau on al.asset_id = hau.asset_id
where
  (report_range:start_range >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
  AND report_range:end_range<= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}))
group by
  al.asset_id
)
select
  a.asset_id,
  coalesce(a.custom_name, 'Unnamed') as asset,
  c.name as category,
  concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type,
  a.asset_class as class,
  a.make,
  a.model,
  concat(coalesce(a.make, ' '), concat(' ', coalesce(a.model, ' '))) as make_and_model,
  wo.work_order_id,
  wo.date_created,
  m.name as branch,
  wo.date_completed,
  wo.work_order_status_name,
  coalesce(wo.description, ' ') as description,
  wo.work_order_type_id,
  wo.billing_type_id,
  bt.name as billing_type,
  coalesce(wo.cost, 0) as cost,
  wo.invoice_formatted,
  coalesce(p.parts_total_cost, 0) as parts_total_cost,
  coalesce(p.parts_quantity, 0) as parts_quantity,
  coalesce(su.selected_on_time,0) as selected_on_time,
  ot.name as originator
from
  table(assetlist({{ _user_attributes['user_id'] }}::numeric)) al
  join (select
          wo.*,
          case
            when invoice_number = '' then 'No Invoice Number Assigned'
            else coalesce(invoice_number, 'No Invoice Number Assigned')
          end as invoice_formatted,
          m.name as branch
        from work_orders.work_orders wo
        left join markets m on m.market_id = wo.branch_id
        where
          {% condition branch_filter %} m.name {% endcondition %}
       ) wo on wo.asset_id = al.asset_id
  left join markets m on m.market_id = wo.branch_id
  left join assets a on wo.asset_id = a.asset_id
  left join categories c on c.category_id = a.category_id
  left join asset_types ast on ast.asset_type_id = a.asset_type_id
  left join parts_cost p on p.work_order_id = wo.work_order_id
  left join selection_utilization su on su.asset_id = al.asset_id
  left join work_orders.billing_types bt on wo.billing_type_id = bt.billing_type_id
  left join work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
  left join work_orders.originator_types ot on woo.originator_type_id = ot.originator_type_id
 where
  {% condition status_filter %} wo.work_order_status_name {% endcondition %}
  and wo.archived_date is null
  AND
  {% if date_range_breakdown._parameter_value == "'Work Order Created'" %}
  wo.date_created
  {% elsif date_range_breakdown._parameter_value == "'Work Order Completed'" %}
  wo.date_completed
  {% else %}
  wo.date_created
  {% endif %}
    BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
        AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
  --(wo.date_created >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
  --AND wo.date_created <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}))
  AND {% condition class_filter %} class {% endcondition %}
  AND {% condition category_filter %} category {% endcondition %}
  AND {% condition make_filter %} a.make {% endcondition %}
  AND {% condition model_filter %} a.model {% endcondition %}
  AND {% condition asset_type_filter %} asset_type {% endcondition %}
  AND {% condition asset_filter %} asset {% endcondition %}
  AND {% condition invoice_filter %} wo.invoice_formatted {% endcondition %}
  AND (cost > 0 OR p.parts_total_cost > 0)
  AND {% condition originator_filter %} ot.name {% endcondition %}
 ;;

  }

  filter: date_filter {
    type: date
  }

  filter: class_filter {
    type: string
  }

  filter: category_filter {
    type: string
  }

  filter: asset_type_filter {
    type: string
  }

  filter: asset_filter {
    type: string
  }

  filter: make_filter {
    type: string
  }

  filter: model_filter {
    type: string
  }

  filter: invoice_filter {
    type: string
  }

  filter: status_filter {
    label: "Work Order Status Filter"
    type: string
  }

  filter: branch_filter {
    type: string
  }

  filter: originator_filter {
    type: string
  }

  measure: count {
    group_label: "Work Order Counts by Status"
    label: "Total Work Orders"
    type: count
    drill_fields: [detail*]
  }

  measure: count_open {
    group_label: "Work Order Counts by Status"
    label: "Open Work Orders"
    type: count
    filters: [work_order_status_name: "'Open'"]
    drill_fields: [detail*]
  }

  measure: count_closed {
    group_label: "Work Order Counts by Status"
    label: "Closed Work Orders"
    type: count
    filters: [work_order_status_name: "'Closed'"]
    drill_fields: [detail*]
  }

  measure: count_pending {
    group_label: "Work Order Counts by Status"
    label: "Pending Work Orders"
    type: count
    filters: [work_order_status_name: "'Pending'"]
    drill_fields: [detail*]
  }

  measure: count_billed {
    group_label: "Work Order Counts by Status"
    label: "Billed Work Orders"
    type: count
    filters: [work_order_status_name: "'Billed'"]
    drill_fields: [detail*]
  }

  dimension: work_order_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: date_created {
    group_label: "Date"
    label: "Date Opened"
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_created_formatted {
    group_label: "HTML Formatted Date"
    label: "Date Opened"
    sql: ${date_created_date};;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: make_and_model {
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }

  dimension: selected_on_time {
    type: number
    sql: ${TABLE}."SELECTED_ON_TIME" ;;
    value_format_name: decimal_2
  }

  measure: total_selected_on_time {
    label: "On Time (Selected)"
    description: "Combined total of run time and idle time."
    type: max
    sql: ${selected_on_time} ;;
    value_format_name: decimal_2
    html: {{rendered_value}} hrs ;;
  }

  dimension_group: date_completed {
    group_label: "Date"
    label: "Date Closed"
    type: time
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  dimension_group: date_completed_formatted {
    group_label: "HTML Formatted Date"
    label: "Date Closed"
    sql: ${date_completed_date};;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: work_order_status_name {
    label: "Status"
    type: string
    sql: ${TABLE}."WORK_ORDER_STATUS_NAME" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: invoice_formatted {
    label: "Invoice Number"
    type: string
    sql: ${TABLE}."INVOICE_FORMATTED" ;;
  }

  dimension: work_order_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
  }

  dimension: billing_type_id {
    type: number
    sql: ${TABLE}."BILLING_TYPE_ID" ;;
  }

  dimension: billing_type {
    type: string
    sql: ${TABLE}."BILLING_TYPE" ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}."COST" ;;
  }

  dimension: parts_total_cost {
    type: number
    sql: ${TABLE}."PARTS_TOTAL_COST" ;;
  }

  dimension: parts_quantity {
    type: number
    sql: ${TABLE}."PARTS_QUANTITY" ;;
  }

  measure: total_parts_total_cost{
    label: "Total Parts Cost"
    type: sum
    sql: ${parts_total_cost};;
    value_format_name: usd
  }

  measure: total_column{
    label: "Total Cost"
    type: sum
    sql: ${parts_total_cost} + ${cost};;
    value_format_name: usd
    drill_fields: [detail*]
    html:
      {% if value > 0 %}
      <a href="#drillmenu" target="_self">{{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
      {% else %}
      <a href="#drillmenu" target="_self">{{rendered_value}}</a>
      {% endif %} ;;
  }

  measure: total_column_not_formatted{
    label: "Total Cost Not Formatted"
    type: sum
    sql: ${parts_total_cost} + ${cost};;
    value_format_name: usd
    drill_fields: [detail*]
  }


  measure: total_parts_quantity{
    label: "Total Parts Quantity"
    type: sum
    sql: ${parts_quantity};;
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: link_to_asset_t3 {
    type: string
    sql: ${TABLE}."ASSET" ;;
    label: "Asset"
    group_label: "Link to T3 Status Page"
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/history?selectedDate={{ current_date._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: link_to_work_order_t3 {
    #   order_by_field: oec
    group_label: "Link to T3"
    label: "Work Order ID"
    type: string
    sql: concat(case when ${work_order_type_id} = 1 then 'WO-' else 'INSP-' end,${work_order_id}) ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  dimension: originator {
    type: string
    sql: ${TABLE}."ORIGINATOR" ;;
  }

  measure: total_current_wo_cost{
    group_label: "Costs by Work Order Status"
    label: "Total Current WO Cost"
    type: sum
    sql: ${cost};;
    value_format_name: usd
  }

  measure: total_open_wo_cost{
    group_label: "Costs by Work Order Status"
    label: "Open"
    type: sum
    sql: ${parts_total_cost} + ${cost};;
    value_format_name: usd
    filters: [work_order_status_name: "'Open'"]
    drill_fields: [detail*]
  }

  measure: total_pending_wo_cost{
    group_label: "Costs by Work Order Status"
    label: "Pending"
    type: sum
    sql: ${parts_total_cost} + ${cost};;
    value_format_name: usd
    filters: [work_order_status_name: "'Pending'"]
    drill_fields: [detail*]
  }

  measure: total_billed_wo_cost{
    group_label: "Costs by Work Order Status"
    label: "Billed"
    type: sum
    sql: ${parts_total_cost} + ${cost};;
    value_format_name: usd
    filters: [work_order_status_name: "'Billed'"]
    drill_fields: [detail*]
  }

  measure: total_closed_wo_cost{
    group_label: "Costs by Work Order Status"
    label: "Closed"
    type: sum
    sql: ${parts_total_cost} + ${cost};;
    value_format_name: usd
    filters: [work_order_status_name: "'Closed'"]
    drill_fields: [detail*]
  }

  parameter: date_range_breakdown {
    type: string
    allowed_value: { value: "Work Order Created"}
    allowed_value: { value: "Work Order Completed"}
  }

  set: detail {
    fields: [
      work_order_id,
      invoice_formatted,
      asset_id,
      date_created_time,
      branch,
      date_completed_time,
      work_order_status_name,
      description,
      total_current_wo_cost,
      total_parts_total_cost,
      total_column
    ]
  }
}
