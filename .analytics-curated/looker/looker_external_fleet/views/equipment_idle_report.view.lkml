view: equipment_idle_report {
  derived_table: {
    sql:
with base_data as (
select distinct
        bdu.asset_id
        ,bdu.date
        ,bdu.custom_name
        ,bdu.make
        ,bdu.model
        ,bdu.tracker_tracker_id
        ,coalesce(tm.tracker,'No Tracker') as tracker
        ,tm.public_health_status
        ,bdu.asset_type
        ,bdu.asset_class
        ,bdu.category
        ,bdu.branch
        ,bdu.rental_company_id
        ,bdu.owner_company_id
        ,coalesce(o.name,'No Group') as groups
        , case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then on_time_utc
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then on_time_cst
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then on_time_mnt
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then on_time_wst
          --- else is Eastern Standard Time
          else on_time_est
        end as on_time -- Time machine was on, regardless of usage
        , case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then run_time_utc
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then run_time_cst
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then run_time_mnt
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then run_time_wst
          --- else is Eastern Standard Time
          else run_time_est
        end as run_time -- Time machine was actually used
        , case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then idle_time_utc
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then idle_time_cst
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then idle_time_mnt
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then idle_time_wst
          --- else is Eastern Standard Time
          else idle_time_est
        end as idle_time -- Time machine was idle
        , case
           when bdu.owner_company_id = {{ _user_attributes['company_id'] }} then 'Owned'
           when bdu.rental_company_id = {{ _user_attributes['company_id'] }} then 'Rented'
           else NULL
        end as asset_ownership
    from business_intelligence.triage.stg_t3__by_day_utilization bdu
    left join business_intelligence.triage.stg_t3__telematics_health tm ON tm.asset_id = bdu.asset_id
    left join organization_asset_xref oax on bdu.asset_id = oax.asset_id
    left join es_warehouse.public.organizations o on oax.organization_id = o.organization_id
    where (rental_company_id = {{ _user_attributes['company_id'] }}::numeric
          or owner_company_id = {{ _user_attributes['company_id'] }}::numeric)
    and bdu.asset_type = 'Equipment'
    and on_time is not NULL
    {% if date_filter._is_filtered %}
    and bdu.date >= {% date_start date_filter %}
    and bdu.date <= {% date_end date_filter %}
    {% endif %}
    and {% condition asset_class_filter %} bdu.asset_class {% endcondition %}
    and {% condition category_filter %} bdu.category {% endcondition %}
    and {% condition asset_filter %} bdu.custom_name {% endcondition %}
    and {% condition branch_filter %} bdu.branch {% endcondition %}
    and {% condition groups_filter %} bdu.groups {% endcondition %}
    and {% condition ownership_filter %} asset_ownership {% endcondition %}
),
total_idle_by_asset AS (
  select asset_id, SUM(idle_time) AS total_idle_time
  from base_data
  group by asset_id
),
ranked_assets AS (
  SELECT
    asset_id,
    total_idle_time,
    ROW_NUMBER() OVER (ORDER BY total_idle_time DESC) AS row_num
  FROM total_idle_by_asset
),
top_ten AS (
  SELECT asset_id
  FROM ranked_assets
  WHERE row_num <= 10
)
select bd.*,
case when tt.asset_id is not null then 'True' else 'False' end as top_ten_flag
from base_data bd
left join top_ten tt on bd.asset_id = tt.asset_id
where (bd.rental_company_id = {{ _user_attributes['company_id'] }}::numeric
      or bd.owner_company_id = {{ _user_attributes['company_id'] }}::numeric)
and bd.asset_type = 'Equipment'
and on_time is not NULL
{% if date_filter._is_filtered %}
and bd.date >= {% date_start date_filter %}
and bd.date <= {% date_end date_filter %}
{% endif %}
and {% condition asset_class_filter %} bd.asset_class {% endcondition %}
and {% condition category_filter %} bd.category {% endcondition %}
and {% condition asset_filter %} bd.custom_name {% endcondition %}
and {% condition branch_filter %} bd.branch {% endcondition %}
and {% condition groups_filter %} bd.groups {% endcondition %}
and {% condition ownership_filter %} bd.asset_ownership {% endcondition %};;
}
## Parameters
  parameter: duration_selection {
    type: string
    allowed_value: { value: "Daily"}
    allowed_value: { value: "Weekly"}
    allowed_value: { value: "Monthly"}
  }

## Dimensions
  dimension_group: date {
    type: time
    sql:  ${TABLE}."DATE" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: custom_name {
    label: "Asset"
    type: string
    sql: TRIM(${TABLE}."CUSTOM_NAME") ;;
  }

  dimension: tracker {
    type: string
    sql: ${TABLE}."TRACKER" ;;
  }

  dimension: idle_time {
    type: number
    sql:${TABLE}."IDLE_TIME";;
  }

  dimension: run_time {
    type: number
    sql:${TABLE}."RUN_TIME";;
  }

  dimension: on_time {
    type: number
    sql:${TABLE}."ON_TIME";;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: asset_class {
    type: string
    label: "Class"
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: public_health_status {
    label: "Tracker Health Status"
    type: string
    sql: INITCAP(${TABLE}."PUBLIC_HEALTH_STATUS") ;;
  }

  dimension: asset_custom_name_to_asset_info {
    group_label: "Link to T3"
    label: "Asset"
    type: string
    sql: ${custom_name};;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: date_formatted {
    group_label: "HTML Formatted Time"
    label: "Date"
    type: date
    sql: ${date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: dynamic_timeframe {
    group_label: "Dynamic Date"
    label: "Date"
    type: string
    sql:
    CASE
    WHEN {% parameter duration_selection %} = 'Daily' THEN ${date_date}
    WHEN {% parameter duration_selection %} = 'Weekly' THEN ${date_week}
    WHEN {% parameter duration_selection %} = 'Monthly' THEN ${date_month}
    END ;;
    html: {% if duration_selection._parameter_value == "'Daily'" %}
          {{ rendered_value | date: "%b %d, %Y" }}
          {% elsif duration_selection._parameter_value == "'Weekly'"  %}
          Week of {{ rendered_value | date: "%b %d, %Y" }}
          {% else %}
          {{ rendered_value | append: "-01" | date: "%b %Y" }}
          {% endif %} ;;
  }

  dimension: groups {
    type: string
    sql: coalesce(${TABLE}."GROUPS", 'Ungrouped Assets')  ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH"  ;;
  }

  dimension: ownership {
    type: string
    sql: ${TABLE}."ASSET_OWNERSHIP"  ;;
  }

  dimension: top_ten_flag {
    type: string
    sql: ${TABLE}."TOP_TEN_FLAG"  ;;
  }

## Measures
  measure: run_time_total {
    type: sum
    label: "Run Time"
    sql:${TABLE}."RUN_TIME";;
  }

  measure: idle_time_total {
    type: sum
    label: "Idle Time"
    sql:${TABLE}."IDLE_TIME";;
  }

  measure: on_time_total {
    type: sum
    label: "On Time"
    sql:${TABLE}."ON_TIME";;
  }

  measure: idle_percentage {
    type: number
    sql:
      CASE
      WHEN ABS(${idle_time_total}) = 0 THEN 0
      WHEN ABS(${on_time_total}) = 0 THEN 0
      ELSE ABS(${idle_time_total}) / ABS(${on_time_total})
    END ;;
  value_format_name: percent_1
}

  measure: total_assets {
    type: count_distinct
    sql: ${asset_id} ;;
  }

  measure: total_assets_with_idle {
    label: "Total Assets With Idle"
    type: count_distinct
    sql: CASE WHEN ${idle_time} > 0 THEN ${asset_id} ELSE NULL END ;;
  }

  measure: total_assets_no_idle {
    type: number
    sql: ${total_assets} - ${total_assets_with_idle} ;;
  }

  measure: on_time_hours {
    type: number
    label: "On Time"
    group_label: "Hours"
    sql: ${on_time_total} / 3600 ;;
    html:  {{on_time_fmt._rendered_value}} ;;
    description: "Total time machine was turned on, regardless of usage."
    ##value_format_name: decimal_2
  }

  measure: idle_time_hours {
    type: number
    label: "Idle Time"
    group_label: "Hours"
    sql: ${idle_time_total} / 3600 ;;
    html:  {{idle_time_fmt._rendered_value}} ;;
    description: "Total time machine was turned on & sat idle or inactive."
    drill_fields: [detail*]
    ##value_format_name: decimal_2
  }

  measure: run_time_hours {
    type: number
    label: "Utilization Time"
    group_label: "Hours"
    sql: ${run_time_total} / 3600 ;;
    html:  {{run_time_fmt._rendered_value}} ;;
    description: "Total time machine was turned on & used or operated."
    ##value_format_name: decimal_2
  }

  measure: run_time_fmt {
    sql: CONCAT(FLOOR(${run_time_hours}), 'h ', ROUND(((${run_time_hours} - FLOOR(${run_time_hours})) * 60)), 'm') ;;
  }

  measure: idle_time_fmt {
    sql: CONCAT(FLOOR(${idle_time_hours}), 'h ', ROUND(((${idle_time_hours} - FLOOR(${idle_time_hours})) * 60)), 'm') ;;
  }

  measure: on_time_fmt {
    sql: CONCAT(FLOOR(${on_time_hours}), 'h ', ROUND(((${on_time_hours} - FLOOR(${on_time_hours})) * 60)), 'm') ;;
  }

## Summary Dimension

  dimension: asset_summary {
    sql: 'Asset Summary' ;;
    html:
    <br/>
    <table>
    <tr>
      <td width="200px"><h4>Total Assets:</h4></td>
      <td width="125px"><h4>{{total_assets._rendered_value}}</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total Assets with Idle Time:</h4></td>
      <td width="125px"><h4>{{total_assets_with_idle._rendered_value}}</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Idle Percentage:</h4></td>
      <td width="125px"><h4>{{idle_percentage._rendered_value}}</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total Run Time:</h4></td>
      <td width="125px"><h4>{{run_time_total._rendered_value}} hrs.</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total Idle Time:</h4></td>
      <td width="125px"><h4>{{idle_time_total._rendered_value}} hrs.</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total On Time:</h4></td>
      <td width="125px"><h4>{{on_time_total._rendered_value}} hrs.</h4></td>
    </tr>
    <tr>
    </table>
      ;;
  }

## Filters
  filter: date_filter {
    type: date_time
  }

  filter: category_filter {
    type: string
  }

  filter: asset_class_filter {
    type: string
  }

  filter: asset_filter {
    type: string
  }

  filter: groups_filter {
    type: string
  }

  filter: ownership_filter {
    type: string
  }

  filter: branch_filter {
    type: string
  }

  set: detail {
    fields: [
    custom_name,
    make,
    model,
    asset_class,
    on_time_fmt,
    run_time_fmt,
    idle_time_fmt
    ]
  }
}
