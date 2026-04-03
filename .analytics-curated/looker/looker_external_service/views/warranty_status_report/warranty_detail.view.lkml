view: warranty_detail {
  derived_table: {
    sql: WITH work_orders as
      (
      select a.asset_id,
             count(*) AS open_work_orders
      from es_warehouse.work_orders.work_orders wo
          --left join work_orders.urgency_levels ul on wo.urgency_level_id = ul.urgency_level_id
          left join markets m on m.market_id = wo.branch_id
          left join assets a on wo.asset_id = a.asset_id
          --left join markets mb on mb.market_id = a.service_branch_id
          --left join categories c on c.category_id = a.category_id
          --left join asset_types ast on ast.asset_type_id = a.asset_type_id
          --left join (select alo.asset_id, value from asset_status_key_values askv left join (select asset_id from table(assetlist(120416::numeric))) alo on alo.asset_id = askv.asset_id where name = 'asset_health_status') ah on ah.asset_id = wo.asset_id
          --left join asset_last_location ll on ll.asset_id = wo.asset_id
      where
          wo.date_completed is null
          AND wo.archived_date is null
          AND m.company_id in ({{ _user_attributes['company_id'] }}::numeric) --1854::numeric
          AND wo.work_order_type_id = 1 --only pulling in general wo and not inspections
          AND wo.work_order_status_id = 1 --work order status is open
          and a.deleted = false
          and m.active = true
      group by a.asset_id
      )
      ,asset_status_values as
      (
      SELECT askv.asset_id,askv.value as asset_inventory_status FROM asset_status_key_values askv
      JOIN table(assetlist({{ _user_attributes['user_id'] }}::numeric)) asl on asl.asset_id=askv.asset_id
      WHERE NAME = 'asset_inventory_status'
      )
      ,asset_aggregates as
      (
      SELECT
      ag.asset_id,
      case when sum(asset_has_warranty_flg) > 0 then 'Y' else 'N'end as asset_has_warranty,
      case when sum(warranty_is_active_flg) > 0 then 'Y' else 'N'end as asset_has_active_warranty
      FROM
        (
        select asl.asset_id,
        case when awx.asset_id is null then 0 else 1 end as asset_has_warranty_flg,
        add_months(a.placed_in_service,wi.time_value) as warranty_expiration_date,
        --case when awx.asset_id is not null  and  u.name = 'Months' then add_months(a.placed_in_service,wi.time_value)
        --when awx.asset_id is not null  and  u.name = 'Days' then dateadd(day,wi.time_value,a.placed_in_service)
        --when awx.asset_id is not null  and  u.name = 'Weeks' then dateadd(week,wi.time_value,a.placed_in_service)
        --else  null end as warranty_expiration_date,
        DATEDIFF('days',current_date(),warranty_expiration_date)::number(38, 18)+1 as warranty_days_left,
        case when (warranty_days_left >0 and warranty_days_left <= 60) then 'Y' else 'N' end as warranty_expires_60_days,
        case when (warranty_days_left >60 and warranty_days_left <= 120) then 'Y' else 'N' end as warranty_expires_120_days,
        case when (warranty_days_left >=0 and warranty_days_left <= 60) then '0 - 60 Days'
        when (warranty_days_left >61 and warranty_days_left <= 120) then '61 - 120 Days'
        when (warranty_days_left >120 ) then '120+ Days'
        else null end as warranty_expiration_flg,
        case when warranty_days_left > 0 then 1 else 0 end as warranty_is_active_flg
        FROM table(assetlist({{ _user_attributes['user_id'] }}::numeric)) asl
        join es_warehouse.public.assets a on asl.asset_id = a.asset_id
        left join es_warehouse.public.assets_aggregate aa on asl.asset_id = aa.asset_id
        left join es_warehouse.public.asset_warranty_xref awx on  asl.asset_id = awx.asset_id and awx.date_deleted is null
        left join es_warehouse.public.warranties w on w.warranty_id = awx.warranty_id
        left join es_warehouse.public.warranty_items wi on wi.warranty_id=w.warranty_id   and wi.date_deleted is null
        --left join es_warehouse.public.time_intervals t on wi.time_interval_id = t.time_interval_id
        --left join es_warehouse.public.units u on t.unit_id = u.unit_id
        ) ag
     GROUP BY ag.asset_id
      )
      select
      --w.warranty_id as warranty_id_w,
      asl.asset_id as asset_id_asl,
      a.company_id as company_id_a,
      a.year,
      a.serial_number,
      a.vin,
      --aa.asset_id as asset_id_oec,
      --awx.warranty_id,
      a.placed_in_service,
      a.asset_class,
      a.hours,
      a.odometer,
      a.custom_name as asset_name,
      c.name as category,
      w.description as warranty_descr,
      --wi.date_deleted,
      wi.description as warranty_item_descr,
      --u.name as warranty_time_unit,
      --t.value as warranty_time_value,
      coalesce(aa.oec,0) as oec,
      wo.open_work_orders,
      askv.asset_inventory_status,
      concat(a.make,' ',a.model) as make_and_model,
      m.name as branch,
      ag.asset_has_warranty,
      ag.asset_has_active_warranty,
      case when awx.warranty_id is not null then 'N' else 'Y' END as asset_has_active_warranty_flg,
      add_months(a.placed_in_service,wi.time_value) as warranty_expiration_date,
      --case when awx.warranty_id is not null and  u.name = 'Months' then add_months(a.placed_in_service,wi.time_value)
      --when awx.warranty_id is not null and  u.name = 'Days' then dateadd(day,wi.time_value,a.placed_in_service)
      --when awx.warranty_id is not null and  u.name = 'Weeks' then dateadd(week,wi.time_value,a.placed_in_service)
      --else  null end as warranty_expiration_date,
      DATEDIFF('days',current_date(),warranty_expiration_date)::number(38, 18)+1 as warranty_days_left,
      case when (warranty_days_left >0 and warranty_days_left <= 60) then 'Y' else 'N' end as warranty_expires_60_days,
      case when (warranty_days_left >60 and warranty_days_left <= 120) then 'Y' else 'N' end as warranty_expires_120_days,
      case when (warranty_days_left >=0 and warranty_days_left <= 60) then '0 - 60 Days'
      when (warranty_days_left >61 and warranty_days_left <= 120) then '61 - 120 Days'
      when (warranty_days_left >120 ) then '120+ Days'
      else null end as warranty_expiration_flg,
      case when warranty_days_left >0 then 'Y' else 'N' end as warranty_is_active_flg
      FROM
      table(assetlist({{ _user_attributes['user_id'] }}::numeric)) asl
      join es_warehouse.public.assets a on asl.asset_id = a.asset_id
      left join es_warehouse.public.assets_aggregate aa on asl.asset_id = aa.asset_id
      left join es_warehouse.public.asset_warranty_xref awx on  asl.asset_id = awx.asset_id and awx.date_deleted is null
      left join es_warehouse.public.warranties w on w.warranty_id = awx.warranty_id
      left join es_warehouse.public.warranty_items wi on wi.warranty_id=w.warranty_id   and wi.date_deleted is null
      --left join es_warehouse.public.time_intervals t on wi.time_interval_id = t.time_interval_id
      --left join es_warehouse.public.units u on t.unit_id = u.unit_id
      left join work_orders wo on asl.asset_id=wo.asset_id
      left join categories c on a.category_id=c.category_id
      left join asset_status_values askv on asl.asset_id=askv.asset_id
      left join markets m on m.market_id = a.service_branch_id
      left join asset_aggregates ag on asl.asset_id = ag.asset_id
      where
          --(UPPER( ast.name ) = UPPER('Equipment') OR UPPER( ast.name ) = UPPER('Vehicle'))
          {% condition branch_filter %} m.name {% endcondition %}
          AND
          {% condition category_filter %} c.name {% endcondition %}
          AND
          {% condition asset_filter %} a.custom_name {% endcondition %}
          AND
          {% condition asset_class_filter %} a.asset_class {% endcondition %}
          AND
          {% condition warranty_expiration_flg_filter %} warranty_expiration_flg {% endcondition %}
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
    value_format_name: id
  }


  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER";;
    }


  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }


  dimension: serial_number_or_vin {
    type: string
    sql: coalesce(${serial_number},${vin}) ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
    value_format_name: decimal_0
  }

  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
    value_format_name: decimal_0
  }

  dimension: placed_in_service {
    type: date
    sql: ${TABLE}."PLACED_IN_SERVICE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: asset_id_asl {
    type: string
    sql: ${TABLE}."ASSET_ID_ASL" ;;
  }


  dimension: company_id_a {
    type: number
    sql: ${TABLE}."COMPANY_ID_A" ;;
  }

  dimension: asset_name {
    type: string
    sql: ${TABLE}."ASSET_NAME" ;;
    label: "Asset"
  }

  dimension: category {
    label: "Category"
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: warranty_descr {
    label: "Warranty"
    type: string
    sql: ${TABLE}."WARRANTY_DESCR" ;;
  }

  dimension: warranty_item_descr {
    label: "Warranty Item"
    type: string
    sql: ${TABLE}."WARRANTY_ITEM_DESCR" ;;
  }

  dimension: oec {
    label: "OEC"
    value_format_name: usd_0
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: open_work_orders {
    type: number
    sql: ${TABLE}."OPEN_WORK_ORDERS" ;;
  }

  dimension: asset_has_warranty {
    type: string
    sql: ${TABLE}."ASSET_HAS_WARRANTY" ;;
  }


  dimension: warranty_is_active_flg {
    type: string
    sql: ${TABLE}."WARRANTY_IS_ACTIVE_FLG" ;;
  }


  dimension_group: warranty_expiration_date {
    label: "Warranty Expiration"
    type: time
    sql: ${TABLE}."WARRANTY_EXPIRATION_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: warranty_days_left {
    type: number
    sql: ${TABLE}."WARRANTY_DAYS_LEFT" ;;
  }

  dimension: warranty_expires_60_days {
    type: string
    sql: ${TABLE}."WARRANTY_EXPIRES_60_DAYS" ;;
  }

  dimension: warranty_expires_120_days {
    type: string
    sql: ${TABLE}."WARRANTY_EXPIRES_120_DAYS" ;;
  }

  dimension: warranty_expiration_flg {
    type: string
    sql: ${TABLE}."WARRANTY_EXPIRATION_FLG" ;;
  }

  dimension: asset_has_active_warranty {
    type: string
    sql: ${TABLE}."ASSET_HAS_ACTIVE_WARRANTY" ;;
  }


  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: make_and_model {
    label: "Make and Model"
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  set: detail {
    fields: [
      link_to_asset_t3,
      serial_number_or_vin,
      make_and_model,
      asset_class,
      category,
      year,
      hours,
      odometer,
      oec,
      asset_inventory_status
    ]
  }

  dimension: link_to_asset_t3 {
    type: string
    sql: ${TABLE}."ASSET_NAME" ;;
    label: "Asset"
    group_label: "Link to T3 Status Page"
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id_asl._filterable_value }}/history?selectedDate={{ current_date._filterable_value }}" target="_blank">{{value}}</a></font?</u>;;
  }

  dimension: expiration_month_formatted {
    group_label: "HTML Passed Warranty Expiriation Format"
    label: " "
    sql: ${warranty_expiration_date_month};;
    html: {{ rendered_value | append: "-01" | date: "%B %Y" }};;

  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  measure: total_assets {
    type: count_distinct
    sql: ${asset_id_asl};;
  }

  measure: total_asset_warranties {
    label: " "
    type: count_distinct
    sql: ${asset_id_asl};;
    filters: [asset_has_warranty: "Y"]
    drill_fields: [work_order_detail*]
    html:
    <br />Total Asset Warranties Expiring this Month <br />{{ total_asset_warranties._rendered_value }};;
    value_format_name: decimal_0
  }

  measure: total_assets_without_active_warranties {
    type: count_distinct
    sql: ${asset_id_asl};;
    filters: [asset_has_active_warranty: "N"]
    drill_fields: [detail*]
  }

  measure: total_asset_active_warranties {
    type: count_distinct
    sql: ${asset_id_asl};;
    filters: [asset_has_active_warranty: "Y"]
    drill_fields: [work_order_detail*]
  }

  measure: total_asset_warranties_perc{
    type: number
    sql: case when ${total_assets}<>0 then ${total_assets_without_active_warranties}/${total_assets} else 0 end;;
    value_format_name: percent_0
  }

  measure: total_asset_active_warranties_perc{
    type: number
    sql: case when ${total_assets}<>0 then ${total_asset_active_warranties}/${total_assets} else 0 end;;
    value_format_name: percent_0
  }

  measure: total_asset_without_active_warranties_perc{
    type: number
    sql: case when ${total_assets}<>0 then ${total_assets_without_active_warranties}/${total_assets} else 0 end;;
    value_format_name: percent_0
  }


  measure: total_asset_warranties_60day_perc{
    type: number
    sql: case when ${total_asset_active_warranties}<>0 then ${asset_warranty_expires_60_Days}/${total_asset_active_warranties} else 0 end;;
    value_format_name: percent_0
  }


  measure: asset_warranty_expires_60_Days {
    type: count_distinct
    sql: ${asset_id_asl};;
    filters: [warranty_expires_60_days: "Y"]
    drill_fields: [work_order_detail*]
  }

  measure: company_warranties {
    type: count_distinct
    sql: ${asset_id_asl};;
  }


  measure: oec_warranties{
    type: count_distinct
    sql: ${oec};;
    filters: [asset_has_active_warranty: "Y"]
  }

  measure: total_oec{
    label: "Total OEC"
    type: sum_distinct
    sql_distinct_key: ${asset_id_asl} ;;
    sql: ${oec};;
    value_format_name: usd_0
  }

  measure: total_oec_warranty{
    label: "Total OEC Warranty"
    type: sum_distinct
    sql_distinct_key: ${asset_id_asl} ;;
    sql: ${oec};;
    filters: [asset_has_active_warranty: "Y"]
    value_format_name: usd_0
  }

  measure: oec_warranty_perc_of_total{
    type: number
    sql: case when ${total_assets}<>0 then ${total_oec_warranty} / ${total_oec} else 0 end;;
    value_format_name: percent_0
  }

  measure: total_open_work_orders{
    label: "Open Work Orders"
    type: sum_distinct
    sql_distinct_key: ${asset_id_asl} ;;
    sql: ${open_work_orders};;
    filters: [asset_has_active_warranty: "Y"]
    drill_fields: [work_order_detail*]

  }


  set:  work_order_detail {
    fields: [
      warranty_work_orders.link_to_work_order_t3,
      link_to_asset_t3,
      warranty_work_orders.oec,
      warranty_work_orders.asset_type,
      warranty_work_orders.asset_class,
      warranty_work_orders.make_and_model,
      warranty_work_orders.branch,
      warranty_work_orders.down_status,
      warranty_work_orders.urgency_level,
      asset_inventory_status
    ]
  }

  filter: branch_filter {
    suggest_explore: warranty_detail
    suggest_dimension: warranty_detail.branch
  }

  filter: category_filter {
    suggest_explore: warranty_detail
    suggest_dimension: warranty_detail.category
  }

  filter: asset_class_filter {
    suggest_explore: warranty_detail
    suggest_dimension: warranty_detail.asset_class
  }

  filter: asset_filter {
    suggest_explore: warranty_detail
    suggest_dimension: warranty_detail.asset_name
  }

  filter: warranty_expiration_flg_filter {
    suggest_explore: warranty_detail
   suggest_dimension: warranty_detail.warranty_expiration_flg
  }

}
