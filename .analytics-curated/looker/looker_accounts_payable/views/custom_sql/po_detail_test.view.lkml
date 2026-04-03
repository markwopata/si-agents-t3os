view: po_detail_test {
  derived_table: {
    sql: SELECT
    POH.CUSTVENDID        AS VENDOR_ID,
    POH.DOCNO             AS DOCUMENT_NUMBER,
    POH.CREATEDFROM       AS SOURCE,
    POH.WHENCREATED       AS DOCUMENT_DATE,
    POH.DOCPARID          AS DOCUMENT_TYPE,
    POH.WHENPOSTED        AS POST_DATE,
    POL.ITEMID            AS ITEM_ID,
    POL.MEMO              AS LINE_MEMO,
    POL.SOURCE_DOCLINEKEY AS SOURCE_LINE_RECORDNO,
    POL.DEPARTMENTID      AS DEPT_ID,
    DEPT.TITLE            AS DEPT_NAME,
    POL.LOCATIONID        AS ENTITY,
    POL.UIQTY             AS QUANTITY,
    POL.UIPRICE           AS UNIT_PRICE
FROM
    ANALYTICS.INTACCT.PODOCUMENT POH
        LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY POL ON POH.DOCID = POL.DOCHDRID
        LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON POL.DEPARTMENTID = DEPT.DEPARTMENTID
        LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON POH.CUSTVENDID = VEND.VENDORID
       ;;
  }

  measure: count {type: count drill_fields: [detail*]}
  dimension: vendor_id {type: string sql: ${TABLE}."VENDOR_ID" ;;}
  dimension: document_number {type: string sql: ${TABLE}."DOCUMENT_NUMBER" ;;}
  dimension: source {type: string sql: ${TABLE}."SOURCE" ;;}
  dimension: document_date {type: string sql: ${TABLE}."DOCUMENT_DATE" ;;}
  dimension: document_type {type: string sql: ${TABLE}."DOCUMENT_TYPE" ;;}
  dimension: post_date {convert_tz: no type: date sql: ${TABLE}."POST_DATE" ;;}
  dimension: item_id {type: string sql: ${TABLE}."ITEM_ID" ;;}
  dimension: line_memo {type: string sql: ${TABLE}."LINE_MEMO" ;;}
  dimension: source_line_recordno {type: string sql: ${TABLE}."SOURCE_LINE_RECORDNO" ;;}
  dimension: dept_id {type: string sql: ${TABLE}."DEPT_ID" ;;}
  dimension: dept_name {type: string sql: ${TABLE}."DEPT_NAME" ;;}
  dimension: entity {type: string sql: ${TABLE}."ENTITY" ;;}
  dimension: quantity {type: number sql: ${TABLE}."QUANTITY" ;;}
  dimension: unit_price {type: number sql: ${TABLE}."UNIT_PRICE" ;;}

  set: detail {
    fields: [
      vendor_id,
      document_number,
      source,
      document_date,
      document_type,
      post_date,
      item_id,
      line_memo,
      source_line_recordno,
      dept_id,
      dept_name,
      entity,
      quantity,
      unit_price
    ]
  }
}
