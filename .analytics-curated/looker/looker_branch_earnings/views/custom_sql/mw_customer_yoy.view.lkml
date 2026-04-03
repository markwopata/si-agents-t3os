view: mw_customer_yoy {
  derived_table: {
    sql:
      with all_customers as (select concat(ld.CUSTOMER_NAME, ' - ', ld.COMPANY_ID) as customer_name,
       ld.COMPANY_ID,
       l.CITY,
       s.name                                         as state,
       l.ZIP_CODE                                     as zip,
       sum(ld.amount)                                 as total_revenue
from analytics.intacct_models.int_admin_invoice_and_credit_line_detail ld
         left join ES_COMPANIES ec
                   on ld.COMPANY_ID = ec.COMPANY_ID
         left join es_warehouse.public.COMPANIES c
                   on ld.COMPANY_ID = c.COMPANY_ID
         left join es_warehouse.public.NET_TERMS nt
                   on c.NET_TERMS_ID = nt.NET_TERMS_ID
         left join es_warehouse.public.LOCATIONS l
                   on c.BILLING_LOCATION_ID = l.LOCATION_ID
         left join ES_WAREHOUSE.PUBLIC.STATES s
                   on l.STATE_ID = s.STATE_ID
         join analytics.public.market_region_xwalk mrx
                   on ld.market_id = mrx.market_id
where ec.COMPANY_ID is null
  and nt.NAME <> 'Cash on Delivery'
  and s.name in ('New Mexico', 'Colorado', 'Idaho', 'Arizona', 'Wyoming', 'Montana', 'Nevada', 'Utah')
  and ld.LINE_ITEM_TYPE_ID in (6, 8, 43, 44, 108, 109)
  and ld.AMOUNT <> 0
  and ld.BILLING_APPROVED_DATE >=  DATE_TRUNC('year', DATEADD(year, -1, CURRENT_DATE))
  and mrx.region_name = 'Mountain West'
group by all),

-- now get prior year revenue
prior_rev as (select
ld.COMPANY_ID,
       sum(ld.amount)                                 as prior_rev
from analytics.intacct_models.int_admin_invoice_and_credit_line_detail ld
         left join ES_COMPANIES ec
                   on ld.COMPANY_ID = ec.COMPANY_ID
         left join es_warehouse.public.COMPANIES c
                   on ld.COMPANY_ID = c.COMPANY_ID
         left join es_warehouse.public.NET_TERMS nt
                   on c.NET_TERMS_ID = nt.NET_TERMS_ID
         left join es_warehouse.public.LOCATIONS l
                   on c.BILLING_LOCATION_ID = l.LOCATION_ID
         left join ES_WAREHOUSE.PUBLIC.STATES s
                   on l.STATE_ID = s.STATE_ID
          join analytics.public.market_region_xwalk mrx
                   on ld.market_id = mrx.market_id
where ec.COMPANY_ID is null
  and nt.NAME <> 'Cash on Delivery'
  and s.name in ('New Mexico', 'Colorado', 'Idaho', 'Arizona', 'Wyoming', 'Montana', 'Nevada', 'Utah')
  and ld.LINE_ITEM_TYPE_ID in (6, 8, 43, 44, 108, 109)
  and ld.AMOUNT <> 0
  and date_trunc(year, ld.BILLING_APPROVED_DATE) =  DATE_TRUNC('year', DATEADD(year, -1, CURRENT_DATE))
  and mrx.region_name = 'Mountain West'
group by all),


-- Current year revenue
current_rev as (select
ld.COMPANY_ID,
       sum(ld.amount)                                 as current_rev
from analytics.intacct_models.int_admin_invoice_and_credit_line_detail ld
         left join ES_COMPANIES ec
                   on ld.COMPANY_ID = ec.COMPANY_ID
         left join es_warehouse.public.COMPANIES c
                   on ld.COMPANY_ID = c.COMPANY_ID
         left join es_warehouse.public.NET_TERMS nt
                   on c.NET_TERMS_ID = nt.NET_TERMS_ID
         left join es_warehouse.public.LOCATIONS l
                   on c.BILLING_LOCATION_ID = l.LOCATION_ID
         left join ES_WAREHOUSE.PUBLIC.STATES s
                   on l.STATE_ID = s.STATE_ID
         join analytics.public.market_region_xwalk mrx
                   on ld.market_id = mrx.market_id
where ec.COMPANY_ID is null
  and nt.NAME <> 'Cash on Delivery'
  and s.name in ('New Mexico', 'Colorado', 'Idaho', 'Arizona', 'Wyoming', 'Montana', 'Nevada', 'Utah')
  and ld.LINE_ITEM_TYPE_ID in (6, 8, 43, 44, 108, 109)
  and ld.AMOUNT <> 0
  and date_trunc(year, ld.BILLING_APPROVED_DATE) =  DATE_TRUNC('year', current_date)
  and mrx.region_name = 'Mountain West'
group by all)
-- combine
select ac.*, coalesce(pr.prior_rev, 0) as prior_rev, coalesce(cr.current_rev,0) as current_rev
    from all_customers ac
left join prior_rev pr
on ac.company_id = pr.company_id
left join current_rev cr
on ac.COMPANY_ID = cr.COMPANY_ID

      ;;
  }

  dimension: customer_name {
    label: "Customer Name"
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: Company_ID {
    label: "Company ID"
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: City {
    label: "City"
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    label: "State"
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: ZIP {
    label: "ZIP Code"
    type: string
    sql: ${TABLE}."ZIP" ;;
  }

  measure: current_revenue {
    label: "Current Year Revenue"
    type: sum
    sql: ${TABLE}."CURRENT_REV" ;;
    value_format_name: usd_0 # Example formatting
  }

  measure: prior_revenue {
    label: "Prior Year Revenue"
    type: sum
    sql: ${TABLE}."PRIOR_REV" ;;
    value_format_name: usd_0 # Example formatting
  }}
