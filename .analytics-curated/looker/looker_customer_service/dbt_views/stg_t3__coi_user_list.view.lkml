view: stg_t3__coi_user_list {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__COI_USER_LIST" ;;

  dimension_group: baseline_loaded {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BASELINE_LOADED_AT" ;;
  }
  dimension: company_address_1 {
    type: string
    sql: ${TABLE}."Company Address 1" ;;
  }
  dimension: company_address_2 {
    type: string
    sql: ${TABLE}."Company Address 2" ;;
  }
  dimension: company_city {
    type: string
    sql: ${TABLE}."Company City" ;;
  }
  dimension: company_country {
    type: string
    sql: ${TABLE}."Company Country" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."Company Name" ;;
  }
  dimension: company_stateprovince {
    label: "Company State/Province"
    type: string
    sql: ${TABLE}."Company State/Province" ;;
  }
  dimension: company_zip_codepost_codepin_code {
    type: string
    label: "Company Zip Code/Post Code/Pin Code"
    sql:
    CASE
      WHEN NULLIF(TRIM(${TABLE}."Company Zip Code/Post Code/Pin Code"), '') IS NULL
        THEN ${TABLE}."Company Zip Code/Post Code/Pin Code"
      ELSE LPAD(TRIM(${TABLE}."Company Zip Code/Post Code/Pin Code"), 5, '0')
    END ;;
  }
  dimension: email {
    type: string
    sql: ${TABLE}."Email" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."First Name" ;;
  }
  dimension: insurance_tier {
    type: string
    sql: ${TABLE}."Insurance Tier" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."Last Name" ;;
  }
  dimension: supplier_id {
    type: number
    sql: ${TABLE}."SUPPLIER_ID" ;;
  }
  dimension: tax_id {
    type: string
    sql: ${TABLE}."Tax ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [company_name, first_name, last_name]
  }
}
