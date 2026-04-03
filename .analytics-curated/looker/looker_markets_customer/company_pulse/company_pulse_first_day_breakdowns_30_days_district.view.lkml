view: company_pulse_first_day_breakdowns_30_days_district {
  derived_table: {
    sql:
       with district_selection as (
        select
        distinct district
        from
        analytics.public.market_region_xwalk
        where
        {% condition district_name_filter %} district {% endcondition %}

        )

        , district_selection_count as (
        select
        count(district) as total_districts_selected
        from
        district_selection
        )

        , region_first_district AS (
            select min(district) as first_district, region_name
            from analytics.public.market_region_xwalk xw
            where
            {% condition region_name_filter %} region_name {% endcondition %}
            group by region_name
        )
        , assigned_district as (
            select
            iff(xw_district.district IS NULL, first_district, xw_district.district) as district
            from analytics.payroll.company_directory
            left join analytics.public.market_region_xwalk xw_district ON xw_district.district = split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',3)
              and {% condition region_name_filter %} xw_district.region_name {% endcondition %}
            join region_first_district rfd
            where lower(work_email) = '{{ _user_attributes['email'] }}'
            group by iff(xw_district.district IS NULL, first_district, xw_district.district)
        )

      select
      fd.*,
      xw.market_name,
      --xw.market_type,
      case when right(xw.market_name, 9) = 'Hard Down' then true else false end as hard_down,
              CASE WHEN xw.market_name ILIKE '%Landmark%' THEN 'Landmark'
        when xw.market_name ILIKE '%Mobile Tool Trailer%' THEN 'Mobile Tool Trailer'
        WHEN xw.market_name ILIKE '%Onsite Yard%' THEN 'Onsite Yard'
        WHEN xw.market_name ILIKE '%Containers%' then 'Container' ELSE xw.market_type END as special_locations_type,
      xw.district,
      xw.region_name,
      xw.is_open_over_12_months as is_current_months_open_greater_than_twelve,
      IFF(IFF(dsc.total_districts_selected = 1, ds.district ,ad.district) = xw.district,TRUE,FALSE) as is_selected_district

      from analytics.bi_ops.first_day_breakdowns_by_market_30_days fd
      join analytics.public.market_region_xwalk xw ON fd.market_id = xw.market_id
      -- left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
      --  group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt
      --  on vmt.market_id = fd.market_id
        cross join district_selection_count dsc
        left join district_selection ds on dsc.total_districts_selected = 1
        cross join assigned_district ad

        WHERE (xw.division_name <> 'Materials' OR xw.division_name IS NULL)
        and {% condition region_name_filter %} xw.region_name {% endcondition %}
      ;;
  }

  measure: completed_dropoffs_30 {
    type: sum
    sql: ${TABLE}."COMPLETED_DROPOFFS_30" ;;
  }

  dimension_group: delivery_date {
    type: time
    sql: ${TABLE}."DELIVERY_DATE" ;;
    timeframes: [raw, date, week, month, quarter, year]
    datatype: date
  }

  dimension: formatted_month {
    group_label: "HTML Formatted Month"
    label: "Month"
    type: string
    sql: concat(${delivery_date_month}, '-01') ;;
    html: {{ value | date: "%b %Y" }};;
  }

  measure: first_day_breakdowns {
    type: average
    sql: ${TABLE}.first_day_breakdowns_by_market ;;
    value_format_name: percent_1
  }
    filter: region_name_filter {
      type: string
    }

    filter: district_name_filter {
      type: string
    }

    dimension: is_selected_district {
      type: yesno
      sql: ${TABLE}."IS_SELECTED_DISTRICT" ;;
    }

    dimension: selected_district {
      type: string
      sql: case when ${is_selected_district} = 'Yes' then 'Highlighted' else ' ' end ;;
    }
  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: months_open_over_12 {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
  }

  dimension: hard_down {
    type: yesno
    sql: ${TABLE}."HARD_DOWN" ;;
  }

  dimension: special_locations_type {
    type: string
    sql: ${TABLE}."SPECIAL_LOCATIONS_TYPE";;
  }


  measure: wos_within_24_hrs_30_day_count {
    type: sum
    sql: ${TABLE}."WOS_WITHIN_24HRS_30_DAY_COUNT" ;;
  }
  measure: first_day_breakdown_perc {
    label: "First Day Breakdown %"
    type: number
    sql: CASE
         WHEN ${completed_dropoffs_30} IS NULL OR ${completed_dropoffs_30} = 0 THEN 0
         ELSE ${wos_within_24_hrs_30_day_count} / ${completed_dropoffs_30}
       END ;;
    value_format_name: percent_1
  }
  measure: wos_within_24_hrs_30_day_count_selected {
    label: "WOS within 24hrs (Selected)"
    type: sum
    sql: ${TABLE}."WOS_WITHIN_24HRS_30_DAY_COUNT" ;;
    filters: [is_selected_district: "Yes"]
  }

  measure: wos_within_24_hrs_30_day_count_unselected {
    label: "WOS within 24hrs (Unselected)"
    type: sum
    sql: ${TABLE}."WOS_WITHIN_24HRS_30_DAY_COUNT" ;;
    filters: [is_selected_district: "No"]
  }
  measure: completed_dropoffs_30_selected {
    label: "Completed dropoffs with 24 hrs (Selected)"
    type: sum
    sql: ${TABLE}."COMPLETED_DROPOFFS_30" ;;
    filters: [is_selected_district: "Yes"]
  }
  measure: completed_dropoffs_30_unselected {
    label: "Completed dropoffs with 24 hrs (Unselected)"
    type: sum
    sql: ${TABLE}."COMPLETED_DROPOFFS_30" ;;
    filters: [is_selected_district: "No"]
  }
  measure: first_day_breakdown_perc_selected {
    label: "First Day Breakdown % (Selected)"
    type: number
    sql: CASE
          WHEN ${completed_dropoffs_30_selected} IS NULL OR ${completed_dropoffs_30_selected} = 0 THEN 0
          ELSE ${wos_within_24_hrs_30_day_count_selected} / ${completed_dropoffs_30_selected}
          END ;;
    value_format_name: percent_1
  }

  measure: first_day_breakdown_perc_unselected {
    label: "First Day Breakdown % (Unselected)"
    type: number
    sql: CASE
          WHEN ${completed_dropoffs_30_unselected} IS NULL OR ${completed_dropoffs_30_unselected} = 0 THEN 0
          ELSE ${wos_within_24_hrs_30_day_count_unselected} / ${completed_dropoffs_30_unselected}
          END ;;
    value_format_name: percent_1
  }
  measure: count {
    type: count
  }

}
