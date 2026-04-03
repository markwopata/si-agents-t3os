view: t3_vendors_mapping {
  derived_table: {
    sql:
       SELECT
    T3E.ENTITY_ID AS T3_ENTITY_ID,
    T3E.NAME AS T3_ENTITY_NAME,
    T3E.EIN AS T3_TAX_ID,
    T3E.CREATED_BY_ID,
    T3E.CREATED_AT,
    T3E.MODIFIED_BY_ID,
    T3E.MODIFIED_AT,
    T3E.ACTIVE,
    T3E.IS_VENDOR AS T3_ENTITY_IS_VENDOR,
    T3E.IS_CUSTOMER AS T3_ENTITY_IS_CUSTOMER,
    T3E_EVS.ENTITY_ID AS MAPPING_ENTITY_ID,
    T3E_EVS.EXTERNAL_ERP_VENDOR_REF AS MAPPING_SAGE_VENDOR_ID,
    V.VENDORID AS SAGE_VENDOR_ID,
    V.NAME AS SAGE_VENDOR_NAME,
    REPLACE(V.TAXID, '-', '') AS SAGE_TAX_ID,
    CASE WHEN T3_ENTITY_NAME <> SAGE_VENDOR_NAME THEN TRUE END AS NAME_FLAG,
    CASE WHEN CAST(T3_TAX_ID AS VARCHAR) <> SAGE_TAX_ID THEN TRUE END AS TAX_ID_FLAG,
    CASE WHEN SAGE_VENDOR_ID IS NULL THEN TRUE END AS NO_MAPPED_SAGE_VENDOR,
    CASE WHEN LEFT(SAGE_VENDOR_ID, 1) <> 'V' THEN TRUE END AS INVALID_SAGE_VENDOR1,
    CASE WHEN LENGTH(SAGE_VENDOR_ID) <> 6 THEN TRUE END AS INVALID_SAGE_VENDOR2,
    COALESCE(NAME_FLAG, TAX_ID_FLAG, NO_MAPPED_SAGE_VENDOR, INVALID_SAGE_VENDOR1, INVALID_SAGE_VENDOR2) AS VENDOR_FLAG
FROM ES_WAREHOUSE.PURCHASES.ENTITIES T3E
LEFT JOIN ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS T3E_EVS
ON T3E.ENTITY_ID = T3E_EVS.ENTITY_ID
LEFT JOIN ANALYTICS.INTACCT.VENDOR V
ON T3E_EVS.EXTERNAL_ERP_VENDOR_REF = V.VENDORID
WHERE COMPANY_ID = 1854 AND VENDOR_FLAG IS NOT NULL;;
  }


    dimension: T3_ENTITY_ID {
      type: string
      sql: ${TABLE}.T3_ENTITY_ID;;
    }

    dimension: T3_ENTITY_NAME {
      type: string
      sql: ${TABLE}.T3_ENTITY_NAME;;
    }

    dimension: T3_TAX_ID {
      type: string
      sql: ${TABLE}.T3_TAX_ID;;
    }

    dimension: CREATED_BY_ID {
      type: string
      sql: ${TABLE}.CREATED_BY_ID;;
    }

    dimension: CREATED_AT {
      type: date_time
      sql: ${TABLE}.CREATED_AT;;
    }

    dimension: MODIFIED_BY_ID {
      type: string
      sql: ${TABLE}.MODIFIED_BY_ID;;
    }

    dimension: MODIFIED_AT {
      type: date_time
      sql: ${TABLE}.MODIFIED_AT;;
    }

    dimension: ACTIVE {
      type: string
      sql: ${TABLE}.ACTIVE;;
    }

    dimension: T3_ENTITY_IS_VENDOR {
      type: string
      sql: ${TABLE}.T3_ENTITY_IS_VENDOR;;
    }

    dimension: T3_ENTITY_IS_CUSTOMER {
      type: string
      sql: ${TABLE}.T3_ENTITY_IS_CUSTOMER;;
    }

    dimension: MAPPING_ENTITY_ID {
      type: string
      sql: ${TABLE}.MAPPING_ENTITY_ID;;
    }

    dimension: MAPPING_SAGE_VENDOR_ID {
      type: string
      sql: ${TABLE}.MAPPING_SAGE_VENDOR_ID;;
    }

    dimension: SAGE_VENDOR_ID {
      type: string
      sql: ${TABLE}.SAGE_VENDOR_ID;;
    }

    dimension: SAGE_VENDOR_NAME {
      type: string
      sql: ${TABLE}.SAGE_VENDOR_NAME;;
    }

    dimension: SAGE_TAX_ID {
      type: string
      sql: ${TABLE}.SAGE_TAX_ID;;
    }

    dimension: NAME_FLAG {
      type: string
      sql: ${TABLE}.NAME_FLAG;;
    }

    dimension: TAX_ID_FLAG {
      type: string
      sql: ${TABLE}.TAX_ID_FLAG;;
    }

    dimension: NO_MAPPED_SAGE_VENDOR {
      type: string
      sql: ${TABLE}.NO_MAPPED_SAGE_VENDOR;;
    }

    dimension: INVALID_SAGE_VENDOR1 {
      type: string
      sql: ${TABLE}.INVALID_SAGE_VENDOR1;;
    }

    dimension: INVALID_SAGE_VENDOR2 {
      type: string
      sql: ${TABLE}.INVALID_SAGE_VENDOR2;;
    }

    dimension: VENDOR_FLAG {
      type: string
      sql: ${TABLE}.VENDOR_FLAG;;
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

# view: damaged_goods {
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
