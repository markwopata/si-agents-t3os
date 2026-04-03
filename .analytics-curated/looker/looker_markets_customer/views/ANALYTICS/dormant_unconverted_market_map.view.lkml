view: dormant_unconverted_market_map {
  derived_table: {
    sql:
     with company_filter as (
    select distinct company_id
      from business_intelligence.triage.stg_bi__dormant_unconverted_companies
    ),
    base as (
      select
             i.company_id,
             li.market_id,
             li.amount,
             li.billing_approved_date
      from es_warehouse.public.invoices i
      join company_filter cf
        on cf.company_id = i.company_id
      join analytics.intacct_models.int_admin_invoice_and_credit_line_detail li
        on li.invoice_id = i.invoice_id
      where li.line_item_type_id in (6,8,108,109)
    ),
    trr as (
      select company_id, market_id, sum(amount) as total_rental_revenue
      from base
      group by company_id, market_id
    ),
    base_agg as (
      select
          company_id,
          market_id,
          sum(amount) as lifetime_amt,
          sum(case when billing_approved_date >= dateadd(month, -12, current_date)
                   then amount end) as ttm_amt
      from base
      group by company_id, market_id
    )
    select
        c.company_id,
        c.name,
        mrx.market_id,
        mrx.market_name,
        mrx.district,
        trr.total_rental_revenue lifetime_rental_revenue,
        ba.ttm_amt as ttm_rental_revenue
    from base_agg ba
    join es_warehouse.public.companies c
      on c.company_id = ba.company_id
    join analytics.public.market_region_xwalk mrx
      on mrx.market_id = ba.market_id
    join trr
      on trr.company_id = ba.company_id
      and trr.market_id = mrx.market_id ;;
  }

  dimension: company_id { type: number sql: ${TABLE}.company_id ;; }
  dimension: company_name { type: string sql: ${TABLE}.name ;; }
  dimension: market_id { type: number sql: ${TABLE}.market_id ;; }
  dimension: market_name { type: string sql: ${TABLE}.market_name ;; }
  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }
  dimension: ttm_rental_revenue {
    type: number
    sql: ${TABLE}.ttm_rental_revenue ;;
    value_format_name: usd_0
  }
  dimension: lifetime_rental_revenue {
    type: number
    sql: ${TABLE}.lifetime_rental_revenue ;;
    value_format_name: usd_0
  }
  dimension: in_user_district_market {
    type: yesno
    sql: CASE WHEN ${user_district_pull_market.assigned_district} IS NOT NULL THEN TRUE ELSE FALSE END ;;
  }


}
