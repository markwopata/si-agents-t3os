view: company_pulse_time_ute_history {
    derived_table: {
      sql:
      WITH region_selection as (
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


      select mmtuh.month,
        mmtuh.region,
        mmtuh.district,
        mmtuh.market,
        mmtuh.market_type,
        mmtuh.hard_down,
        mmtuh.market_id,
        mmtuh.is_current_months_open_greater_than_twelve,
        mmtuh.on_rent_oec,
        mmtuh.total_oec,

        IFF( IFF(total_regions_selected = 1,rs.region,ar.region) = xw.region_name,TRUE,FALSE) as is_selected_region


        from analytics.bi_ops.monthly_market_time_ute_hist mmtuh
        join analytics.public.market_region_xwalk xw on mmtuh.market_id = xw.market_id
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

    dimension: month {
      type: date
      sql: ${TABLE}."MONTH" ;;
    }

   dimension: formatted_month {
    group_label: "HTML Formatted Date"
    label: "Month"
    type: date
    sql:${month} ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
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

    measure: percent_bar {
      type: number
      sql: 1 ;;
      value_format_name: percent_0
    }

    measure: time_ute_percent_bar {
      type: number
      sql: ${percent_bar} - ${time_utilization} ;;
      value_format_name: percent_0
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
