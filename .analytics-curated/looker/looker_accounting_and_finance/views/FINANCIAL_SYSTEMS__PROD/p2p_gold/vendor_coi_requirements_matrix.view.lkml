view: vendor_coi_requirements_matrix {
  sql_table_name: "P2P_GOLD"."VENDOR_COI_REQUIREMENTS_MATRIX" ;;

  dimension: category_sub_vendor {
    type: string
    sql: ${TABLE}."CATEGORY_SUB_VENDOR" ;;
  }
  dimension: category_vendor {
    type: string
    sql: ${TABLE}."CATEGORY_VENDOR" ;;
  }
  dimension: coi_template_number {
    type: number
    sql: ${TABLE}."COI_TEMPLATE_NUMBER" ;;
  }
  dimension_group: date_seed_last_updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_SEED_LAST_UPDATED" ;;
  }
  dimension: hash_value {
    type: number
    sql: ${TABLE}."HASH_VALUE" ;;
  }
  dimension: is_auto_required {
    type: number
    sql: ${TABLE}."IS_AUTO_REQUIRED" ;;
  }
  dimension: is_cargo_required {
    type: number
    sql: ${TABLE}."IS_CARGO_REQUIRED" ;;
  }
  dimension: is_garage_required {
    type: number
    sql: ${TABLE}."IS_GARAGE_REQUIRED" ;;
  }
  dimension: is_general_liability_required {
    type: number
    sql: ${TABLE}."IS_GENERAL_LIABILITY_REQUIRED" ;;
  }
  dimension: is_professional_liability_required {
    type: number
    sql: ${TABLE}."IS_PROFESSIONAL_LIABILITY_REQUIRED" ;;
  }
  dimension: is_umbrella_required {
    type: number
    sql: ${TABLE}."IS_UMBRELLA_REQUIRED" ;;
  }
  dimension: is_workmans_comp_required {
    type: number
    sql: ${TABLE}."IS_WORKMANS_COMP_REQUIRED" ;;
  }
  dimension: type_vendor {
    type: string
    sql: ${TABLE}."TYPE_VENDOR" ;;
  }
  measure: count {
    type: count
  }
}
