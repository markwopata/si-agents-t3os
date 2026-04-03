view: purchase_orders {
  derived_table: {
    sql: SELECT
    POS.VENDOR_ID,
    VEND.NAME                 AS VENDOR_NAME,
    CASE WHEN VEND.REPORTING_CATEGORY = 'Related Party' THEN 'Yes' ELSE '-' END AS RELATED_PARTY,
    POS.PO_NUMBER,
    POS.DATE,
    POS.AUDIT_TRAIL_DATE,
    SUBSTR(POS.ITEM_ID, 2, 4) AS ACCT,
    GLA.TITLE                 AS ACCOUNT_DESCRIPTION,
    POS.ENTITY,
    POS.LOCATION              AS BRANCH_ID,
    DEPT.TITLE                AS BRANCH_DESCRIPTION,
    POS.EXPENSE_LINE_ID       AS EXP_LINE_ID,
    EL.NAME                   AS EXP_LINE_DESCRIPTION,
    POS.QUANTITY,
    POS.UNIT_PRICE,
    POS.EXT_COST,
    POS.SOURCE
FROM
    (SELECT
         INT_POH.CUSTVENDID                        AS VENDOR_ID,
         INT_POH.DOCNO                             AS PO_NUMBER,
         INT_POH.WHENCREATED                       AS DATE,
         INT_POH.AUWHENCREATED                     AS AUDIT_TRAIL_DATE,
         COALESCE(OTN.NEW_ITEM_ID, INT_POL.ITEMID) AS ITEM_ID,
         INT_POL.LOCATIONID                        AS ENTITY,
         INT_POL.DEPARTMENTID                      AS LOCATION,
         INT_POL.GLDIMEXPENSE_LINE                 AS EXPENSE_LINE_ID,
         INT_POL.UIQTY                             AS QUANTITY,
         INT_POL.UIPRICE                           AS UNIT_PRICE,
         INT_POL.UIQTY * INT_POL.UIPRICE           AS EXT_COST,
         'Sage'                                    AS SOURCE

     FROM
         ANALYTICS.INTACCT.PODOCUMENT INT_POH
             LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY INT_POL ON INT_POH.DOCID = INT_POL.DOCHDRID
             LEFT JOIN ANALYTICS.INTACCT.USERINFO USR ON INT_POH.CREATEDBY = USR.RECORDNO
             LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.OGITEM_TO_NEWITEM OTN ON INT_POL.ITEMID = OTN.OG_ITEM_ID
     WHERE
          (INT_POH.DOCPARID = 'Purchase Order Entry' AND
           CAST(CONVERT_TIMEZONE('America/Chicago', INT_POH.AUWHENCREATED) AS DATE) >= '2023-10-16')
       OR (INT_POH.DOCPARID = 'Purchase Order' AND
           CAST(CONVERT_TIMEZONE('America/Chicago', INT_POH.AUWHENCREATED) AS DATE) < '2023-10-16' AND
           INT_POH.T3_PR_CREATED_BY IS NULL)

     UNION ALL

     SELECT
         COALESCE(VEND_REDIRECT.VENDOR_REDIRECT, VEND.EXTERNAL_ERP_VENDOR_REF)   AS VENDOR_ID,
         TO_CHAR(POH.PURCHASE_ORDER_NUMBER)                                      AS PO_NUMBER,
         CAST(CONVERT_TIMEZONE('America/Chicago', POH.DATE_CREATED) AS DATE)     AS DATE,
         CONVERT_TIMEZONE('America/Chicago', POH.DATE_CREATED)                   AS AUDIT_TRAIL_DATE,
         CASE
             WHEN
                 ITM.ITEM_TYPE = 'INVENTORY'
                 THEN
                 'A1301'
             ELSE
                 (CASE
                      WHEN
                          ITM.ITEM_TYPE != 'INVENTORY'
                          THEN
                          LEFT(NINV.NAME, 5)
                      ELSE
                          'XXXX'
                     END)
             END                                                                 AS ITEM_ID,
         COALESCE(BERP.INTACCT_LOCATION_ID, 'E1')                                AS ENTITY,
         COALESCE(BERP.INTACCT_DEPARTMENT_ID, TO_CHAR(POH.REQUESTING_BRANCH_ID)) AS LOCATION,
         NULL                                                                    AS EXPENSE_LINE_ID,
         POL.QUANTITY                                                            AS QUANTITY,
         POL.PRICE_PER_UNIT                                                      AS UNIT_PRICE,
         POL.QUANTITY * POL.PRICE_PER_UNIT                                       AS EXT_COST,
         'T3'                                                                    AS SOURCE
     FROM
         PROCUREMENT.PUBLIC.PURCHASE_ORDERS POH
             LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS POL ON POH.PURCHASE_ORDER_ID = POL.PURCHASE_ORDER_ID
             LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS USER1 ON USER1.USER_ID = POH.CREATED_BY_ID
             LEFT JOIN PROCUREMENT.PUBLIC.ITEMS ITM ON POL.ITEM_ID = ITM.ITEM_ID
             LEFT JOIN PROCUREMENT.PUBLIC.NON_INVENTORY_ITEMS NINV ON NINV.ITEM_ID = POL.ITEM_ID
             LEFT JOIN ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS VEND ON POH.VENDOR_ID = VEND.ENTITY_ID
             LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND_REDIRECT ON VEND.EXTERNAL_ERP_VENDOR_REF = VEND_REDIRECT.VENDORID
             LEFT JOIN ES_WAREHOUSE.PUBLIC.BRANCH_ERP_REFS BERP ON POH.REQUESTING_BRANCH_ID = BERP.BRANCH_ID
     WHERE
           POH.COMPANY_ID = 1854
       AND ITM.ITEM_TYPE != 'SERVICE'
       AND POH.PURCHASE_ORDER_NUMBER IS NOT NULL) POS
        LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON POS.VENDOR_ID = VEND.VENDORID
        LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON SUBSTR(POS.ITEM_ID, 2, 4) = GLA.ACCOUNTNO
        LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON POS.LOCATION = DEPT.DEPARTMENTID
        LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE EL ON POS.EXPENSE_LINE_ID = EL.ID
       ;;
  }

  measure: count {type: count drill_fields: [detail*]}

  dimension: vendor_id {type: string sql: ${TABLE}."VENDOR_ID" ;;}
  dimension: vendor_name {type: string sql: ${TABLE}."VENDOR_NAME" ;;}
  dimension: related_party {type: string sql: ${TABLE}."RELATED_PARTY" ;;}
  dimension: po_number {type: string sql: ${TABLE}."PO_NUMBER" ;;}
  dimension: date {convert_tz: no type: date sql: ${TABLE}."DATE" ;;}
  dimension: audit_trail_date {type: date_time sql: ${TABLE}."AUDIT_TRAIL_DATE" ;;}
  dimension: acct {type: string sql: ${TABLE}."ACCT" ;;}
  dimension: account_description {type: string sql: ${TABLE}."ACCOUNT_DESCRIPTION" ;;}
  dimension: entity {type: string sql: ${TABLE}."ENTITY" ;;}
  dimension: branch_id {type: string sql: ${TABLE}."BRANCH_ID" ;;}
  dimension: branch_description {type: string sql: ${TABLE}."BRANCH_DESCRIPTION" ;;}
  dimension: expense_line_id {type: string sql: ${TABLE}."EXPENSE_LINE_ID" ;;}
  dimension: exp_line_description {type: string sql: ${TABLE}."EXP_LINE_DESCRIPTION" ;;}
  measure: quantity {type: sum sql: ${TABLE}."QUANTITY" ;;}
  dimension: unit_price {type: number sql: ${TABLE}."UNIT_PRICE" ;;}
  measure: ext_cost {type: sum sql: ${TABLE}."EXT_COST" ;;}
  dimension: source {type: string sql: ${TABLE}."SOURCE" ;;}
  measure: po_count {type: count_distinct sql: ${TABLE}."PO_NUMBER" ;;}

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      related_party,
      po_number,
      date,
      audit_trail_date,
      acct,
      account_description,
      entity,
      branch_id,
      branch_description,
      expense_line_id,
      exp_line_description,
      quantity,
      unit_price,
      ext_cost,
      source,
      po_count
    ]
  }
}
