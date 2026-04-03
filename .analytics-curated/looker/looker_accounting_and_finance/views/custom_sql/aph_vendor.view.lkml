view: aph_vendor {
  derived_table: {
    sql:
       select distinct pol.asset_id as asset_id, po.vendor_id as vendor_id, c.name as vendor_name, pol.RECONCILIATION_STATUS as reconciliation_status, pol.order_status as order_status,
      nt.name as net_terms, nt.days as net_terms_days, pol.market_id, mkt.name as market_name
    from ES_WAREHOUSE.PUBLIC.company_purchase_order_line_items as pol
    left join ES_WAREHOUSE.public.company_purchase_orders as po on pol.company_purchase_order_id = po.company_purchase_order_id
    left join ES_WAREHOUSE.PUBLIC.companies as c on po.vendor_id = c.company_id
    left join ES_WAREHOUSE.PUBLIC.NET_TERMS as nt on po.NET_TERMS_ID = nt.NET_TERMS_ID
    left join ES_WAREHOUSE.PUBLIC.MARKETS as mkt on pol.market_id = mkt.market_id
    where pol.asset_id is not null
    and c.supply_vendor = true;;
  }


  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: vendor_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: reconciliation_status {
    type: string
    sql: ${TABLE}."RECONCILIATION_STATUS" ;;
  }

  dimension: order_status {
    type: string
    sql: ${TABLE}."ORDER_STATUS" ;;
  }

  dimension: net_terms {
    type: string
    sql: ${TABLE}."NET_TERMS" ;;
  }

  dimension: net_terms_days {
    type: number
    sql: ${TABLE}."NET_TERMS_DAYS" ;;
  }

  dimension: net_terms_days_to_use {
    type: number
    sql: case when ${net_terms_days} is null then 30 else ${net_terms_days} end ;;
  }


  dimension: due_date {
    type: date
    sql: dateadd(day,${net_terms_days_to_use},${assets.purchase_created_date}) ;;
    #sql: add_days(${net_terms_days_to_use},${asset_purchase_created_date_snowflake.asset_purchase_created_date}) ;;
  }


  dimension: days_until_due {
    type: number
    #sql: DATE_PART('day', ${due_date}::timestamp - CURRENT_TIMESTAMP()::timestamp)  ;;
    #sql: datediff(day, ${due_date} , CURRENT_TIMESTAMP())  ;;
    sql: datediff(day, CURRENT_TIMESTAMP() , ${due_date})  ;;
  }




  dimension: due_days_buckets {
    sql:
     CASE
     WHEN ${days_until_due} <= 0  THEN '0 or Less: Past Due'
     WHEN ${days_until_due} between 1 and 30 THEN '1 - 30'
      WHEN ${days_until_due} between 31 and 60 THEN '31 - 60'
       WHEN ${days_until_due} between 61 and 90 THEN '61 - 90'
     ELSE '91+'
     END ;;
  }

  dimension: due_days_buckets_monthly {
    type: string
    sql:
     CASE
    WHEN  DATEDIFF(MONTH,current_date,${due_date})  <= -1 THEN 'Past Due'
    WHEN  DATEDIFF(MONTH,current_date,${due_date})  = 0 THEN 'Due in Current Month'
    WHEN  (${due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date})  = 1) THEN 'Due Next Month'
    WHEN  (${due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date})  = 2) THEN 'Due In 2 Months'
    WHEN  (${due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date})  > 2) THEN 'More Than 2 Months'
    ELSE 'Missing' END ;;
  }

  dimension: due_days_buckets_monthly_order {
    type: number
    sql:
     CASE
    WHEN  DATEDIFF(MONTH,current_date,${due_date})  <= -1 then 1
    WHEN  DATEDIFF(MONTH,current_date,${due_date})  = 0 THEN 2
    WHEN  (${due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date})  = 1) THEN 3
    WHEN  (${due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date})  = 2) THEN 4
    WHEN  (${due_date} >= current_date) and (DATEDIFF(MONTH,current_date,${due_date})  > 2) THEN 5
    ELSE 6 END ;;
  }



}
