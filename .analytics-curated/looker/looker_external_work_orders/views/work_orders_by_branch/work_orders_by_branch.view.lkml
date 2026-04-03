view: work_orders_by_branch {
  derived_table: {
    sql: select
           wo.work_order_id,
           wo.date_created,
           m.name as branch,
           wo.asset_id,
           a.custom_name as asset,
           c.name as category,
           initcap(ast.name) as asset_type,
           a.asset_class,
           concat(a.make,' ',a.model) as make_and_model,
           case when severity_level_id = 1 then 'Soft Down' when severity_level_id = 2 then 'Hard Down' else 'Undefined' end as down_status,
           ul.name as urgency_level,
           value as asset_inventory_status,
           ll.address
      from
          work_orders.work_orders wo
          left join work_orders.urgency_levels ul on wo.urgency_level_id = ul.urgency_level_id
          left join markets m on m.market_id = wo.branch_id
          left join assets a on wo.asset_id = a.asset_id
          left join markets mb on mb.market_id = a.service_branch_id
          left join categories c on c.category_id = a.category_id
          left join asset_types ast on ast.asset_type_id = a.asset_type_id
          left join (select alo.asset_id, value from asset_status_key_values askv left join (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric))) alo on alo.asset_id = askv.asset_id where name = 'asset_inventory_status') ah on ah.asset_id = wo.asset_id
          left join asset_last_location ll on ll.asset_id = wo.asset_id
      where
          wo.date_completed is null
          AND wo.archived_date is null
          AND m.company_id in ('{{ _user_attributes['company_id'] }}'::numeric)
          AND wo.work_order_type_id = 1 --only pulling in general wo and not inspections
          AND wo.work_order_status_id = 1 --work order status is open
          and a.deleted = false
          and m.active = true
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

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: make_and_model {
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }

  dimension: down_status {
    label: "WO Down Status"
    type: string
    sql: ${TABLE}."DOWN_STATUS" ;;
    html:
    {% if down_status._value == 'Hard Down'  %}
    <font color="#DA344D">{{ rendered_value }}</font>
    {% else %}
    {{rendered_value}}
    {% endif %};;
  }

  dimension: urgency_level {
    type: string
    sql: ${TABLE}."URGENCY_LEVEL" ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
    html:
    {% if asset_inventory_status._value == 'Hard Down'  %}
    <font color="#DA344D">{{rendered_value }}</font>
    {% else %}
    {{rendered_value}}
    {% endif %}
    ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  measure: total_soft_down_work_orders {
    type: count
    filters: [down_status: "Soft Down"]
    drill_fields: [detail*]
  }

  measure: total_hard_down_work_orders {
    type: count
    filters: [down_status: "Hard Down"]
    drill_fields: [detail*]
  }

  dimension: hard_down_symbol {
    group_label: "Hard Down Symbol"
    label: " "
    type: string
    sql: case when ${asset_inventory_status} = 'Hard Down' then '►' else ' ' end ;;
    html: {{rendered_value}} ;;
  }

  dimension: link_to_asset_service_view {
    group_label: "Link To T3"
    label: "Asset"
    type: string
    sql: ${asset} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/service" target="_blank">{{value}}</a></font></u>;;
  }

  set: detail {
    fields: [
      work_orders.link_to_work_order_t3,
      work_orders.date_time_formatted,
      work_orders.description,
      down_status,
      urgency_level,
      link_to_asset_service_view,
      asset_inventory_status,
      make_and_model,
      asset_class
    ]
  }
}