view: asset_class_utilization_history {
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
          coalesce(edr.category,'No Category') as category,
          coalesce(edr.asset_class,'No Asset Class') as asset_class,
          --sum(case
          --    when ds.day between edr.asset_start and edr.asset_end then 1
          --    when ds.day = edr.asset_start and ds.day = edr.asset_end then 1
          --    else null end) as on_rent_count,
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
             cat.name as category,
             a.asset_class,
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
              left join categories cat on cat.category_id = a.category_id and cat.company_id = {{ _user_attributes['company_id'] }}
              left join markets m on m.market_id = a.inventory_branch_id
          where
            {% condition custom_name_filter %} a.custom_name {% endcondition %}
            AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
            AND {% condition category_filter %} cat.name {% endcondition %}
            AND {% condition branch_filter %} m.name {% endcondition %}
            AND {% condition asset_type_filter %} ast.name {% endcondition %}
            ) edr on ds.day between edr.asset_start and edr.asset_end
          --join es_warehouse_stage.public.effective_daily_rate edr on ds.day BETWEEN edr.asset_start AND edr.asset_end
        --  join (
        --  select
        --      alo.asset_id,
        --      a.asset_class
        --  from
        --     table(assetlist(101457::numeric)) alo
             --table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
          --   join assets a on a.asset_id = alo.asset_id
         -- ) alo on alo.asset_id = edr.asset_id
      group by
          ds.day,
          coalesce(edr.asset_class,'No Asset Class'),
          coalesce(edr.category,'No Category')
      UNION
      select
          ds.day,
          coalesce(edr.category,'No Category') as category,
          coalesce(edr.asset_class,'No Asset Class') as asset_class,
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
             cat.name as category,
             a.asset_class,
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
              left join categories cat on cat.category_id = a.category_id and cat.company_id = {{ _user_attributes['company_id'] }}
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
          ds.day,
          coalesce(edr.asset_class,'No Asset Class'),
          coalesce(edr.category,'No Category')
      )
      ,total_assets_by_day as (
      select
          ds.day,
          coalesce(alo.category,'No Category') as category,
          coalesce(alo.asset_class,'No Asset Class') as asset_class,
          count(distinct(alo.asset_id)) as total_assets,
          sum(coalesce(alo.oec,0)) as total_oec
      from
          date_series ds
          join ES_WAREHOUSE.SCD.scd_asset_rsp arb on ds.day between arb.date_start and arb.date_end
          join (
          select
              alo.asset_id,
              cat.name as category,
              a.asset_class,
              aa.oec
          from
             table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
             --table(assetlist(101457::numeric)) alo
             --table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
             join assets a on a.asset_id = alo.asset_id
             join assets_aggregate aa on alo.asset_id = aa.asset_id
             left join asset_types ast on ast.asset_type_id = a.asset_type_id
             left join categories cat on cat.category_id = a.category_id and cat.company_id = {{ _user_attributes['company_id'] }}
             left join markets m on m.market_id = a.inventory_branch_id
          where
            {% condition custom_name_filter %} a.custom_name {% endcondition %}
            AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
            AND {% condition category_filter %} cat.name {% endcondition %}
            AND {% condition branch_filter %} m.name {% endcondition %}
            AND {% condition asset_type_filter %} ast.name {% endcondition %}
          ) alo on alo.asset_id = arb.asset_id
      group by
          ds.day,
          coalesce(alo.asset_class,'No Asset Class'),
          coalesce(alo.category,'No Category')
      UNION
      select
          ds.day,
          coalesce(alo.category,'No Category') as category,
          coalesce(alo.asset_class,'No Asset Class') as asset_class,
          count(distinct(alo.asset_id)) as total_assets,
          sum(coalesce(alo.oec,0)) as total_oec
      from
          date_series ds
          join ES_WAREHOUSE.SCD.scd_asset_rsp arb on ds.day between arb.date_start and arb.date_end
          join (
          select
              a.asset_id,
              cat.name as category,
              a.asset_class,
              aa.oec
          from
             --table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
             --table(assetlist(101457::numeric)) alo
             --table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
             --join
             assets a
             join assets_aggregate aa on a.asset_id = aa.asset_id
             left join asset_types ast on ast.asset_type_id = a.asset_type_id
             left join categories cat on cat.category_id = a.category_id and cat.company_id = {{ _user_attributes['company_id'] }}
             join markets m on m.market_id = a.rental_branch_id AND m.company_id = {{ _user_attributes['company_id'] }}
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
      group by
          ds.day,
          coalesce(alo.asset_class,'No Asset Class'),
          coalesce(alo.category,'No Category')
      )
      ,on_rent_assets_summarized as (
      select
        day,
        category,
        asset_class,
        sum(on_rent_count) as on_rent_count,
        sum(on_rent_oec) as on_rent_oec,
        sum(rental_rev_effective_daily_rate) as rental_rev_effective_daily_rate
      from
        on_rent_by_day
      group by
        day,
        asset_class,
        category
      )
      ,total_asset_summarized as (
      select
        day,
        category,
        asset_class,
        sum(total_assets) as total_assets,
        sum(total_oec) as total_oec
      from
        total_assets_by_day
      group by
        day,
        asset_class,
        category
      )
      select
          ta.day,
          ta.category,
          ta.asset_class,
          coalesce(oa.on_rent_count,0) as on_rent_asset_count,
          ta.total_assets,
          coalesce(on_rent_oec,0) as on_rent_oec,
          ta.total_oec,
          coalesce(oa.rental_rev_effective_daily_rate,0) as rental_rev_effective_daily_rate,
          case when dayname(ta.day) not in ('Sat','Sun') then 1 else 0 end as weekday_flag
      from
          total_asset_summarized ta
          left join on_rent_assets_summarized oa on oa.day = ta.day and ta.asset_class = oa.asset_class and ta.category = oa.category
       ;;
  }

  measure: count {
    type: count
    drill_fields: [asset_detail*]
  }

  dimension: day {
    type: date
    sql: ${TABLE}."DAY" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
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
    sql: concat(${day},${asset_class}) ;;
  }

  measure: total_weekdays_last_30_days {
    type: sum
    sql: ${weekday_flag} ;;
    filters: [day: "Last 30 Days", weekday_flag: "1"]
  }

  measure: total_weekdays_last_60_days {
    type: sum
    sql: ${weekday_flag} ;;
    filters: [day: "Last 60 Days", weekday_flag: "1"]
  }

  measure: total_weekdays_last_90_days {
    type: sum
    sql: ${weekday_flag} ;;
    filters: [day: "Last 90 Days", weekday_flag: "1"]
  }

  measure: total_weekdays_last_120_days {
    type: sum
    sql: ${weekday_flag} ;;
    filters: [day: "Last 120 Days", weekday_flag: "1"]
  }

  measure: total_weekdays_last_180_days {
    type: sum
    sql: ${weekday_flag} ;;
    filters: [day: "Last 180 Days", weekday_flag: "1"]
  }

  measure: total_assets_last_30_days {
    type: sum
    sql: ${total_assets} ;;
    filters: [day: "Last 30 Days"]
  }

  measure: total_current_oec {
    label: "Total OEC"
    type: sum
    sql: ${total_oec} ;;
    filters: [day: "Today"]
    value_format_name: usd_0
  }

  measure: current_total_assets_on_rent {
    label: "On Rent"
    description: "Assets on Rent / Total Assets"
    type: sum
    sql: ${on_rent_asset_count} ;;
    filters: [day: "Today"]
    html: {{rendered_value}} / {{current_total_available_assets._rendered_value}} ;;
  }

  measure: current_total_available_assets {
    label: "Total Available Assets"
    type: sum
    sql: ${total_assets} ;;
    filters: [day: "Today"]
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

  measure: total_current_oec_on_rent{
    label: "Total Current OEC On Rent"
    type: sum
    sql: ${on_rent_oec} ;;
    value_format_name: usd_0
    filters: [day: "Today"]
  }

  measure: current_oec_percentage_on_rent {
    label: "% of OEC On Rent"
    type: number
    sql: ${total_current_oec_on_rent}/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
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
    sql: ${rental_rev_effective_daily_rate} ;;
    filters: [day: "Last 30 days", weekday_flag: "1"]
    value_format_name: usd_0
  }

  measure: dummy_asset_class_detail {
    hidden: yes
    type: sum
    sql: 0 ;;
    drill_fields: [asset_class_detail*]
  }

  measure: financial_utilization_last_30 {
    type: number
    sql: (${total_estimated_rental_revenue_last_30} * 12)/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
    drill_fields: [asset_class_detail*]
#     link: {
#       label: "View Financial Utilization by Asset Class"
#       url: "
#       {% assign vis= '{\"show_view_names\":false,
#       \"show_row_numbers\":true,
#       \"transpose\":false,
#       \"truncate_text\":true,
#       \"hide_totals\":false,
#       \"hide_row_totals\":false,
#       \"size_to_fit\":true,
#       \"table_theme\":\"white\",
#       \"limit_displayed_rows\":false,
#       \"enable_conditional_formatting\":false,
#       \"header_text_alignment\":\"left\",
#       \"header_font_size\":12,
#       \"rows_font_size\":12,
#       \"conditional_formatting_include_totals\":false,
#       \"conditional_formatting_include_nulls\":false,
#       \"type\":\"looker_grid\",
#       \"defaults_version\":1,
#       \"series_types\":{}}' %}

# {{dummy_asset_class_detail._link}}&f[asset_class_utilization_history.asset_type_filter]=&f[asset_class_utilization_history.category_filter]=&vis={{vis | encode_uri}}
#       "
#     }
    html:
    <a href="#drillmenu" target="_self">
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% endif %}
    </a>
    ;;
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
    drill_fields: [asset_class_detail*]
    # link: {
    #   label: "View Financial Utilization by Asset Class"
    #   url: "
    #   {% assign vis= '{\"show_view_names\":false,
    #   \"show_row_numbers\":true,
    #   \"transpose\":false,
    #   \"truncate_text\":true,
    #   \"hide_totals\":false,
    #   \"hide_row_totals\":false,
    #   \"size_to_fit\":true,
    #   \"table_theme\":\"white\",
    #   \"limit_displayed_rows\":false,
    #   \"enable_conditional_formatting\":false,
    #   \"header_text_alignment\":\"left\",
    #   \"header_font_size\":12,
    #   \"rows_font_size\":12,
    #   \"conditional_formatting_include_totals\":false,
    #   \"conditional_formatting_include_nulls\":false,
    #   \"type\":\"looker_grid\",
    #   \"defaults_version\":1,
    #   \"series_types\":{}}' %}

    #   {{dummy_asset_class_detail._link}}&f[asset_class_utilization_history.asset_type_filter]=&f[asset_class_utilization_history.category_filter]=&vis={{vis | encode_uri}}
    #   "
    # }
    html:
    <a href="#drillmenu" target="_self">
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% endif %}
    </a>
    ;;
    #green
    #red
    #yellow
  }

  measure: last_60_effective_rate {
    type: number
    sql: (${total_estimated_rental_revenue_last_60}) ;;
  }

  measure: current_oec  {
    type: number
    sql: case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
  }

  measure: last_30_effective_rate {
    type: number
    sql: (${total_estimated_rental_revenue_last_30}) ;;
  }

  measure: last_30_annualized {
    type: number
    sql: ${last_30_effective_rate} * 12 ;;
  }

  measure: last_60_annualized {
    type: number
    sql: ${last_60_effective_rate} * 6 ;;
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
    drill_fields: [asset_class_detail*]
    # link: {
    #   label: "View Financial Utilization by Asset Class"
    #   url: "
    #   {% assign vis= '{\"show_view_names\":false,
    #   \"show_row_numbers\":true,
    #   \"transpose\":false,
    #   \"truncate_text\":true,
    #   \"hide_totals\":false,
    #   \"hide_row_totals\":false,
    #   \"size_to_fit\":true,
    #   \"table_theme\":\"white\",
    #   \"limit_displayed_rows\":false,
    #   \"enable_conditional_formatting\":false,
    #   \"header_text_alignment\":\"left\",
    #   \"header_font_size\":12,
    #   \"rows_font_size\":12,
    #   \"conditional_formatting_include_totals\":false,
    #   \"conditional_formatting_include_nulls\":false,
    #   \"type\":\"looker_grid\",
    #   \"defaults_version\":1,
    #   \"series_types\":{}}' %}

    #   {{dummy_asset_class_detail._link}}&f[asset_class_utilization_history.asset_type_filter]=&f[asset_class_utilization_history.category_filter]=&vis={{vis | encode_uri}}
    #   "
    # }
    html:
    <a href="#drillmenu" target="_self">
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% endif %}
    </a>
    ;;
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
    drill_fields: [asset_class_detail*]
    # link: {
    #   label: "View Financial Utilization by Asset Class"
    #   url: "
    #   {% assign vis= '{\"show_view_names\":false,
    #   \"show_row_numbers\":true,
    #   \"transpose\":false,
    #   \"truncate_text\":true,
    #   \"hide_totals\":false,
    #   \"hide_row_totals\":false,
    #   \"size_to_fit\":true,
    #   \"table_theme\":\"white\",
    #   \"limit_displayed_rows\":false,
    #   \"enable_conditional_formatting\":false,
    #   \"header_text_alignment\":\"left\",
    #   \"header_font_size\":12,
    #   \"rows_font_size\":12,
    #   \"conditional_formatting_include_totals\":false,
    #   \"conditional_formatting_include_nulls\":false,
    #   \"type\":\"looker_grid\",
    #   \"defaults_version\":1,
    #   \"series_types\":{}}' %}

    #   {{dummy_asset_class_detail._link}}&f[asset_class_utilization_history.asset_type_filter]=&f[asset_class_utilization_history.category_filter]=&vis={{vis | encode_uri}}
    #   "
    # }
    html:
    <a href="#drillmenu" target="_self">
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% endif %}
    </a>
    ;;
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
    drill_fields: [asset_class_detail*]
    # link: {
    #   label: "View Financial Utilization by Asset Class"
    #   url: "
    #   {% assign vis= '{\"show_view_names\":false,
    #   \"show_row_numbers\":true,
    #   \"transpose\":false,
    #   \"truncate_text\":true,
    #   \"hide_totals\":false,
    #   \"hide_row_totals\":false,
    #   \"size_to_fit\":true,
    #   \"table_theme\":\"white\",
    #   \"limit_displayed_rows\":false,
    #   \"enable_conditional_formatting\":false,
    #   \"header_text_alignment\":\"left\",
    #   \"header_font_size\":12,
    #   \"rows_font_size\":12,
    #   \"conditional_formatting_include_totals\":false,
    #   \"conditional_formatting_include_nulls\":false,
    #   \"type\":\"looker_grid\",
    #   \"defaults_version\":1,
    #   \"series_types\":{}}' %}

    #   {{dummy_asset_class_detail._link}}&f[asset_class_utilization_history.asset_type_filter]=&f[asset_class_utilization_history.category_filter]=&vis={{vis | encode_uri}}
    #   "
    # }
    html:
    <a href="#drillmenu" target="_self">
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% endif %}
    </a>
    ;;
    #green
    #red
    #yellow
  }

  dimension: asset_class_non_table {
    group_label: "Non Table Value"
    label: "Asset Class"
    type: string
    sql: ${asset_class} ;;
  }

  measure: dummy_asset_detail {
    hidden: yes
    type: sum
    sql: 0 ;;
    drill_fields: [asset_detail*]
  }

  measure: asset_class_drill_financial_utilization_last_30 {
    group_label: "Asset Class Drill Down"
    label: "Financial Utilizaiton Last 30"
    type: number
    sql: (${total_estimated_rental_revenue_last_30} * 12)/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
    drill_fields: [asset_detail*]
    # link: {
    #   label: "View Financial Utilization by Asset"
    #   url: "
    #   {% assign vis= '{\"show_view_names\":false,
    #   \"show_row_numbers\":true,
    #   \"transpose\":false,
    #   \"truncate_text\":true,
    #   \"hide_totals\":false,
    #   \"hide_row_totals\":false,
    #   \"size_to_fit\":true,
    #   \"table_theme\":\"white\",
    #   \"limit_displayed_rows\":false,
    #   \"enable_conditional_formatting\":false,
    #   \"header_text_alignment\":\"left\",
    #   \"header_font_size\":12,
    #   \"rows_font_size\":12,
    #   \"conditional_formatting_include_totals\":false,
    #   \"conditional_formatting_include_nulls\":false,
    #   \"type\":\"looker_grid\",
    #   \"defaults_version\":1,
    #   \"series_types\":{}}' %}

    #   {{dummy_asset_detail._link}}&f[asset_class_utilization_history.asset_type_filter]=&f[asset_class_utilization_history.category_filter]=&vis={{vis | encode_uri}}
    #   "
    # }
    html:
    <a href="#drillmenu" target="_self">
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% endif %}
    </a>
    ;;
    #green
    #red
    #yellow
  }

  measure: asset_class_drill_financial_utilization_last_60 {
    group_label: "Asset Class Drill Down"
    label: "Financial Utilizaiton Last 60"
    type: number
    sql: (${total_estimated_rental_revenue_last_60} * 6)/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
    drill_fields: [asset_detail*]
    # link: {
    #   label: "View Financial Utilization by Asset"
    #   url: "
    #   {% assign vis= '{\"show_view_names\":false,
    #   \"show_row_numbers\":true,
    #   \"transpose\":false,
    #   \"truncate_text\":true,
    #   \"hide_totals\":false,
    #   \"hide_row_totals\":false,
    #   \"size_to_fit\":true,
    #   \"table_theme\":\"white\",
    #   \"limit_displayed_rows\":false,
    #   \"enable_conditional_formatting\":false,
    #   \"header_text_alignment\":\"left\",
    #   \"header_font_size\":12,
    #   \"rows_font_size\":12,
    #   \"conditional_formatting_include_totals\":false,
    #   \"conditional_formatting_include_nulls\":false,
    #   \"type\":\"looker_grid\",
    #   \"defaults_version\":1,
    #   \"series_types\":{}}' %}

    #   {{dummy_asset_detail._link}}&f[asset_class_utilization_history.asset_type_filter]=&f[asset_class_utilization_history.category_filter]=&vis={{vis | encode_uri}}
    #   "
    # }
    html:
    <a href="#drillmenu" target="_self">
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% endif %}
    </a>
    ;;
    #green
    #red
    #yellow
  }

  measure: asset_class_drill_financial_utilization_last_90 {
    group_label: "Asset Class Drill Down"
    label: "Financial Utilizaiton Last 90"
    type: number
    sql: (${total_estimated_rental_revenue_last_90} * 4)/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
    drill_fields: [asset_detail*]
    # link: {
    #   label: "View Financial Utilization by Asset"
    #   url: "
    #   {% assign vis= '{\"show_view_names\":false,
    #   \"show_row_numbers\":true,
    #   \"transpose\":false,
    #   \"truncate_text\":true,
    #   \"hide_totals\":false,
    #   \"hide_row_totals\":false,
    #   \"size_to_fit\":true,
    #   \"table_theme\":\"white\",
    #   \"limit_displayed_rows\":false,
    #   \"enable_conditional_formatting\":false,
    #   \"header_text_alignment\":\"left\",
    #   \"header_font_size\":12,
    #   \"rows_font_size\":12,
    #   \"conditional_formatting_include_totals\":false,
    #   \"conditional_formatting_include_nulls\":false,
    #   \"type\":\"looker_grid\",
    #   \"defaults_version\":1,
    #   \"series_types\":{}}' %}

    #   {{dummy_asset_detail._link}}&f[asset_class_utilization_history.asset_type_filter]=&f[asset_class_utilization_history.category_filter]=&vis={{vis | encode_uri}}
    #   "
    # }
    html:
    <a href="#drillmenu" target="_self">
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% endif %}
    </a>
    ;;
    #green
    #red
    #yellow
  }

  measure: asset_class_drill_financial_utilization_last_120 {
    group_label: "Asset Class Drill Down"
    label: "Financial Utilizaiton Last 120"
    type: number
    sql: (${total_estimated_rental_revenue_last_120} * 3)/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
    drill_fields: [asset_detail*]
    # link: {
    #   label: "View Financial Utilization by Asset"
    #   url: "
    #   {% assign vis= '{\"show_view_names\":false,
    #   \"show_row_numbers\":true,
    #   \"transpose\":false,
    #   \"truncate_text\":true,
    #   \"hide_totals\":false,
    #   \"hide_row_totals\":false,
    #   \"size_to_fit\":true,
    #   \"table_theme\":\"white\",
    #   \"limit_displayed_rows\":false,
    #   \"enable_conditional_formatting\":false,
    #   \"header_text_alignment\":\"left\",
    #   \"header_font_size\":12,
    #   \"rows_font_size\":12,
    #   \"conditional_formatting_include_totals\":false,
    #   \"conditional_formatting_include_nulls\":false,
    #   \"type\":\"looker_grid\",
    #   \"defaults_version\":1,
    #   \"series_types\":{}}' %}

    #   {{dummy_asset_detail._link}}&f[asset_class_utilization_history.asset_type_filter]=&f[asset_class_utilization_history.category_filter]=&vis={{vis | encode_uri}}
    #   "
    # }
    html:
    <a href="#drillmenu" target="_self">
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% endif %}
    </a>
    ;;
    #green
    #red
    #yellow
  }

  measure: asset_class_drill_financial_utilization_last_180 {
    group_label: "Asset Class Drill Down"
    label: "Financial Utilizaiton Last 180"
    type: number
    sql: (${total_estimated_rental_revenue_last_180} * 2)/case when ${total_current_oec} = 0 then null else ${total_current_oec} end ;;
    value_format_name: percent_1
    drill_fields: [asset_detail*]
    # link: {
    #   label: "View Financial Utilization by Asset"
    #   url: "
    #   {% assign vis= '{\"show_view_names\":false,
    #   \"show_row_numbers\":true,
    #   \"transpose\":false,
    #   \"truncate_text\":true,
    #   \"hide_totals\":false,
    #   \"hide_row_totals\":false,
    #   \"size_to_fit\":true,
    #   \"table_theme\":\"white\",
    #   \"limit_displayed_rows\":false,
    #   \"enable_conditional_formatting\":false,
    #   \"header_text_alignment\":\"left\",
    #   \"header_font_size\":12,
    #   \"rows_font_size\":12,
    #   \"conditional_formatting_include_totals\":false,
    #   \"conditional_formatting_include_nulls\":false,
    #   \"type\":\"looker_grid\",
    #   \"defaults_version\":1,
    #   \"series_types\":{}}' %}

    #   {{dummy_asset_detail._link}}&f[asset_class_utilization_history.asset_type_filter]=&f[asset_class_utilization_history.category_filter]=&vis={{vis | encode_uri}}
    #   "
    # }
    html:
    <a href="#drillmenu" target="_self">
    {% if value >= 0.37 %}
    <font color="#268162"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% elsif value < 0.33 %}
    <font color="#B32F37"><b>{{ rendered_value }}</b></font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% else %}
    <font color="#E47A28">{{ rendered_value }}</font> <img src="https://imgur.com/ZCNurvk.png" height="15" width="15">
    {% endif %}
    </a>
    ;;
    #green
    #red
    #yellow
  }

  filter: custom_name_filter {
    # suggest_explore: asset_class_utilization_history
    # suggest_dimension: asset_class_utilization_history.custom_name
  }

  filter: asset_class_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.asset_class
  }

  filter: branch_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.branch
  }

  filter: category_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.category
  }

  filter: asset_type_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.asset_type
  }

  set: asset_class_detail {
    fields: [
      category,
      asset_class_non_table,
      total_current_oec,
      current_total_assets_on_rent,
      current_oec_percentage_on_rent,
      asset_class_drill_financial_utilization_last_30,
      asset_class_drill_financial_utilization_last_60,
      asset_class_drill_financial_utilization_last_90,
      asset_class_drill_financial_utilization_last_120,
      asset_class_drill_financial_utilization_last_180
    ]
  }

  set: asset_detail {
    fields: [
      asset_class_utilization_history_asset_drill.category,
      asset_class_utilization_history_asset_drill.asset_class,
      asset_class_utilization_history_asset_drill.asset_custom_name_to_asset_info,
      asset_class_utilization_history_asset_drill.make,
      asset_class_utilization_history_asset_drill.model,
      asset_class_utilization_history_asset_drill.total_current_oec_drill_down,
      asset_class_utilization_history_asset_drill.financial_utilization_last_30,
      asset_class_utilization_history_asset_drill.financial_utilization_last_60,
      asset_class_utilization_history_asset_drill.financial_utilization_last_90,
      asset_class_utilization_history_asset_drill.financial_utilization_last_120,
      asset_class_utilization_history_asset_drill.financial_utilization_last_180
    ]
  }
}
