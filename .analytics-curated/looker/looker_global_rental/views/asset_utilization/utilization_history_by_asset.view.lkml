view: utilization_history_by_asset {
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
          edr.asset_id,
          --sum(case
          --    when ds.day between edr.asset_start and edr.asset_end then 1
          --    when ds.day = edr.asset_start and ds.day = edr.asset_end then 1
          --    else null end) as on_rent_count,
          1 as on_rent_count,
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
            {% condition utilization_history.custom_name_filter %} a.custom_name {% endcondition %}
            AND {% condition utilization_history.asset_class_filter %} a.asset_class {% endcondition %}
            AND {% condition utilization_history.category_filter %} cat.name {% endcondition %}
            AND {% condition utilization_history.branch_filter %} m.name {% endcondition %}
            AND {% condition utilization_history.asset_type_filter %} ast.name {% endcondition %}
      ) edr on ds.day between edr.asset_start and edr.asset_end
      group by
        ds.day,
        edr.asset_id
      UNION
      select
          ds.day,
          edr.asset_id,
          --sum(case
          --    when ds.day between edr.asset_start and edr.asset_end then 1
          --    when ds.day = edr.asset_start and ds.day = edr.asset_end then 1
          --    else null end) as on_rent_count,
          1 as on_rent_count,
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

              --join
              assets a
              join es_warehouse_stage.public.effective_daily_rate edr on a.asset_id = edr.asset_id and edr.company_id = {{ _user_attributes['company_id'] }}
              left join asset_types ast on ast.asset_type_id = a.asset_type_id
              left join categories cat on cat.category_id = a.category_id
              left join markets m on m.market_id = a.rental_branch_id
          where
            {% condition utilization_history.custom_name_filter %} a.custom_name {% endcondition %}
            AND {% condition utilization_history.asset_class_filter %} a.asset_class {% endcondition %}
            AND {% condition utilization_history.category_filter %} cat.name {% endcondition %}
            AND {% condition utilization_history.branch_filter %} m.name {% endcondition %}
            AND {% condition utilization_history.asset_type_filter %} ast.name {% endcondition %}
            AND a.asset_id not in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
            AND a.deleted = FALSE
            AND m.company_id = {{ _user_attributes['company_id'] }}
      ) edr on ds.day between edr.asset_start and edr.asset_end
      group by
        ds.day,
        edr.asset_id
      )
      ,total_assets_by_day as (
      select
      ds.day,
      alo.asset_id,
      coalesce(alo.asset_class,'No Asset Class') as asset_class,
      alo.custom_name,
      alo.category,
      alo.branch,
      alo.asset_type,
      alo.make,
      alo.model,
      count(distinct(alo.asset_id)) as total_assets,
      sum(coalesce(alo.oec,0)) as total_oec
      from
      date_series ds
      join ES_WAREHOUSE.SCD.scd_asset_rsp arb on ds.day between arb.date_start and arb.date_end
      join (
        select
          alo.asset_id,
          a.asset_class,
          aa.oec,
          a.custom_name,
          cat.name as category,
          m.name as branch,
          a.make,
          a.model,
          concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type
        from
          -- table(assetlist(101457::numeric)) alo
          table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
          join assets a on a.asset_id = alo.asset_id
          join assets_aggregate aa on alo.asset_id = aa.asset_id
          left join asset_types ast on ast.asset_type_id = a.asset_type_id
          left join categories cat on cat.category_id = a.category_id
          left join markets m on m.market_id = a.inventory_branch_id
        where
          {% condition utilization_history.custom_name_filter %} a.custom_name {% endcondition %}
          AND {% condition utilization_history.asset_class_filter %} a.asset_class {% endcondition %}
          AND {% condition utilization_history.category_filter %} cat.name {% endcondition %}
          AND {% condition utilization_history.branch_filter %} m.name {% endcondition %}
          AND {% condition utilization_history.asset_type_filter %} ast.name {% endcondition %}
      ) alo on alo.asset_id = arb.asset_id
      -- where
      --    m.company_id = 6302
      group by
        ds.day,
        alo.asset_id,
        coalesce(alo.asset_class,'No Asset Class'),
        alo.custom_name,
        alo.category,
        alo.branch,
        alo.asset_type,
        alo.make,
        alo.model
      UNION
      select
        ds.day,
        alo.asset_id,
        coalesce(alo.asset_class,'No Asset Class') as asset_class,
        alo.custom_name,
        alo.category,
        alo.branch,
        alo.asset_type,
        alo.make,
        alo.model,
        count(distinct(alo.asset_id)) as total_assets,
        sum(coalesce(alo.oec,0)) as total_oec
      from
        date_series ds
        join ES_WAREHOUSE.SCD.scd_asset_rsp arb on ds.day between arb.date_start and arb.date_end
        join (
          select
            a.asset_id,
            a.asset_class,
            aa.oec,
            a.custom_name,
            cat.name as category,
            m.name as branch,
            a.make,
            a.model,
            concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type
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
            {% condition utilization_history.custom_name_filter %} a.custom_name {% endcondition %}
            AND {% condition utilization_history.asset_class_filter %} a.asset_class {% endcondition %}
            AND {% condition utilization_history.category_filter %} cat.name {% endcondition %}
            AND {% condition utilization_history.branch_filter %} m.name {% endcondition %}
            AND {% condition utilization_history.asset_type_filter %} ast.name {% endcondition %}
            AND a.asset_id not in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
            AND a.deleted = FALSE
            AND m.company_id = {{ _user_attributes['company_id'] }}
      ) alo on alo.asset_id = arb.asset_id
      -- where
      --    m.company_id = 6302
      group by
        ds.day,
        alo.asset_id,
        coalesce(alo.asset_class,'No Asset Class'),
        alo.custom_name,
        alo.category,
        alo.branch,
        alo.asset_type,
        alo.make,
        alo.model
      )
      select
      ta.day,
      ta.asset_id,
      ta.custom_name,
      ta.asset_class,
      ta.category,
      ta.branch,
      ta.asset_type,
      ta.make,
      ta.model,
      coalesce(ah.value,a.value) as asset_health_status,
      coalesce(oa.on_rent_count,0) as on_rent_asset_count,
      ta.total_assets,
      coalesce(on_rent_oec,0) as on_rent_oec,
      coalesce(ta.total_oec,0) as total_oec,
      case when ta.total_oec = 0 or ta.total_oec is null then 0 else coalesce(oa.rental_rev_effective_daily_rate,0) end as rental_rev_effective_daily_rate,
      case when dayname(ta.day) not in ('Sat','Sun') then 1 else 0 end as weekday_flag
      from
      total_assets_by_day ta
      left join on_rent_by_day oa on oa.day = ta.day and oa.asset_id = ta.asset_id
      left join (select alo.asset_id, value from asset_status_key_values askv left join
      (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric))) alo on alo.asset_id = askv.asset_id where name = 'asset_inventory_status') ah
      on ah.asset_id = ta.asset_id
      left join
      (select a.asset_id, askv.value
      from
      assets a
      join asset_status_key_values askv on askv.asset_id = a.asset_id
      join markets m on m.market_id = a.rental_branch_id AND m.company_id = {{ _user_attributes['company_id'] }}
      where askv.name = 'asset_inventory_status' AND a.asset_id not in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))) a
      on a.asset_id = ta.asset_id
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: day {
    type: date
    sql: ${TABLE}."DAY" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: custom_name {
    label: "Asset"
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
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

  dimension: asset_health_status {
    label: "Current Asset Status"
    type: string
    sql: ${TABLE}."ASSET_HEALTH_STATUS" ;;
  }

  dimension: weekday_flag {
    type: number
    sql: ${TABLE}."WEEKDAY_FLAG" ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${day},${asset_id}) ;;
  }

  dimension: day_formatted {
    group_label: "HTML Passed Date Format" label: "Date"
    sql: ${day} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: asset_custom_name_to_asset_info {
    group_label: "Link to T3"
    label: "Asset"
    type: string
    sql: ${custom_name};;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
  }

  measure: total_weekdays_last_31_days {
    type: sum
    sql: ${weekday_flag} ;;
    filters: [day: "Last 30 Days"]
  }

  measure: total_assets_last_31_days {
    type: sum
    sql: ${total_assets} ;;
    filters: [day: "Last 30 Days", weekday_flag: "1"]
  }

  measure: total_current_oec {
    label: "Asset OEC"
    type: sum
    sql: ${total_oec} ;;
    filters: [day: "Today"]
    value_format_name: usd_0
  }

  measure: total_current_asset_oec {
    group_label: "KPI Drill Down"
    label: "Asset OEC"
    type: sum
    sql: ${total_oec} ;;
    filters: [day: "Today"]
    value_format_name: usd_0
  }

  measure: total_oec_by_day {
    type: sum
    sql: ${total_oec} ;;
    value_format_name: usd_0
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
    filters: [day: "Last 30 days", weekday_flag: "1"]
    value_format_name: usd_0
  }

  measure: financial_utilization {
    type: number
    sql: (${total_estimated_rental_revenue} * 12)/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
  }

  measure: on_rent_asset_count_last_31_days {
    label: "Assets On Rent (Last 30 Days)"
    type: sum
    sql: ${on_rent_asset_count} ;;
    filters: [day: "Last 30 Days", weekday_flag: "1"]
  }

  measure: unit_utilization_last_31_days {
    label: "Unit Utilization Last 30 Days"
    type: number
    sql: ${on_rent_asset_count_last_31_days}/case when ${total_assets_last_31_days} = 0 then null else ${total_assets_last_31_days} end ;;
    value_format_name: percent_1
  }

  measure: total_current_oec_on_rent {
    type: sum
    sql: ${on_rent_oec};;
    value_format: "$0.0,,\" M\""
    filters: [day: "Today"]
  }

  measure: total_current_oec_on_rent_percentage {
    type: number
    sql: ${total_current_oec_on_rent} / case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
  }

  measure: unit_utilization {
    type: number
    sql: ${total_on_rent_asset_count}/case when ${total_asset_count} = 0 then null else ${total_asset_count} end ;;
    value_format_name: percent_1
  }

  measure: oec_on_rent_percentage {
    type: number
    sql: ${total_oec_on_rent_by_day}/case when ${total_oec_by_day} = 0 then null else ${total_oec_by_day} end ;;
    value_format_name: percent_1
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

  set: detail {
    fields: [
      day,
      asset_id,
      on_rent_asset_count,
      total_assets,
      on_rent_oec,
      total_oec,
      rental_rev_effective_daily_rate
    ]
  }
}
