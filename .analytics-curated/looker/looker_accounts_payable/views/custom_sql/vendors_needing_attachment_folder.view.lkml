view: vendors_needing_attachment_folder {
  derived_table: {
    sql: --VERSION 02
      SELECT
    VEND.VENDORID         AS VENDOR_ID,
    VEND.NAME             AS VENDOR_NAME,
    VEND.VENDOR_CATEGORY  AS VENDOR_CATEGORY,
    VEND.VENDOR_PORTAL_ID AS CLUSTDOC_ID,
    VEND.REQUIRES_COI     AS REQUIRES_COI,
    VEND.SUPDOCID         AS ATTACHMENT_ID
FROM
    ANALYTICS.INTACCT.VENDOR VEND
WHERE
      (VEND.VENDOR_CATEGORY = 'Transportation Services/Postage' OR VEND.REQUIRES_COI = TRUE)
  AND VEND.SUPDOCID IS NULL
  AND VEND.STATUS = 'active'
       ;;
  }

  measure: count {type: count drill_fields: [detail*]}
  dimension: vendor_id {type: string sql: ${TABLE}."VENDOR_ID" ;;}
  dimension: vendor_name {type: string sql: ${TABLE}."VENDOR_NAME" ;;}
  dimension: vendor_category {type: string sql: ${TABLE}."VENDOR_CATEGORY" ;;}
  dimension: clustdoc_id {type: string sql: ${TABLE}."CLUSTDOC_ID" ;;}
  dimension: requires_coi {type: string sql: ${TABLE}."REQUIRES_COI" ;;}
  dimension: attachment_id {type: string sql: ${TABLE}."ATTACHMENT_ID" ;;}

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      vendor_category,
      clustdoc_id,
      requires_coi,
      attachment_id
    ]
  }
}
