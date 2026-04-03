view: t3_vendor_upload {
  derived_table: {
    sql: SELECT
          VENDINT.VENDORID,
          VENDINT.NAME,
          VENDINT.TAXID,
          CONTACT.MAILADDRESS_ADDRESS1,
          CONTACT.MAILADDRESS_ADDRESS2,
          CONTACT.MAILADDRESS_CITY,
          CONTACT.MAILADDRESS_STATE,
          CONTACT.MAILADDRESS_ZIP,
          VENDINT.VENDTYPE,
          CAST(VENDINT.WHENCREATED AS DATE) AS "created_date"

      FROM "ANALYTICS"."INTACCT"."VENDOR" VENDINT
      LEFT JOIN "ANALYTICS"."INTACCT"."CONTACT" CONTACT ON VENDINT.DISPLAYCONTACTKEY = CONTACT.RECORDNO

      WHERE VENDINT.STATUS = 'active'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: taxid {
    type: string
    sql: ${TABLE}."TAXID" ;;
  }

  dimension: displaycontact_mailaddress_address_1 {
    type: string
    sql: ${TABLE}."DISPLAYCONTACT_MAILADDRESS_ADDRESS_1" ;;
  }

  dimension: displaycontact_mailaddress_address_2 {
    type: string
    sql: ${TABLE}."DISPLAYCONTACT_MAILADDRESS_ADDRESS_2" ;;
  }

  dimension: displaycontact_mailaddress_city {
    type: string
    sql: ${TABLE}."DISPLAYCONTACT_MAILADDRESS_CITY" ;;
  }

  dimension: displaycontact_mailaddress_state {
    type: string
    sql: ${TABLE}."DISPLAYCONTACT_MAILADDRESS_STATE" ;;
  }

  dimension: displaycontact_mailaddress_zip {
    type: string
    sql: ${TABLE}."DISPLAYCONTACT_MAILADDRESS_ZIP" ;;
  }

  dimension: vendtype {
    type: string
    sql: ${TABLE}."VENDTYPE" ;;
  }

  dimension: created_date {
    type: date
    sql: ${TABLE}."created_date" ;;
  }

  set: detail {
    fields: [
      vendorid,
      name,
      taxid,
      displaycontact_mailaddress_address_1,
      displaycontact_mailaddress_address_2,
      displaycontact_mailaddress_city,
      displaycontact_mailaddress_state,
      displaycontact_mailaddress_zip,
      vendtype,
      created_date
    ]
  }
}
