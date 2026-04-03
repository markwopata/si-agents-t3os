view: workday_region_cleanup {
  derived_table: {
    sql: select woh.EMPLOYEE_ID,
       woh.FULL_LEGAL_NAME,
       woh.MARKET_ID,
       mrx.MARKET_NAME,
       woh.REGION as workday_region,
       CONCAT('R',mrx.REGION,' ',mrx.REGION_NAME) as organization_region
from PEOPLE_ANALYTICS.WORKDAY_RAAS.WORKER_ORGANIZATION_HIERARCHY woh
left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx on woh.MARKET_ID = mrx.MARKET_ID
where woh.REGION != CONCAT('R',mrx.REGION,' ',mrx.REGION_NAME) ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: full_legal_name {
    type: string
    sql: ${TABLE}."FULL_LEGAL_NAME" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: workday_region {
    type: string
    sql: ${TABLE}."WORKDAY_REGION" ;;
  }

  dimension: organization_region {
    type: string
    sql: ${TABLE}."ORGANIZATION_REGION" ;;
  }
}
