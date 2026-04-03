view: company_pulse_financial_utilization_history {

    derived_table: {
      sql:
  with generate_series as (
       select
          *
      from
          table(es_warehouse.public.generate_series(
          dateadd(month, -14, date_trunc('month',current_date))::timestamp_tz,
          current_date::timestamp_tz,
          'day'))
      )

      , region_selection as (
          select
            distinct region_name as region
          from
            analytics.public.market_region_xwalk
          where
            {% condition region_name_filter %} region_name {% endcondition %}
            --region_name IN ('Midwest', 'Mountain West')
        )

        , region_selection_count as (
          select
            count(region) as total_regions_selected
          from
            region_selection
        )

        , assigned_region as (
          select
            IFF(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'Corp', 'Midwest',
            IFF(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'R2 Mountain West', 'Mountain West',
                IFF(
                    split_part(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2), ' ',2) = ''
                    ,'Midwest'
                    ,split_part(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2), ' ',2)
                    )
                )
              ) as region
          from
            analytics.payroll.company_directory
          where
            lower(work_email) = '{{ _user_attributes['email'] }}'
          )

      , market_selection as (
      select
          series::date as date,
          mrx.region_name as region,
          mrx.district,
          mrx.market_name as market,
          mrx.market_type,
          mrx.market_id,
          case when right(mrx.market_name, 9) = 'Hard Down' then true else false end,
          vmt.is_current_months_open_greater_than_twelve
      from
          generate_series
          cross join analytics.public.market_region_xwalk mrx
           left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
      group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt
            on vmt.market_id = mrx.market_id

      where
        mrx.division_name = 'Equipment Rental' and (series::date = dateadd(day, -1, dateadd(month, 1, date_trunc(month, series::date)))) OR (series::date = current_date) -- last day of each month
      )
      , monthly_market_oec as (
      select
          date,
          ms.region,
          ms.district,
          ms.market,
          ms.market_type,
          ms.market_id,
          case when right(ms.market, 9) = 'Hard Down' then true else false end as hard_down,
          ms.is_current_months_open_greater_than_twelve,
         -- sum(case when asset_inventory_status = 'On Rent' then oec end) as on_rent_oec,
          sum(aa.oec) as total_oec
      from
          market_selection ms
          join es_warehouse.scd.scd_asset_rsp rb on ms.market_id = rb.rental_branch_id AND ms.date BETWEEN rb.date_start AND rb.date_end
          join es_warehouse.scd.scd_asset_inventory_status ais on ais.asset_id = rb.asset_id AND ms.date BETWEEN ais.date_start AND ais.date_end
          join es_warehouse.public.assets_aggregate aa on aa.asset_id = ais.asset_id
          join analytics.bi_ops.asset_ownership ao on ao.asset_id = aa.asset_id
      where
          ao.ownership in ('ES','OWN', 'CUSTOMER', 'RETAIL')
          AND ao.rentable = TRUE
          AND ao.market_company_id = 1854
      group by
          date,
          ms.region,
          ms.district,
          ms.market,
          ms.market_type,
          ms.market_id,
          case when right(ms.market, 9) = 'Hard Down' then true else false end,
          ms.is_current_months_open_greater_than_twelve )

      , rev_cte as (
       select
          date_trunc(month, dd.date) as month,

          mrx.region_name,
          mrx.district,
          mrx.market_name,
          mrx.market_type,
          mrx.market_id,
          case when right(mrx.market_name, 9) = 'Hard Down' then true else false end as hard_down,
          sum(ild.invoice_line_details_amount) as rental_revenue
      from
          platform.gold.v_line_items r
          JOIN platform.gold.v_invoice_line_details ild on ild.INVOICE_LINE_DETAILS_LINE_ITEM_KEY = r.line_item_key
          JOIN platform.gold.v_markets m on m.market_key = ild.INVOICE_LINE_DETAILS_MARKET_KEY
          JOIN platform.gold.v_dates dd on ild.invoice_line_details_gl_billing_approved_date_key = dd.date_key
          JOIN analytics.public.market_region_xwalk mrx on mrx.market_id = m.market_id
      where
          dd.date >= dateadd(month, -13, date_trunc('month',current_date))::timestamp_tz
          AND r.LINE_ITEM_RENTAL_REVENUE = TRUE
          AND mrx.division_name = 'Equipment Rental'
      group by
          date_trunc(month, dd.date),
          mrx.region_name,
          mrx.district,
          mrx.market_name,
          mrx.market_type,
          mrx.market_id,
          case when right(mrx.market_name, 9) = 'Hard Down' then true else false end
      )
      select
          r.month,
          mmo.date as last_date,
          mmo.region as region_name,
          mmo.district,
          mmo.market as market_name,
          mmo.market_id,
          mmo.market_type,
          mmo.hard_down,
         -- mol.months_open_over_12,
          mmo.total_oec,
          r.rental_revenue,

          vmt.is_current_months_open_greater_than_twelve,
          IFF(IFF(rsc.total_regions_selected = 1, rs.region ,ar.region)= xw.region_name,TRUE,FALSE) as is_selected_region
      from monthly_market_oec mmo
      join rev_cte r on mmo.market_id = r.market_id and r.month = date_trunc(month, mmo.date)
      join analytics.public.market_region_xwalk xw on mmo.market_id = xw.market_id
      left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve
          from analytics.public.v_market_t3_analytics
          group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt
            on vmt.market_id = mmo.market_id
      cross join region_selection_count rsc
      left join region_selection rs on rsc.total_regions_selected = 1
      cross join assigned_region ar

        ;;
    }

  filter: region_name_filter {
    type: string
  }
  dimension: is_selected_region {
    type: yesno
    sql: ${TABLE}."IS_SELECTED_REGION" ;;
  }
  dimension: selected_region_name {
    type: string
    sql: case when ${is_selected_region} = 'Yes' then 'Highlighted' else ' ' end ;;
  }
    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: region_name {
      label: "Region"
      type: string
      sql: ${TABLE}."REGION_NAME" ;;
    }

    dimension_group: month {
      type: time
      sql: ${TABLE}."MONTH" ;;
    }

  dimension: formatted_month {
    group_label: "HTML Formatted Month"
    label: "Month"
    type: date
    sql: ${month_date} ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

    dimension_group: last_date {
      type: time
      sql: ${TABLE}."LAST_DATE" ;;
    }
    dimension: district {
      type: string
      sql: ${TABLE}."DISTRICT" ;;
    }

    dimension: market_name {
      label: "Market"
      type: string
      sql: ${TABLE}."MARKET_NAME" ;;
    }

    dimension: market_type {
      type: string
      sql: ${TABLE}."MARKET_TYPE" ;;
    }

    dimension: hard_down {
      type: yesno
      sql: ${TABLE}."HARD_DOWN" ;;
    }

    dimension: months_open_over_12 {
      type: yesno
      sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
    }

    dimension: total_oec {
      type: number
      sql: ${TABLE}."TOTAL_OEC" -- this is the total oec at a market on the last day of the month;;
    }

    dimension: rental_revenue {
      type: number
      sql: ${TABLE}."RENTAL_REVENUE" --monthly rental revenue for a market;;
    }

    measure: total_oec_sum {
      type: sum
      sql: ${total_oec} ;;
      value_format_name: usd_0
    }

    measure: total_rental_revenue {
      type: sum
      sql: ${rental_revenue} ;;
      value_format_name: usd_0
    }


    measure: financial_utilization {
      type: number
      sql:
          case when
          ${total_rental_revenue} = 0 then 0
          when ${total_oec_sum} = 0 OR ${total_oec_sum} IS NULL then 0
          else
          ${total_rental_revenue} * 365 / MAX(${last_date_day_of_month}) / ${total_oec_sum}
          end
          ;;
      value_format_name: percent_1
    }

  measure: last {
    type: number
    sql:MAX(${last_date_day_of_month})-- really made just to test ^
        ;;
  }

    measure: percent_bar {
      type: number
      sql: 1 ;;
      value_format_name: percent_0
    }

    set: detail {
      fields: [ month_month,
        region_name,
        district,
        market_name,
        market_type,
        total_oec,
        rental_revenue
      ]
    }
  }