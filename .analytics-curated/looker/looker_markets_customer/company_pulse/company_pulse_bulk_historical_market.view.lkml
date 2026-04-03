view: company_pulse_bulk_historical_market {
    derived_table: {
      sql:
        with bulk_last_day_info AS (
        with max_update_date as (
            select
                max(hlfs.gl_date) as max_date
            from
                analytics.branch_earnings.high_level_financials hlfs
                JOIN analytics.gs.plexi_periods pp on pp.trunc::date = hlfs.gl_date::date
            where
                period_published = 'published'
            )
            , market_open_length as (
            select
                market_id,
                IFF(datediff(months,branch_earnings_start_month,max_date)+1 > 12,TRUE,FALSE) as months_open_over_12
            from
                ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE
                CROSS JOIN max_update_date
            where
                market_id BETWEEN 0 AND 500000
                AND market_id != 15967
            ),
      rental_day_list AS
              (
                 SELECT
          LAST_DAY(DATEADD(MONTH, -seq4(), DATE_TRUNC('MONTH', CURRENT_DATE))) AS series
        FROM TABLE(GENERATOR(ROWCOUNT => 14)) where series < current_date
              )
              , average_cost as (
                    select PRODUCT_ID,
                           INVENTORY_LOCATION_ID,
                           WEIGHTED_AVERAGE_COST
                    from ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS
                    where IS_CURRENT = true
              )
              , on_rent as (
                  select rdl.series::date as rental_day
                       , r.rental_id
                       , r.rental_type_id
                       , o.order_id
                       , o.MARKET_ID
                       , xw.REGION_NAME
                       , xw.DISTRICT
                       , xw.MARKET_NAME
                       , xw.MARKET_TYPE
                       , sp.STORE_PART_ID
                       , pt.part_type_id
                       , pt.description
                       , p.MASTER_PART_ID as part_id
                       , p.PART_NUMBER as part_number
                       , rpa.QUANTITY
                       , ac.WEIGHTED_AVERAGE_COST as cost
                       , sp.STORE_ID
                       , rpa.QUANTITY * cost as               total_cost
                       , rpa.START_DATE::date as start_date
                       , rpa.END_DATE::date as end_date
                       , os.USER_ID as salesperson_user_id
                       , concat(u.FIRST_NAME,' ',u.LAST_NAME) as salesperson_full_name
                  from ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS rpa
                           join rental_day_list rdl
                                on rdl.series BETWEEN (convert_timezone('America/Chicago', rpa.start_date))
                                  and COALESCE((convert_timezone('America/Chicago', rpa.end_date)), '2099-12-31')
                           join ES_WAREHOUSE.PUBLIC.RENTALS r
                                on rpa.RENTAL_ID = r.RENTAL_ID
                           join ES_WAREHOUSE.PUBLIC.ORDERS o
                                on r.ORDER_ID = o.ORDER_ID
                           left join ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS os
                                on o.ORDER_ID = os.ORDER_ID
                           left join ES_WAREHOUSE.PUBLIC.USERS u
                                on os.USER_ID = u.USER_ID
                           left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
                                on o.MARKET_ID = xw.MARKET_ID
                           join ES_WAREHOUSE.INVENTORY.inventory_locations s
                                on o.MARKET_ID = s.BRANCH_ID
                           join ANALYTICS.PARTS_INVENTORY.PARTS p
                                on rpa.PART_ID = p.PART_ID
                           join ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
                                on s.inventory_location_id = sp.STORE_ID
                                    and sp.PART_ID = p.MASTER_PART_ID

        join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
        on pt.PART_TYPE_ID = p.PART_TYPE_ID
        left join average_cost ac --kaa
        on ac.PRODUCT_ID = p.MASTER_PART_ID and ac.INVENTORY_LOCATION_ID = sp.store_id
        )
        select rental_day
        , onr.REGION_NAME
        , onr.district
        , onr.market_id
        , onr.market_name
        , onr.MARKET_TYPE
        , rental_id
        , rental_type_id
        , order_id
        , store_id
        , store_part_id
        , part_id
        , part_number
        , description
        , start_date
        , end_date
        , salesperson_user_id
        , salesperson_full_name
        , sum(cost) as bulk_unit_cost_on_rent
        , sum(quantity) as bulk_parts_on_rent
        , sum(total_cost) as bulk_cost_on_rent
        , current_date() as last_updated
        , row_number() OVER(ORDER BY rental_day DESC) as unique_record
        , mol.months_open_over_12
        from on_rent onr
        join market_open_length mol on onr.market_id = mol.market_id
        group by rental_day,
        onr.region_name,
        onr.district,
        onr.market_type,
        onr.market_id,
        onr.market_name,
        rental_id,
        rental_type_id,
        order_id,
        store_id,
        store_part_id,
        part_id,
        part_number,
        description,
        start_date,
        end_date,
        salesperson_user_id,
        salesperson_full_name,
        mol.months_open_over_12

        ),
        market_selection as (
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
        case when right(xw.market_name, 9) = 'Hard Down' then true else false end as hard_down,
        IFF(IFF(msc.total_markets_selected = 1, ms.market ,am.market) = xw.market_name,TRUE,FALSE) as is_selected_market

        from bulk_last_day_info abr
        -- left join analytics.public.v_market_t3_analytics vmt on vmt.market_id = abr.market_id
        join analytics.public.market_region_xwalk xw on abr.market_id = xw.market_id
        --left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
        --group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt
        --on vmt.market_id = abr.market_id
        cross join market_selection_count msc
        left join market_selection ms on msc.total_markets_selected = 1
        cross join assigned_market am
        WHERE (xw.division_name <> 'Materials' OR xw.division_name IS NULL)
        and {% condition district_name_filter %} xw.district {% endcondition %}



        -----  THIS IS ONLY BRINGING IN INFORMATION ABOUT BULK QUANTITIES ON THE LAST DAYS OF THE LAST 13 MONTHS
        ;;
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

    measure: count {
      type: count
      drill_fields: [detail*]
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

    dimension_group: rental_day {
      type: time
      sql: ${TABLE}."RENTAL_DAY" ;;
    }

    dimension: rental_day_formatted {
      group_label: "HTML Formatted Day"
      label: "Date"
      type: date
      sql: ${rental_day_date} ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: rental_month_formatted {
      group_label: "HTML Formatted Day"
      label: "Month"
      type: date
      sql: DATE_TRUNC(month, TO_DATE(${rental_day_date})) ;;
      html: {{ rendered_value | date: "%b %Y"  }};;
    }

    dimension: rental_id {
      type: string
      sql: ${TABLE}."RENTAL_ID" ;;
    }

    dimension: rental_type_id {
      type: string
      sql: ${TABLE}."RENTAL_TYPE_ID" ;;
    }

    dimension: order_id {
      type: string
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

    dimension: formatted_start_date {
      group_label: "HTML Formatted Date"
      label: "Start Date"
      type: date
      sql: ${start_date_date} ;;
      html: {{ rendered_value | date: "%b %d, %Y" }};;
    }

    dimension_group: end_date {
      type: time
      datatype: date
      sql: ${TABLE}."END_DATE" ;;
    }

    dimension: formatted_end_date {
      group_label: "HTML Formatted Date"
      label: "End Date"
      type: date
      sql: ${end_date_date} ;;
      html: {{ rendered_value | date: "%b %d, %Y" }};;
    }

    dimension: bulk_parts_on_rent {
      type: number
      sql: ${TABLE}."BULK_PARTS_ON_RENT" ;;
    }

    dimension: bulk_cost_on_rent {
      description: "Sum of Cost * Quantity of Parts"
      type: number
      sql: ${TABLE}."BULK_COST_ON_RENT" ;;
      value_format_name: usd_0
    }

    dimension: bulk_unit_cost_on_rent {
      type: number
      sql: ${TABLE}."BULK_UNIT_COST_ON_RENT" ;;
      value_format_name: usd_0
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
      value_format_name: usd_0
    }

    measure: unit_cost_total {
      label: "Cost of Parts per Unit"
      type: sum
      sql: ${bulk_unit_cost_on_rent} ;;
      value_format_name: usd_0
    }

    dimension: current_day {
      type: yesno
      sql: current_date = ${rental_day_date} ;;
    }

    measure: current_day_unit_cost_on_rent {
      type: number
      sql: ${cost_total} ;;
      value_format_name: usd_0
    }

    measure: current_day_unit_total_on_rent {
      type: number
      sql: ${unit_total} ;;
      drill_fields: [detail*]
    }

    set: detail {
      fields: [market_name, rental_id, order_id, formatted_start_date, formatted_end_date, part_id, part_number, part_description, store_id, store_part_id, unit_total, unit_cost_total, cost_total]
    }
  }
