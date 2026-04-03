view: region_hierarchy_time_ute {
  derived_table: {
    sql: with generate_series as (
      select
          *
      from
          table(es_warehouse.public.generate_series(
                  date_trunc('month',current_date)::timestamp_tz,
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
        (mrx.division_name = 'Equipment Rental' or mrx.division_name is null)
      )
      , daily_market_oec as (
      select
          date,
          ms.region,
          ms.district,
          ms.market,
          ms.market_type,
          ms.market_id,
          case when right(ms.market, 9) = 'Hard Down' then true else false end as hard_down,
          ms.is_current_months_open_greater_than_twelve,
          sum(case when asset_inventory_status = 'On Rent' then oec end) as on_rent_oec,
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
          ms.is_current_months_open_greater_than_twelve
      )
      , final_cte AS (
      select
          date_trunc('month',date) as month,
          dmo.region,
          dmo.district,
          dmo.market,
          dmo.market_type,
          dmo.hard_down,
          dmo.market_id,
          dmo.is_current_months_open_greater_than_twelve,
          sum(on_rent_oec) as on_rent_oec,
          sum(total_oec) as total_oec
      from
          daily_market_oec dmo
      group by
          month,
          dmo.region,
          dmo.district,
          dmo.market,
          dmo.market_type,
          dmo.market_id,
          dmo.hard_down,
          dmo.is_current_months_open_greater_than_twelve
        )

          SELECT
            fc.* ,
            IFF( IFF(rsc.total_regions_selected = 1, rs.region ,ar.region) = xw.region_name,TRUE,FALSE) as is_selected_region
          FROM final_cte fc
          join analytics.public.market_region_xwalk xw on fc.market_id = xw.market_id
          cross join region_selection_count rsc
          left join region_selection rs on rsc.total_regions_selected = 1
          cross join assigned_region ar;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: month {
    type: date
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }


  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: hard_down {
    type: yesno
    sql: ${TABLE}."HARD_DOWN" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: months_open_over_12 {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
  }

  dimension: on_rent_oec {
    type: number
    sql: ${TABLE}."ON_RENT_OEC" ;;
  }

  dimension: total_oec {
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
  }

  measure: average_on_rent_oec {
    type: average
    sql: ${on_rent_oec} ;;
    value_format_name: usd_0
  }

  measure: average_total_oec {
    type: average
    sql: ${total_oec} ;;
    value_format_name: usd_0
  }

  measure: total_on_rent_oec {
    type: sum
    sql: ${on_rent_oec} ;;
    value_format_name: usd_0
  }

  measure: total_available_oec {
    type: sum
    sql: ${total_oec} ;;
    value_format_name: usd_0
  }

  measure: time_utilization {
    type: number
    # sql: ${average_on_rent_oec}/${average_total_oec} ;;
    sql: ${total_on_rent_oec} / nullifzero(${total_available_oec}) ;;
    value_format_name: percent_1
  }

  measure: total_on_rent_selected {
    group_label: "OEC Selected"
    type: sum
    label: "Total OEC On Rent"
    sql: ${on_rent_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [is_selected_region: "YES"]
  }

  measure: total_on_rent_unselected {
    group_label: "OEC Unselected"
    type: sum
    label: "Total OEC On Rent"
    sql: ${on_rent_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [is_selected_region: "NO"]
  }

  measure: time_utilization_percentage_selected {
    group_label: "Time Ute Selected"
    label: "Time Utilization %"
    type: number
    sql:case when ${total_on_rent_oec} = 0 then 0
              when ${total_available_oec} = 0 OR ${total_available_oec} IS NULL then 0
              else ${total_on_rent_selected}/nullifzero(${total_available_oec}) end;;
    value_format_name: percent_1
  }

  measure: time_utilization_percentage_unselected {
    group_label: "Time Ute Unselected"
    label: "Time Utilization %"
    type: number
    sql:case when ${total_on_rent_oec} = 0 then 0
              when ${total_available_oec} = 0 OR ${total_available_oec} IS NULL then 0
              else ${total_on_rent_unselected}/nullifzero(${total_available_oec}) end;;
    value_format_name: percent_1
  }

  measure: percent_bar {
    type: number
    sql: 1 ;;
    value_format_name: percent_1
  }

  measure: rest_of_percent_bar {
    type: number
    sql: ${percent_bar} - ${time_utilization} ;;
    value_format_name: percent_1
  }

  dimension: is_selected_region {
    type: yesno
    sql: ${TABLE}."IS_SELECTED_REGION" ;;
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
      month,
      region,
      district,
      market,
      market_type,
      market_id,
      months_open_over_12,
      on_rent_oec,
      total_oec
    ]
  }
}