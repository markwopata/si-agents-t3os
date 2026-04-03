
view: region_hierarchy_financial_utilization {
  derived_table: {
    sql:
      with oec_cte as (
      select
          mrx.region_name,
          mrx.district,
          mrx.market_name,
          mrx.market_id,
          mrx.market_type,
          case when right(mrx.market_name, 9) = 'Hard Down' then true else false end as hard_down,
          sum(aa.oec) as oec
      from
          analytics.bi_ops.asset_ownership ao
          JOIN analytics.public.market_region_xwalk mrx on mrx.market_id = ao.market_id
          JOIN ES_WAREHOUSE.PUBLIC.assets_aggregate aa ON ao.asset_id = aa.asset_id
      WHERE
          ao.ownership in ('ES','OWN', 'CUSTOMER', 'RETAIL')
          AND ao.rentable = TRUE
          AND ao.market_company_id = 1854
      GROUP BY
          mrx.region_name,
          mrx.district,
          mrx.market_name,
          mrx.market_id,
          mrx.market_type,
          case when right(mrx.market_name, 9) = 'Hard Down' then true else false end
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
          ,
      rev_cte as (
      select
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
          dd.date >= current_date - interval '31 days'
          AND r.LINE_ITEM_RENTAL_REVENUE = TRUE
          AND (mrx.division_name = 'Equipment Rental' OR mrx.division_name is null)
      group by
          mrx.region_name,
          mrx.district,
          mrx.market_name,
          mrx.market_type,
          mrx.market_id,
          case when right(mrx.market_name, 9) = 'Hard Down' then true else false end
      )
      select
          o.region_name,
          o.district,
          o.market_name,
          o.market_type,
          o.hard_down,
         -- mol.months_open_over_12,
          o.oec,
          r.rental_revenue,
          vmt.is_current_months_open_greater_than_twelve,
          IFF( IFF(rsc.total_regions_selected = 1, rs.region ,ar.region) = xw.region_name,TRUE,FALSE) as is_selected_region
      from
          oec_cte o
          join rev_cte r on o.market_id = r.market_id
      left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
      group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt
        on vmt.market_id = o.market_id
      join analytics.public.market_region_xwalk xw on o.market_id = xw.market_id
      cross join region_selection_count rsc
      left join region_selection rs on rsc.total_regions_selected = 1
      cross join assigned_region ar;;
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

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }

  measure: total_oec {
    type: sum
    sql: ${oec} ;;
    value_format_name: usd
  }

  measure: total_rental_revenue {
    type: sum
    sql: ${rental_revenue} ;;
    value_format_name: usd
  }

  measure: financial_utilization {
    type: number
    sql:
    case when
    ${total_rental_revenue} = 0 then 0
    when ${total_oec} = 0 OR ${total_oec} IS NULL then 0
    else
    ${total_rental_revenue} * 365 / 31 / ${total_oec}
    end
    ;;
    value_format_name: percent_1
  }

  dimension: is_selected_region {
    type: yesno
    sql: ${TABLE}."IS_SELECTED_REGION" ;;
  }

  measure: total_rental_revenue_selected {
    group_label: "Rental Revenue Unselected"
    type: sum
    label: "Total Rental Revenue"
    sql: ${rental_revenue} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [is_selected_region: "YES"]
  }

  measure: total_rental_revenue_unselected {
    group_label: "Rental Revenue Unselected"
    type: sum
    label: "Total Rental Revenue"
    sql: ${rental_revenue} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [is_selected_region: "NO"]
  }

  measure: financial_utilization_percentage_selected {
    group_label: "Fin Ute Selected"
    label: "Financial Utilization %"
    type: number
    sql:case when ${total_rental_revenue} = 0 then 0
              when ${total_oec} = 0 OR ${total_oec} IS NULL then 0
              else ${total_rental_revenue_selected} * 365 / 31 / nullifzero(${total_oec}) end;;
    value_format_name: percent_1
  }

  measure: financial_utilization_percentage_unselected {
    group_label: "Fin Ute Unselected"
    label: "Financial Utilization %"
    type: number
    sql:case when ${total_rental_revenue} = 0 then 0
              when ${total_oec} = 0 OR ${total_oec} IS NULL then 0
              else ${total_rental_revenue_unselected} * 365 / 31 / nullifzero(${total_oec}) end;;
    value_format_name: percent_1
  }

  measure: percent_bar {
    type: number
    sql: 1 ;;
    value_format_name: percent_0
  }

  measure: fin_ute_percent_bar {
    type: number
    sql: ${percent_bar} - ${financial_utilization};;
    value_format_name: percent_1
  }

  dimension: selected_region_name {
    type: string
    sql: case when ${is_selected_region} = 'Yes' then 'Highlighted' else ' ' end ;;
  }

  filter: region_name_filter {
    type: string
  }

  set: detail {
    fields: [
        region_name,
  district,
  market_name,
  market_type,
  oec,
  rental_revenue
    ]
  }
}