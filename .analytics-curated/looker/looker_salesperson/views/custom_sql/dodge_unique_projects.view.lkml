view: dodge_unique_projects {

  derived_table: {
    sql:
     SELECT dr_nbr as dr_nbr, max(max_publish_date) AS max_publish_Date , MAX(STAGE_ORDER) AS max_stage_order    FROM (
SELECT PC.dr_nbr,
TRY_TO_DATE(PC.PUBLISH_DATE,'YYYYMMDD') AS max_publish_date,
STAGE.STAGE_DESC AS STAGE_DESC, SO.STAGE_ORDER AS STAGE_ORDER
FROM INBOUND.DODGE_CONSTRUCTION_VIEW.FF_OUT_REP_PROJECT_CAPSULE AS PC
LEFT JOIN INBOUND.DODGE_CONSTRUCTION_VIEW.FF_OUT_REP_STAGE AS STAGE
ON STAGE.DR_NBR::varchar = PC.DR_NBR::varchar
LEFT JOIN ANALYTICS.DODGE.STAGE_ORDER AS SO
ON STAGE.STAGE_DESC = SO.STAGE_DESC
WHERE STAGE.STAGE_DESC NOT IN ('Abandoned','Delayed','Pre-Design','Planning Schematics')
AND PC.PROJ_TYPE NOT IN ('Sale/Spec Homes','Swimming Pool','Custom Homes','Unclassified')
AND (PC.EST_LOW_VALUE IS NOT NULL OR PC.EST_HIGH_VALUE IS NOT NULL)
) AS x
GROUP by dr_nbr      ;;
  }

  dimension: dr_nbr {
    type: string
    sql: ${TABLE}.dr_nbr ;;
  }

  dimension: max_publish_date {
    type: date
    sql: ${TABLE}.max_publish_date ;;
  }

  dimension:max_stage_order {
    type: number
    sql: ${TABLE}.max_stage_order ;;
  }


  }
