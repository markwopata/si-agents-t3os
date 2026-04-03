view: delek_on_rent_report {
    derived_table: {
      sql:
      select
      'On Rent' as rental_status,
      rental_id,
      purchase_order_name,
      custom_name,
      quantity,
      asset_class,
      price_per_day,
      price_per_week,
      price_per_month,
      rental_start_date,
      total_days_on_rent,
      billing_days_left,
      scheduled_off_rent_date,
      to_date_rental,
      next_cycle_date,
      last_cycle_date
      from business_intelligence.triage.stg_t3__on_rent
      where company_id = 180677;;
    }
    dimension: rental_status {
      sql: ${TABLE}."RENTAL_STATUS" ;;
      description: ""
    }
    dimension: rental_id {
      sql: ${TABLE}."RENTAL_ID" ;;
      description: ""
    }
    dimension: purchase_order_name {
      sql: ${TABLE}."PURCHASE_ORDER_NAME" ;;
      label: "Purchase Order"
      description: ""
    }
    dimension: custom_name {
      sql: ${TABLE}."CUSTOM_NAME" ;;
      label: "Asset"
      description: ""
    }
    dimension: quantity {
      sql: ${TABLE}."QUANTITY" ;;
      description: ""
      type: number
    }
    dimension: asset_class {
      sql: ${TABLE}."ASSET_CLASS" ;;
      label: "Class"
      description: ""
    }
    dimension: price_per_day {
      sql: ${TABLE}."PRICE_PER_DAY" ;;
      description: ""
      value_format: "$#,##0"
      type: number
    }
    dimension: price_per_week {
      sql: ${TABLE}."PRICE_PER_WEEK" ;;
      description: ""
      value_format: "$#,##0"
      type: number
    }
    dimension: price_per_month {
      sql: ${TABLE}."PRICE_PER_MONTH" ;;
      description: ""
      value_format: "$#,##0"
      type: number
    }
    dimension: rental_start_date {
      sql: ${TABLE}."RENTAL_START_DATE" ;;
      description: ""
      type: date
    }
    dimension: total_days_on_rent {
      sql: ${TABLE}."TOTAL_DAYS_ON_RENT" ;;
      label: "Days on Rent"
      description: ""
      type: number
    }
    dimension: billing_days_left {
      sql: ${TABLE}."BILLING_DAYS_LEFT" ;;
      description: ""
      type: number
    }
    dimension: scheduled_off_rent_date {
      sql: ${TABLE}."SCHEDULED_OFF_RENT_DATE" ;;
      description: ""
      type: date
    }
    dimension: to_date_rental {
      sql: ${TABLE}."TO_DATE_RENTAL" ;;
      description: ""
      value_format: "$#,##0"
      type: number
    }
    dimension: next_cycle_date {
      sql: ${TABLE}."NEXT_CYCLE_DATE" ;;
      description: ""
      type: date_time
    }
    dimension: last_cycle_date {
      sql: ${TABLE}."LAST_CYCLE_DATE" ;;
      description: ""
      type: date_time
    }
  }
