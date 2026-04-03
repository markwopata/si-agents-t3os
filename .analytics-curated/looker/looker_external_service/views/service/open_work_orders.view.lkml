view: open_work_orders {
  derived_table: {
    sql: select
          wo.work_order_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',wo.date_created)::date as date_created,
          wo.description,
          a.asset_id,
          a.custom_name as asset,
          m.name as branch,
          listagg(DISTINCT coalesce(ct.name,''), ', ') as tags_assigned_to_wo,
          al.address,
          wo.work_order_type_id,
          datediff(days,wo.date_created,current_date) as days_open,
          concat(u.first_name,' ',u.last_name) as user_assignment,
          ot.name as originator
      from
          work_orders.work_orders wo
          left join es_warehouse.public.markets m on wo.branch_id = m.market_id
          left join es_warehouse.public.assets a on a.asset_id = wo.asset_id
          left join work_orders.work_order_user_assignments woua on woua.work_order_id = wo.work_order_id AND (woua.end_date is null OR woua.end_date <= current_timestamp())
          left join es_warehouse.public.users u on u.user_id = woua.user_id
          left join work_orders.work_order_company_tags woct on woct.work_order_id = wo.work_order_id
          left join work_orders.work_orders_by_tag wot on wot.work_order_id = wo.work_order_id
          left join work_orders.company_tags ct on ct.company_tag_id = woct.company_tag_id
          left join work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
          left join work_orders.originator_types ot on woo.originator_type_id = ot.originator_type_id
          left join es_warehouse.public.asset_last_location al on al.asset_id = wo.asset_id
          left join es_warehouse.public.asset_status_key_values askv on askv.asset_id = a.asset_id and askv.name = 'asset_inventory_status'
      where
          wo.archived_date is null
          AND wo.date_completed is null
          AND woct.deleted_on is null
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND {% condition originator_filter %} ot.name {% endcondition %}
          AND {% condition user_assignment_filter %} concat(u.first_name,' ',u.last_name) {% endcondition %}
          AND {% condition inventory_status_filter %} askv.value {% endcondition %}
          AND m.company_id = {{ _user_attributes['company_id'] }}
      group by
          wo.work_order_id,
          wo.date_created,
          wo.description,
          a.asset_id,
          a.custom_name,
          m.name,
          al.address,
          wo.work_order_type_id,
          concat(u.first_name,' ',u.last_name),
          ot.name
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: tags_assigned_to_wo {
    type: string
    sql: ${TABLE}."TAGS_ASSIGNED_TO_WO" ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: work_order_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
  }

  dimension: days_open {
    type: number
    sql: ${TABLE}."DAYS_OPEN" ;;
  }

  dimension: user_assignment {
    type: string
    sql: ${TABLE}."USER_ASSIGNMENT" ;;
  }

  dimension: originator {
    type: string
    sql: ${TABLE}."ORIGINATOR" ;;
  }

  dimension: work_order_date_created {
    group_label: "HTML Formatted Date Created"
    label: "Tag Added Date"
    type: date
    sql: ${date_created_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: link_to_asset_service_view {
    group_label: "Link To T3"
    label: "Asset"
    type: string
    sql: ${asset} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/service" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: link_to_work_order_t3 {
    group_label: "Link to T3"
    label: "Work Order ID"
    type: string
    sql: concat(case when ${work_order_type_id} = 1 then 'WO-' else 'INSP-' end,${work_order_id}) ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  measure: total_open_work_orders {
    type: count_distinct
    sql: ${work_order_id} ;;
    filters: [work_order_type_id: "1"]
    drill_fields: [detail*]
  }

  measure: total_open_inspections {
    type: count_distinct
    sql: ${work_order_id} ;;
    filters: [work_order_type_id: "2"]
    drill_fields: [detail*]
  }

  measure: total_days_open {
    type: sum
    sql: ${days_open} ;;
  }

  filter: branch_filter {
  }

  filter: originator_filter {
  }

  filter: user_assignment_filter {
  }

  filter: inventory_status_filter {
  }

  set: detail {
    fields: [
      link_to_work_order_t3,
      work_order_date_created,
      description,
      tags_assigned_to_wo,
      link_to_asset_service_view,
      branch,
      address,
      total_days_open
    ]
  }
}
