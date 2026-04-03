view: yard_tech_lookup_tool {
  derived_table: {
    sql: SELECT r.rental_id,
         c.name                                                                                 AS customer,
         CASE WHEN r.asset_id IS NULL THEN ec.equipment_class_id ELSE aa.equipment_class_id END AS equipment_class_id,
         CASE WHEN r.asset_id IS NULL THEN ec.name ELSE aa.class END                            AS equipment_class,
p.part_number,
p.search,
rpa.quantity,
         r.job_description                                                                      AS terms,
         r.asset_id,
         r.start_date,
         l.street_1,
         l.street_2,
         l.city,
         st.abbreviation                                                                        AS state,
         l.zip_code,
         o.market_id,
         xwalk.market_name                                                                      AS market_name,
         d.note                                                                                 AS note,
         CONCAT(d.note, ' / ', r.job_description)                                                AS notes_and_terms,
         COALESCE(aa.serial_number, aa.vin)                                                     AS serial_vin,
         aa.year                                                                                AS year,
         aa.make                                                                                AS make,
         aa.model                                                                               AS model,
         CONVERT_TIMEZONE('UTC', 'America/Chicago', d.scheduled_date::timestamp)                 AS delivery_date,
         r.rental_status_id                                                                     AS rental_status_id,
         rs.name                                                                                AS rental_status,
         r.price_per_day,
         r.price_per_week,
         r.price_per_month,
         c.company_id                                                                           AS company_id,
         r.order_id,
         ud.first_name || ' ' || ud.last_name                                                   AS delivery_driver,
         xwalk.district,
         xwalk.region_name,
         xwalk.market_type
    FROM es_warehouse.public.rentals AS r
             LEFT JOIN es_warehouse.public.orders AS o
             ON r.order_id = o.order_id
             LEFT JOIN es_warehouse.public.users AS u
             ON o.user_id = u.user_id
             LEFT JOIN es_warehouse.public.companies AS c
             ON u.company_id = c.company_id
             LEFT JOIN es_warehouse.public.deliveries AS d
             ON r.drop_off_delivery_id = d.delivery_id
             LEFT JOIN es_warehouse.public.locations AS l
             ON d.location_id = l.location_id
             LEFT JOIN es_warehouse.public.states AS st
             ON l.state_id = st.state_id
             LEFT JOIN es_warehouse.public.assets_aggregate AS aa
             ON aa.asset_id = r.asset_id
             LEFT JOIN es_warehouse."PUBLIC".equipment_classes AS ec
             ON r.equipment_class_id = ec.equipment_class_id
             LEFT JOIN es_warehouse."PUBLIC".markets AS mkt
             ON o.market_id = mkt.market_id
             LEFT JOIN analytics."PUBLIC".market_region_xwalk AS xwalk
             ON mkt.market_id = xwalk.market_id
             LEFT JOIN es_warehouse.public.order_notes AS ordnotes
             ON o.order_id = ordnotes.order_id
             LEFT JOIN es_warehouse.public.rental_statuses AS rs
             ON r.rental_status_id = rs.rental_status_id
             LEFT JOIN es_warehouse.public.users AS ud
             ON d.driver_user_id = ud.user_id
left join ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS rpa
on r.RENTAL_ID = rpa.RENTAL_ID
left join ES_WAREHOUSE.INVENTORY.PARTS p
on rpa.PART_ID = p.PART_ID

UNION ALL

select
null rental_id,
'Transport' customer,
aa.equipment_class_id,
aa.class equipment_class,
null part_number,
null search,
null quantity,
null terms,
d.asset_id,
null start_date,
l.street_1,
l.street_2,
l.city,
s.abbreviation state,
l.zip_code,
o.market_id,
mrx.market_name,
d.note,
concat(d.note, ' / ', d.delivery_details) notes_and_terms,
coalesce(aa.serial_number, aa.vin) serial_vin,
aa.year,
aa.make,
aa.model,
convert_timezone('UTC', 'America/Chicago', d.scheduled_date::timestamp) delivery_date,
null rental_status_id,
ds.name rental_status,
null price_per_day,
null price_per_week,
null price_per_month,
null company_id,
d.order_id,
u1.first_name || ' ' || u1.last_name delivery_driver,
mrx.district,
mrx.region_name,
mrx.market_type
from es_warehouse.public.deliveries d
join es_warehouse.public.delivery_statuses ds on d.delivery_status_id = ds.delivery_status_id
join es_warehouse.public.orders o on d.order_id = o.order_id
join analytics.public.market_region_xwalk mrx on o.market_id = mrx.market_id
left join es_warehouse.public.locations l on d.origin_location_id = l.location_id
left join es_warehouse.public.states s on l.state_id = s.state_id
left join es_warehouse.public.users u1 on d.driver_user_id = u1.user_id
left join es_warehouse.public.users u2 on d.completed_by_user_id = u2.user_id
left join es_warehouse.public.assets_aggregate aa on d.asset_id = aa.asset_id
where d.rental_id is null
  ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
    value_format_name: id
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID"  ;;
    value_format_name: id
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID"  ;;
    value_format_name: id
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE"  ;;
  }

  dimension: rental_contracts {
    type: string
    html:
    <font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/orders/{{ order_id._value | url_encode }}" target="_blank">Rental Contracts</a></font></u>;;
    sql: ${TABLE}.order_id  ;;}

  dimension: user_history {
    type: string
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/263?Rental%20ID={{ rental_id._value | url_encode }}" target="_blank">User History</a></font></u>;;
    sql: ${TABLE}.rental_id  ;;}


  dimension: customer {
    type: string
    sql: ${TABLE}.customer ;;
  }

  dimension: transport_filter {
    label: "Is Transport?"
    type: yesno
    sql: ${customer} = 'Transport' ;;
  }


  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: rental_status_id {
    type: number
    sql: ${TABLE}.rental_status_id ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}.rental_status ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}.year ;;
  }

  dimension: delivery_date {
    type: date_time
    sql: ${TABLE}.delivery_date ;;
    convert_tz: no
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: serial_vin {
    type: string
    sql: ${TABLE}.serial_vin ;;
  }

  dimension: equipment_class {
    type: string
    # html:
    #     <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/265?Equipment%20Class={{ equipment_class._filterable_value | url_encode }}&Market%20Name={{ market_name._filterable_value | url_encode }}" target="_blank">{{ equipment_class._value }}</a></font></u> ;;
    html: <a href="https://equipmentshare.looker.com/dashboards/265?Equipment%20Class={{ equipment_class._filterable_value | url_encode }}&Market%20Name={{ market_name._filterable_value | url_encode }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ equipment_class._value }}</a> ;;
    sql: ${TABLE}.equipment_class ;;
  }

  dimension: equipment_class_dd {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: bulk_part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
 }

  dimension: bulk_part_class {
    type: string
    sql: ${TABLE}."SEARCH" ;;
  }

  dimension: bulk_part_quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    value_format_name: id
  }

  dimension: notes_and_terms {
    label: "Notes / Terms"
    type:  string
    sql: ${TABLE}.notes_and_terms ;;
  }


  dimension: terms {
    type: string
    sql: ${TABLE}.terms ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension_group: start_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.start_date ;;
  }

  dimension: start_date_time_raw {
    type: date_time
    sql: ${TABLE}.start_date ;;
  }

  dimension: drop_off_street_1 {
    type: string
    sql: ${TABLE}.street_1 ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}.note;;
  }

  dimension: drop_off_street_2 {
    type: string
    sql: ${TABLE}.street_2 ;;
  }

  dimension: drop_off_city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: drop_off_state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: drop_off_zip_code {
    type: number
    sql: ${TABLE}.zip_code ;;
  }

  dimension: delivery_driver {
    type: string
    sql: ${TABLE}.delivery_driver ;;
  }


  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: add_asset_id {
    type: string
    # html:<font color="blue "><u><a href = "https://app.seekwell.io/form/13a1e7ab3e864eb7b5b78b289ae1be11?TIMESTAMP={{ "now" | date: "%Y-%m-%d %H:%M" }}&RENTAL_ID={{rental_id._value }}&EMAIL_ADDRESS={{  _user_attributes['email'] }}" target="_blank">Add/Edit Asset ID to Rental</a></font></u>
    html: <a href="https://app.seekwell.io/form/13a1e7ab3e864eb7b5b78b289ae1be11?TIMESTAMP={{ "now" | date: "%Y-%m-%d %H:%M" }}&RENTAL_ID={{rental_id._value }}&EMAIL_ADDRESS={{  _user_attributes['email'] }}" target="_blank" style="color: #0063f3; text-decoration: underline;">Add/Edit Asset ID to Rental</a>

    ;;
    sql: ${rental_id};;
  }


  dimension: add_asset_id_2 {
    type: string
    html:
    <font color="blue "><u><a href = "https://ba.equipmentshare.com/yard_techs/lookup_asset?rental_id={{rental_id._value }}" target="_blank">Add/Edit Asset ID to Rental</a></font></u>
    ;;
    sql: ${rental_id};;
  }


  dimension:swap_asset_id {
    type: string
    html:
    <font color="blue "><u><a href = "https://ba.equipmentshare.com/yard_techs/lookup_asset_swap?rental_id={{rental_id._value }}&current_asset_id={{asset_id._value }}" target="_blank">Swap Asset</a></font></u>
    ;;
    sql: ${rental_id};;
  }


 dimension: add_asset_id_3 {
  type: string
  html:
    <font color="blue "><u><a href = "http://127.0.0.1:5000/yard_techs?rental_id={{rental_id._value }}&rental_status={{rental_status._value | url_encode }}&email={{  _user_attributes['email'] }}" target="_blank">Add/Edit Asset ID to Rental</a></font></u>
    ;;
  sql: ${rental_id};;
}

  dimension: add_asset_id_4 {
    type: string
    html:
    <font color="blue "><u><a href = "https://ba.equipmentshare.com/yard_techs?rental_id={{rental_id._value }}&rental_status={{rental_status._value  }}&email={{  _user_attributes['email'] }}" target="_blank">Add/Edit Asset ID to Rental</a></font></u>
    ;;
    sql: ${rental_id};;
  }

  dimension: day_rate_achievement {
    group_label: "Rate Achievement"
    type: string
    sql: case when ${price_per_day}<active_branch_rental_rates_pivot.floor_day_rate then 'Below Floor'
            when ${price_per_day}>=active_branch_rental_rates_pivot.floor_day_rate and ${price_per_day}<active_branch_rental_rates_pivot.online_day_rate then 'Above Floor/Below Online'
            when ${price_per_day}>=active_branch_rental_rates_pivot.online_day_rate then 'Above Online'
           else 'Above Floor/Below Online' end;;
  }

  dimension: week_rate_achievement {
    group_label: "Rate Achievement"
    type: string
    sql: case when ${price_per_week}<active_branch_rental_rates_pivot.floor_week_rate then 'Below Floor'
            when ${price_per_week}>=active_branch_rental_rates_pivot.floor_week_rate and ${price_per_week}<active_branch_rental_rates_pivot.online_week_rate then 'Above Floor/Below Online'
            when ${price_per_week}>=active_branch_rental_rates_pivot.online_week_rate then 'Above Online'
           else 'Above Floor/Below Online' end;;
  }

  dimension: month_rate_achievement {
    group_label: "Rate Achievement"
    type: string
    sql: case when ${price_per_month}<active_branch_rental_rates_pivot.floor_month_rate then 'Below Floor'
            when ${price_per_month}>=active_branch_rental_rates_pivot.floor_month_rate and ${price_per_month}<active_branch_rental_rates_pivot.online_month_rate then 'Above Floor/Below Online'
            when ${price_per_month}>=active_branch_rental_rates_pivot.online_month_rate then 'Above Online'
           else 'Above Floor/Below Online' end;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }

  dimension: formatted_price_per_day {
    group_label: "Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    html: {% if day_rate_achievement._value == 'Below Floor'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }

  dimension: formatted_price_per_week {
    group_label: "Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    html: {% if week_rate_achievement._value == 'Below Floor'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }

  dimension: formatted_price_per_month {
    group_label: "Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    html: {% if month_rate_achievement._value == 'Below Floor'%}
            <div style="color: white; background-color: rgba(168, 8, 8, 1); text-align:center">{{rendered_value}} </div>
            {% else %}
            {{rendered_value}}
            {% endif %};;
  }

  measure: note_count {
    type: count_distinct
    sql: ${note} ;;
  }

  measure: terms_count {
    type: count_distinct
    sql: ${terms} ;;
  }

  measure: rentals_count {
    type: count_distinct
    drill_fields: [yard_tech_details*]
    sql: ${rental_id} ;;
  }

  dimension: notes_terms {
    type: string
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/193?Rental%20ID={{rental_id._value }}" target="_blank">Notes and Terms</a></font></u>
    ;;
    sql: ${rental_id};;
  }

  dimension: Rental_ID_W_Link {
    type: string
    sql: ${rental_id} ;;
    # html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/rentals/{{ rental_id._value }}" target="_blank">{{ rental_id._value }}</a></font></u>;;
    html: <a href="https://admin.equipmentshare.com/#/home/rentals/{{ rental_id._value }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ rental_id._value }}</a> ;;
  }

  dimension: Order_ID_W_Link {
    type: string
    sql: ${order_id} ;;
    html: <a href="https://admin.equipmentshare.com/#/home/orders/{{ order_id._value }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ order_id._value }}</a> ;;
  }

  set: yard_tech_details {
    fields: [equipment_class_dd,rental_id,rental_status,customer,market_name,delivery_date,drop_off_street_1,drop_off_street_2,drop_off_city,drop_off_state,drop_off_zip_code]
  }

  dimension: force_rates_join {
    hidden: yes
    sql: ${active_branch_rental_rates_pivot.branch_id} ;;
  }


  }
