view: utilization_history {
  derived_table: {
    sql: with date_series as (
      select
          series::date as day
      from
          table
          (generate_series(
          convert_timezone('{{ _user_attributes['user_timezone'] }}', dateadd(days,-179,current_timestamp))::date::timestamp_tz,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', current_timestamp)::date::timestamp_tz,
          'day'))
      )
      ,on_rent_by_day as (
      select
          ds.day,
          --sum(case
          --    when ds.day between edr.asset_start and edr.asset_end then 1
          --    when ds.day = edr.asset_start and ds.day = edr.asset_end then 1
          --    else null end)
          count(distinct(edr.asset_id)) as on_rent_count,
          --sum(case
          --    when ds.day between edr.asset_start and edr.asset_end then oec
          --    when ds.day = edr.asset_start and ds.day = edr.asset_end then oec
          --    else null end)
          sum(coalesce(oec,0)) as on_rent_oec,
          sum(NULLIF(effective_daily_rate,0)) as rental_rev_effective_daily_rate
      from
          date_series ds
          join (
          select
             alo.asset_id,
             edr.oec,
             edr.asset_start,
             edr.asset_end,
             case when edr.oec = 0 or edr.oec is null then 0 else edr.effective_daily_rate end as effective_daily_rate
          from
              --table(assetlist(101457::numeric)) alo
              table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
              join es_warehouse_stage.public.effective_daily_rate edr on alo.asset_id = edr.asset_id and edr.company_id = {{ _user_attributes['company_id'] }}
              join assets a on a.asset_id = alo.asset_id
              left join asset_types ast on ast.asset_type_id = a.asset_type_id
              left join categories cat on cat.category_id = a.category_id
              left join markets m on m.market_id = a.inventory_branch_id
          where
            {% condition custom_name_filter %} a.custom_name {% endcondition %}
            AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
            AND {% condition category_filter %} cat.name {% endcondition %}
            AND {% condition branch_filter %} m.name {% endcondition %}
            AND {% condition asset_type_filter %} ast.name {% endcondition %}
          ) edr on ds.day between edr.asset_start and edr.asset_end
          group by
            ds.day
      UNION
      select
          ds.day,
          --sum(case
          --    when ds.day between edr.asset_start and edr.asset_end then 1
          --    when ds.day = edr.asset_start and ds.day = edr.asset_end then 1
          --    else null end)
          count(distinct(edr.asset_id)) as on_rent_count,
          --sum(case
          --    when ds.day between edr.asset_start and edr.asset_end then oec
          --    when ds.day = edr.asset_start and ds.day = edr.asset_end then oec
          --    else null end)
          sum(coalesce(oec,0)) as on_rent_oec,
          sum(NULLIF(effective_daily_rate,0)) as rental_rev_effective_daily_rate
      from
          date_series ds
          join (
          select
             a.asset_id,
             edr.oec,
             edr.asset_start,
             edr.asset_end,
             case when edr.oec = 0 or edr.oec is null then 0 else edr.effective_daily_rate end as effective_daily_rate
          from
              --table(assetlist(101457::numeric)) alo
              --table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
              assets a
              join markets m on m.market_id = a.rental_branch_id and m.company_id = {{ _user_attributes['company_id'] }}
              join es_warehouse_stage.public.effective_daily_rate edr on a.asset_id = edr.asset_id and edr.company_id = {{ _user_attributes['company_id'] }}
              left join asset_types ast on ast.asset_type_id = a.asset_type_id
              left join categories cat on cat.category_id = a.category_id
          where
            {% condition custom_name_filter %} a.custom_name {% endcondition %}
            AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
            AND {% condition category_filter %} cat.name {% endcondition %}
            AND {% condition branch_filter %} m.name {% endcondition %}
            AND {% condition asset_type_filter %} ast.name {% endcondition %}
            AND a.asset_id not in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
            AND a.deleted = FALSE
            AND m.company_id = {{ _user_attributes['company_id'] }}
          ) edr on ds.day between edr.asset_start and edr.asset_end
          --join es_warehouse_stage.public.effective_daily_rate edr on ds.day BETWEEN edr.asset_start AND edr.asset_end
          --join table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
          --join table(assetlist(101457::numeric)) alo on alo.asset_id = edr.asset_id
      --where
        --  edr.company_id = 6302
      group by
          ds.day
      )
      ,total_assets_by_day as (
      select
          ds.day,
          count(distinct(alo.asset_id)) as total_assets,
          sum(alo.oec) as total_oec
      from
          date_series ds
          join ES_WAREHOUSE.SCD.scd_asset_rsp arb on ds.day between arb.date_start and arb.date_end
          join (
          select
              alo.asset_id,
              a.asset_class,
              aa.oec
          from
            -- table(assetlist(101457::numeric)) alo
            table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
             join assets a on a.asset_id = alo.asset_id
             join assets_aggregate aa on alo.asset_id = aa.asset_id
             left join asset_types ast on ast.asset_type_id = a.asset_type_id
             left join categories cat on cat.category_id = a.category_id
             left join markets m on m.market_id = a.inventory_branch_id
          where
            {% condition custom_name_filter %} a.custom_name {% endcondition %}
            AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
            AND {% condition category_filter %} cat.name {% endcondition %}
            AND {% condition branch_filter %} m.name {% endcondition %}
            AND {% condition asset_type_filter %} ast.name {% endcondition %}
          ) alo on alo.asset_id = arb.asset_id
     -- where
      --    m.company_id = 6302
      group by
      ds.day
      UNION
      select
          ds.day,
          count(distinct(alo.asset_id)) as total_assets,
          sum(alo.oec) as total_oec
      from
          date_series ds
          join ES_WAREHOUSE.SCD.scd_asset_rsp arb on ds.day between arb.date_start and arb.date_end
          join (
          select
              a.asset_id,
              a.asset_class,
              aa.oec
          from
            -- table(assetlist(101457::numeric)) alo
            --table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
             --join
             assets a
             join assets_aggregate aa on a.asset_id = aa.asset_id
             left join asset_types ast on ast.asset_type_id = a.asset_type_id
             left join categories cat on cat.category_id = a.category_id
             join markets m on m.market_id = a.rental_branch_id
          where
            {% condition custom_name_filter %} a.custom_name {% endcondition %}
            AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
            AND {% condition category_filter %} cat.name {% endcondition %}
            AND {% condition branch_filter %} m.name {% endcondition %}
            AND {% condition asset_type_filter %} ast.name {% endcondition %}
            AND a.asset_id not in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
            AND a.deleted = FALSE
            AND m.company_id = {{ _user_attributes['company_id'] }}
          ) alo on alo.asset_id = arb.asset_id
     -- where
      --    m.company_id = 6302
      group by
      ds.day
      )
      ,on_rent_assets_summarized as (
      select
        day,
        sum(on_rent_count) as on_rent_count,
        sum(on_rent_oec) as on_rent_oec,
        sum(rental_rev_effective_daily_rate) as rental_rev_effective_daily_rate
      from
        on_rent_by_day
      group by
        day
      )
      ,total_asset_summarized as (
      select
        day,
        sum(total_assets) as total_assets,
        sum(total_oec) as total_oec
      from
        total_assets_by_day
      group by
        day
      )
      select
        ta.day,
        coalesce(oa.on_rent_count,0) as on_rent_asset_count,
        ta.total_assets,
        coalesce(on_rent_oec,0) as on_rent_oec,
        ta.total_oec,
        oa.rental_rev_effective_daily_rate,
        case when dayname(ta.day) not in ('Sat','Sun') then 1 else 0 end as weekday_flag
      from
        total_asset_summarized ta
        left join on_rent_assets_summarized oa on oa.day = ta.day

      ;;
  }

  measure: count {
    type: count
  }

  dimension: day {
    type: date
    sql: ${TABLE}."DAY" ;;
  }

  dimension: on_rent_asset_count {
    type: number
    sql: ${TABLE}."ON_RENT_ASSET_COUNT" ;;
  }

  dimension: total_assets {
    type: number
    sql: ${TABLE}."TOTAL_ASSETS" ;;
  }

  dimension: on_rent_oec {
    type: number
    sql: ${TABLE}."ON_RENT_OEC" ;;
  }

  dimension: total_oec {
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
  }

  dimension: rental_rev_effective_daily_rate {
    type: number
    sql: ${TABLE}."RENTAL_REV_EFFECTIVE_DAILY_RATE" ;;
  }

  dimension: weekday_flag {
    type: number
    sql: ${TABLE}."WEEKDAY_FLAG" ;;
  }

  dimension: day_formatted {
    group_label: "HTML Passed Date Format" label: "Date"
    sql: ${day} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: total_weekdays_last_31_days {
    type: sum
    sql: ${weekday_flag} ;;
    filters: [day: "Last 30 Days"]
  }

  measure: total_assets_last_31_days {
    type: sum
    sql: ${total_assets} ;;
    filters: [day: "Last 30 Days"]
  }

  measure: total_current_oec {
    type: sum
    sql: ${total_oec} ;;
    filters: [day: "Today"]
    value_format_name: usd_0
  }

  measure: total_oec_by_day {
    type: sum
    sql: ${total_oec} ;;
    value_format_name: usd_0
    drill_fields: [top_kpi_drill*]
  }

  measure: total_oec_on_rent_by_day{
    type: sum
    sql: ${on_rent_oec} ;;
    value_format_name: usd_0
  }

  measure: total_on_rent_asset_count {
    type: sum
    sql: ${on_rent_asset_count} ;;
  }

  measure: total_asset_count {
    type: sum
    sql: ${total_assets} ;;
  }

  measure: total_estimated_rental_revenue {
    type: sum
    sql: ${rental_rev_effective_daily_rate} ;;
    filters: [day: "Last 30 days"]
    value_format_name: usd_0
  }

  # count total weekdays for last 30 days and replace that number for *365/number here/

  measure: financial_utilization {
    type: number
    sql: (${total_estimated_rental_revenue} * 12)/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
    drill_fields: [top_kpi_drill*]
  }

  measure: on_rent_asset_count_last_31_days {
    label: "Assets On Rent (Last 30 Days)"
    type: sum
    sql: ${on_rent_asset_count} ;;
    filters: [day: "Last 30 Days"]
  }

  measure: unit_utilization_last_31_days {
    label: "Unit Utilization Last 30 Days"
    type: number
    sql: ${on_rent_asset_count_last_31_days}/case when ${total_assets_last_31_days} = 0 then null else ${total_assets_last_31_days} end ;;
    value_format_name: percent_1
    drill_fields: [top_kpi_drill*]
  }

  measure: total_current_oec_on_rent {
    type: sum
    sql: ${on_rent_oec};;
    value_format: "$0.0,,\" M\""
    filters: [day: "Today"]
    drill_fields: [top_kpi_drill*]
  }

  measure: total_current_oec_on_rent_percentage {
    type: number
    sql: ${total_current_oec_on_rent} / case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
    drill_fields: [top_kpi_drill*]
  }

  measure: unit_utilization {
    type: number
    sql: ${total_on_rent_asset_count}/case when ${total_asset_count} = 0 then null else ${total_asset_count} end ;;
    value_format_name: percent_1
    drill_fields: [top_kpi_drill*]
  }

  measure: oec_on_rent_percentage {
    type: number
    sql: ${total_oec_on_rent_by_day}/case when ${total_oec_by_day} = 0 then null else ${total_oec_by_day} end ;;
    value_format_name: percent_1
    drill_fields: [top_kpi_drill*]
  }

  dimension: link_to_utilization_report {
    group_label: "Link to T3 Report"
    label: "View Report"
    type: string
    sql: 'View Report Link' ;;
    html: <font color="#0063f3"><a href="https://staging-looker-analytics.estrack.com/dashboards/267?Asset+Type=Equipment&Category=&Asset=&Branch=&Asset+Class=" target="_blank">
      Click here to view the full Utilization Report</a></font>;;
  }

  filter: custom_name_filter {
    suggest_explore: asset_class_utilization_history
    suggest_dimension: asset_class_utilization_history_asset_drill.custom_name
  }

  filter: asset_class_filter {
    suggest_explore: asset_class_utilization_history
    suggest_dimension: asset_class_utilization_history_asset_drill.asset_class
  }

  filter: branch_filter {
    suggest_explore: asset_class_utilization_history
    suggest_dimension: asset_class_utilization_history_asset_drill.branch
  }

  filter: category_filter {
    suggest_explore: asset_class_utilization_history
    suggest_dimension: asset_class_utilization_history_asset_drill.category
  }

  filter: asset_type_filter {
    suggest_explore: asset_class_utilization_history
    suggest_dimension: asset_class_utilization_history_asset_drill.asset_type
  }

  set: top_kpi_drill {
    fields: [
      utilization_history_by_asset.asset_class,
      utilization_history_by_asset.asset_custom_name_to_asset_info,
      utilization_history_by_asset.make,
      utilization_history_by_asset.model,
      utilization_history_by_asset.total_current_asset_oec,
      utilization_history_by_asset.asset_health_status,
      utilization_history_by_asset.financial_utilization,
      utilization_history_by_asset.unit_utilization_last_31_days
    ]
  }
}
