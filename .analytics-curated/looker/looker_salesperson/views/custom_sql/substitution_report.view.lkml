view: substitution_report {
  derived_table: {
    sql: select b.*
      from (
      select r.rental_id,
      rc.name as renting_company,
      m.name,
      convert_timezone('America/Chicago', r.start_date)::date as start_date,
      convert_timezone('America/Chicago', r.end_date)::date as end_date,
      datediff (day,r.start_date, r.end_date) as rental_duration,
      datediff (day,r.start_date, current_date) as days_on_rent,
      rs.name as rental_status,
      rec.name as on_contract,
      ec.name as on_rent,
      a.asset_id as asset_id,
      c.name as owner,
      rec.equipment_class_id::integer as rec_id,
      ec.equipment_class_id::integer as ec_id,
      concat(trim(su.first_name),' ',trim(su.last_name)) as salesperson,
      mr.region_name as region_name,
      mr.district as district,
      r.price_per_hour,
      r.price_per_day,
      r.price_per_week,
      r.price_per_month,
      case when (rec.equipment_class_id = ec.equipment_class_id) then 0
      when (rec.equipment_class_id = 131 and ec.equipment_class_id = 95) then 0
      when (rec.equipment_class_id = 95 and ec.equipment_class_id = 131) then 0
      when (rec.equipment_class_id = 90 and ec.equipment_class_id = 184) then 0
      when (rec.equipment_class_id = 184 and ec.equipment_class_id = 90) then 0
      when (rec.equipment_class_id = 209 and ec.equipment_class_id = 166) then 0
      when (rec.equipment_class_id = 166 and ec.equipment_class_id = 209) then 0
      when (rec.equipment_class_id = 5550 and ec.equipment_class_id = 5549) then 0
      when (rec.equipment_class_id = 5549 and ec.equipment_class_id = 5550) then 0
      when (rec.equipment_class_id <> ec.equipment_class_id) then 1
      else 1 end as substitutions
      from "ES_WAREHOUSE"."PUBLIC"."RENTALS" r
      join "ES_WAREHOUSE"."PUBLIC"."RENTAL_STATUSES" rs on rs.rental_status_id = r.rental_status_id
      join "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_CLASSES" rec on rec.equipment_class_id = r.equipment_class_id
      join "ES_WAREHOUSE"."PUBLIC"."ASSETS" a on a.asset_id = r.asset_id
      join "ES_WAREHOUSE"."PUBLIC"."COMPANIES" c on c.company_id = a.company_id
      join "ES_WAREHOUSE"."PUBLIC"."USERS" u on u.user_id = c.company_id
      join "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_CLASSES_MODELS_XREF" ex on ex.equipment_model_id = a.equipment_model_id
      join "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_CLASSES" ec on ec.equipment_class_id = ex.equipment_class_id
      join "ES_WAREHOUSE"."PUBLIC"."ORDERS" o on r.order_id = o.order_id
      join "ES_WAREHOUSE"."PUBLIC"."ORDER_SALESPERSONS" os on o.order_id = os.order_id and os.salesperson_type_id = 1
      join "ES_WAREHOUSE"."PUBLIC"."MARKETS" m on m.market_id = o.market_id
      join "ES_WAREHOUSE"."PUBLIC"."USERS" ru on ru.user_id = o.user_id
      join "ES_WAREHOUSE"."PUBLIC"."COMPANIES" rc on rc.company_id = ru.company_id
      join "ES_WAREHOUSE"."PUBLIC"."USERS" su on coalesce(os.user_id,o.salesperson_user_id) = su.USER_ID
      join "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK" mr on o.MARKET_ID = mr.MARKET_ID
      WHERE ({% date_start date_filter %} < r.end_date and {% date_end date_filter %} > r.start_date)
         OR (r.start_date < {% date_end date_filter %} and r.end_date > {% date_start date_filter %})
      ) b
      order by end_date desc
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: renting_company {
    type: string
    sql: ${TABLE}."RENTING_COMPANY" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: end_date {
    type: date
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: rental_duration {
    label: "Expected Rental Duration"
    type: number
    sql: ${TABLE}."RENTAL_DURATION" ;;
  }

  dimension: days_on_rent {
    type: number
    sql: ${TABLE}."DAYS_ON_RENT" ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

  dimension: on_contract {
    type: string
    sql: ${TABLE}."ON_CONTRACT" ;;
  }

  dimension: on_rent {
    type: string
    sql: ${TABLE}."ON_RENT" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_id_link_to_asset_dashboard {
    type: number
    value_format_name: id
    sql: ${asset_id} ;;
    html:  <u><p style="color:Blue;"><a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{ value | url_encode }}" target="_blank">{{rendered_value}}</a></p></u>;;
  }

  dimension: owner {
    type: string
    sql: ${TABLE}."OWNER" ;;
  }

  dimension: rec_id {
    type: number
    sql: ${TABLE}."REC_ID" ;;
  }

  dimension: ec_id {
    type: number
    sql: ${TABLE}."EC_ID" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: substitutions {
    type: number
    sql: ${TABLE}."SUBSTITUTIONS" ;;
  }

  dimension: price_per_day {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }
  dimension: price_per_hour {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
  }
  dimension: price_per_month {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }
  dimension: price_per_week {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }

  set: detail {
    fields: [
      rental_id,
      renting_company,
      name,
      start_date,
      end_date,
      rental_duration,
      rental_status,
      on_contract,
      on_rent,
      asset_id,
      owner,
      rec_id,
      ec_id,
      substitutions
    ]
  }

  filter: date_filter {
    type: date
  }
}
