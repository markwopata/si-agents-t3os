view: overdue_work_order_inspections {
  derived_table: {
    sql: select
          wo.work_order_id,
          wo.work_order_type_id,
          wo.description,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',wo.date_created)::date as date_created,
          ot.name as originator,
          a.custom_name as asset,
          a.asset_id,
          concat(a.make, ' ',coalesce(a.model,'')) as make_and_model,
          m.name as branch,
          listagg(DISTINCT ct.name, ', ') as tags_assigned_to_wo,
          al.address,
          case when UPPER(asl.maintenance_group_interval_name) like '%ANSI%' THEN 'Overdue ANSI'
          when UPPER(asl.maintenance_group_interval_name) like '%ANNUAL%' THEN 'Overdue Annual'
          when UPPER(asl.maintenance_group_interval_name) like '%DOT%' THEN 'Overdue DOT'
          when (UPPER(asl.maintenance_group_interval_name) NOT like '%ANSI%' OR UPPER(asl.maintenance_group_interval_name) NOT like '%ANNUAL%' OR UPPER(asl.maintenance_group_interval_name) NOT like '%DOT%') then 'Overdue PM'
          else
          'Unclassfied'
          end as overdue_status
      from
          es_warehouse.public.asset_service_intervals asl
          join work_orders.work_orders wo on asl.work_order_id = wo.work_order_id
          join es_warehouse.public.markets m on wo.branch_id = m.market_id
          join es_warehouse.public.assets a on a.asset_id = wo.asset_id
          left join work_orders.work_order_company_tags woct on woct.work_order_id = wo.work_order_id
          left join work_orders.company_tags ct on ct.company_tag_id = woct.company_tag_id
          left join work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
          left join work_orders.originator_types ot on woo.originator_type_id = ot.originator_type_id
          left join work_orders.work_order_user_assignments woua on woua.work_order_id = wo.work_order_id AND (woua.end_date is null OR woua.end_date >= current_timestamp)
          left join es_warehouse.public.users u on u.user_id = woua.user_id
          left join es_warehouse.public.asset_last_location al on al.asset_id = wo.asset_id
          left join es_warehouse.public.asset_status_key_values askv on askv.asset_id = a.asset_id and askv.name = 'asset_inventory_status'
      where
          {% condition branch_filter %} m.name {% endcondition %}
          AND m.company_id = {{ _user_attributes['company_id'] }}
          AND wo.archived_date is null
          AND woct.deleted_on is null
          AND {% condition originator_filter %} ot.name {% endcondition %}
          AND {% condition user_assignment_filter %} concat(u.first_name,' ',u.last_name) {% endcondition %}
          AND {% condition inventory_status_filter %} askv.value {% endcondition %}
          AND (coalesce(truncate((asl.usage_percentage_remaining*100)),truncate((asl.time_percentage_remaining*100)))) <= 0
      group by
          wo.work_order_id,
          wo.work_order_type_id,
          wo.description,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',wo.date_created)::date,
          ot.name,
          a.custom_name,
          a.asset_id,
          concat(a.make, ' ',coalesce(a.model,'')),
          m.name,
          al.address,
          case when UPPER(asl.maintenance_group_interval_name) like '%ANSI%' THEN 'Overdue ANSI'
          when UPPER(asl.maintenance_group_interval_name) like '%ANNUAL%' THEN 'Overdue Annual'
          when UPPER(asl.maintenance_group_interval_name) like '%DOT%' THEN 'Overdue DOT'
          when (UPPER(asl.maintenance_group_interval_name) NOT like '%ANSI%' OR UPPER(asl.maintenance_group_interval_name) NOT like '%ANNUAL%' OR UPPER(asl.maintenance_group_interval_name) NOT like '%DOT%') then 'Overdue PM'
          else
          'Unclassfied'
          end
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

  dimension: work_order_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: date_created {
    type: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: originator {
    type: string
    sql: ${TABLE}."ORIGINATOR" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: make_and_model {
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: tags_assigned_to_wo {
    label: "Work Order Tags"
    type: string
    sql: ${TABLE}."TAGS_ASSIGNED_TO_WO" ;;
  }

  dimension: overdue_status {
    type: string
    sql: ${TABLE}."OVERDUE_STATUS" ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: link_to_work_order_t3 {
    group_label: "Link to T3"
    label: "Work Order ID"
    type: string
    sql: concat(case when ${work_order_type_id} = 1 then 'WO-' else 'INSP-' end,${work_order_id}) ;;
    html:
    <h4><p><font color="#b02a3e"><b>❯ {{overdue_status._rendered_value}}</b></font></p></h4>
    <p><font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{rendered_value}}</a></u></font></p>
    <p><b>Work Order Tags:</b></p> <p>{{tags_assigned_to_wo._value}}</p>
    ;;
  }

  dimension: asset_custom_name_to_asset_info {
    group_label: "Link to T3"
    label: "Asset"
    type: string
    sql: ${asset};;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{rendered_value}}</a></u></font>
    <p><b>Make and Model:</b></p> <p>{{make_and_model._value}}</p>
    <p><b>Last Address Location:</b></p> <p>{{address._value}}</p>
    ;;
  }

  dimension: work_order_created_formatted {
    type: date
    group_label: "HTML Passed Date Format"
    label: "Work Order Date Created"
    sql: ${date_created} ;;
    html: <b>Work Order Date Created:</b></p> <p>{{ rendered_value | date: "%b %d, %Y"  }}</p>
    <p><b>Description:</b></p> <p>{{description._value}}</p>
    ;;
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
      work_order_id,
      work_order_type_id,
      description,
      date_created,
      originator,
      asset,
      asset_id,
      branch,
      tags_assigned_to_wo
    ]
  }
}
