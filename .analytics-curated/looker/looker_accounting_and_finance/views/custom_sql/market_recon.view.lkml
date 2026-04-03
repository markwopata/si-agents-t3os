view: market_recon {
  derived_table: {
    sql: SELECT s.DEPARTMENTID                                                                AS MARKET_ID,
       s.TITLE                                                                       AS SAGE_MARKET_NAME,
       s.WHENCREATED                                                                 AS SAGE_CREATED_DATE,
       s.DATE_NO_LONGER_NEW_MARKET                                                   AS SAGE_DATE_NO_LONGER_NEW_MARKET,
       CAST(mm.BASIC_OPERATIONAL_READINESS_TARGET_DATE AS DATE)                      AS TARGET_OPERATIONAL_READINESS_DATE,
       mr.MARKET_START_MONTH,
       s.DEPARTMENT_TYPE                                                             AS SAGE_DEPARTMENT_TYPE,
       s.STATUS                                                                      AS SAGE_STATUS,
       p.DEPARTMENTID                                                                AS SAGE_PARENT_ID,
       p.TITLE                                                                       AS SAGE_PARENT_NAME,
       p.DEPARTMENT_TYPE                                                             AS SAGE_PARENT_TYPE,
       CASE WHEN p.DEPARTMENT_TYPE = 'District' THEN RIGHT(p.TITLE, 3) ELSE NULL END AS SAGE_DISTRICT,
       x.MARKET_NAME                                                                 AS XWALK_MARKET_NAME,
       x.DISTRICT                                                                    AS XWALK_DISTRICT,
       m.NAME                                                                        AS T3_MARKET_NAME,
       m.ACTIVE                                                                      AS T3_ACTIVE_MARKET,
       m.DISTRICT_ID                                                                 AS T3_DISTRICT_ID,
       d.DISTRICT_ID                                                                 AS MARKET_DATA_DISTRICT,
       r.REGION_ID                                                                   AS MARKET_DATA_REGION,
       r.REGION_NAME                                                                 AS MARKET_DATA_REGION_NAME
FROM ANALYTICS.INTACCT.DEPARTMENT s
         LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT p ON s.PARENTKEY = p.RECORDNO
         LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK x ON s.DEPARTMENTID = x.MARKET_ID::VARCHAR
         LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS m ON s.DEPARTMENTID = m.MARKET_ID::VARCHAR AND m.COMPANY_ID = 1854
         LEFT JOIN ANALYTICS.MARKET_DATA.MARKET_DATA md ON s.DEPARTMENTID = md.MARKET_ID::VARCHAR
         LEFT JOIN ANALYTICS.PUBLIC.DISTRICTS d ON md.DISTRICT_ID = d.ID
         LEFT JOIN ANALYTICS.PUBLIC.REGIONS r ON d.REGION_ID = r.REGION_ID
         LEFT JOIN ANALYTICS.MONDAY.MASTER_MARKETS_BOARD mm ON s.DEPARTMENTID = mm.MARKET_ID::VARCHAR
         LEFT JOIN ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE mr ON s.DEPARTMENTID = mr.MARKET_ID::VARCHAR
WHERE (s.DEPARTMENT_TYPE IN ('Branch - T3', 'D365') OR s.DEPARTMENT_TYPE IS NULL)
  AND s.STATUS <> 'inactive'
  AND p.DEPARTMENTID NOT IN ('COMPANY3', 'CORP10', 'DEPARTMENTS')
  AND s.DEPARTMENTID NOT IN ('PNP', 'PNPR1', 'PNPR3');;
  }

  dimension: market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: sage_market_name {
    label: "Sage Market Name"
    type: string
    sql: ${TABLE}."SAGE_MARKET_NAME" ;;
  }

  dimension: sage_created_date {
    label: "Sage Created Date"
    type: date
    sql: ${TABLE}."SAGE_CREATED_DATE" ;;
  }

  dimension: sage_date_no_longer_new_market {
    label: "Sage Date No Longer New Market"
    type: date
    sql: ${TABLE}."SAGE_DATE_NO_LONGER_NEW_MARKET" ;;
  }

  dimension: target_operational_readiness_date {
    label: "Target Operational Readiness Date"
    type: date
    sql: ${TABLE}."TARGET_OPERATIONAL_READINESS_DATE" ;;
  }

  dimension: market_start_month {
    label: "Market Start Month"
    type: date
    sql: ${TABLE}."MARKET_START_MONTH" ;;
  }

  dimension: sage_department_type {
    label: "Sage Department Type"
    type: string
    sql: ${TABLE}."SAGE_DEPARTMENT_TYPE" ;;
  }

  dimension: sage_status {
    label: "Sage Status"
    type: string
    sql: ${TABLE}."SAGE_STATUS" ;;
  }

  dimension: sage_parent_id {
    label: "Sage Parent ID"
    type: string
    sql: ${TABLE}."SAGE_PARENT_ID" ;;
  }

  dimension: sage_parent_name {
    label: "Sage Parent Name"
    type: string
    sql: ${TABLE}."SAGE_PARENT_NAME" ;;
  }

  dimension: sage_parent_type {
    label: "Sage Parent Type"
    type: string
    sql: ${TABLE}."SAGE_PARENT_TYPE" ;;
  }

  dimension: sage_district {
    label: "Sage District"
    type: string
    sql: ${TABLE}."SAGE_DISTRICT" ;;
  }

  dimension: xwalk_market_name {
    label: "XWALK Market Name"
    type: string
    sql: ${TABLE}."XWALK_MARKET_NAME" ;;
  }

  dimension: xwalk_district {
    label: "XWALK District"
    type: string
    sql: ${TABLE}."XWALK_DISTRICT" ;;
  }

  dimension: t3_market_name {
    label: "T3 Market Name"
    type: string
    sql: ${TABLE}."T3_MARKET_NAME" ;;
  }

  dimension: t3_active_market {
    label: "T3 Active Market"
    type: yesno
    sql: ${TABLE}."T3_ACTIVE_MARKET" ;;
  }

  dimension: t3_district_id {
    label: "T3 District ID"
    type: string
    sql: ${TABLE}."T3_DISTRICT_ID" ;;
  }

  dimension: market_data_district {
    label: "District"
    type: string
    sql: ${TABLE}."MARKET_DATA_DISTRICT" ;;
  }

  dimension: market_data_region {
    label: "Region"
    type: string
    sql: ${TABLE}."MARKET_DATA_REGION" ;;
  }

  dimension: market_data_region_name {
    label: "Region Name"
    type: string
    sql: ${TABLE}."MARKET_DATA_REGION_NAME" ;;
  }

  measure: name_match {
    label: "Sage/T3 Name Match"
    type: yesno
    sql: ${sage_market_name} = ${t3_market_name} ;;
  }

  measure: xwalk_district_match {
    label: "Sage/Market Data District Match"
    type: yesno
    sql: ${sage_district} = ${market_data_district} ;;
  }
}
