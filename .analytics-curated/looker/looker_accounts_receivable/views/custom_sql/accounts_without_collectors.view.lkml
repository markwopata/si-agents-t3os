view: accounts_without_collectors {
  derived_table: {
    sql:
      SELECT
        ARH.CUSTOMERID AS CUSTOMER_ID,
        ARH.CUSTOMERNAME AS CUSTOMER_NAME,
        CCA.FINAL_COLLECTOR AS COLLECTOR,
        CTM.SALESPERSON_NAME AS SALESPERSON,
        ARH.BILLTO_MAILADDRESS_ADDRESS1 AS ADDRESS,
        ARH.BILLTO_MAILADDRESS_CITY AS CITY,
        ARH.BILLTO_MAILADDRESS_STATE AS STATE,
        ARH.BILLTO_MAILADDRESS_ZIP AS ZIP,
        ARH.BILLTO_CONTACTNAME AS CONTACT_NAME,
        ARH.BILLTO_PHONE1 AS PHONE,
        ARH.BILLTO_EMAIL1 AS EMAIL,
        ARH.STATE         AS STATUS
      FROM
        ANALYTICS.INTACCT.ARRECORD ARH
        LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD ON ARH.RECORDNO = ARD.RECORDKEY
        LEFT JOIN ANALYTICS.INTACCT.CUSTOMER C ON ARD.RECORDNO = C.RECORDNO
        LEFT JOIN ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS CCA ON ARH.CUSTOMERID = CCA.COMPANY_ID
        LEFT JOIN ANALYTICS.TREASURY.AR_METRICS_DETAIL ARMD ON CCA.COMPANY_ID = ARMD.CUSTOMER_ID
        LEFT JOIN ANALYTICS.TREASURY.COLLECTION_TARGETS_MASTER CTM ON ARMD.BRANCH_ID = CTM.BRANCH_ID
      WHERE
        ARH.CUSTOMERID NOT LIKE 'C-%' -- Exclude values starting with 'C-'
        AND TRY_CAST(ARH.CUSTOMERID AS INTEGER) IS NOT NULL -- Check if CUSTOMER_ID can be cast to INTEGER
        AND ARH.CUSTOMERID IS NOT NULL -- Ensure CUSTOMER_ID is not null
    ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}.CUSTOMER_ID ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}.CUSTOMER_NAME ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}.COLLECTOR ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}.SALESPERSON ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}.ADDRESS ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.CITY ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.STATE ;;
  }

  dimension: zip {
    type: string
    sql: ${TABLE}.ZIP ;;
  }

  dimension: contact_name {
    type: string
    sql: ${TABLE}.CONTACT_NAME ;;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}.PHONE ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.EMAIL ;;
  }

  dimension: status{
    type: string
    sql: ${TABLE}.STATUS;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      customer_id,
      customer_name,
      collector,
      salesperson,
      address,
      city,
      state,
      zip,
      contact_name,
      phone,
      email,
      status
    ]
  }
}
