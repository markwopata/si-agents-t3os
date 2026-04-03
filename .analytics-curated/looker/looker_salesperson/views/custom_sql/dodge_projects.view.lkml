view: dodge_projects {

  derived_table: {
    sql:
   SELECT DISTINCT * FROM (   SELECT PROJ_CAP.DR_NBR AS DR_NBR, PROJ_CAP.TITLE AS PROJECT, PROJ_STAGE.STAGE_DESC AS STAGE_DESC, PROJ_CAP.EST_HIGH_VALUE AS ESTIMATED_HIGH_VALUE,
PROJ_CAP.EST_LOW_VALUE AS ESTIMATED_LOW_VALUE, PROJ_CAP.P_ADDR_LINE_1 AS ADDRESS_LINE_1, PROJ_CAP.STD_COUNTY_NAME AS COUNTY,
SUBSTRING(PROJ_CAP.P_ZIP_CODE,0,5) AS ZIP_CODE,
TRY_TO_DATE(PROJ_CAP.BID_DATE,'YYYYMMDD')
AS BID_DATE,
TRY_TO_DATE(PROJ_CAP.PUBLISH_DATE,'YYYYMMDD')
AS PUBLISH_DATE,
PROJ_CAP.CN_PROJECT_URL AS PROJECT_URL, PROJ_CAP.PROJ_TYPE AS PROJECT_TYPE, P_CITY_NAME AS CITY, P_STATE_ID AS STATE, SO.STAGE_ORDER AS STAGE_ORDER
FROM INBOUND.DODGE_CONSTRUCTION_VIEW.FF_OUT_REP_PROJECT_CAPSULE AS PROJ_CAP
LEFT JOIN INBOUND.DODGE_CONSTRUCTION_VIEW.FF_OUT_REP_STAGE AS PROJ_STAGE
ON PROJ_CAP.DR_NBR::varchar = PROJ_STAGE.DR_NBR::varchar
LEFT JOIN ANALYTICS.DODGE.STAGE_ORDER AS SO
ON PROJ_STAGE.STAGE_DESC = SO.STAGE_DESC
WHERE PROJ_STAGE.STAGE_DESC NOT IN ('Abandoned','Delayed','Pre-Design','Planning Schematics')
AND PROJ_CAP.PROJ_TYPE NOT IN ('Sale/Spec Homes','Swimming Pool','Custom Homes','Unclassified')
AND (PROJ_CAP.EST_LOW_VALUE IS NOT NULL OR PROJ_CAP.EST_HIGH_VALUE IS NOT NULL)
) AS X
;;
  }

  dimension: dr_nbr {
    type: string
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
    sql: ${TABLE}.PROJECT ;;
    # html:
    #     <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/227?Project={{ project._value | url_encode }}" target="_blank">{{ project._value }}</a></font></u>
    #     ;;  ------ Commenting out since that dashboard is retired KC 03/12/24
  }

  dimension: add_to_homepage {
    type: string
    html:
        <font color="blue "><u><a href = "https://ba.equipmentshare.com/crm/dodge_homepage?dr_nbr={{ dr_nbr._value | url_encode }}&project={{ project._value  }}&email={{  _user_attributes['email'] }}" target="_blank">Add to Homepage</a></font></u>
        ;;
    sql: ${TABLE}.PROJECT ;;
  }

  dimension: stage_desc {
    type: string
    sql: ${TABLE}.STAGE_DESC ;;
  }

  dimension: county {
    type: string
    sql: ${TABLE}.COUNTY ;;
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
    html:<font color="blue "><u><a href="https://www.google.com/maps/dir/?api=1&destination={{ address_line_1._value | url_encode }}+{{ city._value | url_encode }}+{{ state._value | url_encode }}+{{ zip_code._value | url_encode }}&travelmode=car" target="_blank">{{ address_line_1._value }}</a></font></u> ;;
  }

  dimension: zip_code {
    type: string
    map_layer_name: us_zipcode_tabulation_areas
    sql: ${TABLE}.ZIP_CODE ;;
  }

  dimension: bid_date {
    type: date
    sql: ${TABLE}.BID_DATE ;;
  }

  dimension: publish_date {
    type: date
    sql: ${TABLE}.PUBLISH_DATE ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.CITY ;;
  }

  dimension: state {
    type: string
    map_layer_name: us_states
    sql: ${TABLE}.STATE ;;
  }

  dimension: stage_order {
    type: number
    sql: ${TABLE}.STAGE_ORDER ;;
  }


  dimension: project_url {
    type: string
   html:<font color="blue "><u><a href="https://apps.construction.com/projects/{{ dr_nbr._value }}#directsearch" target="_blank">Link to Dodge Project</a></font></u> ;;
   sql: ${TABLE}.PROJECT_URL ;;
 }



  dimension: project_market {
    type: string
    sql: case when ${msa.msa} is null and ${city} is null then ${state}
          when ${msa.msa} is null and ${state} is null then ${city}
          when ${msa.msa} is null then ${city}||', '||${state} else ${msa.msa} end ;;
  }

  dimension: project_type {
    type: string
    sql: ${TABLE}.PROJECT_TYPE ;;
  }



  # dimension: get_directions {
  #   type: string
  #   sql: ${TABLE}.DR_NBR ;;
  #   html:<font color="blue "><u><a href="https://www.google.com/maps/dir/?api=1&destination={{ company_address._value | url_encode }}+{{ company_city._value | url_encode }}+{{ company_state._value | url_encode }}+{{ company_zipcode._value | url_encode }}&travelmode=car" target="_blank">Get Directions</a></font></u> ;;
  # }

  dimension: create_dodge_project {
    type: string
    html: <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/create_project_dodge?Project_Name={{  project._value }}&Project_Address={{  address_line_1._value }}&Project_Zipcode={{  zip_code._value }}&Project_City={{  city._value }}&Project_State={{  state._value }}&Project_Type={{  project_type._value }}&Project_Value={{  estimated_low_value._value }}" target="_blank">Create Project</a></font></u>
      ;;
    sql: ${project};;
  }

  }
