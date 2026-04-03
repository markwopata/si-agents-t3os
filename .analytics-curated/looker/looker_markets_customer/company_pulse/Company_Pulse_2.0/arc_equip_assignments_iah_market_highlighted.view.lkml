view: arc_equip_assignments_iah_market_highlighted {
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

        select
        darc.*, xw.district, xw.market_name, xw.region_name, xw.market_type, xw.is_open_over_12_months, xw.branch_earnings_start_month as market_start_month,
        CASE WHEN RIGHT(xw.market_name, 9) = 'Hard Down' THEN TRUE ELSE FALSE END AS hard_down,
        CASE WHEN xw.market_name ILIKE '%Landmark%' THEN 'Landmark'
        when xw.market_name ILIKE '%Mobile Tool Trailer%' THEN 'Mobile Tool Trailer'
        WHEN xw.market_name ILIKE '%Onsite Yard%' THEN 'Onsite Yard'
        WHEN xw.market_name ILIKE '%Containers%' then 'Container' ELSE xw.market_type END as special_locations_type,
        IFF(IFF(msc.total_markets_selected = 1, ms.market ,am.market) = xw.market_name,TRUE,FALSE) AS is_selected_market
        FROM business_intelligence.triage.stg_bi__daily_actively_renting_customers darc
        JOIN analytics.public.market_region_xwalk xw ON xw.market_id = darc.market_id
        cross join market_selection_count msc
        left join market_selection ms on msc.total_markets_selected = 1
        cross join assigned_market am

        WHERE (xw.division_name <> 'Materials' OR xw.division_name IS NULL)
      --  and {% condition market_name_filter %} xw.market_name {% endcondition %}
        AND {% condition district_name_filter %} xw.district {% endcondition %}
      --  AND {% condition region_name_filter %} xw.region_name {% endcondition %}
      --  AND {% condition market_type_filter %} xw.market_type {% endcondition %}

        -- YOU CAN ONLY SUM UP THE OEC OR ASSETS ON RENT AT THE COMPANY LEVEL WITH THIS SOURCE.
        -- USE MARKET LEVEL ASSET METRICS DAILY FOR OEC/AOR MARKET/DISTRICT/REGION/COMPANY NUMBERS
        ;;
    }

    filter: market_name_filter {
      type: string
    }

    filter: district_name_filter {
      type: string
    }

    filter: region_name_filter {
      type: string
    }

    filter: market_type_filter {
      type: string
    }


    filter: region_highlight_filter {
      type: string
    }

    dimension: is_selected_market{
      type: yesno
      sql: ${TABLE}."IS_SELECTED_MARKET" ;;
    }

    dimension: selected_market_name {
      type: string
      sql: case when ${is_selected_market} = 'Yes' then 'Highlighted' else ' ' end ;;
    }

    dimension_group: date {
      type: time
      sql: ${TABLE}."DATE" ;;
    }

    dimension: formatted_date {
      group_label: "HTML Formatted Date"
      label: "Date"
      type: date
      sql: ${date_date} ;;
      html: {{ rendered_value | date: "%b %d, %Y" }};;
    }

    dimension: formatted_date_as_month {
      group_label: "HTML Formatted Date"
      label: "Month Date"
      type: date
      sql: ${date_date} ;;
      html: {{ rendered_value | date: "%b %Y"  }};;
    }

    dimension: formatted_month {
      group_label: "HTML Formatted Date"
      label: "Month"
      type: date
      sql: DATE_TRUNC(month,${date_date}::DATE) ;;
      html: {{ rendered_value | date: "%b %Y"  }};;
    }

    dimension: asset_id {
      group_label: "Asset Information"
      type: string
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension: oec {
      group_label: "Asset Information"
      type: number
      sql: ${TABLE}."OEC" ;;
    }

    measure: oec_sum {
      type: sum
      sql: ${oec} ;;
    }

    dimension: rental_id {
      type: string
      sql: ${TABLE}."RENTAL_ID" ;;
    }

    dimension: market_id {
      group_label: "Location Information"
      type: string
      sql: ${TABLE}."MARKET_ID" ;;
    }

    dimension: market_name {
      group_label: "Location Information"
      type: string
      sql: ${TABLE}."MARKET_NAME" ;;
    }

    dimension: is_open_over_12_months {
      group_label: "Location Information"
      type: yesno
      sql: ${TABLE}."IS_OPEN_OVER_12_MONTHS" ;;
    }

    dimension: market_start_month {
      type: date
      sql: ${TABLE}."MARKET_START_MONTH" ;;
    }

    dimension: district {
      group_label: "Location Information"
      type: string
      sql: ${TABLE}."DISTRICT" ;;
    }

    dimension: region_name {
      group_label: "Location Information"
      type: string
      sql: ${TABLE}."REGION_NAME" ;;
    }

    dimension: hard_down {
      group_label: "Location Information"
      type: yesno
      sql: ${TABLE}."HARD_DOWN" ;;
    }

  dimension: special_locations_type {
    group_label: "Location Information"
    type: string
    sql: ${TABLE}."SPECIAL_LOCATIONS_TYPE";;
  }

    dimension_group: date_start {
      type: time
      sql: ${TABLE}."DATE_START" ;;
    }

    dimension_group: date_end {
      type: time
      sql: ${TABLE}."DATE_END" ;;
    }

    dimension: company_id {
      type: string
      sql: ${TABLE}."COMPANY_ID" ;;
    }

    dimension: company_name {
      type: string
      sql: ${TABLE}."COMPANY_NAME" ;;
    }

    dimension: is_current_day {
      type: yesno
      sql: current_date = ${TABLE}."DATE" ;;
    }

    dimension: is_yesterday {
      type: yesno
      sql: ${TABLE}."DATE" = DATEADD(day, -1,current_date)  ;;
    }

    dimension: is_last_30_days {
      type: yesno
      sql: ${TABLE}."IS_LAST_30_DAYS" ;;
    }

    dimension: is_last_31_days {
      type: yesno
      sql: ${TABLE}."IS_LAST_31_DAYS" ;;
    }

    dimension: is_last_60_days {
      type: yesno
      sql: ${TABLE}."IS_LAST_60_DAYS" ;;
    }

    dimension: is_last_90_days {
      type: yesno
      sql: ${TABLE}."IS_LAST_90_DAYS" ;;
    }

    dimension: is_prior_month_to_date {
      type: yesno
      sql: ${TABLE}."IS_PRIOR_MONTH_TO_DATE" ;;
    }

    dimension: is_prior_month {
      type: yesno
      sql: ${TABLE}."IS_PRIOR_MONTH" ;;
    }

    dimension: is_current_month {
      type: yesno
      sql: ${TABLE}."IS_CURRENT_MONTH" ;;
    }

    dimension: is_first_day_of_month {
      type: yesno
      sql: ${TABLE}."IS_FIRST_DAY_OF_MONTH" ;;
    }

    dimension: is_last_day_of_month {
      type: yesno
      sql: ${TABLE}."IS_LAST_DAY_OF_MONTH" ;;
    }

    measure: actively_renting_customers {
      type: count_distinct
      sql: ${company_id} ;;
    }

    measure: actively_renting_customers_selected {
      group_label: "Selected Metric"
      label: "Actively Renting Customers"
      description: "Count of customers in the selected market with rental assets on rent in a given time period."
      type: count_distinct
      sql: ${company_id} ;;
      filters: [is_selected_market: "yes"]

    }

    measure: actively_renting_customers_unselected {
      group_label: "Unselected Metric"
      label: "Actively Renting Customers"
      description: "Count of customers in unselected markets with rental assets on rent in a given time period."
      type: count_distinct
      sql: ${company_id} ;;
      filters: [is_selected_market: "no"]

    }

  }
