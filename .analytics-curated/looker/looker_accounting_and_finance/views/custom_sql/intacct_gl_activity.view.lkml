view: intacct_gl_activity {
  derived_table: {
    sql: SELECT
          GLB.BATCHNO,
          GLB.BATCH_TITLE,
          CAST(GLB.BATCH_DATE AS DATE) AS "POSTING_DATE",
          GLB.JOURNAL,
          GLB.MODULE,
          USER1.DESCRIPTION            AS "CREATED_BY_NAME",
          USER2.DESCRIPTION            AS "APPROVED_BY_NAME",
          GLE.ACCOUNTNO                AS "ACCOUNT",
          GLE.DEPARTMENT               AS "LOCATION",
          GLE.LOCATION                 AS "ENTITY",
          GLE.DESCRIPTION              AS "LINE_ITEM_DESCRIPTION",
          CASE WHEN GLE.TR_TYPE = 1 THEN GLE.AMOUNT ELSE 0 END AS "DEBIT_AMOUNT",
          CASE WHEN GLE.TR_TYPE <>1 THEN GLE.AMOUNT ELSE 0 END AS "CREDIT_AMOUNT",
          GLE.AMOUNT * GLE.TR_TYPE     AS "NET_AMOUNT",
          CASE WHEN GLE.STATISTICAL = 'F' THEN 'Financial' ELSE 'Statistical' END AS "ENTRY_TYPE",
          GLB.STATE AS "STATE"
      FROM
          ANALYTICS.INTACCT.GLBATCH GLB
              LEFT JOIN ANALYTICS.INTACCT.GLENTRY GLE ON GLB.RECORDNO = GLE.BATCHNO
              LEFT JOIN ANALYTICS.INTACCT.USERINFO USER1 ON GLB.USERKEY = USER1.RECORDNO
              LEFT JOIN ANALYTICS.INTACCT.USERINFO USER2 ON GLB.MODIFIEDBY = USER2.RECORDNO
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: batchno {
    type: number
    sql: ${TABLE}."BATCHNO" ;;
  }

  dimension: batch_title {
    type: string
    sql: ${TABLE}."BATCH_TITLE" ;;
  }

  dimension: posting_date {
    type: date
    sql: ${TABLE}."POSTING_DATE" ;;
  }

  dimension: journal {
    type: string
    sql: ${TABLE}."JOURNAL" ;;
  }

  dimension: module {
    type: string
    sql: ${TABLE}."MODULE" ;;
  }

  dimension: created_by_name {
    type: string
    sql: ${TABLE}."CREATED_BY_NAME" ;;
  }

  dimension: approved_by_name {
    type: string
    sql: ${TABLE}."APPROVED_BY_NAME" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: line_item_description {
    type: string
    sql: ${TABLE}."LINE_ITEM_DESCRIPTION" ;;
  }

  dimension: debit_amount {
    type: number
    sql: ${TABLE}."DEBIT_AMOUNT" ;;
  }

  dimension: credit_amount {
    type: number
    sql: ${TABLE}."CREDIT_AMOUNT" ;;
  }

  dimension: net_amount {
    type: number
    sql: ${TABLE}."NET_AMOUNT" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  set: detail {
    fields: [
      batchno,
      batch_title,
      posting_date,
      journal,
      module,
      created_by_name,
      approved_by_name,
      account,
      location,
      entity,
      line_item_description,
      debit_amount,
      credit_amount,
      net_amount,
      state
    ]
  }
}
