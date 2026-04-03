view: sage_out_of_balance {

    derived_table: {
      sql: SELECT
    GLB.JOURNAL                                   AS JOURNAL,
    GLB.BATCHNO                                   AS TRANSACTION_NUMBER,
    GLB.BATCH_DATE                                AS POSTING_DATE,
    GLB.MODULE                                    AS MODULE,
    SUM(ROUND((GLE.TRX_AMOUNT * GLE.TR_TYPE), 2)) AS NET_AMOUNT
FROM
    ANALYTICS.INTACCT.GLBATCH GLB
        LEFT JOIN ANALYTICS.INTACCT.GLENTRY GLE ON GLB.RECORDNO = GLE.BATCHNO
        LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON GLE.ACCOUNTNO = GLA.ACCOUNTNO
        LEFT JOIN ANALYTICS.INTACCT.USERINFO UI1 ON GLB.USERKEY = UI1.RECORDNO
        LEFT JOIN ANALYTICS.INTACCT.USERINFO UI2 ON GLB.CREATEDBY = UI2.RECORDNO
        LEFT JOIN ANALYTICS.INTACCT.USERINFO UI3 ON GLB.MODIFIEDBY = UI3.RECORDNO
        LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON GLE.DEPARTMENT = DEPT.DEPARTMENTID
WHERE
      GLB.STATE = 'Posted'
  AND GLB.BATCH_DATE -->= '2023-01-01'
 >= DATEADD(day, -1, current_timestamp())

GROUP BY ALL
HAVING
    NET_AMOUNT !=0
order by posting_date desc
               ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: journal {
      type: number
      sql: ${TABLE}."JOURNAL" ;;
    }

    dimension: transaction_number {
      type: string
      sql: ${TABLE}."TRANSACTION_NUMBER" ;;
    }

    dimension: posting_date {
      type: date
      sql: ${TABLE}."POSTING_DATE" ;;
    }


  dimension: module {
    type: string
    sql: ${TABLE}."MODULE" ;;
  }



   measure: net_amount {
      type: number
      sql: ${TABLE}."NET_AMOUNT" ;;
    }

    # dimension: po_date {
    #   type: date
    #   sql: ${TABLE}."PO_Date" ;;
    # }

    # dimension_group: created_on {
    #   type: time
    #   sql: ${TABLE}."Created_On" ;;
    # }

    # dimension_group: modified_on {
    #   type: time
    #   sql: ${TABLE}."Modified_On" ;;
    # }

    set: detail {
      fields: [
    journal, transaction_number, posting_date, module
      ]
    }
  }
