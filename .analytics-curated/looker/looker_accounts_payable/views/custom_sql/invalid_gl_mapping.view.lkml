#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: invalid_gl_mapping {
  derived_table: {
    sql: SELECT
          GL_ACTIVITY.ENTITY,
          GL_ACTIVITY.DEPT_ID,
          GL_ACTIVITY.DEPT_NAME,
          GL_ACTIVITY.ACCOUNT,
          GL_ACTIVITY.ACCOUNT_NAME,
          GL_ACTIVITY.EXP_LINE_ID,
          GL_ACTIVITY.EXP_LINE_NAME,
          SUM(GL_ACTIVITY.NET_AMOUNT) AS NET_AMT
      FROM
          (SELECT
               GLB.JOURNAL                                                                AS JOURNAL,
               GLB.BATCHNO                                                                AS TRANSACTION_NUMBER,
               GLB.BATCH_DATE                                                             AS POSTING_DATE,
               GLB.BATCH_TITLE                                                            AS BATCH_TITLE,
               GLB.STATE                                                                  AS STATE,
               GLB.REFERENCENO                                                            AS REFERENCE,
               GLB.MODULE                                                                 AS MODULE,
               GLE.LINE_NO                                                                AS LINE_NUMBER,
               GLE.ACCOUNTNO                                                              AS ACCOUNT,
               GLA.TITLE                                                                  AS ACCOUNT_NAME,
               GLE.LOCATION                                                               AS ENTITY,
               GLE.DEPARTMENT                                                             AS DEPT_ID,
               DEPT.TITLE                                                                 AS DEPT_NAME,
               GLE.GLDIMEXPENSE_LINE                                                      AS EXP_LINE_ID,
               EL.NAME                                                                    AS EXP_LINE_NAME,
               GLE.DESCRIPTION                                                            AS LINE_MEMO,
               ROUND(CASE WHEN GLE.TR_TYPE = 1 THEN GLE.TRX_AMOUNT ELSE 0 END, 2)         AS DEBIT,
               ROUND(CASE WHEN GLE.TR_TYPE = -1 THEN (GLE.TRX_AMOUNT * -1) ELSE 0 END, 2) AS CREDIT,
               ROUND((GLE.TRX_AMOUNT * GLE.TR_TYPE), 2)                                   AS NET_AMOUNT,
               UI1.DESCRIPTION                                                            AS ORIGINATOR_NAME,
               UI2.DESCRIPTION                                                            AS SUBMITTER_NAME,
               UI3.DESCRIPTION                                                            AS APPROVER_NAME,
               REL_DEPT.EL_TO_DEPT_OK
           FROM
               ANALYTICS.INTACCT.GLBATCH GLB
                   LEFT JOIN ANALYTICS.INTACCT.GLENTRY GLE ON GLB.RECORDNO = GLE.BATCHNO
                   LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON GLE.ACCOUNTNO = GLA.ACCOUNTNO
                   LEFT JOIN ANALYTICS.INTACCT.USERINFO UI1 ON GLB.USERKEY = UI1.RECORDNO
                   LEFT JOIN ANALYTICS.INTACCT.USERINFO UI2 ON GLB.CREATEDBY = UI2.RECORDNO
                   LEFT JOIN ANALYTICS.INTACCT.USERINFO UI3 ON GLB.MODIFIEDBY = UI3.RECORDNO
                   LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON GLE.DEPARTMENT = DEPT.DEPARTMENTID
                   LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE EL ON GLE.GLDIMEXPENSE_LINE = EL.ID
                   LEFT JOIN (SELECT DISTINCT
                                  EXPENSE_LINE AS EXP_LINE_NAME,
                                  VALUE        AS DEPT_ID,
                                  TRUE         AS EL_TO_DEPT_OK
                              FROM
                                  ANALYTICS.INTACCT.EXPENSE_LINE_MAPPING ELM1_DEP
                              WHERE
                                  ELM1_DEP.DIMENSION = 'DEPARTMENT') REL_DEPT
                             ON EL.NAME = REL_DEPT.EXP_LINE_NAME AND GLE.DEPARTMENT = REL_DEPT.DEPT_ID
                   LEFT JOIN (SELECT DISTINCT
                                  EXPENSE_LINE AS EXP_LINE_NAME,
                                  VALUE        AS GL_ACCOUNT,
                                  TRUE         AS EL_TO_GLACCOUNT_OK
                              FROM
                                  ANALYTICS.INTACCT.EXPENSE_LINE_MAPPING ELM2_ACCT
                              WHERE
                                  ELM2_ACCT.DIMENSION = 'GLACCOUNT') REL_ACCT
                             ON EL.NAME = REL_ACCT.EXP_LINE_NAME AND GLE.ACCOUNTNO = REL_ACCT.GL_ACCOUNT
           WHERE
                 GLB.STATE = 'Posted'
      --   AND GLB.BATCH_DATE BETWEEN '2023-06-01' AND '2023-06-30'
             AND GLB.BATCH_DATE >= '2023-01-01'
             AND (REL_DEPT.EL_TO_DEPT_OK IS NULL OR REL_ACCT.EL_TO_GLACCOUNT_OK IS NULL)
             AND GLE.GLDIMEXPENSE_LINE IS NOT NULL
             AND GLA.CLOSINGTYPE IN ('closed to account', 'closing account')) GL_ACTIVITY
      GROUP BY
          GL_ACTIVITY.ENTITY,
          GL_ACTIVITY.DEPT_ID,
          GL_ACTIVITY.DEPT_NAME,
          GL_ACTIVITY.ACCOUNT,
          GL_ACTIVITY.ACCOUNT_NAME,
          GL_ACTIVITY.EXP_LINE_ID,
          GL_ACTIVITY.EXP_LINE_NAME
      HAVING
          NET_AMT != 0 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: dept_id {
    type: string
    sql: ${TABLE}."DEPT_ID" ;;
  }

  dimension: dept_name {
    type: string
    sql: ${TABLE}."DEPT_NAME" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: exp_line_id {
    type: string
    sql: ${TABLE}."EXP_LINE_ID" ;;
  }

  dimension: exp_line_name {
    type: string
    sql: ${TABLE}."EXP_LINE_NAME" ;;
  }

  dimension: net_amt {
    type: number
    sql: ${TABLE}."NET_AMT" ;;
  }

  set: detail {
    fields: [
        entity,
	dept_id,
	dept_name,
	account,
	account_name,
	exp_line_id,
	exp_line_name,
	net_amt
    ]
  }
}
