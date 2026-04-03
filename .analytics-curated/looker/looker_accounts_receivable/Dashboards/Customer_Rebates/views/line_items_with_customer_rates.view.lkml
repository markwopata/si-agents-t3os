view: line_items_with_customer_rates {
 derived_table: {
  sql:
  SELECT
          i.INVOICE_ID,
          li.LINE_ITEM_ID,
          crr.*,
          greatest(crr.EFFECTIVE_START_DATE, crr.DATE_CREATED) as rebate_rate_start_date
      from ES_WAREHOUSE.public.LINE_ITEMS li
      join ES_WAREHOUSE.PUBLIC.INVOICES i on i.INVOICE_ID = li.INVOICE_ID
      join ES_WAREHOUSE.PUBLIC.RENTALS r on li.RENTAL_ID = r.RENTAL_ID
      left join ANALYTICS.RATE_ACHIEVEMENT.COMPANY_RENTAL_RATES crr on i.COMPANY_ID = crr.COMPANY_ID
          and r.EQUIPMENT_CLASS_ID = crr.EQUIPMENT_CLASS_ID
          and i.BILLING_APPROVED_DATE between greatest(crr.EFFECTIVE_START_DATE, crr.DATE_CREATED) and crr.CONTRACT_EXPIRATION_DATE
      where li.LINE_ITEM_TYPE_ID = 8
      qualify ROW_NUMBER() OVER(PARTITION BY LINE_ITEM_ID ORDER BY crr.DATE_CREATED desc nulls last) = 1
  ;;
}
    dimension: company_id {
      type: number
      sql: ${TABLE}."COMPANY_ID" ;;
    }

    dimension: equipment_class_id {
      type: number
      sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }


    dimension_group: date_created {
      type: time
      timeframes: [raw, time, date, week, month, quarter, year]
      sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
    }
    dimension_group: effective_start {
      type: time
      timeframes: [raw, time, date, week, month, quarter, year]
      sql: CAST(${TABLE}."EFFECTIVE_START_DATE" AS TIMESTAMP_NTZ) ;;
    }
    dimension_group: effective_agreed_upon {
      type: time
      timeframes: [raw, time, date, week, month, quarter, year]
      sql: CAST(${TABLE}."EFFECTIVE_AGREED_UPON_DATE" AS TIMESTAMP_NTZ) ;;
    }
    dimension_group: contract_expiration {
      type: time
      timeframes: [raw, time, date, week, month, quarter, year]
      # sql:CAST(IFF(${TABLE}."DATE_CREATED"<${TABLE}."END_DATE" AND ${TABLE}."DATE_VOIDED">${TABLE}."END_DATE", ${TABLE}."END_DATE", IFF(${TABLE}."DATE_CREATED">${TABLE}."END_DATE",IFNULL(${TABLE}."DATE_VOIDED",'9999-12-31'),IFNULL(${TABLE}."DATE_VOIDED",IFNULL(${TABLE}."END_DATE",'9999-12-31')))) AS TIMESTAMP_NTZ);;
      sql:CAST(${TABLE}."CONTRACT_EXPIRATION_DATE" AS TIMESTAMP_NTZ);;
    }


    dimension: price_per_day {
      type: number
      sql: coalesce(${TABLE}."PRICE_PER_DAY",null) ;;
    }
    dimension: price_per_hour {
      type: number
      sql: coalesce(${TABLE}."PRICE_PER_HOUR",null) ;;
    }
    dimension: price_per_month {
      type: number
      sql: coalesce(${TABLE}."PRICE_PER_MONTH",null) ;;
    }
    dimension: price_per_week {
      type: number
      sql: coalesce(${TABLE}."PRICE_PER_WEEK",null) ;;
    }

}

# view: line_items_with_customer_rebates {
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
