view: salesperson_rentals_and_reservations {
    sql_table_name:  "ANALYTICS"."BI_OPS"."SALESPERSON_RENTALS_AND_RESERVATIONS"
      ;;
  dimension: rental_asset_pk {
    type: string
    sql: CONCAT(
      CAST(${TABLE}."RENTAL_ID" AS VARCHAR),
      '::',
      CAST(${TABLE}."ASSET_ID" AS VARCHAR)
    ) ;;
    primary_key: yes
    hidden: yes
    }
    dimension: rental_status {
      type: string
      sql: ${TABLE}."RENTAL_STATUS"  ;;
    }
    dimension: company {
      type: string
      sql: ${TABLE}."COMPANY"  ;;
    }
    dimension: company_id {
      type: number
      sql: ${TABLE}."COMPANY_ID"  ;;
    }
    dimension: ordered_by {
      type: string
      sql: ${TABLE}."ORDERED_BY"  ;;
    }
    dimension: TAM {
      type: string
      sql: ${TABLE}."TAM"  ;;
    }
    dimension: tam_user_id {
      type: number
      sql: ${TABLE}."TAM_USER_ID"  ;;
    }

    dimension: tam_email_address {
      type: string
      sql: ${TABLE}."TAM_EMAIL_ADDRESS"  ;;
    }
    dimension: market_id {
      type: number
      sql: ${TABLE}."MARKET_ID"  ;;
    }
    dimension: market_name {
      type: string
      sql: ${TABLE}."MARKET_NAME"  ;;
    }
    dimension: district {
      type: string
      sql: ${TABLE}."DISTRICT"  ;;
    }
    dimension: region_name {

     type: string
      sql: ${TABLE}."REGION_NAME"  ;;
    }
    dimension: rental_id {
      type: number
      sql: ${TABLE}."REGION_NAME"  ;;
    }
    dimension: rental_start_date {
      type: date
      sql: ${TABLE}."RENTAL_START_DATE"  ;;
    }
    dimension: rental_end_date {
      type: date
      sql: ${TABLE}."RENTAL_END_DATE"  ;;
    }
    dimension: overdue_rental {
      type: string
      sql: ${TABLE}."OVERDUE_RENTAL"  ;;
    }
    dimension: days_until_rental_end_date {
      type: string
      sql: ${TABLE}."DAYS_UNTIL_RENTAL_END_DATE"  ;;
    }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID"  ;;
  }
    dimension: asset_start_date {
      type: date
      sql: ${TABLE}."ASSET_START_DATE"  ;;
    }
    dimension: asset_end_date {
      type: date
      sql: ${TABLE}."ASSET_END_DATE"  ;;
    }
    dimension: equipment_class {
      type: string
      sql: ${TABLE}."EQUIPMENT_CLASS"  ;;
    }
    dimension: is_rerent {
      type: string
      sql: ${TABLE}."IS_RERENT"  ;;
    }
    dimension: make_and_model {
      type: string
      sql: ${TABLE}."MAKE_AND_MODEL"  ;;
    }
    dimension: scheduled_drop_off_delivery_date {
      type: date
      sql: ${TABLE}."SCHEDULED_DROP_OFF_DELIVERY_DATE"  ;;
    }
  measure: asset_count {
    type: count_distinct
    sql: ${asset_id};;
  }

  }
