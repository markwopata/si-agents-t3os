view: fuel_emissions {

  derived_table: {
    sql:
    select
            DISTINCT
            date
            ,CAST(asset_id AS STRING) AS asset_id
            ,asset
            ,make
            ,model
            ,vin
            ,SERIAL_NUMBER_VIN
            ,asset_class
            ,odometer
            ,hours
            ,geofences
            ,address
            ,location
            ,rental_id
            ,rental_company_id
            ,owner_company_id
            ,emissions_per_day
            ,gallons_used_per_day
            ,idle_emissions_per_day
            ,idle_gallons_per_day
            ,engine_power_type

            ,FIRST_VALUE(address) IGNORE NULLS OVER (
              PARTITION BY asset_id
              ORDER BY DATE DESC
            ) AS last_address

            ,FIRST_VALUE(geofences) IGNORE NULLS OVER (
              PARTITION BY asset_id
              ORDER BY DATE DESC
            ) AS last_geofence
            ,
          case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(on_time_utc / 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(on_time_cst/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then NULLIF(on_time_mnt/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(on_time_wst/ 60 / 60,0)
          -- else is Eastern Standard Time
          else NULLIF(on_time_est/ 60 / 60,0)
          end as on_time
          , case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(run_time_utc/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(run_time_cst/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then NULLIF(run_time_mnt/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(run_time_wst/ 60 / 60,0)
          -- else is Eastern Standard Time
          else NULLIF(run_time_est/ 60 / 60,0)
          end as run_time
          , case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(idle_time_utc/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(idle_time_cst/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then NULLIF(idle_time_mnt/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(idle_time_wst/ 60 / 60,0)
          -- else is Eastern Standard Time
          else NULLIF(idle_time_est/ 60 / 60,0)
          end as idle_time
          , case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then miles_driven_utc
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then miles_driven_cst
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then miles_driven_mnt
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then miles_driven_wst
          -- else is Eastern Standard Time
          else miles_driven_est
          end as miles_driven
            , case
               when bdu.owner_company_id = {{ _user_attributes['company_id'] }} then 'Owned'
               when bdu.rental_company_id = {{ _user_attributes['company_id'] }} then 'Rented'
               else NULL
            end as asset_ownership
        FROM business_intelligence.triage.stg_t3__by_day_utilization bdu
        WHERE (rental_company_id = {{ _user_attributes['company_id'] }}::numeric
              or owner_company_id = {{ _user_attributes['company_id'] }}::numeric)
        {% if date_filter._is_filtered %}
        and date >= {% date_start date_filter %}
        and date <= {% date_end date_filter %}
        {% endif %}
        AND {% condition asset_filter %} bdu.asset {% endcondition %}
        AND {% condition asset_class_filter %} bdu.asset_class {% endcondition %}
        AND {% condition make_filter %} bdu.make {% endcondition %}
        AND {% condition model_filter %} bdu.model {% endcondition %}
        AND {% condition engine_type_filter %} bdu.engine_power_type {% endcondition %}
        -- GROUP BY ALL
  ;;
  }



  # ---------------------
  # Dimensions
  # ---------------------

  dimension_group: date {type: time sql: ${TABLE}.DATE ;;}
  dimension: asset { type: string sql: ${TABLE}.ASSET ;; }
  dimension: asset_id { type: number sql: ${TABLE}.ASSET_ID ;; }
  dimension: vin { type: string sql: ${TABLE}.VIN ;; }
  dimension: model { type: string sql: ${TABLE}.MODEL ;; }
  dimension: make { type: string sql: ${TABLE}.MAKE ;; }
  dimension: asset_class { type: string sql: ${TABLE}.ASSET_CLASS ;; label: "Class"}
  dimension: rental_id { type: number sql: ${TABLE}.RENTAL_ID ;; }
  dimension: gallons_used_per_day { type: number sql: ${TABLE}.GALLONS_USED_PER_DAY ;; }
  dimension: idle_gallons_per_day { type: number sql: ${TABLE}.IDLE_GALLONS_PER_DAY ;; }
  dimension: emissions_per_day { type: number sql: ${TABLE}.EMISSIONS_PER_DAY ;; }
  dimension: idle_emissions_per_day { type: number sql: ${TABLE}.IDLE_EMISSIONS_PER_DAY ;; }
  dimension: engine_power_type { type: string sql: ${TABLE}.ENGINE_POWER_TYPE ;; }
  #dimension: last_address { type: string sql: ${TABLE}.LAST_LOCATION ;; }
  dimension: asset_hyperlink {
    group_label: "Link to T3"
    label: "Asset"
    type: string
    sql: ${TABLE}.ASSET ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
  }

  dimension: last_address {
    label: "Last Address"
    type: string
    sql: ${TABLE}."LAST_ADDRESS" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ date_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

  dimension: last_geofence {
    label: "Last Geofence"
    type: string
    sql: ${TABLE}."LAST_GEOFENCE" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ date_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

  dimension: last_location {
    label: "Location"
    type: string
    sql: coalesce(${last_address},${last_geofence}) ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ date_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

  dimension: dynamic_last_location {
    label_from_parameter: show_last_location_options
    label: "Daily Location"
    sql:{% if show_last_location_options._parameter_value == "'Default'" %}
      ${last_location}
    {% elsif show_last_location_options._parameter_value == "'Geofence'" %}
      ${last_geofence}
    {% elsif show_last_location_options._parameter_value == "'Address'" %}
      ${last_address}
    {% else %}
      NULL
    {% endif %} ;;
  }

  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
    html: {{rendered_value}} mi. ;;
    value_format_name: decimal_1
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
    html: {{rendered_value}} hrs. ;;
    value_format_name: decimal_1
  }

  dimension: serial_number_vin {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_VIN" ;;
  }

  dimension: run_time {
    type: number
    sql: ${TABLE}."RUN_TIME" ;;
  }

  dimension: idle_time {
    type: number
    sql: ${TABLE}."IDLE_TIME";;
  }

  dimension: miles_driven {
    type: number
    sql: ${TABLE}."MILES_DRIVEN" ;;
  }

  dimension: on_time {
    type: number
    sql: ${TABLE}."ON_TIME" ;;
  }

  # ---------------------
  # Meaures
  # ---------------------
  measure: distinct_assets { type: count_distinct sql: ${asset_id} ;; value_format_name: decimal_0 }
  measure: distinct_rentals { type: count_distinct sql: ${rental_id} ;; value_format_name: decimal_0 }

  measure: total_emissions {
    type: sum sql: ${emissions_per_day} ;;
    value_format_name: decimal_0
    html: <a href="#drillmenu" target="_self">{{rendered_value}} kg CO2 <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    drill_fields: [date_date, asset_hyperlink, asset_class, make, model, serial_number_vin, engine_power_type, dynamic_last_location, odometer, hours, total_emissions, total_idle_emissions, total_fuel_gallons, total_run_time_by_day, total_idle_time_by_day, total_on_time_by_day, total_miles_driven_no_icon]
  }

  measure: average_emissions { type: average sql: ${emissions_per_day} ;; value_format_name: decimal_2 }
  measure: total_idle_emissions { type: sum sql: ${idle_emissions_per_day} ;; value_format_name: decimal_0 html: <a href="#drillmenu" target="_self">{{rendered_value}} kg CO2</a> ;;}
  measure: total_fuel_gallons { type: sum sql: ${gallons_used_per_day} ;; value_format_name: decimal_0 }
  measure: total_idle_fuel_gallons { type: sum sql: ${idle_gallons_per_day} ;; value_format_name: decimal_0 }
  measure: idle_share_of_emissions {
    type: number
    value_format_name: percent_2
    sql: CASE WHEN SUM(${emissions_per_day}) = 0 THEN NULL ELSE SUM(${idle_emissions_per_day}) / NULLIF(SUM(${emissions_per_day}),0) END ;;
  }
  measure: emission_intensity { type: number sql: SUM(${emissions_per_day}) / SUM(${gallons_used_per_day})  ;; value_format_name: decimal_2 }
  measure: emission_intensity_unweighted { type: number sql: AVG(${emissions_per_day}) / AVG(${gallons_used_per_day})  ;; value_format_name: decimal_2 }


  measure: total_run_time_no_icon {
    type: string
    sql: coalesce(FLOOR(sum(${run_time})) || 'h ' ||  ROUND(((sum(${run_time}) - FLOOR(sum(${run_time}))) * 60)) || 'm', '0h 0m') ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} </a> ;;
    # drill_fields: [detail*]
    # value_format_name: decimal_2
  }

  measure: total_run_time_by_day {
    group_label: "Run Time No Icon"
    label: "Total Run Time"
    type: sum
    sql: ${run_time} ;;
    html: {{total_run_time_no_icon._rendered_value}} ;;
    # drill_fields: [run_time_detail*]
    value_format_name: decimal_1
  }

  measure: total_idle_time_no_icon {
    type: string
    sql: coalesce(FLOOR(sum(${idle_time})) || 'h ' ||  ROUND(((sum(${idle_time}) - FLOOR(sum(${idle_time}))) * 60)) || 'm', '0h 0m') ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} </a> ;;
    # drill_fields: [detail*]
    # value_format_name: decimal_2
  }

  measure: total_idle_time_by_day {
    group_label: "Idle Time No Icon"
    label: "Total Idle Time"
    type: sum
    sql: ${idle_time} ;;
    html: {{total_idle_time_no_icon._rendered_value}} ;;
    # drill_fields: [idle_time_detail*]
    value_format_name: decimal_1
  }

  measure: total_on_time_no_icon {
    type: string
    sql: coalesce(FLOOR(sum(${on_time})) || 'h ' ||  ROUND(((sum(${on_time}) - FLOOR(sum(${on_time}))) * 60)) || 'm', '0h 0m') ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} </a> ;;
    # drill_fields: [detail*]
    # value_format_name: decimal_2
  }

  measure: total_on_time_by_day {
    group_label: "On Time No Icon"
    label: "Total On Time"
    type: sum
    sql: ${on_time} ;;
    html: {{total_on_time_no_icon._rendered_value}} ;;
    # drill_fields: [on_time_detail*]
    value_format_name: decimal_1
  }

  measure: total_miles_driven_no_icon {
    type: sum
    label: "Total Miles Driven"
    sql: ${miles_driven} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} mi.</a> ;;
    # drill_fields: [detail*]
    value_format_name: decimal_2
  }

  # ---------------------
  # Filters
  # ---------------------

  filter: date_filter {
    type: date_time
  }

  filter: asset_filter {
    type: string
  }

  filter: asset_class_filter {
    type: string
  }

  filter: make_filter {
    type: string
  }

  filter: model_filter {
    type: string
  }

  filter: engine_type_filter {
    type: string
  }

  # ---------------------
  # Parameters
  # ---------------------

  parameter: show_last_location_options {
    type: string
    allowed_value: { value: "Default"}
    allowed_value: { value: "Geofence"}
    allowed_value: { value: "Address"}
  }

  parameter: show_in_progress_trips {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }



}
