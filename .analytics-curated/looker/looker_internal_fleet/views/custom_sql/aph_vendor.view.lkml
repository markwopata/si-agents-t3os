view: aph_vendor {
  derived_table: {
    sql:
       select distinct

            pol.asset_id as asset_id,
            po.vendor_id as vendor_id,
            po.modified_at, --kendall added tue aug 27 2024
            po.approved_at, --kendall added tue aug 27 2024
            c.name as vendor_name,
            pol.RECONCILIATION_STATUS as reconciliation_status,
            pol.order_status as order_status,
            nt.name as net_terms,
            nt.days as net_terms_days,
            pol.market_id,
            mkt.name as market_name,
            pol.invoice_date as invoice_date,
            pol.title_status,
            pol.week_to_be_paid, ----kendall added tue aug 27 2024
            pol.net_price, --kendall added tue aug 27 2024
            pol.freight_cost,--kendall added tue aug 27 2024
            pol.rebate,--kendall added tue aug 27 2024
            pol.sales_tax,--kendall added tue aug 27 2024
            pol.aftermarket_oec,--kendall added tue aug 27 2024
            ((coalesce(pol.net_price,0) + coalesce(pol.freight_cost,0) + coalesce(pol.sales_tax,0) + coalesce(pol.aftermarket_oec,0)) - (coalesce(pol.rebate,0))) as ft_line_calculated_oec,--kendall added tue aug 27 2024
            pol.release_date,--kendall added tue aug 27 2024
            pol.due_date as new_due_date,--kendall added tue aug 29 2024
            pol.note,
            retail_invoices_paid.paid_date as customer_paid_date,--kendall added tue aug 29 2024
            retail_invoices_paid.paid as customer_paid,--kendall added sep 4
            vend.ft_book_of_business,--kendall added sep 4
            vend.ft_category,--kendall added sep 4
            vend.ft_core_designation,--kendall added sep 4
            vend.ft_financing_designation,--kendall added sep 4
            vend.ft_fleet_track_id,--kendall added sep 4
            vend.vendorid as sage_vendor_id

      from ES_WAREHOUSE.PUBLIC.company_purchase_order_line_items as pol
      left join ES_WAREHOUSE.public.company_purchase_orders as po on pol.company_purchase_order_id = po.company_purchase_order_id
      left join ES_WAREHOUSE.PUBLIC.companies as c on po.vendor_id = c.company_id
      left join ES_WAREHOUSE.PUBLIC.NET_TERMS as nt on po.NET_TERMS_ID = nt.NET_TERMS_ID
      left join ES_WAREHOUSE.PUBLIC.MARKETS as mkt on pol.market_id = mkt.market_id
      left join analytics.intacct.vendor as vend on po.vendor_id = vend.ft_fleet_track_id
      --we need to select asset id to get the retail invoices paid and the date where paid date is true and newest while keeping 1-1 relationship to asset id
      left join --kendall added tue aug 29 2024
      (
      select
      asset_id,
      paid_date,
      paid
      from (
      select
      asset_id,
      invoices.paid_date,
      invoices.paid,
      row_number() over (partition by line_items.asset_id order by invoices.paid_date desc) as rn
      from
      es_warehouse.public.line_items
      left join es_warehouse.public.invoices on line_items.invoice_id = invoices.invoice_id
      where
      invoices.paid = true
      --and invoices.company_id = '1854'
      and line_items.line_item_type_id = 127 --*OWN PROGRAM
      ) as ranked_payments
      where rn = 1
      ) retail_invoices_paid on pol.asset_id = retail_invoices_paid.asset_id



      where pol.asset_id is not null
      and c.supply_vendor = true
      and pol.deleted_at is null
      and pol.order_status <> 'Cancelled';;
  }


  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: vendor_id {
    type: number
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

  dimension: title_status {
    type: string
    sql: ${TABLE}."TITLE_STATUS" ;;
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

  dimension: invoice_date {
    type: date
    sql: ${TABLE}."INVOICE_DATE";;
  }

  dimension: due_date {
    type: date
    sql: coalesce(${manual_overide_due_date},dateadd(day,${net_terms_days_to_use},${fleet_track_data.purchase_created_at})) ;;
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

  dimension: latest_modified_date {
    type: date
    sql: ${TABLE}."MODIFIED_AT";;
  }
  dimension: latest_approved_date {
    type: date
    sql: ${TABLE}."APPROVED_AT";;
  }

  dimension: approval_status {
    type: string
    sql: CASE
        WHEN ${latest_modified_date} > ${latest_approved_date} THEN 'pending_approval'
        WHEN ${latest_modified_date} < ${latest_approved_date} THEN 'approved'
        WHEN ${latest_approved_date} is not null and ${latest_modified_date} is null THEN 'approved'
        ELSE 'unknown'
       END ;;
  }

  dimension: week_to_be_paid {
    type: date
    sql: ${TABLE}."WEEK_TO_BE_PAID";;
  }

  dimension: x_recon_status_w_statment_verification {
    type: string
    sql: CONCAT(${TABLE}."RECONCILIATION_STATUS", '-', ${TABLE}."ORDER_STATUS") ;;
  }

  dimension: recon_status_w_statment_verification {
    type: string
    sql:
    CASE
      WHEN ${reconciliation_status} IN ('Reconciled', 'Reconciled. Aftermarket in progress', 'Second Reconciliation') THEN
        CASE
          WHEN ${order_status} = 'Received' THEN '2-Reconciled and Received'
          WHEN ${order_status} = 'Shipped' THEN '4-Reconciled and Shipped'
          ELSE '6-Reconciled and Not Shipped'
        END
      WHEN ${reconciliation_status} = 'Statement Verified' THEN
        CASE
          WHEN ${order_status} = 'Received' THEN '1-Statement Verified and Received'
          WHEN ${order_status} = 'Shipped' THEN '3-Statement Verified and Shipped'
          ELSE '5-Statement Verified and Not Shipped'
        END
      ELSE '7-Unreconciled'
    END ;;
  }
  # reconciliation_status
  # order_status

  dimension: net_price {
    type: number
    sql: ${TABLE}."NET_PRICE";;
  }

  # dimension: freight_cost {
  #   type: number
  #   sql: ${TABLE}."FREIGHT_COST";;
  # }
  # dimension: sales_tax {
  #   type: number
  #   sql: ${TABLE}."SALES_TAX"";;
  # }
  # dimension: aftermarket_oec {
  #   type: number
  #   sql: ${TABLE}."AFTERMARKET_OEC";;
  # }
  # dimension: rebate {
  #   type: number
  #   sql: ${TABLE}."REBATE";;
  # }


  dimension: fleet_calculation_oec {
    type: number
    sql: ${TABLE}."FT_LINE_CALCULATED_OEC";;
  }
  dimension: release_date {
    type: date
    sql: ${TABLE}."RELEASE_DATE";;
  }
  dimension: manual_overide_due_date {
    type: date
    sql: ${TABLE}."NEW_DUE_DATE";;
  }
  dimension: customer_paid_date {
    type: date
    sql: ${TABLE}."CUSTOMER_PAID_DATE";;
  }
  dimension: customer_paid {
    type: string
    sql: ${TABLE}."CUSTOMER_PAID";;
  }
  dimension: book_of_business {
    type: string
    sql: ${TABLE}."FT_BOOK_OF_BUSINESS";;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."FT_CATEGORY";;
  }
  dimension: core_designation {
    type: string
    sql: ${TABLE}."FT_CORE_DESIGNATION";;
  }
  dimension: financing_designation {
    type: string
    sql: ${TABLE}."FT_FINANCING_DESIGNATION";;
  }
  dimension: sage_vendor_id {
    type: string
    sql: ${TABLE}."SAGE_VENDOR_ID";;
  }
  dimension: note {
    type: string
    sql: ${TABLE}."NOTE";;
  }
}
