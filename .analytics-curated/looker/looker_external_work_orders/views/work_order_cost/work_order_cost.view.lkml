view: work_order_cost {
  derived_table: {
    sql:
with parts_cost as (
    SELECT TO_WO.WORK_ORDER_ID,
       sum(to_wo.TOTAL_COST - COALESCE(from_wo.TOTAL_COST, 0)) AS PARTS_TOTAL_COST,
       sum(to_wo.quantity - COALESCE(from_wo.quantity, 0)) AS PARTS_QUANTITY
FROM (SELECT IT.TO_ID AS WORK_ORDER_ID,
             sum(TI.COST_PER_ITEM * TI.quantity_received) AS TOTAL_COST,
             sum(TI.quantity_received) as quantity
        FROM ES_WAREHOUSE.INVENTORY.TRANSACTIONS IT
        JOIN ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS TI
          ON IT.TRANSACTION_ID = TI.TRANSACTION_ID
       WHERE IT.TRANSACTION_TYPE_ID = 7
         AND IT.TRANSACTION_STATUS_ID = 5
         AND IT.COMPANY_ID = {{ _user_attributes['company_id'] }}
         AND IT.DATE_COMPLETED IS NOT NULL
       GROUP BY IT.TO_ID, TI.PART_ID
      ) AS TO_WO
 LEFT JOIN (SELECT IT.FROM_ID AS WORK_ORDER_ID,
                   sum(TI.COST_PER_ITEM * TI.quantity_received) AS TOTAL_COST,
                   sum(TI.quantity_received) as quantity
              FROM ES_WAREHOUSE.INVENTORY.TRANSACTIONS IT
              JOIN ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS TI
                ON IT.TRANSACTION_ID = TI.TRANSACTION_ID
             WHERE IT.TRANSACTION_TYPE_ID = 9
               AND IT.TRANSACTION_STATUS_ID = 5
               AND IT.DATE_COMPLETED IS NOT NULL
             GROUP BY IT.FROM_ID, TI.PART_ID
            ) AS FROM_WO
ON TO_WO.WORK_ORDER_ID = FROM_WO.WORK_ORDER_ID
GROUP BY TO_WO.WORK_ORDER_ID
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
, previous_utilization as (
select
  al.asset_id,
  sum(on_time + idle_time)/3600 as previous_on_time
from
  own_asset_ids al
  left join es_warehouse.public.hourly_asset_usage hau on al.asset_id = hau.asset_id
where
  report_range:start_range <= dateadd(day,-1,convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}))
  AND
  report_range:end_range >= dateadd(
    day,
    datediff(day,
      convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}),
      convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
      ),
    convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}))
group by
  al.asset_id
)
, selected_work_orders as (
select
  al.asset_id,
  al.asset,
  al.asset_class,
  al.asset_type,
  al.make,
  al.model,
  al.category,
  sum(coalesce(wo.cost,0) + coalesce(pc.parts_total_cost, 0)) as selected_cost,
  count(wo.work_order_id) as selected_total_work_orders
from
  own_asset_ids al
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
       )wo on wo.asset_id = al.asset_id
  left join parts_cost pc on wo.work_order_id = pc.work_order_id
where
  {% condition status_filter %} wo.work_order_status_name {% endcondition %}
  and {% condition invoice_filter %} wo.invoice_formatted {% endcondition %}
  and
  {% if date_range_breakdown._parameter_value == "'Work Order Created'" %}
  wo.date_created
  {% elsif date_range_breakdown._parameter_value == "'Work Order Completed'" %}
  wo.date_completed
  {% else %}
  wo.date_created
  {% endif %}
    BETWEEN
    convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
    AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
  AND (wo.cost > 0 or pc.parts_total_cost > 0)
  AND wo.archived_date is null
group by
  al.asset_id,
  al.asset,
  al.asset_class,
  al.asset_type,
  al.make,
  al.model,
  al.category
)
, previous_work_orders as (
select
  al.asset_id,
  sum(coalesce(wo.cost,0) + coalesce(pc.parts_total_cost, 0)) as previous_cost,
  count(wo.work_order_id) as previous_total_work_orders
from
  own_asset_ids al
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
  )wo on wo.asset_id = al.asset_id
  left join parts_cost pc on wo.work_order_id = pc.work_order_id
WHERE
  {% condition status_filter %} wo.work_order_status_name {% endcondition %}
  and {% condition invoice_filter %} wo.invoice_formatted {% endcondition %}
  and
  {% if date_range_breakdown._parameter_value == "'Work Order Created'" %}
  wo.date_created
  {% elsif date_range_breakdown._parameter_value == "Work Order Completed" %}
  wo.date_completed
  {% else %}
  wo.date_created
  {% endif %}
    BETWEEN dateadd(
      day,
      datediff(day,
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}),
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
      ),
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
    )
    AND dateadd(day,-1,convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}))
  AND (wo.cost > 0 or pc.parts_total_cost > 0)
  AND wo.archived_date is null
group by
  al.asset_id
)
SELECT
  al.asset_id,
  al.asset,
  al.asset_class,
  al.asset_type,
  al.make,
  al.model,
  al.category,
  sw.selected_cost as selected_cost,
  sw.selected_total_work_orders,
  pw.previous_total_work_orders,
  coalesce(pw.previous_cost,0) as previous_cost,
  coalesce(su.selected_on_time,0) as selected_on_time,
  coalesce(pu.previous_on_time,0) as previous_on_time,
  ot.name as originator
