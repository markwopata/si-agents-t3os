view: vendor_contact_info {
  derived_table: {
    sql:
      SELECT
    V.RECORDNO,
    V.VENDORID,
    V.PAYTOKEY,
    C1.CONTACTNAME AS PAYTO_CONTACTNAME,
    C2.CONTACTNAME AS PRIME_CONTACTNAME,
    C1.EMAIL1 AS PAYTO_E1,
    C1.EMAIL2 AS PAYTO_E2,
    C2.EMAIL1 AS PRIME_E1,
    C2.EMAIL2 AS PRIME_E2,
    C1.PHONE1 AS PAYTO_PHONE1,
    C1.PHONE2 AS PAYTO_PHONE2,
    C2.PHONE1 AS PRIME_PHONE1,
    C2.PHONE2 AS PRIME_PHONE2,
    C1.MAILADDRESS_ADDRESS1 AS PAYTO_ADDRESS1,
    C1.MAILADDRESS_ADDRESS2 AS PAYTO_ADDRESS2,
    C2.MAILADDRESS_ADDRESS1 AS PRIME_ADDRESS1,
    C2.MAILADDRESS_ADDRESS2 AS PRIME_ADDRESS2,
    C1.MAILADDRESS_CITY AS PAYTO_CITY,
    C2.MAILADDRESS_CITY AS PRIME_CITY,
    C1.MAILADDRESS_STATE AS PAYTO_STATE,
    C2.MAILADDRESS_STATE AS PRIME_STATE,
    C1.MAILADDRESS_ZIP AS PAYTO_ZIP,
    C2.MAILADDRESS_ZIP AS PRIME_ZIP,
    V.NAME1099,
    V.FORM1099BOX,
    V.FORM1099TYPE,
    CASE
        WHEN V.FORM1099BOX = '1' THEN 'Rents'
        WHEN V.FORM1099BOX = '2' THEN 'Royalties'
        WHEN V.FORM1099BOX = '3' THEN 'Other income'
        WHEN V.FORM1099BOX = '4' THEN 'Federal income tax withheld'
        WHEN V.FORM1099BOX = '5' THEN 'Fishing boat proceeds'
        WHEN V.FORM1099BOX = '6' THEN 'Medical and health care payments'
        WHEN V.FORM1099BOX = '8' THEN 'Substitute payments in lieu of dividends or interest'
        WHEN V.FORM1099BOX = '9' THEN 'Crop insurance proceeds'
        WHEN V.FORM1099BOX = '10' THEN 'Gross proceeds paid to an attorney'
        WHEN V.FORM1099BOX = '11' THEN 'Fish purchased for resale'
        WHEN V.FORM1099BOX = '12' THEN 'Section 409A deferrals'
        WHEN V.FORM1099BOX = '14' THEN 'Excess golden parachute payments'
        WHEN V.FORM1099BOX = '15' THEN 'Nonqualified deferred compensation'
        WHEN V.FORM1099BOX = '16' THEN 'State tax withheld'
        WHEN V.FORM1099BOX = '18' THEN 'State income'
    END AS FORM1099_CATEGORY
FROM ANALYTICS.INTACCT.VENDOR V
    LEFT JOIN ANALYTICS.INTACCT.CONTACT C1 ON C1.RECORDNO = V.PAYTOKEY
    LEFT JOIN ANALYTICS.INTACCT.CONTACT C2 ON C2.RECORDNO = V.DISPLAYCONTACTKEY;;
  }


  dimension: RECORDNO {
    type: string
    sql: ${TABLE}.RECORDNO;;
  }

  dimension: VENDORID {
    type: string
    sql: ${TABLE}.VENDORID;;
  }

  dimension: PAYTOKEY {
    type: string
    sql: ${TABLE}.PAYTOKEY;;
  }

  dimension: PAYTO_CONTACTNAME {
    type: string
    sql: ${TABLE}.PAYTO_CONTACTNAME;;
  }

  dimension: PRIME_CONTACTNAME {
    type: string
    sql: ${TABLE}.PRIME_CONTACTNAME;;
  }

  dimension: PAYTO_E1 {
    type: string
    sql: ${TABLE}.PAYTO_E1;;
  }

  dimension: PAYTO_E2 {
    type: string
    sql: ${TABLE}.PAYTO_E2;;
  }

  dimension: PRIME_E1 {
    type: string
    sql: ${TABLE}.PRIME_E1;;
  }

  dimension: PRIME_E2 {
    type: string
    sql: ${TABLE}.PRIME_E2;;
  }

  dimension: PAYTO_PHONE1 {
    type: string
    sql: ${TABLE}.PAYTO_PHONE1;;
  }

  dimension: PAYTO_PHONE2 {
    type: string
    sql: ${TABLE}.PAYTO_PHONE2;;
  }

  dimension: PRIME_PHONE1 {
    type: string
    sql: ${TABLE}.PRIME_PHONE1;;
  }

  dimension: PRIME_PHONE2 {
    type: string
    sql: ${TABLE}.PRIME_PHONE2;;
  }

  dimension: PAYTO_ADDRESS1 {
    type: string
    sql: ${TABLE}.PAYTO_ADDRESS1;;
  }

  dimension: PAYTO_ADDRESS2 {
    type: string
    sql: ${TABLE}.PAYTO_ADDRESS2;;
  }

  dimension: PRIME_ADDRESS1 {
    type: string
    sql: ${TABLE}.PRIME_ADDRESS1;;
  }

  dimension: PRIME_ADDRESS2 {
    type: string
    sql: ${TABLE}.PRIME_ADDRESS2;;
  }

  dimension: PAYTO_CITY {
    type: string
    sql: ${TABLE}.PAYTO_CITY;;
  }

  dimension: PRIME_CITY {
    type: string
    sql: ${TABLE}.PRIME_CITY;;
  }

  dimension: PAYTO_STATE {
    type: string
    sql: ${TABLE}.PAYTO_STATE;;
  }

  dimension: PRIME_STATE {
    type: string
    sql: ${TABLE}.PRIME_STATE;;
  }

  dimension: PAYTO_ZIP {
    type: string
    sql: ${TABLE}.PAYTO_ZIP;;
  }

  dimension: PRIME_ZIP {
    type: string
    sql: ${TABLE}.PRIME_ZIP;;
  }

  dimension: NAME1099 {
    type: string
    sql: ${TABLE}.NAME1099;;
  }

  dimension: FORM1099BOX {
    type: string
    sql: ${TABLE}.FORM1099BOX;;
  }

  dimension: FORM1099TYPE {
    type: string
    sql: ${TABLE}.FORM1099TYPE;;
  }

  dimension: FORM1099_CATEGORY {
    type: string
    sql: ${TABLE}.FORM1099_CATEGORY;;
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

# view: vendor_contact_info {
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
