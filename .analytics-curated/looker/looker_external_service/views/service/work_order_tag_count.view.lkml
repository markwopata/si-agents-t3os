view: work_order_tag_count {
  derived_table: {
    sql: select
          wo.work_order_id,
          wo.work_order_type_id,
          wo.date_created,
          wo.description,
          ct.name as tag_name,
          m.name as branch,
          woua.user_assignment,
          ct.color,
          a.custom_name as asset,
          a.asset_id,
          al.address
      from
          work_orders.work_orders wo
          join work_orders.work_order_company_tags woct on woct.work_order_id = wo.work_order_id
          left join work_orders.work_orders_by_tag wot on wot.work_order_id = wo.work_order_id
          join work_orders.company_tags ct on ct.company_tag_id = woct.company_tag_id
          join es_warehouse.public.markets m on wo.branch_id = m.market_id
          left join es_warehouse.public.assets a on a.asset_id = wo.asset_id
          join work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
          join work_orders.originator_types ot on woo.originator_type_id = ot.originator_type_id
          left join es_warehouse.public.asset_last_location al on al.asset_id = wo.asset_id
          left join es_warehouse.public.asset_status_key_values askv on askv.asset_id = a.asset_id and askv.name = 'asset_inventory_status'
          left join
          (
          select
              wo.work_order_id,
              listagg(concat(u.first_name,' ',u.last_name), ', ') as user_assignment
          from
              work_orders.work_orders wo
              join work_orders.work_order_user_assignments woua on woua.work_order_id = wo.work_order_id
              left join es_warehouse.public.users u on u.user_id = woua.user_id
              join es_warehouse.public.markets m on wo.branch_id = m.market_id
          where
              wo.archived_date is null
              AND wo.date_completed is null
              AND (woua.end_date is null OR woua.end_date >= current_timestamp)
              AND {% condition branch_filter %} m.name {% endcondition %}
              AND {% condition user_assignment_filter %} concat(u.first_name,' ',u.last_name) {% endcondition %}
          group by
              wo.work_order_id
          ) woua on woua.work_order_id = wo.work_order_id
      where
          wo.archived_date is null
          AND wo.date_completed is null
          AND woct.deleted_on is null
          AND ct.company_id = {{ _user_attributes['company_id'] }}
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND {% condition originator_filter %} ot.name {% endcondition %}
          AND {% condition user_assignment_filter %} woua.user_assignment {% endcondition %}
          AND {% condition inventory_status_filter %} askv.value {% endcondition %}
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }

  dimension: work_order_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
    value_format_name: id
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: tag_name {
    type: string
    sql: ${TABLE}."TAG_NAME" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: user_assignment {
    type: string
    sql: ${TABLE}."USER_ASSIGNMENT" ;;
  }

  dimension: color {
    type: string
    sql: ${TABLE}."COLOR" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: work_order_date_created {
    group_label: "HTML Formatted Date Created"
    label: "Tag Added Date"
    type: date
    sql: ${date_created_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: tag_name_formatted {
    group_label: "HTML Formatted"
    label: "Tag Name"
    type: string
    sql: ${tag_name} ;;
    html: <b><font color={{ color._rendered_value }}>{{ rendered_value }}</font></b> ;;
    # html: <p style="color: white; background-color: {{ color._rendered_value }}; font-size:100%; min-width: 80px; text-align:center; border-radius: 5px; height: 20px">{{ rendered_value }}</p> ;;
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

  measure: unique_work_order_tag_count {
    label: "Work Order Tag Count"
    type: count_distinct
    sql: ${work_order_id} ;;
    filters: [work_order_type_id: "1"]
    drill_fields: [detail*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
  }

  measure: unique_inspection_tag_count {
    label: "Inspection Tag Count"
    type: count_distinct
    sql: ${work_order_id} ;;
    filters: [work_order_type_id: "2"]
    drill_fields: [detail*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
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
      link_to_asset_service_view,
      address,
      tag_name_formatted,
      branch,
      user_assignment
    ]
  }
}
