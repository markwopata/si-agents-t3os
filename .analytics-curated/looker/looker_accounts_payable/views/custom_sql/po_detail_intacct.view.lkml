view: po_detail_intacct {
  derived_table: {
    sql: SELECT
          POH.CUSTVENDID                                                                                         AS VENDOR_ID,
          VEND.NAME                                                                                              AS VENDOR_NAME,
          VEND.STATUS                                                                                            AS VENDOR_STATUS,
          VEND.VENDOR_CATEGORY                                                                                   AS VENDOR_CATEGORY,
          VEND.VENDTYPE                                                                                          AS VENDOR_TYPE,
          CASE
              WHEN (POH.T3_PO_CREATED_BY IS NOT NULL AND POH.T3_PR_CREATED_BY IS NOT NULL) THEN 'CC RECEIPT'
              ELSE (CASE WHEN (POH.T3_PO_CREATED_BY IS NOT NULL) THEN 'INTACCT_POE' ELSE ('INTACCT_PO') END) END AS SOURCE,
          POH.WHENCREATED                                                                                        AS PO_DATE,
          POH.DOCNO                                                                                              AS PO_NUMBER,
          SPLIT_PART(POH.DOCNO, '-', 0)                                                                          AS BASE_PO_NUMBER,
          CASE
              WHEN (POH.T3_PO_CREATED_BY IS NOT NULL AND POH.T3_PR_CREATED_BY IS NOT NULL) THEN (CONCAT(
                      TRIM(SPLIT_PART(POH.T3_PO_CREATED_BY, '-', 2)), ' (', TRIM(SPLIT_PART(POH.T3_PO_CREATED_BY, '-', 0)),
                      ')'))
              ELSE (CASE
                        WHEN (POH.T3_PO_CREATED_BY IS NOT NULL) THEN (CONCAT(USER2.DESCRIPTION, ' (', USER2.RECORDNO, ')'))
                        ELSE (CONCAT(USER1.DESCRIPTION, ' (', USER1.RECORDNO, ')')) END) END                     AS CREATED_BY,
          POH.STATUS                                                                                             AS PO_STATUS,
          POH.T3_PR_CREATED_BY                                                                                   AS RECEIVED_BY,
          POH.PONUMBER                                                                                           AS REFERENCE,
          POH.MESSAGE                                                                                            AS MESSAGE,
          POL.ITEMID                                                                                             AS ITEM_ID,
          POL.ITEMDESC                                                                                           AS ITEM_DESCRIPTION,
          ITEM_TO_GL.ACCOUNT                                                                                     AS ACCOUNT,
          GLA.TITLE                                                                                              AS ACCOUNT_NAME,
          GLA.ACCOUNTTYPE                                                                                        AS ACCOUNT_TYPE,
          GLA.CATEGORY                                                                                           AS ACCOUNT_CATEGORY,
          GLA.CLOSINGTYPE                                                                                        AS ACCOUNT_CLOSE_TYPE,
          GLA.NORMALBALANCE                                                                                      AS ACCOUNT_NORMAL_BALANCE,
          POL.MEMO                                                                                               AS MEMO,
          POL.DEPARTMENTID                                                                                       AS LOCATION_ID,
          LOC.TITLE                                                                                              AS LOCATION_NAME,
          POL.LOCATIONID                                                                                         AS COMPANY,
          POL.UIQTY                                                                                              AS QUANTITY,
          POL.UIPRICE                                                                                            AS PRICE_PER_UNIT,
          POL.UIQTY * POL.UIPRICE                                                                                AS EXTENDED_COST
      FROM
          ANALYTICS.INTACCT.PODOCUMENT POH
              LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY POL ON POH.DOCID = POL.DOCHDRID
              LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON POH.CUSTVENDID = VEND.VENDORID
              LEFT JOIN ANALYTICS.INTACCT.USERINFO USER1 ON POH.CREATEDBY = USER1.RECORDNO
              LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT POE_HEADER
                        ON POH.CREATEDFROM = POE_HEADER.DOCID AND POE_HEADER.DOCPARID = 'Purchase Order Entry'
              LEFT JOIN ANALYTICS.INTACCT.USERINFO USER2 ON POE_HEADER.CREATEDUSERID = USER2.LOGINID
              LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.ITEMID_TO_GL_ACCOUNT ITEM_TO_GL ON POL.ITEMID = ITEM_TO_GL.ITEM_ID
              LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON ITEM_TO_GL.ACCOUNT = GLA.ACCOUNTNO
              LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT LOC ON POL.DEPARTMENTID = LOC.DEPARTMENTID
      WHERE
            POH.DOCPARID = 'Purchase Order'
        --AND SPLIT_PART(POH.DOCNO, '-', 0) IN ('494321', '242436', '242434')
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

  dimension: vendor_status {
    type: string
    sql: ${TABLE}."VENDOR_STATUS" ;;
  }

  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }

  dimension: vendor_type {
    type: string
    sql: ${TABLE}."VENDOR_TYPE" ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  dimension: po_date {
    type: date
    sql: ${TABLE}."PO_DATE" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: base_po_number {
    type: string
    sql: ${TABLE}."BASE_PO_NUMBER" ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: po_status {
    type: string
    sql: ${TABLE}."PO_STATUS" ;;
  }

  dimension: received_by {
    type: string
    sql: ${TABLE}."RECEIVED_BY" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: message {
    type: string
    sql: ${TABLE}."MESSAGE" ;;
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }

  dimension: item_description {
    type: string
    sql: ${TABLE}."ITEM_DESCRIPTION" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: account_type {
    type: string
    sql: ${TABLE}."ACCOUNT_TYPE" ;;
  }

  dimension: account_category {
    type: string
    sql: ${TABLE}."ACCOUNT_CATEGORY" ;;
  }

  dimension: account_close_type {
    type: string
    sql: ${TABLE}."ACCOUNT_CLOSE_TYPE" ;;
  }

  dimension: account_normal_balance {
    type: string
    sql: ${TABLE}."ACCOUNT_NORMAL_BALANCE" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: location_id {
    type: string
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: location_name {
    type: string
    sql: ${TABLE}."LOCATION_NAME" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }

  dimension: extended_cost {
    type: number
    sql: ${TABLE}."EXTENDED_COST" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      vendor_status,
      vendor_category,
      vendor_type,
      source,
      po_date,
      po_number,
      base_po_number,
      created_by,
      po_status,
      received_by,
      reference,
      message,
      item_id,
      item_description,
      account,
      account_name,
      account_type,
      account_category,
      account_close_type,
      account_normal_balance,
      memo,
      location_id,
      location_name,
      company,
      quantity,
      price_per_unit,
      extended_cost
    ]
  }
}
