view: last_complete_delivery {
  derived_table: {
    sql:
      WITH last_assign AS (
                          SELECT *
                            FROM es_warehouse."PUBLIC".equipment_assignments AS ea
                           WHERE start_date = (
                                                  SELECT MAX(start_date)
                                                    FROM es_warehouse."PUBLIC".equipment_assignments AS ea2
                                                   WHERE ea.asset_id = ea2.asset_id))
SELECT d.*,
       CONCAT(l.street_1, ', ', l.city, ', ', s.abbreviation, ' ', l.zip_code) AS company_address,
       l.nickname
  FROM last_assign la
           LEFT JOIN es_warehouse.public.deliveries d
           ON la.drop_off_delivery_id = d.delivery_id
           LEFT JOIN es_warehouse.public.locations l
           ON d.location_id = l.location_id
           LEFT JOIN es_warehouse.public.states s
           ON l.state_id = s.state_id
 WHERE d.delivery_status_id = 3;;
  }


  dimension: delivery_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."DELIVERY_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_condition_snapshot_id {
    type: number
    sql: ${TABLE}."ASSET_CONDITION_SNAPSHOT_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: charge {
    type: number
    sql: ${TABLE}."CHARGE" ;;
  }

  dimension_group: completed {
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
    sql: CAST(${TABLE}."COMPLETED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: contact_name {
    type: string
    sql: ${TABLE}."CONTACT_NAME" ;;
  }

  dimension: contact_phone_number {
    type: string
    sql: ${TABLE}."CONTACT_PHONE_NUMBER" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: delivery_company_id {
    type: number
    sql: ${TABLE}."DELIVERY_COMPANY_ID" ;;
  }

  dimension: delivery_creation_type_id {
    type: number
    sql: ${TABLE}."DELIVERY_CREATION_TYPE_ID" ;;
  }

  dimension: delivery_status_id {
    type: number
    sql: ${TABLE}."DELIVERY_STATUS_ID" ;;
  }

  dimension: domain_id {
    type: number
    sql: ${TABLE}."DOMAIN_ID" ;;
  }

  dimension: driver_user_id {
    type: number
    sql: ${TABLE}."DRIVER_USER_ID" ;;
  }

  dimension: facilitator_type_id {
    type: number
    sql: ${TABLE}."FACILITATOR_TYPE_ID" ;;
  }

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: run_name {
    type: string
    sql: ${TABLE}."RUN_NAME" ;;
  }

  dimension_group: scheduled {
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
    sql: CAST(${TABLE}."SCHEDULED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: company_address {
    type: string
    sql: ${TABLE}."COMPANY_ADDRESS" ;;
  }

  dimension: nickname {
    type: string
    label: "Job Name"
    sql: Coalesce(${TABLE}."NICKNAME",'Delivery Pending') ;;
  }

  dimension: jobsite_link {
    type: string
    label: "Last Delivery Location"
    sql: ${company_address} ;;

    link: {
      label: "View Google Maps"
      url: "https://www.google.com/maps/place/{{ value | url_encode }}"
    }
  }

  measure: count {
    type: count
    drill_fields: [delivery_id, run_name, contact_name]
  }

}
