view: dim_rentals {
  sql_table_name: "PLATFORM"."GOLD"."V_RENTALS" ;;

  # PRIMARY KEY
  dimension: rental_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."RENTAL_KEY" ;;
    hidden: yes
  }

  # NATURAL KEYS
  dimension: rental_source {
    type: string
    sql: ${TABLE}."RENTAL_SOURCE" ;;
    description: "Source system for rental data"
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    description: "Natural rental ID"
    value_format_name: id
    link: {
      label: "Rental Details"
      url: "/dashboards/rental_profile?rental_id={{ value }}"
    }
  }

  # RENTAL ATTRIBUTES
  dimension: rental_type_id {
    type: number
    sql: ${TABLE}."RENTAL_TYPE_ID" ;;
    description: "Rental type identifier"
  }

  dimension: rental_status_id {
    type: number
    sql: ${TABLE}."RENTAL_STATUS_ID" ;;
    description: "Rental status identifier"
  }

  dimension: rental_purchase_option_id {
    type: number
    sql: ${TABLE}."RENTAL_PURCHASE_OPTION_ID" ;;
    description: "Purchase option identifier"
  }

  dimension: drop_off_delivery_id {
    type: number
    sql: ${TABLE}."DROP_OFF_DELIVERY_ID" ;;
    description: "Drop off delivery identifier"
  }

  # NEW RENTAL EQUIPMENT ANALYSIS
  dimension: is_rerent {
    type: yesno
    sql: ${TABLE}."IS_RERENT" ;;
    description: "Equipment is refurbished (serial starts with RR-)"
    group_label: "Equipment Analysis"
  }

  dimension: is_swap {
    type: yesno
    sql: ${TABLE}."IS_SWAP" ;;
    description: "Delivered equipment differs from ordered"
    group_label: "Equipment Analysis"
  }

  dimension: rep_type {
    type: string
    sql: ${TABLE}."REP_TYPE" ;;
    description: "Salesperson type: Primary or Secondary"
    group_label: "Sales Information"
  }


  # MEASURES
  measure: count {
    type: count
    description: "Number of rentals"
    drill_fields: [rental_id, rental_source]
  }

  measure: rerent_count {
    type: count
    filters: [is_rerent: "yes"]
    description: "Number of rerent (refurbished) equipment rentals"
  }

  measure: swap_count {
    type: count
    filters: [is_swap: "yes"]
    description: "Number of equipment swaps"
  }

  measure: rerent_percentage {
    type: number
    sql: 100.0 * ${rerent_count} / NULLIF(${count}, 0) ;;
    description: "Percentage of rentals with refurbished equipment"
    value_format_name: percent_1
  }

  # TIMESTAMP
  dimension_group: rental_recordtimestamp {
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
    sql: CAST(${TABLE}."RENTAL_RECORDTIMESTAMP" AS TIMESTAMP_NTZ) ;;
    description: "When this rental record was created"
  }
}
