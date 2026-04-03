view: credit_apps {
  derived_table: {
    sql: SELECT caml.*,cca.final_collector, iff(c.do_not_rent=True,'Yes','No') as DNR
        FROM analytics.gs.credit_app_master_list caml
        LEFT JOIN analytics.gs.collector_customer_assignments cca on caml.customer_id = cca.company_id
        LEFT JOIN es_warehouse.public.companies c on caml.customer_id = c.company_id
        WHERE caml.customer NOT LIKE 'duplicate-company-merged-to%'
        qualify row_number() over (partition by caml.CUSTOMER_ID ORDER BY caml.DATE_COMPLETED desc) = 1;; #selecting most recent update
          }

  dimension: row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALES_PERSON" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."FINAL_COLLECTOR" ;;
  }

  dimension: dnr {
    label: "DNR"
    type: string
    sql: ${TABLE}."DNR" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."CUSTOMER" ;;
  }

  dimension: duns {
    type: string
    sql: ${TABLE}."DUNS_" ;;
  }

  dimension: app_status {
    type: string
    sql: ${TABLE}."APP_STATUS" ;;
  }

  dimension: sic {
    type: string
    sql: ${TABLE}."SIC" ;;
  }

  dimension: naics_1 {
    type: string
    sql: ${TABLE}."NAICS_1" ;;
  }

  dimension: naics_2 {
    type: string
    sql: ${TABLE}."NAICS_2" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension_group: date_received {
    convert_tz: no
    type: time
    timeframes: [date, month, week, year, quarter]
    sql: ${TABLE}."DATE_RECEIVED";;
  }

  dimension_group: date_completed {
    convert_tz: no
    type: time
    timeframes: [date, month, week, year, quarter]
    sql: ${TABLE}."DATE_COMPLETED";;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: fein {
    type: string
    sql: ${TABLE}."FEIN" ;;
  }

  # dimension: tin {
  #   type: string
  #   sql: ${TABLE}."TIN" ;;
  # }

  # dimension: ofac {
  #   type: string
  #   sql: ${TABLE}."OFAC" ;;
  # }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: credit_specialist {
    type: string
    sql: ${TABLE}."CREDIT_SPECIALIST" ;;
  }

  dimension: government_entity {
    type: string
    sql: CASE WHEN ${TABLE}."GOVERNMENT_ENTITY" = TRUE THEN 'Yes'
              WHEN ${TABLE}."GOVERNMENT_ENTITY" = FALSE THEN 'No'
              ELSE NULL END;;
  }

  dimension: online_app_status {
    type: string
    sql: CASE WHEN ${TABLE}."ONLINE_APP_STATUS" = TRUE THEN 'Yes'
              WHEN ${TABLE}."ONLINE_APP_STATUS" = FALSE THEN 'No'
              ELSE NULL END;;
  }

  dimension: insurance_info {
    type: string
    sql: CASE WHEN ${TABLE}."INSURANCE_INFO" = TRUE THEN 'Yes'
              WHEN ${TABLE}."INSURANCE_INFO" = FALSE THEN 'No'
              ELSE NULL END;;
  }

  dimension: date_created {
    type: date_time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  dimension: salesperson_override {
    type: string
    sql:  CASE WHEN ${TABLE}."SALESPERSON_OVERRIDE" = TRUE THEN 'Yes'
              WHEN ${TABLE}."SALESPERSON_OVERRIDE" = FALSE THEN 'No'
              ELSE NULL END;;
  }

  dimension: initial_web_self_signup {
    type: string
    sql:  CASE WHEN ${TABLE}."INITIAL_WEB_SELF_SIGNUP" = TRUE THEN 'Yes'
              WHEN ${TABLE}."INITIAL_WEB_SELF_SIGNUP" = FALSE THEN 'No'
              ELSE NULL END;;
  }

  dimension: credit_safe_number {
    label: "CreditSafe Number"
    type: string
    sql: ${TABLE}."CREDIT_SAFE_NO";;
  }

  # - - - - - MEASURES - - - - -

  measure: count {
    type: count
    drill_fields: [company_name, app_status, date_received_date, salesperson, credit_specialist]
  }
}
