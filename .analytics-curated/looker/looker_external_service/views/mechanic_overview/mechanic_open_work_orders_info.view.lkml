view: mechanic_open_work_orders_info {
  derived_table: {
    sql: select
          wo.work_order_id,
          wo.work_order_type_id,
          concat(u.first_name,' ',u.last_name) as user_assignment,
          u.user_id,
          --listagg(ct.name,', ') as work_order_tags,
          woct.work_order_tags,
          wo.date_created,
          wo.description,
          m.name as branch,
          a.asset_id,
          a.custom_name as asset,
          al.address,
          ot.name as originator,
          round(sum((coalesce(regular_hours, 0))),2) as regular_hours,
          round(sum((coalesce(overtime_hours, 0))),2) as overtime_hours
      from
          work_orders.work_order_user_assignments woua
          join es_warehouse.public.users u on u.user_id = woua.user_id
          join work_orders.work_orders wo on wo.work_order_id = woua.work_order_id
          join es_warehouse.public.markets m on wo.branch_id = m.market_id
          join work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
          join work_orders.originator_types ot on woo.originator_type_id = ot.originator_type_id
          --left join work_orders.work_order_company_tags woct on woct.work_order_id = wo.work_order_id
          --left join work_orders.company_tags ct on ct.company_tag_id = woct.company_tag_id
          left join
                  (
                    select
                      woct.work_order_id,
                      listagg(DISTINCT ct.name,', ') WITHIN GROUP (ORDER BY ct.name) as work_order_tags
                    from
                      work_orders.work_order_company_tags woct
                      left join work_orders.company_tags ct on ct.company_tag_id = woct.company_tag_id
                    where
                      woct.deleted_on is null
                    group by
                      1
                    ) woct on woct.work_order_id = wo.work_order_id
          left join es_warehouse.public.assets a on a.asset_id = wo.asset_id
          left join es_warehouse.public.asset_last_location al on al.asset_id = wo.asset_id
          left join time_tracking.time_entries te on te.user_id = woua.user_id and te.work_order_id = woua.work_order_id
          left join es_warehouse.public.asset_status_key_values askv on askv.asset_id = wo.asset_id and askv.name = 'asset_inventory_status'
      where
          -- (woua.end_date is null OR woua.end_date >= current_timestamp)
          -- AND wo.archived_date is null
          -- AND wo.date_completed is null
          m.company_id = {{ _user_attributes['company_id'] }}
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND {% condition originator_filter %} ot.name {% endcondition %}
          AND {% condition user_assignment_filter %} concat(u.first_name,' ',u.last_name) {% endcondition %}
          AND {% condition inventory_status_filter %} askv.value {% endcondition %}
      group by
          wo.work_order_id,
          wo.work_order_type_id,
          concat(u.first_name,' ',u.last_name),
          u.user_id,
          wo.date_created,
          wo.description,
          m.name,
          a.asset_id,
          a.custom_name,
          al.address,
          ot.name,
          woct.work_order_tags
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: wo_user_assignment {
    type: string
    primary_key: yes
    sql: concat(${work_order_id}, ' ', ${user_assignment}) ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: work_order_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
  }

  dimension: user_assignment {
    type: string
    sql: ${TABLE}."USER_ASSIGNMENT" ;;
  }

  dimension: work_order_tags {
    type: string
    sql: ${TABLE}."WORK_ORDER_TAGS" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
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

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: originator {
    type: string
    sql: ${TABLE}."ORIGINATOR" ;;
  }

  dimension: link_to_work_order_t3 {
    group_label: "Link to T3"
    label: "Work Order ID"
    type: string
    sql: concat(case when ${work_order_type_id} = 1 then 'WO-' else 'INSP-' end,${work_order_id}) ;;
    html:
    {% if work_order_type_id._value == 1 %}
    <h4><p><font color="#00CB86"><b>❯ <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{rendered_value}}</a></u></font></b></font></p></h4>
    <p><b>Date Created:</b></p> <p>{{ work_order_created_formatted._rendered_value  | date: "%b %d, %Y"}}</p>
    <p><b>Originator:</b></p> <p>{{ originator._value }}</p>
    {% else %}
    <h4><p><font color="#FFB14E"><b>❯ <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{rendered_value}}</a></u></font></b></font></p></h4>
    <p><b>Date Created:</b></p> <p>{{ work_order_created_formatted._rendered_value  | date: "%b %d, %Y"}}</p>
    <p><b>Originator:</b></p> <p>{{ originator._value }}</p>
    {% endif %}
    ;;
  }

  dimension: work_order_created_formatted {
    type: date
    group_label: "HTML Passed Date Format"
    label: "Work Order Date Created"
    sql: ${date_created_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: link_to_asset_service_view {
    group_label: "Link to T3"
    label: "Asset"
    type: string
    sql: ${asset} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/service" target="_blank">{{value}}</a></u></font>
    <p><b>Last Address:</b> {{ address._rendered_value }}</p>
    ;;
  }

  dimension: regular_hours {
    type: number
    sql: ${TABLE}."REGULAR_HOURS" ;;
  }

  dimension: overtime_hours {
    type: number
    sql: ${TABLE}."OVERTIME_HOURS" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: assignments {
    type: list
    list_field: user_assignment
  }

  measure: total_regular_hours {
    label: "Total Regular Hours"
    type: sum
    sql: ${regular_hours} ;;
    value_format_name: decimal_1
  }

  measure: total_overtime_hours {
    label: "Total Overtime Hours"
    type: sum
    sql: ${overtime_hours} ;;
    value_format_name: decimal_1
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
      user_assignment,
      work_order_tags,
      work_order_created_formatted,
      description,
      branch,
      asset_id,
      asset,
      address
    ]
  }
}
