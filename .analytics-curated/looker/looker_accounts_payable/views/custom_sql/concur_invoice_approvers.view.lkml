view: concur_invoice_approvers {
  derived_table: {
    sql: SELECT
          INV_APP.GROUP_CODE    AS BRANCH_ID,
          INV_APP."GROUP"       AS BRANCH_NAME,
          INV_APP.APPROVER_ID   AS APPROVER_ID,
          INV_APP.APPROVER_NAME AS APPROVER_NAME,
          INV_APP._ES_UPDATE_TIMESTAMP
      FROM
          ANALYTICS.CONCUR.INVOICE_APPROVERS INV_APP
              JOIN (SELECT
                        INV_APP1.GROUP_CODE                AS BRANCH_ID,
                        MAX(INV_APP1._ES_UPDATE_TIMESTAMP) AS LAST_TIMESTAMP
                    FROM
                        ANALYTICS.CONCUR.INVOICE_APPROVERS INV_APP1
                    WHERE
                        INV_APP1.GROUP_CODE != '-'
                    GROUP BY INV_APP1.GROUP_CODE) LAST
                   ON INV_APP.GROUP_CODE = LAST.BRANCH_ID AND INV_APP._ES_UPDATE_TIMESTAMP = LAST.LAST_TIMESTAMP
      ORDER BY
          INV_APP.GROUP_CODE
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: approver_id {
    type: string
    sql: ${TABLE}."APPROVER_ID" ;;
  }

  dimension: approver_name {
    type: string
    sql: ${TABLE}."APPROVER_NAME" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  set: detail {
    fields: [branch_id, branch_name, approver_id, approver_name, _es_update_timestamp_time]
  }
}
