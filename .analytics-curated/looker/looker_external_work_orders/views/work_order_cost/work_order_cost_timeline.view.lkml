view: work_order_cost_timeline {
  derived_table: {
    sql:
with owned_assets as (
  select
    al.asset_id,
    coalesce(a.custom_name, 'Unnamed') as custom_name,
    a.asset_class as class,
    concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type,
    c.name as category,
    a.make,
    a.model,
    concat(coalesce(a.make, ' '), concat(' ', coalesce(a.model, ' '))) as make_and_model
  from
    table(assetlist({{ _user_attributes['user_id'] }}::numeric)) al
    left join assets a on al.asset_id = a.asset_id
    left join categories c on c.category_id = a.category_id
    left join asset_types ast on ast.asset_type_id = a.asset_type_id
  where
    {% condition work_order_cost.class_filter %} a.asset_class {% endcondition %}
    AND {% condition work_order_cost.category_filter %} category {% endcondition %}
    AND {% condition work_order_cost.make_filter %} a.make {% endcondition %}
    AND {% condition work_order_cost.model_filter %} a.model {% endcondition %}
    AND {% condition work_order_cost.asset_type_filter %} asset_type {% endcondition %}
    AND {% condition work_order_cost.asset_filter %} custom_name {% endcondition %}
)
SELECT
  oa.asset_id,
  oa.custom_name,
  oa.category,
  oa.asset_type,
  oa.class,
  oa.make,
  oa.model,
  oa.make_and_model,
  wo.work_order_id,
  wo.date_created,
  m.name as branch,
  wo.date_completed,
  wo.work_order_status_name,
  coalesce(wo.description, ' ') as description,
  wo.work_order_type_id,
  coalesce(wo.cost, 0) as cost,
  coalesce(wo.hours_at_service, 0) as hours_at_service,
  wo.invoice_formatted
FROM
  owned_assets oa
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
       )wo on wo.asset_id = oa.asset_id
  left join markets m on m.market_id = wo.branch_id
WHERE
  {% condition work_order_cost.status_filter %} wo.work_order_status_name {% endcondition %}
  AND {% condition invoice_filter %} wo.invoice_formatted {% endcondition %}
  AND wo.archived_date is NULL
  AND wo.date_created
    BETWEEN
    dateadd(
      day,
      datediff(day,
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end work_order_cost.date_filter %}),
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start work_order_cost.date_filter %})
        ),
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start work_order_cost.date_filter %})
      )
    AND
    convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end work_order_cost.date_filter %})
  AND cost > 0
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

  measure: count {
    label: "Work Orders Count"
    type: count
    drill_fields: [detail*]
  }

  dimension: work_order_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension_group: date_created {
    group_label: "Date"
    label: "Date Opened"
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
    drill_fields: [] # Disabling drill on cumulative cost TC
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

  dimension_group: date_completed {
    group_label: "Date"
    label: "Date Closed"
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
    drill_fields: [detail*]
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
    group_label: "Link to T3"
    label: "Asset"
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/history?selectedDate={{ current_date._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: link_to_work_order_t3 {
    #   order_by_field: oec
    group_label: "Link to T3"
    label: "Work Order ID"
    type: string
    sql: concat('WO-',${work_order_id}) ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  dimension: invoice_formatted {
    label: "Invoice Number"
    type: string
    sql: ${TABLE}."INVOICE_FORMATTED" ;;
  }

  measure: total_current_wo_cost{
    label: "Work Order Cost w/ Description"
    type: sum
    sql: ${cost};;
    value_format_name: usd
    html: {{rendered_value}}
    <br />
    <p>
    </p>
    <p>Description:
    <br />{{ description._value }}
    </p>
    ;;
    drill_fields: [detail*]
  }

  measure: total_current_wo_cost_noformat{
    label: "Work Order Cost"
    type: sum
    sql: ${cost};;
    value_format_name: usd
    drill_fields: [detail*]
  }

  dimension_group: date_created_formatted {
    type: time
    group_label: "HTML Formatted Date"
    label: "Date Opened"
    sql: ${date_created_date};;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension_group: date_completed_formatted {
    type: time
    group_label: "HTML Formatted Date"
    label: "Date Closed"
    sql: ${date_completed_date};;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  set:  detail {
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
      total_current_wo_cost_noformat
    ]
  }
}
