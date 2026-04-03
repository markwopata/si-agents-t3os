view: regional_hierarchy_bulk_history_comparison_market {
    derived_table: {
      sql:
       with market_selection as (
        select
        distinct market_name as market
        from
        analytics.public.market_region_xwalk
        where
        {% condition market_name_filter %} market_name {% endcondition %}
        --region_name IN ('Midwest', 'Mountain West')
        )

        , market_selection_count as (
        select
        count(market) as total_markets_selected
        from
        market_selection
        )

        , district_first_market AS (
            select min(market_name) as first_market, district
            from analytics.public.market_region_xwalk xw
            where {% condition  district_name_filter %} xw.district {% endcondition %}
            group by district
        )
        , assigned_market as (
            select
            iff(xw_market.market_name IS NULL, first_market,xw_market.market_name) as market
            from analytics.payroll.company_directory
            left join analytics.public.market_region_xwalk xw_market ON xw_market.market_name = split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',4)
                and {% condition district_name_filter %} xw_market.district {% endcondition %}
            join district_first_market dfm
            where lower(work_email) = '{{ _user_attributes['email'] }}'
            group by iff(xw_market.market_name IS NULL, first_market,xw_market.market_name)
        )

        select abr.*,
        xw.is_open_over_12_months as is_current_months_open_greater_than_twelve,
                CASE WHEN xw.market_name ILIKE '%Landmark%' THEN 'Landmark'
        when xw.market_name ILIKE '%Mobile Tool Trailer%' THEN 'Mobile Tool Trailer'
        WHEN xw.market_name ILIKE '%Onsite Yard%' THEN 'Onsite Yard'
        WHEN xw.market_name ILIKE '%Containers%' then 'Container' ELSE xw.market_type END as special_locations_type,
        case when right(xw.market_name, 9) = 'Hard Down' then true else false end as hard_down,
        IFF(IFF(msc.total_markets_selected = 1, ms.market ,am.market) = xw.market_name,TRUE,FALSE) as is_selected_market
        from analytics.bi_ops.rolling_90_day_bulk_on_rent abr

        join analytics.public.market_region_xwalk xw on abr.market_id = xw.market_id
        cross join market_selection_count msc
        left join market_selection ms on msc.total_markets_selected = 1
        cross join assigned_market am

        WHERE (xw.division_name <> 'Materials' OR xw.division_name IS NULL)
        and {% condition district_name_filter %} xw.district {% endcondition %}

        ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    filter: region_name_filter {
      type: string
    }

  filter: market_name_filter {
    type: string
  }

  filter: district_name_filter {
    type: string
  }

  dimension: is_selected_market {
    type: yesno
    sql: ${TABLE}."IS_SELECTED_MARKET" ;;
  }

  dimension: selected_market_name {
    type: string
    sql: case when ${is_selected_market} = 'Yes' then 'Highlighted' else ' ' end ;;
  }

    dimension: unique_record {
      hidden: yes
      type: number
      primary_key: yes
      sql: ${TABLE}."UNIQUE_RECORD" ;;
    }

    dimension: months_open_over_12 {
      type: yesno
      sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
    }

    dimension: rental_day {
      type: date
      sql: ${TABLE}."RENTAL_DAY" ;;
    }

    dimension: rental_day_formatted {
      group_label: "HTML Formatted Day"
      label: "Date"
      type: date
      sql: ${rental_day} ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: rental_id {
      type: string
      sql: ${TABLE}."RENTAL_ID" ;;
    }

    dimension: rental_type_id {
      type: number
      sql: ${TABLE}."RENTAL_TYPE_ID" ;;
    }

    dimension: order_id {
      type: number
      sql: ${TABLE}."ORDER_ID"  ;;
      value_format_name: id
    }

    dimension: store_id {
      type: string
      sql: ${TABLE}."STORE_ID" ;;
      value_format_name: id
    }

    dimension: store_part_id {
      type: string
      sql: ${TABLE}."STORE_PART_ID" ;;
    }

    dimension: part_id {
      type: number
      sql: ${TABLE}."PART_ID" ;;
      value_format_name: id
    }

    dimension: part_number {
      type: string
      sql: ${TABLE}."PART_NUMBER" ;;
    }

    dimension: part_description {
      type: string
      sql: ${TABLE}."DESCRIPTION" ;;
    }

    dimension: region_name {
      type: string
      sql: ${TABLE}."REGION_NAME" ;;
    }

    dimension: hard_down {
      type: yesno
      sql: ${TABLE}."HARD_DOWN" ;;
    }

  dimension: special_locations_type {
    type: string
    sql: ${TABLE}."SPECIAL_LOCATIONS_TYPE";;
  }

    dimension: district {
      type: string
      sql: ${TABLE}."DISTRICT";;
    }

    dimension: market_id {
      type: string
      sql: ${TABLE}."MARKET_ID" ;;
    }

    dimension: market_name {
      type: string
      sql: ${TABLE}."MARKET_NAME" ;;
    }

    dimension: market_type {
      type: string
      sql: ${TABLE}."MARKET_TYPE" ;;
    }

    dimension_group: start_date {
      type: time
      datatype: date
      sql: ${TABLE}."START_DATE" ;;
    }

    dimension_group: end_date {
      type: time
      datatype: date
      sql: ${TABLE}."END_DATE" ;;
    }

    dimension: bulk_parts_on_rent {
      type: number
      sql: ${TABLE}."BULK_PARTS_ON_RENT" ;;
    }

    dimension: bulk_cost_on_rent {
      description: "Sum of Cost * Quantity of Parts"
      type: number
      sql: ${TABLE}."BULK_COST_ON_RENT" ;;
      value_format_name: usd
    }

    dimension: bulk_unit_cost_on_rent {
      type: number
      sql: ${TABLE}."BULK_UNIT_COST_ON_RENT" ;;
      value_format_name: usd
    }

    dimension: last_updated {
      type: date
      sql: ${TABLE}."LAST_UPDATED" ;;
    }

    measure: unit_total {
      label: "Sum of Quantity of Parts"
      type:  sum
      drill_fields: [detail*]
      sql: ${bulk_parts_on_rent} ;;
    }

    measure: cost_total {
      label: "Total Cost"
      type:  sum
      drill_fields: [detail*]
      sql: ${bulk_cost_on_rent} ;;
      value_format_name: usd
    }

    measure: unit_cost_total {
      label: "Cost of Parts per Unit"
      type: sum
      sql: ${bulk_unit_cost_on_rent} ;;
      value_format_name: usd
    }

    dimension: current_day {
      type: yesno
      sql: current_date = ${rental_day} ;;
    }

    measure: current_day_unit_cost_on_rent {
      type: sum
      sql: ${bulk_cost_on_rent} ;;
      filters: [current_day: "YES"]
      value_format_name: usd
    }

    measure: current_day_unit_total_on_rent {
      type: sum
      sql: ${bulk_parts_on_rent} ;;
      filters: [current_day: "YES"]
    }

    measure: current_day_unit_total_on_rent_selected {
      group_label: "Units Total Selected"
      type: sum
      sql: ${bulk_parts_on_rent} ;;
      filters: [is_selected_market: "YES", current_day: "YES"]
    }

    measure: current_day_unit_total_on_rent_unselected {
      group_label: "Units Total Unselected"
      type: sum
      sql: ${bulk_parts_on_rent} ;;
      filters: [is_selected_market: "NO", current_day: "YES"]
    }

    set: detail {
      fields: [market_id, market_name, rental_id, order_id, start_date_date, end_date_date, part_id, part_number, part_description, store_id, store_part_id, unit_total, unit_cost_total, cost_total]
    }
  }
