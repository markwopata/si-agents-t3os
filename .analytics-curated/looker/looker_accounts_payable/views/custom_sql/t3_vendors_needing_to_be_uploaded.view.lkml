view: t3_vendors_needing_to_be_uploaded {
  derived_table: {
    sql: SELECT
    VENDINT.VENDORID AS "VENDOR_ID",
    VENDINT.NAME AS "VENDOR_NAME",
    VENDINT.TAXID AS "VENDOR_TAX_ID",
    CONTACT.MAILADDRESS_ADDRESS1 AS "ADDRESS1",
    CONTACT.MAILADDRESS_ADDRESS2 AS "ADDRESS2",
    CONTACT.MAILADDRESS_CITY AS "CITY",
    CONTACT.MAILADDRESS_STATE AS "STATE",
    CONTACT.MAILADDRESS_ZIP AS "ZIP",
    VENDINT.VENDTYPE,
    VENDINT.REPORTING_CATEGORY,
    VENDINT.WHENCREATED AS "SAGE_CREATED_DATE",
    EVS.EXTERNAL_ERP_VENDOR_REF
FROM
    "ANALYTICS"."INTACCT"."VENDOR" VENDINT
    LEFT JOIN "ANALYTICS"."INTACCT"."CONTACT" CONTACT ON VENDINT.DISPLAYCONTACTKEY = CONTACT.RECORDNO
    LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" EVS ON EVS.EXTERNAL_ERP_VENDOR_REF = VENDINT.VENDORID
WHERE
    VENDINT.STATUS = 'active'
    AND EVS.EXTERNAL_ERP_VENDOR_REF IS NULL
    AND VENDINT.VENDTYPE NOT IN ('Customer Refund', 'Employee', 'Public Utility','Government','501c','W-9 Exempt','W-8')
    AND VENDINT.VENDORID NOT IN ('V27149','V21326','V11391','V24718','V21176')
    AND CONTACT.MAILADDRESS_STATE IN ('AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY','ON','QC','NS','NB','MB','BC','PE','SK','AB','NL')
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: vendor_tax_id {
    type: string
    sql: ${TABLE}."VENDOR_TAX_ID" ;;
  }

  dimension: address1 {
    type: string
    sql: ${TABLE}."ADDRESS1" ;;
  }

  dimension: address2 {
    type: string
    sql: ${TABLE}."ADDRESS2" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: zip {
    type: string
    sql: ${TABLE}."ZIP" ;;
  }

  dimension: vendtype {
    type: string
    sql: ${TABLE}."VENDTYPE" ;;
  }

  dimension: reporting_category {
    type: string
    sql: ${TABLE}."REPORTING_CATEGORY" ;;
  }

  dimension: sage_created_date {
    type: date
    sql: ${TABLE}."SAGE_CREATED_DATE" ;;
  }

  dimension: external_erp_vendor_ref {
    type: string
    sql: ${TABLE}."EXTERNAL_ERP_VENDOR_REF" ;;
  }


  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      vendor_tax_id,
      address1,
      address2,
      city,
      state,
      zip,
      vendtype,
      reporting_category,
      sage_created_date,
      external_erp_vendor_ref
    ]
  }
}