FROM
  own_asset_ids al
  left join selected_work_orders sw on sw.asset_id = al.asset_id
  left join previous_work_orders pw on pw.asset_id = al.asset_id
  left join selection_utilization su on su.asset_id = al.asset_id
  left join previous_utilization pu on pu.asset_id = al.asset_id
  left join work_orders.work_orders wo on wo.asset_id = al.asset_id
  left join work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
  left join work_orders.originator_types ot on woo.originator_type_id = ot.originator_type_id
-- Filtering to only show assets with _either_ a selected period or prev. period costed work order
WHERE    sw.selected_total_work_orders >= 1
      or pw.previous_total_work_orders >= 1
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

  filter: status_filter {
    label: "Work Order Status Filter"
    type: string
  }

  filter: invoice_filter {
    type: string
  }

  filter: branch_filter {
    type: string
  }

  filter: originator_filter {
    type: string
  }

  measure: count {
    type: count
    drill_fields: [selected_work_order_detail*]
  }

  dimension: asset_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
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

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: selected_cost {
    type: number
    sql: ${TABLE}."SELECTED_COST" ;;
    value_format_name: usd_0
  }

  dimension: previous_cost {
    type: number
    sql: ${TABLE}."PREVIOUS_COST" ;;
    value_format_name: usd_0
  }

  dimension: selected_on_time {
    type: number
    sql: ${TABLE}."SELECTED_ON_TIME" ;;
    value_format_name: decimal_2
  }

  dimension: previous_on_time {
    type: number
    sql: ${TABLE}."PREVIOUS_ON_TIME" ;;
    value_format_name: decimal_2
  }

  dimension: selected_total_work_orders {
    type: number
    sql: ${TABLE}."SELECTED_TOTAL_WORK_ORDERS" ;;
    value_format_name: decimal_0
  }

  dimension: previous_total_work_orders {
    type: number
    sql: ${TABLE}."PREVIOUS_TOTAL_WORK_ORDERS" ;;
    value_format_name: decimal_0
  }

  dimension: originator {
    type: string
    sql:${TABLE}."ORIGINATOR" ;;
  }

  dimension: link_to_asset_service_view {
    group_label: "Link To T3"
    label: "Asset"
    type: string
    sql: ${asset} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/service" target="_blank">{{value}}</a></font></u>;;
  }

  measure: total_selected_on_time {
    label: "On Time (Selected)"
    description: "Combined total of run time and idle time."
    type: max
    sql: ${selected_on_time} ;;
    value_format_name: decimal_2
    html: {{rendered_value}} hrs ;;
  }

  measure: total_previous_on_time {
    label: "On Time (Previous)"
    description: "Combined total of run time and idle time."
    type: max
    sql: ${previous_on_time} ;;
    value_format_name: decimal_2
    html: {{rendered_value}} hrs ;;
  }

  measure: total_selected_work_order_cost {
    label: "Total Cost (Selected)"
    type: sum
    sql: ${selected_cost} ;;
    value_format_name: usd
    # drill_fields: [selected_work_order_detail*]
    #html:
    #  {% if value > 0 %}
    #  <a href="#drillmenu" target="_self">{{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    #  {% else %}
    #  <a href="#drillmenu" target="_self">{{rendered_value}}</a>
    #  {% endif %} ;;
  }

  measure: total_selected_work_order_cost_kpi {
    label: "Total Cost KPI (Selected)"
    type: sum
    sql: ${selected_cost} ;;
    value_format_name: usd
    #drill_fields: [selected_work_order_detail*]
  }

  measure: total_previous_work_order_cost {
    label: "Total Cost (Previous)"
    type: sum
    sql: ${previous_cost} ;;
    value_format_name: usd
    #drill_fields: [previous_work_order_detail*]
    html:
      {% if value > 0 %}
      <a href="#drillmenu" target="_self">{{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
      {% else %}
      <a href="#drillmenu" target="_self">{{rendered_value}}</a>
      {% endif %} ;;
  }

  measure: total_cost_comparsion {
    label: "Cost Change vs Previous"
    # type: sum
    type: number
    # sql: ${asset_cost_selected_vs_previous} ;;
    sql: ${total_selected_work_order_cost} - ${total_previous_work_order_cost} ;;
    value_format_name: usd
    html:
    {% if value < 0 %}
    <font color="#00CB86">▾ {{ rendered_value }}</font>
    {% elsif value > 0 %}
    <font color="#DA344D">▴ {{ rendered_value }}</font>
    {% else %}
    {{ rendered_value }}
    {% endif %} ;;
  }

  measure: total_cost_comparison_noformat {
    label: "Cost Change vs Previous (No Formatting)"
    type: number
    sql: ${total_selected_work_order_cost} - ${total_previous_work_order_cost} ;;
    value_format_name: usd
  }

  measure: total_selected_work_orders {
    label: "Work Orders (Selected)"
    type: sum
    sql: ${selected_total_work_orders} ;;
  }

  measure: total_previous_work_orders {
    label: "Work Orders (Previous)"
    type: sum
    sql: ${previous_total_work_orders} ;;
  }

  parameter: date_range_breakdown {
    type: string
    allowed_value: { value: "Work Order Created"}
    allowed_value: { value: "Work Order Completed"}
  }

  set: selected_work_order_detail {
    fields: [
      work_order_cost_selected_detail.detail*
    ]
  }

  set:  previous_work_order_detail {
    fields: [
      work_order_cost_previous_detail.detail*
    ]
  }
}
