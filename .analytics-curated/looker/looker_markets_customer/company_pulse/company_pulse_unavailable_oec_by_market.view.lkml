view: company_pulse_unavailable_oec_by_market {
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

      select
      uo.*,
      --xw.market_name,
      -- xw.market_type,
      case when right(xw.market_name, 9) = 'Hard Down' then true else false end as hard_down,
      vmt.is_current_months_open_greater_than_twelve,
      xw.district,
      xw.region_name,
      iff(
      iff(total_regions_selected = 1, rs.region, ar.region) = xw.region_name,
      true,
      false
      ) as is_selected_region
      from "BI_OPS"."UNAVAILABLE_OEC_BY_MARKET" uo
      join analytics.public.market_region_xwalk xw ON uo.market_id = xw.market_id
      left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
          group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt
            on vmt.market_id = uo.market_id
      cross join region_selection_count rsc
      left join region_selection rs on rsc.total_regions_selected = 1
      cross join assigned_region ar
      ;;
  }

  dimension_group: generated_date {
    type: time
    sql: ${TABLE}."GENERATED_DATE" ;;
    timeframes: [raw, date, week, month, quarter, year]
    datatype: date
  }
  dimension: formatted_month {
    group_label: "HTML Formatted Month"
    label: "Month"
    type: string
    sql: concat(${generated_date_month}, '-01') ;;
    html: {{ value | date: "%b %Y" }};;
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

  dimension: is_selected_region {
    type: yesno
    sql: ${TABLE}.is_selected_region ;;
  }
  dimension: selected_region_name {
    type: string
    sql: case when ${is_selected_region} = 'Yes' then 'Highlighted' else ' ' end ;;
  }
  measure: total_oec {
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
  }
  measure: unavailable_oec {
    type: sum
    sql: ${TABLE}."UNAVAILABLE_OEC" ;;
  }
  measure: total_oec_selected {
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
    filters: [is_selected_region: "Yes"]
  }
  measure: unavailable_oec_selected {
    type: sum
    sql: ${TABLE}."UNAVAILABLE_OEC" ;;
    filters: [is_selected_region: "Yes"]
  }
  measure: total_oec_unselected {
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
    filters: [is_selected_region: "No"]
  }
  measure: unavailable_oec_unselected {
    type: sum
    sql: ${TABLE}."UNAVAILABLE_OEC" ;;
    filters: [is_selected_region: "No"]
  }
  measure: unavailable_oec_selected_perc {
    label: "Unavailable OEC % (Selected)"
    type: number
    sql: ${unavailable_oec_selected}/nullifzero(${total_oec_selected}) ;;
    value_format_name: percent_1
  }
  measure: unavailable_oec_unselected_perc {
    label: "Unavailable OEC % (Unselected)"
    type: number
    sql: ${unavailable_oec_unselected}/nullifzero(${total_oec_unselected}) ;;
    value_format_name: percent_1
  }
  measure: unavailable_oec_percentage {
    label: "Unavailable OEC %"
    type: number
    sql: ${unavailable_oec}/${total_oec} ;;
    value_format_name: percent_1
  }
  measure: unavailable_oec_bar_percentage {
    type: number
    sql: 1 - ${unavailable_oec_percentage} ;;
    value_format_name: percent_1
  }
  measure: count {
    type: count
  }
  filter: region_name_filter {
    type: string
  }
}
