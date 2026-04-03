#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: test_vendor_creation_method {
  derived_table: {
    sql: SELECT
          VEND.VENDORID                                                                                         AS VENDORD_ID,
          VEND.NAME                                                                                             AS VENDOR_NAME,
          CAST(CONVERT_TIMEZONE('America/Chicago', VEND.WHENCREATED) AS DATE)                                   AS VENDOR_CREATE_DATE,
          CASE
              WHEN VEND.VENDOR_PORTAL_ID IS NOT NULL THEN 'Created Via Clustdoc'
              ELSE 'Created in Intacct' END                                                                     AS CREATION_METHOD
      FROM
          ANALYTICS.INTACCT.VENDOR VEND ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendord_id {
    type: string
    sql: ${TABLE}."VENDORD_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: vendor_create_date {
    type: date
    sql: ${TABLE}."VENDOR_CREATE_DATE" ;;
  }

  dimension: creation_method {
    type: string
    sql: ${TABLE}."CREATION_METHOD" ;;
  }

  set: detail {
    fields: [
        vendord_id,
	vendor_name,
	vendor_create_date,
	creation_method
    ]
  }
}
