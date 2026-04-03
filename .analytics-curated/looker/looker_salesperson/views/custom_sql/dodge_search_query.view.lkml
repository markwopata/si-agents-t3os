view: dodge_search_query {

  derived_table: {
    sql:
        SELECT DISTINCT * FROM (
SELECT proj_cap.DR_NBR AS dr_nbr,
proj_cap.title AS project,
proj_cap.p_city_name AS project_city,
proj_cap.P_STATE_ID AS project_state,
substring(proj_cap.P_ZIP_CODE,1,5) AS  project_zip_code,
proj_cap.est_low_value AS estimated_low_value,
proj_cap.est_high_value AS estimated_high_value,
TRY_TO_DATE(proj_cap.BID_DATE,'YYYYMMDD') AS bid_date,
TRY_TO_DATE(proj_cap.PUBLISH_DATE,'YYYYMMDD') AS publish_date,
stag.stage_desc AS action_stage ,
proj_cap.PROJ_TYPE AS project_type,
ffc.FIRM_NAME AS firm_name,
ffc.CONTACT_NAME AS contact_name,
ffc.CONTACT_TITLE AS contact_title,
ffc.C_ADDR_LINE_1 AS firm_address,
ffc.C_CITY_NAME AS firm_city,
ffc.C_STATE_ID AS firm_state,
substring(ffc.C_ZIP_CODE,1,5) AS firm_zip_code,
substring(ffc.PHONE_NBR,1,3)||'-'||substring(ffc.PHONE_NBR,4,3)||'-'||substring(ffc.PHONE_NBR,7,4) AS contact_phone,
ffc.EMAIL_ID AS contact_email,
ffc.WWW_URL AS firm_website , proj_cap.cn_project_url as project_url, proj_cap.p_addr_line_1 as project_address
FROM ANALYTICS.DODGE.FF_OUT_REP_PROJECT_CAPSULE AS proj_cap
LEFT JOIN  ANALYTICS.DODGE.FF_OUT_REP_STAGE AS stag  ON proj_cap.dr_nbr = stag.dr_nbr
LEFT JOIN ANALYTICS.DODGE.FF_OUT_REP_FIRM_RELATIONSHIP AS ffr ON proj_cap.DR_NBR = ffr.DR_NBR
LEFT JOIN ANALYTICS.DODGE.FF_OUT_COMPANY_CONTACTS AS ffc ON ffr.DCIS_FACTOR_CODE = ffc.DCIS_FACTOR_CODE
) AS x ;;
  }

  dimension: dr_nbr {
    type: number
    sql: ${TABLE}.dr_nbr ;;
  }

  dimension: project {
    type: string
    link: {
      label: "Dodge Project Firms"
      url: "https://equipmentshare.looker.com/looks/168?&f[dodge_search_query.project]={{ value }}&toggle=det"
      }
    sql: ${TABLE}.project ;;
  }

  dimension: project_city {
    type: string
    sql: ${TABLE}.project_city ;;
  }

  dimension: project_address {
    type: string
    sql: ${TABLE}.project_address ;;
  }

  dimension: project_state {
    type: string
    sql: ${TABLE}.project_state ;;
  }

  dimension: project_zip_code {
    type: string
    sql: ${TABLE}.project_zip_code ;;
  }

  dimension: estimated_low_value {
    type: number
    sql: ${TABLE}.estimated_low_value ;;
  }

  dimension: estimated_high_value {
    type: number
    sql: ${TABLE}.estimated_high_value ;;
  }

  dimension:bid_date {
    type: date
    sql: ${TABLE}.bid_date ;;
  }

  dimension: action_stage {
    type: string
    sql: ${TABLE}.action_stage ;;
  }

  dimension: project_type {
    type: string
    sql: ${TABLE}.project_type ;;
  }

  dimension:publish_date {
    type: date
    sql: ${TABLE}.publish_date ;;
  }

  dimension: firm_name {
    type: string
    sql: ${TABLE}.firm_name ;;
  }

  dimension: contact_name {
    type: string
    sql: ${TABLE}.contact_name ;;
  }

  dimension: contact_title {
    type: string
    sql: ${TABLE}.contact_title ;;
  }

  dimension: firm_address {
    type: string
    sql: ${TABLE}.firm_address ;;
  }

  dimension: firm_city {
    type: string
    sql: ${TABLE}.firm_city ;;
  }

  dimension: firm_state {
    type: string
    sql: ${TABLE}.firm_state ;;
  }

  dimension: firm_zip_code {
    type: string
    sql: ${TABLE}.firm_zip_code ;;
  }

  dimension: contact_phone {
    type: string
    sql: ${TABLE}.contact_phone ;;
  }

  dimension: contact_email {
    type: string
    sql: ${TABLE}.contact_email ;;
  }

  dimension: firm_website {
    type: string
    sql: ${TABLE}.firm_website ;;
  }

  dimension: project_market {
    type: string
    sql: case when ${msa.msa} is null and ${project_city} is null then ${project_state}
    when ${msa.msa} is null and ${project_state} is null then ${project_city}
    when ${msa.msa} is null then ${project_city}||', '||${project_state} else ${msa.msa} end ;;
  }

  dimension: firm_market {
    type: string
    sql: case when ${msa.msa} is null and ${firm_city} is null then ${firm_state}
          when ${msa.msa} is null and ${firm_state} is null then ${firm_city}
          when ${msa.msa} is null then ${firm_city}||', '||${firm_state} else ${msa.msa} end ;;
  }

  dimension: project_url {
    type: string
     html:<font color="blue "><u><a href="{{ project_url._value }}" target="_blank">Link to Dodge Project</a></font></u> ;;
    sql: ${TABLE}.project_url ;;
  }

  }
