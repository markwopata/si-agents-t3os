view: yard_tech_users {
  derived_table: {
    sql: SELECT
CASE WHEN CA.USER_ID = 36752 THEN YT.EMAIL_ADDRESS ELSE U.EMAIL_ADDRESS END AS CREATED_BY,
CA.DATE_CREATED AS DATE_CREATED,
CA.COMMAND, CA.PARAMETERS:rental_id AS RENTAL_ID
FROM ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT AS CA
LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS AS U
ON CA.USER_ID = U.USER_ID
LEFT JOIN ANALYTICS.WEBAPPS.YARD__TECHS__ADD__ASSET__FORM AS YT
ON CA.PARAMETERS:rental_id = YT.RENTAL_ID
WHERE LOWER(CA.COMMAND) like '%rental%'
AND CA.PARAMETERS:rental_id IS NOT NULL
ORDER BY DATE_CREATED
                                     ;;
  }



  dimension: cretaed_by {
    type: string
    sql: ${TABLE}.CREATED_BY ;;
  }

  dimension: date_created {
    type: date_time
    sql: ${TABLE}.DATE_CREATED ;;
  }

  dimension: command {
    type: string
    sql: ${TABLE}.COMMAND ;;
  }

  dimension: rental_id  {
    type: number
    sql: ${TABLE}.RENTAL_ID ;;
  }
  }
