view: vendors_without_attachment {
  derived_table: {
    sql: SELECT V.VENDORID,
       V.NAME,
       V.VENDTYPE,
       V.VENDOR_CATEGORY,
       V.FORM1099TYPE,
       V.TAXID,
       V.SUPDOCID,
       V.COMMENTS,
       to_date(V.WHENCREATED)     AS "DATECREATED",
       TOTALDUE,
       C.CONTACTNAME,
       C.PHONE1                   AS "PHONE#",
       C.CELLPHONE                AS "CELL#",
       C.EMAIL1                   AS "EMAIL",
       C.MAILADDRESS_ADDRESS1     AS "ADDRESS",
       C.MAILADDRESS_CITY         AS "CITY",
       C.MAILADDRESS_STATE        AS "STATE",
       C.MAILADDRESS_ZIP          AS "ZIP",
       CAST(APP.LASTPAID AS DATE) AS LAST_PAYMENT

FROM "ANALYTICS"."INTACCT"."VENDOR" V
         LEFT JOIN "ANALYTICS"."INTACCT"."CONTACT" C
                   ON C.RECORDNO = V.DISPLAYCONTACTKEY
         LEFT JOIN (SELECT APPAY.VENDORID,
                           MAX(APPAY.WHENCREATED) AS LASTPAID
                    FROM ANALYTICS.INTACCT.APRECORD APPAY
                    WHERE APPAY.RECORDTYPE = 'appayment'
                    GROUP BY APPAY.VENDORID) AS APP
                   ON V.VENDORID = APP.VENDORID

WHERE V.SUPDOCID IS NULL
  AND V.STATUS = 'active'
  AND VENDTYPE NOT IN ('Employee', 'Customer Refund', 'Government', 'Public Utility')

ORDER BY "DATECREATED" DESC ;;
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

  dimension: vendtype {
    type: string
    sql: ${TABLE}."VENDTYPE" ;;
  }

  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }

  dimension: form1099_type {
    type: string
    sql: ${TABLE}."FORM1099TYPE" ;;
  }

  dimension: taxid {
    type: string
    sql: ${TABLE}."TAXID" ;;
  }

  dimension: supdocid {
    type: string
    sql: ${TABLE}."SUPDOCID" ;;
  }

  dimension: comments {
    type: string
    sql: ${TABLE}."COMMENTS" ;;
  }

  dimension: datecreated {
    type: date
    sql: ${TABLE}."DATECREATED" ;;
  }

  dimension: totaldue {
    type: number
    sql: ${TABLE}."TOTALDUE" ;;
  }

  dimension: contactname {
    type: string
    sql: ${TABLE}."CONTACTNAME" ;;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}."PHONE#" ;;
  }

  dimension: cell {
    type: string
    sql: ${TABLE}."CELL#" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
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

  dimension: lastpaymentdate {
    type: date
    sql: ${TABLE}."LAST_PAYMENT" ;;
  }

  set: detail {
    fields: [
      vendorid,
      name,
      vendtype,
      vendor_category,
      form1099_type,
      taxid,
      supdocid,
      comments,
      datecreated,
      totaldue,
      contactname,
      phone,
      cell,
      email,
      address,
      city,
      state,
      zip,
      lastpaymentdate
    ]
  }
}
