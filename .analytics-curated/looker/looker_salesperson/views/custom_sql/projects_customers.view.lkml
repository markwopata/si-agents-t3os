view: projects_customers {
  derived_table: {
    sql: SELECT PC.PROJECT_ID AS PROJECT_ID, PM.PROJECT_NAME AS PROJECT_NAME,
PC.COMPANY_PROSPECT_ID AS COMPANY_PROSPECT_ID, CASE WHEN LEFT(PC.COMPANY_PROSPECT_ID,1) = 'P'
THEN PR.COMPANY_NAME ELSE EX.COMPANY_NAME END AS COMPANY_NAME,
CASE WHEN LEFT(PC.COMPANY_PROSPECT_ID,1) = 'P'
THEN 'Prospect'  else 'Existing Customer' end as TYPE,
PC.SALES_REPRESENTATIVE_EMAIL_ADDRESS AS PROJECT_REP,
CASE WHEN LEFT(PC.COMPANY_PROSPECT_ID,1) = 'P'
THEN PR.SALES_REPRESENTATIVE_EMAIL_ADDRESS  ELSE '' END AS COMPANY_PROSPECT_REP
FROM ANALYTICS.WEBAPPS.CRM__PROJECTS__CUSTOMERS__V4  AS PC
INNER JOIN ANALYTICS.WEBAPPS.CRM__PROJECT__MAPPING__V4 AS PM
ON PC.PROJECT_ID = PM.PROJECT_ID::VARCHAR
LEFT JOIN ANALYTICS.WEBAPPS.CRM__PROSPECTS__MAPPING__V4 AS PR
ON PC.COMPANY_PROSPECT_ID =  PR.PROSPECT_ID
LEFT JOIN ANALYTICS.WEBAPPS.CRM__EXISTING__COMPANIES__MAPPING__V4 AS EX
ON PC.COMPANY_PROSPECT_ID = EX.COMPANY_ID::VARCHAR  ;;
  }



  dimension: project_id {
    type: string
    sql: ${TABLE}.PROJECT_ID ;;
  }

  dimension: project_name {
    type: string
    sql: ${TABLE}.PROJECT_NAME ;;
  }

  dimension: company_prospect_id {
    type: string
    sql: ${TABLE}.COMPANY_PROSPECT_ID ;;
  }

  dimension:  company_name {
    type: string
    sql: ${TABLE}.COMPANY_NAME ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.TYPE ;;
  }

  dimension: project_rep {
    type: string
    sql: ${TABLE}.PROJECT_REP ;;
  }

  dimension: company_prospect_rep {
    type: string
    sql: ${TABLE}.COMPANY_PROSPECT_REP ;;
  }
  }
