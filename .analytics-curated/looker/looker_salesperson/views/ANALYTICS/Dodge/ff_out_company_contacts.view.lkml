view: ff_out_company_contacts {
  sql_table_name: "DODGE"."FF_OUT_COMPANY_CONTACTS"
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
    sql: substring(${TABLE}."C_ZIP_CODE",0,5) ;;
  }

  dimension: c_zip_code_5 {
    type: string
    sql: ${TABLE}."C_ZIP_CODE_5" ;;
  }

  dimension: contact_name {
    type: string
    sql: ${TABLE}."CONTACT_NAME" ;;
  }

  dimension: contact_title {
    type: string
    sql: ${TABLE}."CONTACT_TITLE" ;;
  }

  dimension: dcis_factor_cntct_code {
    type: string
    sql: ${TABLE}."DCIS_FACTOR_CNTCT_CODE" ;;
  }

  dimension: dcis_factor_code {
    type: string
    sql: ${TABLE}."DCIS_FACTOR_CODE" ;;
  }

  dimension: email_id {
    type: string
    sql: ${TABLE}."EMAIL_ID" ;;
  }

  dimension: fax_nbr {
    type: string
    sql: ${TABLE}."FAX_NBR" ;;
  }

  dimension: firm_name {
    type: string
    sql: ${TABLE}."FIRM_NAME" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: mhc_contact_id {
    type: string
    sql: ${TABLE}."MHC_CONTACT_ID" ;;
  }

  dimension: mhc_site_id {
    type: string
    sql: ${TABLE}."MHC_SITE_ID" ;;
  }

  dimension: middle_name {
    type: string
    sql: ${TABLE}."MIDDLE_NAME" ;;
  }

  dimension: phone_nbr {
    type: number
    sql: ${TABLE}."PHONE_NBR" ;;
  }

  dimension: phone_nbr_format {
    type: string
    sql: substring(${phone_nbr},1,3)||'-'||substring(${phone_nbr},4,3)||'-'||substring(${phone_nbr},7,4) ;;
  }

  dimension: prefix {
    type: string
    sql: ${TABLE}."PREFIX" ;;
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

  dimension: suffix {
    type: string
    sql: ${TABLE}."SUFFIX" ;;
  }

  dimension: www_url {
    type: string
    sql: ${TABLE}."WWW_URL" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      firm_name,
      first_name,
      c_county_name,
      middle_name,
      c_city_name,
      contact_name,
      last_name,
      std_county_name
    ]
  }
}
