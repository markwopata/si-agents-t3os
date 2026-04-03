view: warranty_work_orders {
  derived_table: {
    sql: select
           c.name as category,
           a.custom_name as asset,
           aa.oec as oec,
           wo.work_order_id,
           wo.date_created,
           m.name as branch,
           wo.asset_id as asset_id_asl,
           initcap(ast.name) as asset_type,
           a.asset_class,
           concat(a.make,' ',a.model) as make_and_model,
           case when severity_level_id = 1 then 'Soft Down' when severity_level_id = 2 then 'Hard Down' else 'Undefined' end as down_status,
           ul.name as urgency_level,
           value as asset_health_status
      from es_warehouse.work_orders.work_orders wo
         join work_orders.urgency_levels ul on wo.urgency_level_id = ul.urgency_level_id
          left join markets m on m.market_id = wo.branch_id
          join assets a on wo.asset_id = a.asset_id
          left join markets mb on mb.market_id = a.service_branch_id
          left join categories c on c.category_id = a.category_id
          left join asset_types ast on ast.asset_type_id = a.asset_type_id
          left join (select alo.asset_id, value from asset_status_key_values askv left join  table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo on alo.asset_id = askv.asset_id where name = 'asset_health_status') ah on ah.asset_id = wo.asset_id
          left join es_warehouse.public.assets_aggregate aa on a.asset_id = aa.asset_id
          --left join asset_last_location ll on ll.asset_id = wo.asset_id
      where
          wo.date_completed is null
          AND wo.archived_date is null
          AND m.company_id in ({{ _user_attributes['company_id'] }}::numeric) --1854::numeric
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

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: oec {
    label:"OEC"
    value_format_name: usd_0
    type: string
    sql: ${TABLE}."OEC" ;;
  }

  dimension: work_order_id {
    type: string
    sql: ${TABLE}."WORK_ORDER_ID";;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: asset_id_asl {
    type: number
    sql: ${TABLE}."ASSET_ID_ASL" ;;
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
    type: string
    sql: ${TABLE}."DOWN_STATUS" ;;
  }

  dimension: urgency_level {
    type: string
    sql: ${TABLE}."URGENCY_LEVEL" ;;
  }

  dimension: asset_health_status {
    type: string
    sql: ${TABLE}."ASSET_HEALTH_STATUS" ;;
    html:
    {% if asset_health_status._value == 'Hard Down'  %}
    <font color="#DA344D">{{rendered_value }}</font>
    {% else %}
    {{rendered_value}}
    {% endif %}
    ;;
  }

  set: detail {
    fields: [
      category,
      asset,
      work_order_id,
      branch,
      asset_id_asl,
      asset_type,
      asset_class,
      make_and_model,
      down_status,
      urgency_level,
      asset_health_status
    ]
  }

  dimension: link_to_work_order_t3 {
 #   order_by_field: oec
    group_label: "Link to T3"
    label: "Work Order ID"
    type: string
    sql: concat('WO-',${work_order_id}) ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
}