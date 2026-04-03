view: es_ownership {
  derived_table: {
    sql: with equipmentshare_owned as
    (select company_id
    FROM ES_WAREHOUSE.public.companies
    where company_id in (select company_id
                              from es_warehouse.public.companies
                              WHERE name REGEXP 'IES\\d+ .*'
                                  OR COMPANY_ID = 420           -- Demo Units
                                  OR COMPANY_ID = 62875         -- ES Owned special events - still owned by us
                                  OR COMPANY_ID IN (1854, 1855) -- ES Owned
                                  OR COMPANY_ID = 61036         -- Holding account for Trekker owned assets
                                  --CONTRACTOR OWNED/OWN PROGRAM
                                  OR COMPANY_ID IN (SELECT DISTINCT AA.COMPANY_ID
                                                    FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
                                                             JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
                                                                  ON VPP.ASSET_ID = AA.ASSET_ID
                                                    WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
                                                      AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31'))))
select c.company_id,
       case
           when eso.company_id is not null then 'yes'
           else 'no'
           end as es_owned
from ES_WAREHOUSE.public.companies as c
left join equipmentshare_owned as eso
   on eso.company_id = c.company_id
;;
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
   dimension: company_id {
  #   description: "The total number of orders for each user"
     type: string
     sql: ${TABLE}.COMPANY_ID ;;
   }

   dimension: es_owned {
     type:  string
     sql:  ${TABLE}.es_owned ;;
   }

   measure: count_of_es_owned {
     type: count
  #   sql: ${es_owned};;
   }
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

# view: es_ownership {
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
