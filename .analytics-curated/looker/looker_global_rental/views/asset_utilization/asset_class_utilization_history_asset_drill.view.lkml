view: asset_class_utilization_history_asset_drill {
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
          coalesce(alo.asset_class,'No Asset Class') as asset_class,
          alo.asset_id,
          alo.custom_name,
          alo.category,
          alo.branch,
          alo.asset_type,
          alo.make,
          alo.model,
          --sum(case
          --    when ds.day between edr.asset_start and edr.asset_end then 1
          --    when ds.day = edr.asset_start and ds.day = edr.asset_end then 1
          --    else null end)
          1 as on_rent_count,
          --sum(case
          --    when ds.day between edr.asset_start and edr.asset_end then oec
          --    when ds.day = edr.asset_start and ds.day = edr.asset_end then oec
          --    else null end)
          sum(coalesce(oec,0))as on_rent_oec,
          sum(NULLIF(effective_daily_rate,0)) as rental_rev_effective_daily_rate
      from
          date_series ds
          join es_warehouse_stage.public.effective_daily_rate edr on ds.day BETWEEN edr.asset_start AND edr.asset_end and edr.company_id = {{ _user_attributes['company_id'] }}
          --join table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
          join (
          select
              alo.asset_id,
              a.asset_class,
              a.custom_name,
              cat.name as category,
              m.name as branch,
              a.make,
              a.model,
              concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type
          from
            --table(assetlist(101457::numeric)) alo
            table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
            join assets a on a.asset_id = alo.asset_id
            left join asset_types ast on ast.asset_type_id = a.asset_type_id
            left join categories cat on cat.category_id = a.category_id
            left join markets m on m.market_id = a.inventory_branch_id
          where
            {% condition asset_class_utilization_history.custom_name_filter %} a.custom_name {% endcondition %}
            AND {% condition asset_class_utilization_history.asset_class_filter %} a.asset_class {% endcondition %}
            AND {% condition asset_class_utilization_history.category_filter %} cat.name {% endcondition %}
            AND {% condition asset_class_utilization_history.branch_filter %} m.name {% endcondition %}
            AND {% condition asset_class_utilization_history.asset_type_filter %} ast.name {% endcondition %}
          ) alo on alo.asset_id = edr.asset_id
      group by
        ds.day,
        coalesce(alo.asset_class,'No Asset Class'),
        alo.asset_id,
        alo.custom_name,
        alo.category,
        alo.branch,
        alo.asset_type,
        alo.make,
        alo.model
      UNION
      select
          ds.day,
          coalesce(alo.asset_class,'No Asset Class') as asset_class,
          alo.asset_id,
          alo.custom_name,
          alo.category,
          alo.branch,
          alo.asset_type,
          alo.make,
          alo.model,
          --sum(case
          --    when ds.day between edr.asset_start and edr.asset_end then 1
          --    when ds.day = edr.asset_start and ds.day = edr.asset_end then 1
          --    else null end)
          1 as on_rent_count,
          --sum(case
          --    when ds.day between edr.asset_start and edr.asset_end then oec
          --    when ds.day = edr.asset_start and ds.day = edr.asset_end then oec
          --    else null end)
          sum(coalesce(oec,0))as on_rent_oec,
          sum(NULLIF(effective_daily_rate,0)) as rental_rev_effective_daily_rate
      from
          date_series ds
          join es_warehouse_stage.public.effective_daily_rate edr on ds.day BETWEEN edr.asset_start AND edr.asset_end and edr.company_id = {{ _user_attributes['company_id'] }}
          --join table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
          join (
          select
              a.asset_id,
              a.asset_class,
              a.custom_name,
              cat.name as category,
              m.name as branch,
              a.make,
              a.model,
              concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type
          from
            --table(assetlist(101457::numeric)) alo
            --table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
            --join
            assets a
            left join asset_types ast on ast.asset_type_id = a.asset_type_id
            left join categories cat on cat.category_id = a.category_id
            join markets m on m.market_id = a.rental_branch_id
          where
            {% condition asset_class_utilization_history.custom_name_filter %} a.custom_name {% endcondition %}
            AND {% condition asset_class_utilization_history.asset_class_filter %} a.asset_class {% endcondition %}
            AND {% condition asset_class_utilization_history.category_filter %} cat.name {% endcondition %}
            AND {% condition asset_class_utilization_history.branch_filter %} m.name {% endcondition %}
            AND {% condition asset_class_utilization_history.asset_type_filter %} ast.name {% endcondition %}
            AND a.asset_id not in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
            AND m.company_id = {{ _user_attributes['company_id'] }}
            AND a.deleted = FALSE
          ) alo on alo.asset_id = edr.asset_id
      group by
        ds.day,
        coalesce(alo.asset_class,'No Asset Class'),
        alo.asset_id,
        alo.custom_name,
        alo.category,
        alo.branch,
        alo.asset_type,
        alo.make,
        alo.model
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
      left join (
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
          --table(assetlist(101457::numeric)) alo
          table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
          join assets a on a.asset_id = alo.asset_id
          join assets_aggregate aa on alo.asset_id = aa.asset_id
          left join asset_types ast on ast.asset_type_id = a.asset_type_id
          left join categories cat on cat.category_id = a.category_id
          left join markets m on m.market_id = a.inventory_branch_id
        where
          {% condition asset_class_utilization_history.custom_name_filter %} a.custom_name {% endcondition %}
          AND {% condition asset_class_utilization_history.asset_class_filter %} a.asset_class {% endcondition %}
          AND {% condition asset_class_utilization_history.category_filter %} cat.name {% endcondition %}
          AND {% condition asset_class_utilization_history.branch_filter %} m.name {% endcondition %}
          AND {% condition asset_class_utilization_history.asset_type_filter %} ast.name {% endcondition %}
        ) alo on alo.asset_id = arb.asset_id
      group by
        ds.day,
        coalesce(alo.asset_class,'No Asset Class'),
        alo.asset_id,
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
        left join (
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
            --table(assetlist(101457::numeric)) alo
            --table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
            --join
            assets a
            join assets_aggregate aa on a.asset_id = aa.asset_id
            left join asset_types ast on ast.asset_type_id = a.asset_type_id
            left join categories cat on cat.category_id = a.category_id
            join markets m on m.market_id = a.rental_branch_id AND m.company_id = {{ _user_attributes['company_id'] }}
          where
            {% condition asset_class_utilization_history.custom_name_filter %} a.custom_name {% endcondition %}
            AND {% condition asset_class_utilization_history.asset_class_filter %} a.asset_class {% endcondition %}
            AND {% condition asset_class_utilization_history.category_filter %} cat.name {% endcondition %}
            AND {% condition asset_class_utilization_history.branch_filter %} m.name {% endcondition %}
            AND {% condition asset_class_utilization_history.asset_type_filter %} ast.name {% endcondition %}
            AND a.asset_id not in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
            AND m.company_id = {{ _user_attributes['company_id'] }}
            AND a.deleted = FALSE
        ) alo on alo.asset_id = arb.asset_id
      group by
        ds.day,
        coalesce(alo.asset_class,'No Asset Class'),
        alo.asset_id,
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
      coalesce(oa.on_rent_count,0) as on_rent_asset_count,
      coalesce(ta.total_assets,0) as total_assets,
      coalesce(on_rent_oec,0) as on_rent_oec,
      coalesce(ta.total_oec,0) as total_oec,
      case when ta.total_oec = 0 or ta.total_oec is null then 0 else coalesce(oa.rental_rev_effective_daily_rate,0) end as rental_rev_effective_daily_rate,
      case when dayname(ta.day) not in ('Sat','Sun') then 1 else 0 end as weekday_flag
      from
      total_assets_by_day ta
      left join on_rent_by_day oa on oa.day = ta.day and ta.asset_id = oa.asset_id
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

  dimension: weekday_flag {
    type: number
    sql: ${TABLE}."WEEKDAY_FLAG" ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${day},${asset_class},${asset_id},${custom_name}) ;;
  }

  measure: total_weekdays_last_30_days {
    type: sum
    sql: ${weekday_flag} ;;
    filters: [day: "Last 30 Days"]
  }

  measure: total_weekdays_last_60_days {
    type: sum
    sql: ${weekday_flag} ;;
    filters: [day: "Last 60 Days"]
  }

  measure: total_weekdays_last_90_days {
    type: sum
    sql: ${weekday_flag} ;;
    filters: [day: "Last 90 Days"]
  }

  measure: total_weekdays_last_120_days {
    type: sum
    sql: ${weekday_flag} ;;
    filters: [day: "Last 120 Days"]
  }

  measure: total_weekdays_last_180_days {
    type: sum
    sql: ${weekday_flag} ;;
    filters: [day: "Last 180 Days"]
  }

  dimension: asset_custom_name_to_asset_info {
    group_label: "Link to T3"
    label: "Asset"
    type: string
    sql: ${custom_name};;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
  }

  measure: total_on_rent_oec {
    type: sum
    sql: ${on_rent_oec} ;;
  }

  measure: overall_total_oec {
    label: "Total OEC"
    type: sum
    sql: ${total_oec} ;;
  }

  measure: total_assets_last_31_days {
    type: sum
    sql: ${total_assets} ;;
    filters: [day: "Last 31 Days"]
  }

  measure: total_current_oec {
    type: sum
    sql: ${total_oec} ;;
    filters: [day: "Today"]
    value_format_name: usd_0
  }

  measure: total_current_oec_drill_down {
    group_label: "Drill Down"
    label: "Total OEC"
    type: sum
    sql: ${total_oec} ;;
    filters: [day: "Today"]
    value_format_name: usd_0
  }

  measure: total_current_oec_on_rent {
    label: "Total OEC On Rent"
    type: sum
    sql: ${on_rent_oec} ;;
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
  }

  measure: total_on_rent_asset_count {
    type: sum
    sql: ${on_rent_asset_count} ;;
  }

  measure: total_asset_count {
    type: sum
    sql: ${total_assets} ;;
  }

  measure: total_estimated_rental_revenue_last_30 {
    type: sum
    sql: coalesce(${rental_rev_effective_daily_rate},0) ;;
    filters: [day: "Last 30 days", weekday_flag: "1"]
    value_format_name: usd_0
  }

  measure: financial_utilization_last_30 {
    type: number
    sql: (${total_estimated_rental_revenue_last_30} * 12)/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
    html:
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font>
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font>
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font>
    {% endif %} ;;
    #green
    #red
    #yellow
  }

  measure: total_estimated_rental_revenue_last_60 {
    type: sum
    sql: ${rental_rev_effective_daily_rate} ;;
    filters: [day: "Last 60 days", weekday_flag: "1"]
    value_format_name: usd_0
  }

  measure: financial_utilization_last_60 {
    type: number
    sql: (${total_estimated_rental_revenue_last_60} * 6)/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
    html:
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font>
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font>
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font>
    {% endif %} ;;
    #green
    #red
    #yellow
  }

  measure: total_estimated_rental_revenue_last_90 {
    type: sum
    sql: ${rental_rev_effective_daily_rate} ;;
    filters: [day: "Last 90 days", weekday_flag: "1"]
    value_format_name: usd_0
  }

  measure: financial_utilization_last_90 {
    type: number
    sql: (${total_estimated_rental_revenue_last_90} * 4)/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
    html:
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font>
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font>
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font>
    {% endif %} ;;
    #green
    #red
    #yellow
  }

  measure: total_estimated_rental_revenue_last_120 {
    type: sum
    sql: ${rental_rev_effective_daily_rate} ;;
    filters: [day: "Last 120 days", weekday_flag: "1"]
    value_format_name: usd_0
  }

  measure: financial_utilization_last_120 {
    type: number
    sql: (${total_estimated_rental_revenue_last_120} * 3)/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
    html:
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font>
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font>
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font>
    {% endif %} ;;
    #green
    #red
    #yellow
  }

  measure: total_estimated_rental_revenue_last_180 {
    type: sum
    sql: ${rental_rev_effective_daily_rate} ;;
    filters: [day: "Last 180 days", weekday_flag: "1"]
    value_format_name: usd_0
  }

  measure: financial_utilization_last_180 {
    type: number
    sql: (${total_estimated_rental_revenue_last_180} * 2)/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
    html:
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font>
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font>
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font>
    {% endif %} ;;
    #green
    #red
    #yellow
  }

  measure: current_oec_percentage_on_rent {
    label: "% of OEC On Rent"
    type: number
    sql: ${total_current_oec_on_rent}/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
  }

  filter: custom_name_filter {
  }

  filter: asset_class_filter {
  }

  filter: branch_filter {
  }

  filter: category_filter {
  }

  filter: asset_type_filter {
  }

  set: detail {
    fields: [
      asset_class,
      make,
      model,
      custom_name,
      financial_utilization_last_30,
      financial_utilization_last_60,
      financial_utilization_last_90,
      financial_utilization_last_120,
      financial_utilization_last_180
    ]
  }
}
