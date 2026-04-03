view: warrantable_assets_aggregate {
  derived_table: {
    sql:
        SELECT aa.*
        FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS a
          ON aa.asset_ID = a.asset_ID
        WHERE (aa.COMPANY_ID IN (
                select company_id
                from ANALYTICS.PUBLIC.ES_COMPANIES
                where owned = true)
             --CONTRACTOR OWNED/OWN PROGRAM
            OR aa.asset_id IN (
                SELECT DISTINCT aa.asset_id
                FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
                JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
                    ON VPP.ASSET_ID = AA.ASSET_ID
                WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
                    AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31'))
            ) AND aa.service_branch_id != 1492 --"main branch"
            AND (aa.ASSET_TYPE_ID = 1  /*equipment*/ or  (aa.equipment_make_id = 11333 and aa.category_id = 514)) ;;
  }
  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: asset_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
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
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: equipment_make_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_MAKE_ID" ;;
  }

  dimension: equipment_model_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_MODEL_ID" ;;
  }

  dimension_group: first_rental {
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
    sql: ${TABLE}.CAST(${TABLE}."FIRST_RENTAL" AS TIMESTAMP_NTZ) ;;
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: owner {
    type: string
    sql: ${TABLE}."OWNER" ;;
  }

  dimension_group: purchase {
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
    sql: ${TABLE}.CAST(${TABLE}."PURCHASE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: service_branch_id {
    type: number
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  measure: count {
    type: count
    drill_fields: [custom_name, assets.custom_name, assets.asset_id, assets.name, assets.driver_name]
  }

  dimension: market_id_to_use {
    type: number
    sql: coalesce(${rental_branch_id},${inventory_branch_id}) ;;
  }

  dimension:serial_number_vin {
    type: string
    sql: coalesce(${serial_number},${vin}) ;;
  }
}
