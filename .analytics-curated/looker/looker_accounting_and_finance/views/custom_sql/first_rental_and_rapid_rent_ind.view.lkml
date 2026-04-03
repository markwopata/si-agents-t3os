view: first_rental_and_rapid_rent_ind {
  derived_table: {
    sql:
     with first_rental as(
    SELECT        a.asset_id,
           a.serial_number,
           a.asset_type_id,
           a.inventory_branch_id,
           a.rental_branch_id,
           m.name,
           a.year,
           a.company_id,
           a.date_created,
           min(ea.start_date) as first_rental_start_date,
           min(ea.end_date ) as first_rental_end_date,
           max(ea.start_date) as last_rental_start_date,
           max(ea.end_date ) as last_rental_end_date,
           coalesce(aph.oec,aph.purchase_price) as oec_purchase_price
    FROM ES_WAREHOUSE.public.assets a
             LEFT JOIN ES_WAREHOUSE.public.asset_purchase_history aph
                       on a.asset_id = aph.asset_id
             LEFT JOIN ES_WAREHOUSE.public.equipment_assignments ea
                       on a.asset_id = ea.asset_id
             LEFT JOIN ES_WAREHOUSE.public.markets m
                       on a.inventory_branch_id = m.market_id
             LEFT JOIN ES_WAREHOUSE.public.asset_statuses ast
                       on a.asset_id = ast.asset_id
    WHERE (aph.purchase_history_id in (
        SELECT max(purchase_history_id)
        FROM ES_WAREHOUSE.public.asset_purchase_history
        GROUP BY asset_id)
         or purchase_history_id is null
    )
    GROUP BY
    a.inventory_branch_id
    , a.rental_branch_id
    , m.name
    , a.asset_id
    , a.serial_number
    ,a.asset_type_id
    ,a.year
    ,a.company_id
    , a.date_created
    , ast.asset_inventory_status
    , oec_purchase_price
    )
    , rapid_rent_ind as(
      SELECT
        a.asset_id
      , a.available_to_rapid_rent
        FROM ES_WAREHOUSE.public.assets a
        WHERE available_to_rapid_rent = TRUE
    )
    select
    fr.*
    ,case when(rri.available_to_rapid_rent = TRUE ) then 1 else 0 end as rapid_rent_ind
    from first_rental fr
    left join rapid_rent_ind rri
      on fr.asset_id=rri.asset_id
           ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
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

  dimension_group: first_rental_start {
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
    sql: CAST(${TABLE}."FIRST_RENTAL_START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_rental_start {
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
    sql: CAST(${TABLE}."LAST_RENTAL_START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: first_rental_end {
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
    sql: CAST(${TABLE}."FIRST_RENTAL_END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_rental_end {
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
    sql: CAST(${TABLE}."LAST_RENTAL_END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: oec_purchase_price {
    type: number
    sql: ${TABLE}."OEC_PURCHASE_PRICE" ;;
  }

  dimension: rapid_rent_ind {
    type: number
    sql: ${TABLE}."RAPID_RENT_IND" ;;
  }

  set: detail {
    fields: [
      asset_id,
      serial_number,
      asset_type_id,
      inventory_branch_id,
      rental_branch_id,
      name,
      year,
      company_id,
      date_created_time,
      oec_purchase_price,
      rapid_rent_ind
    ]
  }
}
