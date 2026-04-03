view: excluded_po_lines {
  derived_table: {
    sql:
      WITH CombinedQuery AS (
    SELECT
        PRH.STORE_ID,
        BERPR2.BRANCH_ID,
        CASE
            WHEN ITM.ITEM_TYPE = 'INVENTORY' THEN 'A1301'
            ELSE LEFT(NINV.NAME, 5)
        END AS ITEMID,
        ITM.ITEM_TYPE,
        PRL.ACCEPTED_QUANTITY + PRL.REJECTED_QUANTITY AS QUANTITY,
        PRL.PRICE_PER_UNIT AS PRICE_PER_UNIT,
        POH.PURCHASE_ORDER_NUMBER,
        DEPARTMENT.STATUS,
        POH._ES_UPDATE_TIMESTAMP,
        VEND_REDIRECT.VENDORID,
        CASE
            WHEN ITM.ITEM_TYPE = 'INVENTORY' THEN COALESCE(BERPR.INTACCT_DEPARTMENT_ID, TO_CHAR(TRUNC(STR.PARENT_BRANCH_ID, 0)))
            ELSE COALESCE(BERPR2.INTACCT_DEPARTMENT_ID, TO_CHAR(TRUNC(POH.REQUESTING_BRANCH_ID, 0)))
        END AS DEPARTMENT_ID,
        CASE
            WHEN DEPARTMENT.STATUS = 'active' THEN 1
            ELSE 0
        END AS FILTER_FLAG,
        CASE
            WHEN VEND_REDIRECT.VENDORID IS NULL THEN 'Vendor not mapped'
            WHEN DEPARTMENT_ID IS NULL OR DEPARTMENT.STATUS IS NULL THEN 'Location not mapped'
            ELSE NULL
        END AS MAPPING_ISSUE
    FROM
        PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVERS PRH
        JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVER_ITEMS PRL
            ON PRL.PURCHASE_ORDER_RECEIVER_ID = PRH.PURCHASE_ORDER_RECEIVER_ID
        JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDERS POH
            ON POH.PURCHASE_ORDER_ID = PRH.PURCHASE_ORDER_ID
        JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS POL
            ON POL.PURCHASE_ORDER_LINE_ITEM_ID = PRL.PURCHASE_ORDER_LINE_ITEM_ID
        JOIN ES_WAREHOUSE.PUBLIC.USERS USER1
            ON USER1.USER_ID = POH.CREATED_BY_ID
        JOIN ES_WAREHOUSE.PUBLIC.USERS USER2
            ON USER2.USER_ID = PRH.CREATED_BY_ID
        LEFT JOIN PROCUREMENT.PUBLIC.ITEMS ITM
            ON POL.ITEM_ID = ITM.ITEM_ID
        LEFT JOIN PROCUREMENT.PUBLIC.NON_INVENTORY_ITEMS NINV
            ON NINV.ITEM_ID = POL.ITEM_ID
        LEFT JOIN (
            SELECT STR1.STORE_ID,
                   COALESCE(STR1.BRANCH_ID, STR2.BRANCH_ID) AS PARENT_BRANCH_ID
            FROM ES_WAREHOUSE.INVENTORY.STORES STR1
            LEFT JOIN ES_WAREHOUSE.INVENTORY.STORES STR2
                ON STR1.PARENT_ID = STR2.STORE_ID
            WHERE STR1.COMPANY_ID = 1854
        ) AS STR
            ON PRH.STORE_ID = STR.STORE_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.BRANCH_ERP_REFS BERPR
            ON STR.PARENT_BRANCH_ID = BERPR.BRANCH_ID
        LEFT JOIN ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS VEND
            ON POH.VENDOR_ID = VEND.ENTITY_ID
        LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND_REDIRECT
            ON VEND.EXTERNAL_ERP_VENDOR_REF = VEND_REDIRECT.VENDORID
        LEFT JOIN ANALYTICS.INTACCT.VENDOR VENDINT
            ON COALESCE(VEND_REDIRECT.VENDOR_REDIRECT, VEND.EXTERNAL_ERP_VENDOR_REF) = VENDINT.VENDORID
        LEFT JOIN (
            SELECT PURCHASE_ORDER_RECEIVER_ID,
                   CASE
                       WHEN RANK() OVER (PARTITION BY PURCHASE_ORDER_ID ORDER BY DATE_CREATED ASC) > 1
                           THEN CONCAT('-', RANK() OVER (PARTITION BY PURCHASE_ORDER_ID ORDER BY DATE_CREATED ASC))
                       ELSE ''
                   END AS SUFFIX
            FROM PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVERS
        ) SFX
            ON PRH.PURCHASE_ORDER_RECEIVER_ID = SFX.PURCHASE_ORDER_RECEIVER_ID
        LEFT JOIN ANALYTICS.INTACCT.CONTACT CONTACT
            ON VENDINT.DISPLAYCONTACTKEY = CONTACT.RECORDNO
        LEFT JOIN ANALYTICS.INTACCT.CONTACT PAYTOCONTACT
            ON VENDINT.PAYTOKEY = PAYTOCONTACT.RECORDNO
        LEFT JOIN ANALYTICS.INTACCT.CONTACT RETURNTOCONTACT
            ON VENDINT.RETURNTOKEY = RETURNTOCONTACT.RECORDNO
        LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT INTPO
            ON CONCAT(POH.PURCHASE_ORDER_NUMBER, SFX.SUFFIX, IFF(PRH.RECEIVER_TYPE = 'ADJUSTMENT', 'A', '')) = INTPO.DOCNO
        LEFT JOIN ES_WAREHOUSE.PUBLIC.BRANCH_ERP_REFS BERPR2
            ON POH.REQUESTING_BRANCH_ID = BERPR2.BRANCH_ID
        LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPARTMENT
            ON DEPARTMENT_ID = DEPARTMENT.DEPARTMENTID
            AND DEPARTMENT.STATUS = 'active'
        LEFT JOIN (
            SELECT DISTINCT PRL.PURCHASE_ORDER_RECEIVER_ID
            FROM PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVER_ITEMS PRL
            LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS POL
                ON PRL.PURCHASE_ORDER_LINE_ITEM_ID = POL.PURCHASE_ORDER_LINE_ITEM_ID
            LEFT JOIN PROCUREMENT.PUBLIC.ITEMS ITM
                ON POL.ITEM_ID = ITM.ITEM_ID
            WHERE ITM.ITEM_ID IS NULL
        ) MISS_ITEM_CHK
            ON PRH.PURCHASE_ORDER_RECEIVER_ID = MISS_ITEM_CHK.PURCHASE_ORDER_RECEIVER_ID
        LEFT JOIN (
            SELECT MAX(LAST_CLOSED_DATE) AS LAST_CLOSED
            FROM ANALYTICS.CONCUR.LAST_CLOSE_DATE_AP
        ) LC
    WHERE POH.COMPANY_ID = 1854
        AND POH.DATE_CREATED >= DATEADD(DAY, -30, CURRENT_DATE)
)
SELECT *
FROM CombinedQuery
WHERE FILTER_FLAG = 0;;
  }

  dimension: STORE_ID {
    type: string
    sql: ${TABLE}.STORE_ID;;
  }

  dimension: BRANCH_ID {
    type: string
    sql: ${TABLE}.BRANCH_ID;;
  }

  dimension: ITEMID {
    type: string
    sql: ${TABLE}.ITEMID;;
  }

  dimension: ITEM_TYPE {
    type: string
    sql: ${TABLE}.ITEM_TYPE;;
  }

  dimension: QUANTITY {
    type: string
    sql: ${TABLE}.QUANTITY;;
  }

  dimension: PRICE_PER_UNIT {
    type: string
    sql: ${TABLE}.PRICE_PER_UNIT;;
  }

  dimension: PURCHASE_ORDER_NUMBER {
    type: string
    sql: ${TABLE}.PURCHASE_ORDER_NUMBER;;
  }

  dimension: STATUS {
    type: string
    sql: ${TABLE}.STATUS;;
  }

  dimension: DEPARTMENT_ID {
    type: string
    sql: ${TABLE}.DEPARTMENT_ID;;
  }

  dimension: _ES_UPDATE_TIMESTAMP {
    type: date_time
    sql: ${TABLE}._ES_UPDATE_TIMESTAMP;;
  }

  dimension: VENDORID {
    type: string
    sql: ${TABLE}.VENDORID;;
  }

  dimension: FILTER_FLAG {
    type: string
    sql: ${TABLE}.FILTER_FLAG;;
  }

  dimension: MAPPING_ISSUE {
    type: string
    sql: ${TABLE}.MAPPING_ISSUE;;
  }



  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: aprecord_time_difference {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
