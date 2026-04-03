view: company_pulse_first_day_breakdowns_30_days {
  derived_table: {
    sql:
      with region_selection as (
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
      iff(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'Corp', 'Midwest',
      iff(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'R2 Mountain West', 'Mountain West',
      iff(
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

      group by iff(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'Corp', 'Midwest',
      iff(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'R2 Mountain West', 'Mountain West',
      iff(
      split_part(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2), ' ',2) = ''
      ,'Midwest'
      ,split_part(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2), ' ',2)
      )
      )
      )


      )

      select
      fd.*,
      xw.market_name,
      --xw.market_type,
      case when right(xw.market_name, 9) = 'Hard Down' then true else false end as hard_down,
      xw.district,
      xw.region_name,
      vmt.is_current_months_open_greater_than_twelve,
      iff(
      iff(total_regions_selected = 1, rs.region, ar.region) = xw.region_name,
      true,
      false
      ) as is_selected_region
      from analytics.bi_ops.first_day_breakdowns_by_market_30_days fd
      join analytics.public.market_region_xwalk xw ON fd.market_id = xw.market_id
      left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
      group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt
      on vmt.market_id = fd.market_id
      cross join region_selection_count rsc
      left join region_selection rs on rsc.total_regions_selected = 1
      cross join assigned_region ar
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
  dimension: is_selected_region {
    type: yesno
    sql: ${TABLE}.is_selected_region ;;
  }
  dimension: selected_region_name {
    type: string
    sql: case when ${is_selected_region} = 'Yes' then 'Highlighted' else ' ' end ;;
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
    filters: [is_selected_region: "Yes"]
  }

  measure: wos_within_24_hrs_30_day_count_unselected {
    label: "WOS within 24hrs (Unselected)"
    type: sum
    sql: ${TABLE}."WOS_WITHIN_24HRS_30_DAY_COUNT" ;;
    filters: [is_selected_region: "No"]
  }
  measure: completed_dropoffs_30_selected {
    label: "Completed dropoffs with 24 hrs (Selected)"
    type: sum
    sql: ${TABLE}."COMPLETED_DROPOFFS_30" ;;
    filters: [is_selected_region: "Yes"]
  }
  measure: completed_dropoffs_30_unselected {
    label: "Completed dropoffs with 24 hrs (Unselected)"
    type: sum
    sql: ${TABLE}."COMPLETED_DROPOFFS_30" ;;
    filters: [is_selected_region: "No"]
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
  filter: region_name_filter {
    type: string
  }
}
