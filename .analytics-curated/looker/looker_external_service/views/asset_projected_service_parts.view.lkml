view: asset_projected_service_parts {
  derived_table: {
    sql:
      with viewable_assets as (
      select
        a.asset_id
      from
        assets a
        join markets m on a.inventory_branch_id = m.market_id
      where
        a.company_id = {{ _user_attributes['company_id'] }}
        OR m.company_id = {{ _user_attributes['company_id'] }}
      )
      select
          va.asset_id,
          spf.maintenance_group_interval_id,
          spf.projected_service_likely_date,
          --round(sum(spf.projected_part_quantity),0) as projected_part_quantity,
          round(spf.estimated_parts_cost,0) as projected_part_cost
      from
          viewable_assets va
          join DATA_SCIENCE.PUBLIC.MVW_ASSET_SERVICE_FORECAST_PARTS_COST spf on va.asset_id = spf.asset_id
       ;;
  }

  # ${assets.company_id} = {{ _user_attributes['company_id'] }}
  # OR ${markets_service.company_id} = {{ _user_attributes['company_id'] }}
  # )

  # ;;
  # persist_for: "10 minutes"

  # join: assets {
  #   type: inner
  #   relationship: many_to_one
  #   sql_on: ${assets.asset_id} = ${asset_service_intervals.asset_id} ;;
  # }

  # join: categories {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${categories.category_id} = ${assets.category_id} ;;
  # }

  # join: asset_types {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  # }

  # join: asset_status_key_values {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  # }

  # join: markets {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${markets.market_id} = ${assets.inventory_branch_id} ;;
  # }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${maintenance_group_interval_id}) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: maintenance_group_interval_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_ID" ;;
  }

  dimension: projected_service_likely_date {
    type: date
    sql: ${TABLE}."PROJECTED_SERVICE_LIKELY_DATE" ;;
  }

  # dimension: projected_part_quantity {
  #   type: number
  #   sql: ${TABLE}."PROJECTED_PART_QUANTITY" ;;
  # }

  dimension: projected_part_cost {
    type: number
    sql: ${TABLE}."PROJECTED_PART_COST" ;;
  }

  dimension: projected_service_likely_date_formatted {
    description: "Only available for service intervals. Based on utilization history this is the projected date of when maintence will need to take place"
    group_label: "HTML Passed Date Format" label: "Likely Service Date"
    sql: ${projected_service_likely_date} ;;
    type: date
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: days_until_project_service {
    type: number
    sql: datediff(days,convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',current_timestamp)::date,${projected_service_likely_date}) ;;
  }

  measure: dummy {
    hidden: yes
    type: sum
    sql: 0 ;;
    drill_fields: [detail*]
  }

  dimension: due_next_60_days {
    type: yesno
    sql: datediff(days,convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',current_timestamp)::date,${projected_service_likely_date}) <= 60 and datediff(days,convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',current_timestamp)::date,${projected_service_likely_date}) >= 0 ;;
  }

  measure: upcoming_service_projected_next_60_days {
    type: sum
    sql: case when datediff(days,current_date(),${projected_service_likely_date}) <= 60 then 1 else null end ;;
    link: {
      label: "View Upcoming Assets Due for Service Interval"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis= '{\"show_view_names\":false,
      \"show_row_numbers\":true,
      \"transpose\":false,
      \"truncate_text\":true,
      \"hide_totals\":false,
      \"hide_row_totals\":false,
      \"size_to_fit\":true,
      \"table_theme\":\"white\",
      \"limit_displayed_rows\":false,
      \"enable_conditional_formatting\":false,
      \"header_text_alignment\":\"left\",
      \"header_font_size\":\"13\",
      \"rows_font_size\":\"12\",
      \"conditional_formatting_include_totals\":false,
      \"conditional_formatting_include_nulls\":false,
      \"show_sql_query_menu_options\":false,
      \"show_totals\":true,
      \"show_row_totals\":true,
      \"truncate_header\":false,
      \"header_font_color\":\"#000000\",
      \"header_background_color\":\"#E1E2E6\",
      \"type\":\"looker_grid\",
      \"series_types\":{},
      \"defaults_version\":1}' %}

      {% assign dynamic_fields= '[]' %}

      {{dummy._link}}&f[asset_types.asset_type]=&f[categories.name]=&vis={{vis | encode_uri}}&dynamic_fields={{dynamic_fields | encode_uri}}&sorts=asset_projected_service_parts.projected_service_likely_date_formatted+asc"
    }
  }

  # measure: total_projected_part_quantity {
  #   type: sum
  #   sql: ${projected_part_quantity} ;;
  #   filters: [due_next_60_days: "yes"]
  # }

  measure: total_projected_part_cost {
    type: sum
    sql: ${projected_part_cost} ;;
    value_format_name: usd
    filters: [due_next_60_days: "yes"]
  }

  set: detail {
    fields: [
      assets.asset_custom_name_to_service_page,
      asset_last_location.address,
      assets.asset_class,
      assets.make,
      assets.model,
      markets.name,
      asset_service_intervals.service_interval_name,
      asset_service_intervals.remaining_time,
      projected_service_likely_date_formatted
    ]
  }

}
