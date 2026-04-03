view: ff_out_company {
  sql_table_name: "DODGE"."FF_OUT_COMPANY"
    ;;

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  dimension_group: _modified {
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
    sql: CAST(${TABLE}."_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: c_addr_line_1 {
    type: string
    sql: ${TABLE}."C_ADDR_LINE_1" ;;
  }

  dimension: c_addr_line_2 {
    type: string
    sql: ${TABLE}."C_ADDR_LINE_2" ;;
  }

  dimension: c_city_name {
    type: string
    sql: ${TABLE}."C_CITY_NAME" ;;
  }

  dimension: c_country_id {
    type: string
    sql: ${TABLE}."C_COUNTRY_ID" ;;
  }

  dimension: c_county_name {
    type: string
    sql: ${TABLE}."C_COUNTY_NAME" ;;
  }

  dimension: c_fips_county_id {
    type: string
    sql: ${TABLE}."C_FIPS_COUNTY_ID" ;;
  }

  dimension: c_state_id {
    type: string
    sql: ${TABLE}."C_STATE_ID" ;;
  }

  dimension: c_zip_code {
    type: string
    sql: ${TABLE}."C_ZIP_CODE" ;;
  }

  dimension: c_zip_code_5 {
    type: string
    sql: ${TABLE}."C_ZIP_CODE_5" ;;
  }

  dimension: dcis_factor_code {
    type: string
    sql: ${TABLE}."DCIS_FACTOR_CODE" ;;
  }

  dimension: fax_nbr {
    type: string
    sql: ${TABLE}."FAX_NBR" ;;
  }

  dimension: firm_name {
    type: string
    sql: ${TABLE}."FIRM_NAME" ;;
  }

  dimension: mhc_site_id {
    type: string
    sql: ${TABLE}."MHC_SITE_ID" ;;
  }

  dimension: phone_nbr {
    type: number
    sql: ${TABLE}."PHONE_NBR" ;;
  }

  dimension: std_company_type_code {
    type: number
    sql: ${TABLE}."STD_COMPANY_TYPE_CODE" ;;
  }

  dimension: std_company_type_desc {
    type: string
    sql: ${TABLE}."STD_COMPANY_TYPE_DESC" ;;
  }

  dimension: std_county_name {
    type: string
    sql: ${TABLE}."STD_COUNTY_NAME" ;;
  }

  dimension: std_fips_code {
    type: number
    sql: ${TABLE}."STD_FIPS_CODE" ;;
  }

  dimension: www_url {
    type: string
    sql: ${TABLE}."WWW_URL" ;;
  }

  measure: count {
    type: count
    drill_fields: [std_county_name, c_county_name, c_city_name, firm_name]
  }
}
