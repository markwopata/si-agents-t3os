view: billing_company_preferences {
    sql_table_name: ES_WAREHOUSE.PUBLIC.BILLING_COMPANY_PREFERENCES ;;

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: general_services_administration {
    type: yesno
    label: "GSA Billing"
    sql: TRY_PARSE_JSON(${TABLE}.prefs):general_services_administration ;;
  }

  dimension: specialized_billing {
    type: yesno
    label: "Specialized Billing"
    sql: TRY_PARSE_JSON(${TABLE}.prefs):specialized_billing ;;
  }

  dimension: managed_billing {
    type: yesno
    label: "Managed Billing"
    sql: TRY_PARSE_JSON(${TABLE}.prefs):managed_billing ;;
  }

  dimension: four_week_billing_date {
    type: date
    sql:TRY_PARSE_JSON(${TABLE}.prefs):four_week_billing_date::timestamptz ;;
  }
}
