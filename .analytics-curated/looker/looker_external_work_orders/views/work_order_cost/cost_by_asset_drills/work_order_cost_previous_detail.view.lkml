view: work_order_cost_previous_detail {
  derived_table: {
    sql:
select
  a.asset_id,
  a.custom_name as asset,
  c.name as category,
  concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type,
  a.asset_class,
  concat(coalesce(a.make, ' '), concat(' ', coalesce(a.model, ' '))) as make_and_model,
  wo.work_order_id,
  wo.date_created,
  m.name as branch,
  wo.date_completed,
  wo.hours_at_service,
  wo.work_order_status_name,
  wo.description,
  wo.cost,
  wo.invoice_formatted
from
  table(assetlist({{ _user_attributes['user_id'] }}::numeric)) al
   join (select
          *,
          case
            when invoice_number = '' then 'No Invoice Number Assigned'
            else coalesce(invoice_number, 'No Invoice Number Assigned')
          end as invoice_formatted
        from work_orders.work_orders
       )wo on wo.asset_id = al.asset_id
  left join markets m on m.market_id = wo.branch_id
  left join assets a on wo.asset_id = a.asset_id
  left join categories c on c.category_id = a.category_id
  left join asset_types ast on ast.asset_type_id = a.asset_type_id
 where
  {% condition work_order_cost.status_filter %} wo.work_order_status_name {% endcondition %}
  AND {% condition work_order_cost.class_filter %} a.asset_class {% endcondition %}
  AND {% condition work_order_cost.category_filter %} category {% endcondition %}
  AND {% condition work_order_cost.make_filter %} a.make {% endcondition %}
  AND {% condition work_order_cost.model_filter %} a.model {% endcondition %}
  AND {% condition work_order_cost.asset_type_filter %} asset_type {% endcondition %}
  AND {% condition work_order_cost.asset_filter %} asset {% endcondition %}
  AND {% condition invoice_filter %} wo.invoice_formatted {% endcondition %}
  AND {% condition branch_filter %} m.name {% endcondition %}
  AND wo.archived_date is null
  AND wo.cost > 0
  AND wo.date_created
    BETWEEN dateadd(
      day,
      datediff(
        day,
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end work_order_cost.date_filter %}),
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start work_order_cost.date_filter %})
      ),
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start work_order_cost.date_filter %})
      )
    AND     dateadd(
      day,
      -1,
      convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start work_order_cost.date_filter %})
      )
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

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
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
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: make_and_model {
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }

  dimension: work_order_id {
    type: string
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension_group: date_completed {
    type: time
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  dimension: work_order_status_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_STATUS_NAME" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}."COST" ;;
    value_format_name: usd
  }

  dimension: hours_at_service {
    type: number
    sql: ${TABLE}."HOURS_AT_SERVICE" ;;
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
    html: <font color="blue"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/history?selectedDate={{ current_date._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: link_to_work_order_t3 {
    group_label: "Link to T3"
    label: "Work Order ID"
    type: string
    sql: concat('WO-',${work_order_id}) ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  dimension: invoice_formatted {
    label: "Invoice Number"
    type: string
    sql: ${TABLE}."INVOICE_FORMATTED" ;;
  }

  measure: total_previous_wo_cost{
    label: "Total Previous WO Cost"
    type: sum
    sql: ${cost};;
    value_format_name: usd
  }

  dimension_group: date_created_formatted {
    type: time
    group_label: "HTML Formatted Date"
    label: "Date Created"
    sql: ${date_created_date};;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension_group: date_completed_formatted {
    type: time
    group_label: "HTML Formatted Date"
    label: "Date Completed"
    sql: ${date_completed_date};;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  set: detail {
    fields: [
      link_to_work_order_t3,
      link_to_asset_t3,
      class,
      make_and_model,
      hours_at_service,
      description,
      date_created_formatted_date,
      date_completed_formatted_date,
      work_order_status_name,
      total_previous_wo_cost
      ]
  }
}
