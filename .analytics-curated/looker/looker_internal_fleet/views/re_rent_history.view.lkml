
view: re_rent_history {
  derived_table: {
    sql: select r.START_DATE,
             r.END_DATE,
             r.RENTAL_ID,
             ap.ASSET_ID,
             coalesce(ec.NAME, ap.EQUIP_CLASS_NAME) as equipment_class,
             ap.MAKE,
             ap.MODEL,
             xw.REGION_NAME as region_rented_from,
             xw.DISTRICT as district_rented_from,
             xw.MARKET_NAME as market_rented_from,
             r.PRICE_PER_HOUR,
             r.PRICE_PER_DAY,
             r.PRICE_PER_WEEK,
             r.PRICE_PER_MONTH,
             ap.COMPANY_ID,
             ap.COMPANY_NAME as owner_name,
             ap.ASSET_INVENTORY_STATUS as asset_status
      from ES_WAREHOUSE.PUBLIC.RENTALS r
          left join ANALYTICS.ASSET_DETAILS.ASSET_PHYSICAL ap
          on ap.ASSET_ID = r.ASSET_ID
          left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
          on ec.EQUIPMENT_CLASS_ID = r.EQUIPMENT_CLASS_ID
          left join ES_WAREHOUSE.PUBLIC.ORDERS o
          on o.ORDER_ID = r.ORDER_ID
          left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
          on xw.MARKET_ID = o.MARKET_ID
      where ap.IS_RERENT like 'true'
            and ap.COMPANY_ID <> 155
            and {% condition market %} xw.MARKET_NAME {% endcondition %}
            and {% condition district %} xw.DISTRICT {% endcondition %}
            and {% condition region %} xw.REGION_NAME {% endcondition %}
            and {% condition equipment_class %} coalesce(ec.NAME, ap.EQUIP_CLASS_NAME) {% endcondition %}
            and {% condition asset_status %} ap.ASSET_INVENTORY_STATUS {% endcondition %}
            and {% condition owner_name %} ap.COMPANY_NAME {% endcondition %}
            and {% condition date_filter %} r.START_DATE {% endcondition %};;
  }


  dimension_group: rental_start {
    type: time
    sql: ${TABLE}."START_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: rental_end {
    type: time
    sql: ${TABLE}."END_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: equipment_class_name {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: region_rented_from {
    type: string
    sql: ${TABLE}."REGION_RENTED_FROM" ;;
  }

  dimension: district_rented_from {
    type: string
    sql: ${TABLE}."DISTRICT_RENTED_FROM" ;;
  }

  dimension: market_rented_from {
    type: string
    sql: ${TABLE}."MARKET_RENTED_FROM" ;;
  }

  dimension: price_per_hour {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: owner {
    type: string
    sql: ${TABLE}."OWNER_NAME" ;;
  }

  dimension: asset_status {
    type: string
    sql: ${TABLE}."ASSET_STATUS" ;;
  }

  dimension: on_rent_assets {
    type: yesno
    sql: ${asset_status} = 'On Rent' ;;
  }

  measure: count_of_assets {
    type: count
    drill_fields: [asset_detail*]
  }

  filter: date_filter {
    type: date_time
  }

  filter: region {
    type: string
  }

  filter: district {
    type: string
  }

  filter: market {
    type: string
  }

  filter: equipment_class {
    type: string
  }

  filter: assets_status {
    type: string
  }

  filter: owner_name {
    type: string
  }

  set: asset_detail {
    fields: [
      rental_id,
      asset_id,
      equipment_class_name,
      make,
      model,
      asset_status,
      owner,
      market_rented_from,
      district_rented_from,
      region_rented_from
    ]
  }

  set: detail {
    fields: [
        rental_start_date,
  rental_end_date,
  rental_id,
  asset_id,
  equipment_class,
  make,
  model,
  region_rented_from,
  district_rented_from,
  market_rented_from,
  price_per_hour,
  price_per_day,
  price_per_week,
  price_per_month,
  company_id,
  owner_name,
  asset_status
    ]
  }
}
