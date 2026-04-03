#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: cust_to_collect_assign {
  derived_table: {
    sql: SELECT DISTINCT
          TO_CHAR(CCA.COMPANY_ID)                                                           AS CUSTOMER_ID,
          CUST.NAME                                                                         AS CUSTOMER_NAME,
          CASE WHEN COGL.CUSTOMER_ID IS NOT NULL THEN 'LEGAL' ELSE CCA.FINAL_COLLECTOR END  AS COLLECTOR,
          CASE WHEN COGL.CUSTOMER_ID IS NOT NULL THEN 'LEGAL' ELSE CNEM.COLLECTOR_EMAIL END AS EMAIL_ADDRESS
      FROM
          ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS CCA
              LEFT JOIN ANALYTICS.GS.COLLECTOR_OIL_GAS_LEGAL COGL ON CCA.COMPANY_ID = COGL.CUSTOMER_ID and COGL.MONTH_RETURNED_FROM_LEGAL is null
              LEFT JOIN ANALYTICS.GS.COLLECTOR_NAME_EMAIL CNEM
                        ON CCA.FINAL_COLLECTOR = CNEM.COLLECTOR_NAME
              LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES CUST ON CCA.COMPANY_ID = CUST.COMPANY_ID
      ORDER BY
          TO_CHAR(CCA.COMPANY_ID) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  set: detail {
    fields: [
        customer_id,
  customer_name,
  collector,
  email_address
    ]
  }
}
