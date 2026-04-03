view: clustdoc_vendor_log {
  derived_table: {
    sql:
    SELECT
    V.RECORDNO,
    V.VENDORID                                   AS SAGE_VENDOR_ID,
    V.NAME                                       AS SAGE_VENDOR_NAME,
    V.VENDOR_PORTAL_ID                           AS CD_APPLICATION_ID,
    V.COMPANY_LEGAL_NAME,
    V.COMPANY_NAME_DBA,
    AV.SOURCE                                    AS CREATED_VIA,
    SAGE_USER.DESCRIPTION                        AS SAGE_CREATED_BY,
    CD.OWNER                                     AS CLUSTDOC_OWNER,
    COALESCE(CD.OWNER, SAGE_USER.DESCRIPTION)    AS CREATED_BY,
    DATE(AV.ACCESS_TIME)                         AS CREATED_ON,
    AV.OBJECT_LINK                               AS SAGE_URL,
    CASE
        WHEN CD.TAGS LIKE '%URGENT%' THEN true
        else false
    END                                          AS IS_URGENT
FROM ANALYTICS.INTACCT.VENDOR V
LEFT JOIN ANALYTICS.INTACCT_AUDIT.VENDOR AV
    ON V.VENDORID = AV.OBJECT_KEY
    AND AV.ACCESS_MODE = 'Create'
LEFT JOIN ANALYTICS.CLUSTDOC.DOSSIER_EXTRACT CD
    ON V.VENDOR_PORTAL_ID = CD.APPLICATION_ID
LEFT JOIN ANALYTICS.INTACCT.USERINFO SAGE_USER
    ON V.CREATEDBY = SAGE_USER.RECORDNO
ORDER BY CREATED_ON DESC;;
  }

  dimension: RECORDNO {
    type: string
    sql: ${TABLE}.RECORDNO;;
  }

  dimension: SAGE_VENDOR_ID {
    type: string
    sql: ${TABLE}.SAGE_VENDOR_ID;;
  }

  dimension: SAGE_VENDOR_NAME {
    type: string
    sql: ${TABLE}.SAGE_VENDOR_NAME;;
  }

  dimension: CD_APPLICATION_ID {
    type: string
    sql: ${TABLE}.CD_APPLICATION_ID;;
  }

  dimension: COMPANY_LEGAL_NAME {
    type: string
    sql: ${TABLE}.COMPANY_LEGAL_NAME;;
  }

  dimension: COMPANY_NAME_DBA {
    type: string
    sql: ${TABLE}.COMPANY_NAME_DBA;;
  }

  dimension: CREATED_VIA {
    type: string
    sql: ${TABLE}.CREATED_VIA;;
  }

  dimension: SAGE_CREATED_BY {
    type: string
    sql: ${TABLE}.SAGE_CREATED_BY;;
  }

  dimension: CLUSTDOC_OWNER {
    type: string
    sql: ${TABLE}.CLUSTDOC_OWNER;;
  }

  dimension: CREATED_BY {
    type: string
    sql: ${TABLE}.CREATED_BY;;
  }

  dimension_group: CREATED {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.CREATED_ON ;;
  }

  dimension: SAGE_URL {
    type: string
    sql: ${TABLE}.SAGE_URL;;
  }

  dimension: IS_URGENT {
    type: string
    sql: ${TABLE}.IS_URGENT;;
  }

  measure: VENDOR_COUNT {
    type: count_distinct
    sql: ${SAGE_VENDOR_ID} ;;
    description: "Count of distinct vendors"
  }

}
