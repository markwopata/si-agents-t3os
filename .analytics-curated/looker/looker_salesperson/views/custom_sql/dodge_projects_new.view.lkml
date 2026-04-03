view: dodge_projects_new {

  derived_table: {
    sql:
       SELECT DISTINCT * FROM (
SELECT PC.DR_NBR AS DR_NBR, PC.TITLE AS PROJECT, PC.STAGE_DESC AS STAGE_DESC,
PC.EST_HIGH_VALUE AS ESTIMATED_HIGH_VALUE, PC.EST_LOW_VALUE AS ESTIMATED_LOW_VALUE,
PC.P_ADDR_LINE_1 AS ADDRESS_LINE_1, SUBSTRING(PC.P_ZIP_CODE,0,5) AS ZIP_CODE, PC.CN_PROJECT_URL AS PROJECT_URL,
TRY_TO_DATE(PC.BID_DATE,'YYYYMMDD') AS BID_DATE,
TRY_TO_DATE(PC.PUBLISH_DATE,'YYYYMMDD') AS PUBLISH_DATE, PC.P_CITY_NAME AS CITY, PC.P_STATE_ID AS STATE,
PC.PROJ_TYPE AS PROJECT_TYPE
FROM ANALYTICS.DODGE.FF_OUT_REP_PROJECT_CAPSULE AS PC
LEFT JOIN ANALYTICS.DODGE.STAGE_ORDER AS SO
ON PC.STAGE_DESC = SO.STAGE_DESC
WHERE PC.STAGE_DESC NOT IN ('Abandoned','Delayed','Pre-Design','Planning Schematics')
AND PC.PROJ_TYPE NOT IN ('Sale/Spec Homes','Swimming Pool','Custom Homes','Unclassified')
AND (PC.EST_LOW_VALUE IS NOT NULL OR PC.EST_HIGH_VALUE IS NOT NULL)) AS X
    ;;
  }

  dimension: dr_nbr {
    type: number
    sql: ${TABLE}.DR_NBR ;;
  }

  dimension: project {
    type: string
    html:
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/186?Project={{ project._value | url_encode }}" target="_blank">{{ project._value }}</a></font></u>
        ;;
    sql: ${TABLE}.PROJECT ;;
  }

  dimension: project_app {
    type: string
    html:
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/227?Project={{ project._value | url_encode }}" target="_blank">{{ project._value }}</a></font></u>
        ;;
    sql: ${TABLE}.PROJECT ;;
  }

  dimension: add_to_homepage {
    type: string
    html:
        <font color="blue "><u><a href = "https://equipmentshare.com/crm/dodge_homepage?dr_nbr={{ dr_nbr._value | url_encode }}&project={{ project._value  }}&email={{  _user_attributes['email'] }}" target="_blank">Add to Homepage</a></font></u>
        ;;
    sql: ${TABLE}.PROJECT ;;
  }

  dimension: stage_desc {
    type: string
    sql: ${TABLE}.STAGE_DESC ;;
  }

  dimension: estimated_high_value {
    type: number
    sql: ${TABLE}.ESTIMATED_HIGH_VALUE ;;
  }

  dimension: estimated_low_value {
    type: number
    sql: ${TABLE}.ESTIMATED_LOW_VALUE ;;
  }

  dimension: address_line_1 {
    type: string
    sql: ${TABLE}.ADDRESS_LINE_1 ;;
  }

  dimension: zip_code {
    type: string
    sql: ${TABLE}.ZIP_CODE ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.CITY ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.STATE ;;
  }

  dimension: project_market {
    type: string
    sql: case when ${msa.msa} is null and ${city} is null then ${state}
          when ${msa.msa} is null and ${state} is null then ${city}
          when ${msa.msa} is null then ${city}||', '||${state} else ${msa.msa} end ;;
  }

  dimension: bid_date {
    type: date
    sql: ${TABLE}.BID_DATE ;;
  }

  dimension: project_url {
    type: string
    html:<font color="blue "><u><a href="https://apps.construction.com/projects/{{ dr_nbr._value }}#directsearch" target="_blank">Link to Dodge Project</a></font></u> ;;
    sql: ${TABLE}.PROJECT_URL ;;
  }

  dimension: publish_date {
    type: date
    sql: ${TABLE}.PUBLISH_DATE ;;
  }

  dimension: project_type {
    type: string
    sql: ${TABLE}.PROJECT_TYPE ;;
  }
  }
