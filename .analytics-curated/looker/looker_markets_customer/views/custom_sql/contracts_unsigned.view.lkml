view: contracts_unsigned {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    # indexes: ["market_id","company_id"]
    sql:with company_orders_cte AS (SELECT o.market_id
                                 , cc.date_signed::date AS date_signed
                                 , c.company_id
                                 , nt.NAME as net_terms
                                 , c.name
                                 , o.order_id
                                 , r.rental_id
                                 , r.asset_id
                                 , r.end_date::date     as end_date
                            FROM ES_WAREHOUSE.public.orders o
                                     LEFT JOIN ES_WAREHOUSE.public.contracts cc
                                               ON o.order_id = cc.order_id
                                     LEFT JOIN es_warehouse.public.users u
                                               ON o.user_id = u.user_id
                                     LEFT JOIN es_warehouse.public.companies c
                                               ON u.company_id = c.company_id
                                     LEFT JOIN ES_WAREHOUSE.PUBLIC.NET_TERMS nt
                                               on c.NET_TERMS_ID = nt.NET_TERMS_ID
                                     LEFT JOIN es_warehouse.public.rentals r
                                               ON o.order_id = r.order_id
                                     LEFT JOIN es_warehouse.public.assets a
                                               ON r.asset_id = a.asset_id
                                     LEFT JOIN es_warehouse.public.equipment_classes_models_xref x
                                               ON a.equipment_model_id = x.equipment_model_id
                                     JOIN rolling_classes rc
                                          ON x.equipment_class_id = rc.equipment_class_id),
     most_recent_contract AS
         (SELECT max(date_signed) as most_recent_signed_contract,
                 company_id
          FROM company_orders_cte
          GROUP BY company_id)
SELECT mrc.most_recent_signed_contract, coc.*
FROM company_orders_cte coc
         JOIN most_recent_contract mrc
              ON coc.company_id = mrc.company_id
WHERE coalesce(date_signed, '1970-01-01')::date < '2020-05-08'::date
  AND coalesce(coc.end_date, '2099-12-31')::date >= current_date
            ;;
  }
  #May 8, 2020 is hardcoded due to that was the date legal changed the contracts. Anything signed before then is basically useless

  # Define your dimensions and measures here, like this:
  dimension_group: most_recent_signed_contract {
    type: time
    timeframes: [date]
    sql: ${TABLE}."MOST_RECENT_SIGNED_CONTRACT" ;;
  }

  dimension_group: date_signed {
    type: time
    timeframes: [date]
    sql: ${TABLE}."DATE_SIGNED" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: net_terms {
    type: string
    sql: ${TABLE}."NET_TERMS" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID";;
    html: <font color="#0063f3"><u><a href="https://admin.equipmentshare.com/#/home/orders/{{ order_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: rental_end_date {
    type: time
    timeframes: [date]
    sql: ${TABLE}."END_DATE" ;;
  }

  measure: unsigned_rental_contracts {
    type: count_distinct
    sql: ${TABLE}."RENTAL_ID" ;;
    drill_fields: [detail*]
  }

  measure: unsigned_rental_contracts_net_terms {
    type: count_distinct
    label: "Unsigned Rental Contracts on Net Terms"
    sql: ${TABLE}."RENTAL_ID" ;;
    filters: [net_terms: "Net%"]
    drill_fields: [detail*]
  }

  measure: unsigned_rental_contracts_COD {
    type: count_distinct
    label: "Unsigned Rental Contracts on COD"
    sql: ${TABLE}."RENTAL_ID" ;;
    filters: [net_terms: "Cash on Delivery"]
    drill_fields: [detail*]
  }

  measure: unsigned_company_contracts {
    type: count_distinct
    sql: ${TABLE}."COMPANY_ID" ;;
    drill_fields: [detail*]
  }

  measure: unsigned_company_contracts_net_terms {
    type: count_distinct
    label: "Unsigned Company Contracts on Net Terms"
    sql: ${TABLE}."COMPANY_ID" ;;
    filters: [net_terms: "Net%"]
    drill_fields: [detail*]
  }

  measure: unsigned_company_contracts_COD {
    type: count_distinct
    label: "Unsigned Company Contracts on COD"
    sql: ${TABLE}."COMPANY_ID" ;;
    filters: [net_terms: "Cash on Delivery"]
    drill_fields: [detail*]
  }

  set: detail {
    fields: [market_region_xwalk.market_name, company_id, company_name, net_terms, order_id, rental_id, asset_id, rental_end_date_date, date_signed_date]
  }
}
