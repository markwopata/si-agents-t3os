view: concur_approvers_per_sage_location {
  derived_table: {
    sql:
      SELECT DISTINCT
        sage.DEPARTMENTID AS SAGE_LOCATION_ID,
        sage.TITLE AS SAGE_LOCATION_NAME,
        concur.GROUP_CODE AS CONCUR_LOCATION_ID,
        concur."GROUP" AS CONCUR_LOCATION_NAME,
        sage.STATUS AS SAGE_STATUS,
        COALESCE(ad.EMPLOYEE_NAME, concur.APPROVER_NAME) AS CONCUR_APPROVER
      FROM ANALYTICS.INTACCT.DEPARTMENT sage
      LEFT JOIN ANALYTICS.CONCUR.INVOICE_APPROVERS concur
        ON sage.DEPARTMENTID = concur.GROUP_CODE
      LEFT JOIN ANALYTICS.CONCUR.APPROVER_DELEGATES ad
        ON LOWER(ad.EMPLOYEE_ID) = concur.APPROVER_ID
      WHERE sage.STATUS = 'active' ;;
  }

  dimension: sage_location_id {
    type: string
    sql: ${TABLE}."SAGE_LOCATION_ID" ;;
  }

  dimension: sage_location_name {
    type: string
    sql: ${TABLE}."SAGE_LOCATION_NAME" ;;
  }

  dimension: concur_location_id {
    type: string
    sql: ${TABLE}."CONCUR_LOCATION_ID" ;;
  }

  dimension: concur_location_name {
    type: string
    sql: ${TABLE}."CONCUR_LOCATION_NAME" ;;
  }

  dimension: sage_status {
    type: string
    sql: ${TABLE}."SAGE_STATUS" ;;
  }

  dimension: concur_approver {
    type: string
    sql: ${TABLE}."CONCUR_APPROVER" ;;
  }

  set: detail {
    fields: [
      sage_location_id,
      sage_location_name,
      concur_location_id,
      concur_location_name,
      sage_status,
      concur_approver
    ]
  }
}
