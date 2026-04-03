view: rentals_days_revenue_by_company {
    derived_table: {
      sql: with active_total_rentals_by_company as (
            select
                u.company_id,
                c.name as company_name,
                sum(case when rental_status_id = 5 then 1 end) as total_active_rentals,
                count(*) as total_company_rentals
            from
                es_warehouse.public.rentals r
                join es_warehouse.public.orders o on r.order_id = o.order_id
                join es_warehouse.public.users u on o.user_id = u.user_id
                join es_warehouse.public.companies c on c.company_id = u.company_id
            where
                o.deleted = false
                and r.deleted = false
                AND r.rental_type_id <> 4 --Internal rentals
                AND r.rental_status_id not in (1,2,3,8) --1 Needs approval,2 draft,3 pending,8 cancelled
                AND
                overlaps (
                r.start_date,
                r.end_date,
                COALESCE({% date_start date_filter %}::timestamp_tz, current_date - interval '2 week'),
                COALESCE({% date_end date_filter %}::timestamp_tz, current_date)
                )
            group by
                u.company_id,
                c.name
            ),

           days_since_last_rental as (
            select
                c.company_id,
                c.name as company_name,
                r.date_created::date as rental_date_created,
                r.rental_id,
                dateadd('day', datediff('day',r.date_created::date, LAG(r.date_created::date) OVER (PARTITION BY c.company_id ORDER BY r.date_created)), r.date_created::date) as previous_rental_date,
                datediff(days,dateadd('day', datediff('day',r.date_created::date, LAG(r.date_created::date) OVER (PARTITION BY c.company_id ORDER BY r.date_created)), r.date_created::date),r.date_created::date) as days_from_last_rental
            from
                ES_WAREHOUSE.PUBLIC.rentals r
                left join ES_WAREHOUSE.PUBLIC.orders o on r.order_id = o.order_id
                left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = o.user_id
                left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
            where
               --r.date_created between '2023-08-20' AND current_date
               r.date_created BETWEEN COALESCE({% date_start date_filter%}, current_date - interval '2 week')
                                  AND COALESCE({% date_end date_filter%}, current_date)
               AND r.rental_status_id not in (1,2,3,4,8)
               AND r.rental_type_id <> 4
            ),

           avg_days_since_last_rental_by_company as(
            select
              company_id,
              company_name,
              avg(days_from_last_rental) as avg_days_from_last_rental
            from days_since_last_rental
            group by
              company_id,
              company_name
            ),

           prev_month_revenue_by_company as(
            select
                c.company_id,
                c.name,
                sum(li.amount) as prev_month_revenue
            from
                ES_WAREHOUSE.PUBLIC.orders o
                join ES_WAREHOUSE.PUBLIC.invoices i on i.order_id = o.order_id
                join ANALYTICS.PUBLIC.v_line_items li on li.invoice_id = i.invoice_id
                join ES_WAREHOUSE.PUBLIC.approved_invoice_salespersons ais on i.invoice_id = ais.invoice_id
                join ES_WAREHOUSE.PUBLIC.users u on u.user_id = ais.primary_salesperson_id
                join ES_WAREHOUSE.PUBLIC.users u2 on u2.user_id = o.user_id
                join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u2.company_id
            where
              li.line_item_type_id in (6,8,108,109) --rental revenue only?
              AND date_trunc('month',li.gl_date_created::DATE) = (date_trunc('month',current_date) - interval '1 month') --previous month only
            group by
              c.company_id,
              c.name
            ),

           prev_month_revenue_segments_by_company as(
            select
               company_id,
               prev_month_revenue,
               CASE WHEN prev_month_revenue = 0 THEN '$0'
                    WHEN prev_month_revenue < 1000 THEN '$0 - $1K'
                    WHEN prev_month_revenue >= 1000 AND prev_month_revenue < 2000 THEN '$1K - $2K'
                    WHEN prev_month_revenue >= 2000 AND prev_month_revenue < 3000 THEN '$2K - $3K'
                    WHEN prev_month_revenue >= 3000 AND prev_month_revenue < 4000 THEN '$3K - $4K'
                    WHEN prev_month_revenue >= 4000 AND prev_month_revenue < 5000 THEN '$4K - $5K'
                    WHEN prev_month_revenue >= 5000 AND prev_month_revenue < 10000 THEN '$5K - $10K'
                    WHEN prev_month_revenue >= 10000 AND prev_month_revenue < 25000 THEN '$10K - $25K'
                    WHEN prev_month_revenue >= 25000 AND prev_month_revenue < 50000 THEN '$25K - $50K'
                    WHEN prev_month_revenue >= 50000 AND prev_month_revenue < 75000 THEN '$50K - $75K'
                    WHEN prev_month_revenue >= 75000 AND prev_month_revenue < 100000 THEN '$75K - $100K'
                    ELSE '$100K+'
               END AS rev_segment
            from prev_month_revenue_by_company
            )

      select
          r.company_id,
          r.company_name,
          total_active_rentals,
          total_company_rentals,
          avg_days_from_last_rental,
          prev_month_revenue,
          IFNULL(rev_segment,'No Rental Revenue Last Month') AS revenue_segment,
          CASE WHEN avg_days_from_last_rental IS NULL THEN 'Null Average Days'
          ELSE 'Non-Null Average Days' END AS avg_days_null_flag
      from
          active_total_rentals_by_company as r
          left join avg_days_since_last_rental_by_company as d on d.company_id = r.company_id
          left join prev_month_revenue_segments_by_company as s on s.company_id = d.company_id ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: company_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."COMPANY_ID" ;;
    }

    dimension: company_name {
      type: string
      sql: ${TABLE}."COMPANY_NAME" ;;
    }

    dimension: total_active_rentals {
      type: number
      sql: ${TABLE}."TOTAL_ACTIVE_RENTALS" ;;
    }

     measure: total_on_rent_rentals {
      type: sum
      sql: ${total_active_rentals} ;;
    }

    dimension: total_company_rentals {
      type: number
      sql: ${TABLE}."TOTAL_COMPANY_RENTALS" ;;
    }

    measure: total_rentals {
      type: sum
      sql: ${total_company_rentals} ;;
    }

    dimension: avg_days_from_last_rental {
      type: number
      sql: ${TABLE}."AVG_DAYS_FROM_LAST_RENTAL" ;;
    }

    measure: average_days_between_rentals {
      type: average
      value_format: "0.##"
      sql: ${avg_days_from_last_rental} ;;
    }

    dimension: prev_month_revenue {
      type: number
      sql: ${TABLE}."PREV_MONTH_REVENUE" ;;
    }

    measure: previous_month_revenue {
      type: sum
      sql: ${prev_month_revenue} ;;
   }

    dimension: revenue_segment {
      type: string
      sql: ${TABLE}."REVENUE_SEGMENT" ;;
    }

    dimension: avg_days_null_flag {
      type: string
      sql: ${TABLE}."AVG_DAYS_NULL_FLAG" ;;
    }

    filter: date_filter {
      label: "Date Range"
      type: date
    }

    set: detail {
      fields: [
        company_id,
        company_name,
        total_active_rentals,
        total_company_rentals,
        avg_days_from_last_rental,
        prev_month_revenue,
        revenue_segment
      ]
    }
  }
