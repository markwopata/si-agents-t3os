view: asset_utilization_by_day {
  derived_table: {
    sql:
      with
      company_list as
      (
  SELECT company_id
  FROM BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__national_account_assignments
  where (parent_company_id =  {{ _user_attributes['company_id'] }}::integer
  or company_id =  {{ _user_attributes['company_id'] }}::integer)
  UNION select company_id from es_warehouse.public.companies where company_id = {{ _user_attributes['company_id'] }}::integer
      ),
      bdu_f AS (
  SELECT * exclude (ENGINE_POWER_TYPE),
 case when asset_class in ('Energy Storage 20kW Gen Combo Hybrid System', 'Energy Storage 70kW Gen Combo Hybrid System') then 'Diesel' else ENGINE_POWER_TYPE end as ENGINE_POWER_TYPE
  FROM BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__BY_DAY_UTILIZATION bdu
  JOIN company_list cl
    ON bdu.owner_company_id = cl.company_id
    OR bdu.rental_company_id = cl.company_id
  WHERE {% if date_filter._is_filtered %}
    bdu.date >= {% date_start date_filter %}::date
    AND bdu.date <= {% date_end date_filter %}::date
  {% else %}
    bdu.date >= '2025-09-01'::date
    AND bdu.date <= '2026-12-31'::date
  {% endif %}
    AND {% condition job_name_filter %} bdu.job_name {% endcondition %}
    AND {% condition phase_job_name_filter %} bdu.phase_job_name {% endcondition %}
    AND {% condition custom_name_filter %} bdu.custom_name {% endcondition %}
          AND {% condition asset_class_filter %} bdu.asset_class {% endcondition %}
          AND {% condition category_filter %} bdu.category {% endcondition %}
          AND {% condition make_filter %} bdu.make {% endcondition %}
          AND {% condition model_filter %} bdu.model {% endcondition %}
          AND {% condition sub_renting_company_filter %} bdu.sub_renting_company {% endcondition %}
          AND {% condition sub_renting_contact_filter %} bdu.sub_renting_contact {% endcondition %}
          AND {% condition branch_filter %} bdu.branch {% endcondition %}
          AND {% condition asset_type_filter %} bdu.asset_type {% endcondition %}
          AND {% condition tracker_grouping_filter %} bdu.tracker_grouping {% endcondition %}
          AND {% condition rental_company_name_filter %} bdu.rental_company_name {% endcondition %}
          AND {% condition archived_status_filter %} CASE WHEN bdu.archived_status = 'true' THEN 'Archived' ELSE 'Active' END {% endcondition %}
),
    last_check as (
          select
          asset_id
          , max(last_checkin_timestamp_end_date) as last_check
          , max(hours) as hours_max
          , max(odometer) as odo_max
          from
          bdu_f bdu
          group by asset_id
          )
          , last_address as (
          select
          bdu.asset_id
          , bdu.address
          , bdu.geofences
          from
          bdu_f bdu
          join last_check lc on lc.asset_id = bdu.asset_id and lc.last_check = bdu.last_checkin_timestamp_end_date
          )
          , day_used_check as (
          select distinct
            concat(bdu.asset_id,bdu.date) as day_used_check
          , count(concat(bdu.asset_id,bdu.date)) as day_used_check_count
          from
           bdu_f bdu
          GROUP BY concat(asset_id,date)
          )
, temp as (
       select distinct
          bdu.*
          , bdu.date as day
          , CONVERT_TIMEZONE('UTC', '{{ _user_attributes['user_timezone'] }}',lc.last_check::datetime) as last_checkin_timestamp
          , lc.hours_max
          , lc.odo_max
          , bdu.geofences as geofence
          , la.geofences as geofence_max
          , la.address as address_max
          , case
           when bdu.owner_company_id = {{ _user_attributes['company_id'] }} then 'Owned'
          when bdu.rental_company_id = {{ _user_attributes['company_id'] }} then 'Rented'
          else NULL
          end as rented_vs_owned
          , case
          when bdu.owner_company_id = {{ _user_attributes['company_id'] }} then owned_asset_count
          when bdu.rental_company_id = {{ _user_attributes['company_id'] }} then rental_asset_count
          else 0
          end as TOTAL_AVAILABLE_ASSETS
          , {% if show_in_progress_trips._parameter_value == "'No'" %}
          case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(on_time_utc / 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(on_time_cst/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then NULLIF(on_time_mnt/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(on_time_wst/ 60 / 60,0)
          -- else is Eastern Standard Time
          else NULLIF(on_time_est/ 60 / 60,0)
          {% else %}
          case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then COALESCE(on_time_utc/ 60 / 60,0) + COALESCE(in_progress_on_time_utc/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then COALESCE(on_time_cst/ 60 / 60,0) + COALESCE(in_progress_on_time_cst/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then COALESCE(on_time_mnt/ 60 / 60,0) + COALESCE(in_progress_on_time_mnt/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then COALESCE(on_time_wst/ 60 / 60,0) + COALESCE(in_progress_on_time_wst/ 60 / 60,0)
          -- else is Eastern Standard Time
          else COALESCE(on_time_est/ 60 / 60,0) + COALESCE(in_progress_on_time_est/ 60 / 60,0)
          {% endif %}
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
          when on_time > 0 then 1
          else 0
          end as day_used_calced
          , duc.day_used_check_count
          , day_used_calced / duc.day_used_check_count as day_used_mod
          , case
          when day_used_calced / duc.day_used_check_count = 0 and duc.day_used_check_count = 1 then 1
          when day_used_calced > 0 then day_used / duc.day_used_check_count
          else CEIL(day_used / duc.day_used_check_count)
          end as possible_utilization_days_calced
          , epa.subregion_code
          , epa.subregion_name
          , epa.subregion_code_2
          , epa.subregion_name_2
          , epa.subregion_code_3
          , epa.subregion_name_3
          , epa.has_multiple_subregions
          from
          bdu_f bdu
          left join last_check lc on lc.asset_id = bdu.asset_id
          left join last_address la on la.asset_id = bdu.asset_id
          left join es_warehouse.public.organization_asset_xref oax on bdu.asset_id = oax.asset_id
          left join es_warehouse.public.organizations o on oax.organization_id = o.organization_id
          left join day_used_check duc on duc.day_used_check = concat(bdu.asset_id,bdu.date)
          left join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__EPA_SUBREGIONS epa on epa.zip_code = bdu.drop_off_zip_code
          where
           {% condition groups_filter %} o.name {% endcondition %}

          AND
           {% if show_assets_no_contact_over_72_hrs._parameter_value == "'Yes'" %}
            1 = 1
           {% else %}
           bdu.contact_in_72_Hours = 'Yes'
           {% endif %}
          AND
           {% if show_weekends._parameter_value == "'Yes'" %}
            1 = 1
           {% else %}
           bdu.weekend_flag = '0'
           {% endif %}
)
select t.* exclude (burn_rate_gph, fuel_data_source)
, CASE
        -- Rule 1: Zero-consumption Engine Types or specific non-motorized categories
        WHEN ENGINE_POWER_TYPE IN ('Electric/Battery') THEN 3.00
        WHEN ENGINE_POWER_TYPE IN ('Unpowered', 'Pneumatic') THEN 0

        WHEN CATEGORY ILIKE '%TRAILER%' OR CATEGORY ILIKE '%ATTACHMENT%' THEN 0.00
        WHEN CATEGORY ILIKE '%P.P.E.%' OR CATEGORY ILIKE '%TRAFFIC CONTROL%' THEN 0.00

        -- Rule 2: Heavy Earthmoving Equipment
        WHEN CATEGORY ILIKE '%EXCAVATOR%' THEN 4.50
        WHEN CATEGORY ILIKE '%DOZER%' THEN 5.00
        WHEN CATEGORY ILIKE '%LOADER%' OR CATEGORY ILIKE '%BACKHOE%' THEN 2.50
        WHEN CATEGORY ILIKE '%SKID STEER%' THEN 2.00

        -- Rule 3: Trucks and Transport
        WHEN CATEGORY ILIKE '%DUMP TRUCK%' OR CATEGORY ILIKE '%WATER TRUCK%' THEN 3.50
        WHEN CATEGORY ILIKE '%SEMI TRUCK%' THEN 3.00
        WHEN CATEGORY ILIKE '%SERVICE TRUCK%' OR CATEGORY ILIKE '%PICK UP%' THEN 2.00
        WHEN CATEGORY ILIKE '%VAN%' OR CATEGORY ILIKE '%SUV%' THEN 1.50

        -- Rule 4: Material Handling and Lifts
        WHEN CATEGORY ILIKE '%TELEHANDLER%' THEN 1.75
        WHEN CATEGORY ILIKE '%FORKLIFT%' THEN 1.25
        WHEN CATEGORY ILIKE '%BOOM LIFT%' OR CATEGORY ILIKE '%SCISSOR LIFT%' THEN 0.75
        WHEN CATEGORY ILIKE '%AERIAL WORK%' OR CATEGORY ILIKE '%MAN LIFT%' THEN 0.75

        -- Rule 5: Power and Support Equipment
        WHEN CATEGORY ILIKE '%GENERATOR%' OR CATEGORY ILIKE '%POWER SOLUTIONS%' THEN 2.00
        WHEN CATEGORY ILIKE '%AIR COMPRESSOR%' THEN 1.50
        WHEN CATEGORY ILIKE '%WELDER%' THEN 0.60
        WHEN CATEGORY ILIKE '%PUMP%' THEN 1.00

        -- Rule 6: Lighting and Climate
        WHEN CATEGORY ILIKE '%LIGHT PLANT%' OR CATEGORY ILIKE '%LIGHT TOWER%' THEN 0.50
        WHEN CATEGORY ILIKE '%HEATER%' OR CATEGORY ILIKE '%AIR CONDITIONER%' THEN 1.20

        -- Rule 7: Compaction and Ground Prep
        WHEN CATEGORY ILIKE '%ROLLER%' OR CATEGORY ILIKE '%RAMMER%' THEN 1.50
        WHEN CATEGORY ILIKE '%SWEEPER%' OR CATEGORY ILIKE '%SCRUBBER%' THEN 1.00

        -- Rule 8: Default fallback based on Engine Power Type
        WHEN ENGINE_POWER_TYPE = 'Diesel' THEN 2.00
        WHEN ENGINE_POWER_TYPE = 'Gasoline' THEN 1.50
        WHEN ENGINE_POWER_TYPE = 'Propane' THEN 1.00
        WHEN ENGINE_POWER_TYPE = 'Fuel Oil (see heaters)' THEN 1.20

        ELSE 0.00
    END as burn_rate_gph
, case
        when t.fuel_data_source is not null then t.fuel_data_source
        when t.estimated_gallons_per_day is not null then 'Model Estimate'
        else 'Manual Buckets'
end as fuel_data_source
from temp t
    ;;
  }



  dimension: primary_key {
    primary_key: yes
    type: string
    sql:  ${TABLE}."PRIMARY_KEY" ;;
  }

  measure: count {
    type: count
    drill_fields: [run_time_detail*]
  }

  dimension: day {
    type: date
    sql: ${TABLE}."DAY" ;;
  }

  dimension: day_name {
    type: string
    sql: ${TABLE}."DAY_NAME" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: days_on_rent {
    type: number
    sql: ${TABLE}."DAYS_ON_RENT" ;;
  }

  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  dimension: phase_job_id {
    type: number
    sql: ${TABLE}."PHASE_JOB_ID" ;;
  }

  dimension: phase_job_name {
    type: string
    sql: ${TABLE}."PHASE_JOB_NAME" ;;
  }

  # dimension: group_name {
  #   type: string
  #   sql: ${TABLE}."GROUP_NAME" ;;
  # }

  dimension: asset_class {
    label: "Class"
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

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: rental_company_name {
    type: string
    sql: ${TABLE}."RENTAL_COMPANY_NAME" ;;
  }

  dimension: sub_renting_company {
    type: string
    sql: ${TABLE}."SUB_RENTING_COMPANY" ;;
  }

  dimension: sub_renting_contact {
    type: string
    sql: ${TABLE}."SUB_RENTING_CONTACT" ;;
  }

  dimension: gallons_used_per_day {
    type: number
    sql: ${TABLE}."GALLONS_USED_PER_DAY" ;;
  }

  dimension: idle_gallons_per_day {
    type: number
    sql: ${TABLE}."IDLE_GALLONS_PER_DAY" ;;
  }

  dimension: engine_power_type {
    label: "Engine Type"
    type: string
    sql: ${TABLE}."ENGINE_POWER_TYPE" ;;
  }

  dimension: kg_co2_per_gallon {
    type: number
    sql: ${TABLE}."KG_CO2_PER_GALLON" ;;
  }
  dimension: emissions_per_day {
    type: number
    sql: ${TABLE}."EMISSIONS_PER_DAY" ;;
  }
  dimension: idle_emissions_per_day {
    type: number
    sql: ${TABLE}."IDLE_EMISSIONS_PER_DAY" ;;
  }

  dimension: emissions_calculation_type {
    label: "Emissions Type"
    type: string
    sql: ${TABLE}."EMISSIONS_CALCULATION_TYPE" ;;
  }

  measure: emissions_per_day_sum {
    label: "Emissions"
    group_label: "Emissions"
    type: sum
    sql: ${emissions_per_day} ;;
    html:  {{rendered_value}} kg of CO2 ;;
    value_format_name: decimal_2
  }

  measure: idle_emissions_per_day_sum {
    label: "Idle Emissions"
    group_label: "Emissions"
    type: sum
    sql: ${idle_emissions_per_day} ;;
    html:  {{rendered_value}} kg of CO2 ;;
    value_format_name: decimal_2
  }


  dimension: serial_number_vin {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_VIN" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: ownership {
    type: string
    sql: ${TABLE}."OWNERSHIP" ;;
  }

  dimension: tracker_grouping {
    type: string
    sql: ${TABLE}."tracker_grouping" ;;
  }

  dimension: driver_name {
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }

  dimension: driver_vehicle_type{
    label: "Driver"
    type: string
    sql: CASE WHEN ${asset_type} = 'Vehicle' --vehicle asset type
         THEN COALESCE(${driver_name},'')
         ELSE ''
         END;;
  }

  dimension: possible_utilization_days {
    type: number
    sql: ${TABLE}."POSSIBLE_UTILIZATION_DAYS_CALCED" ;;
  }

  # dimension: rental_status {
  #   type: string
  #   sql: ${TABLE}."RENTAL_STATUS" ;;
  # }

  dimension: used_unused_designation {
    type: string
    sql: ${TABLE}."USED_UNUSED_DESIGNATION" ;;
  }

  dimension: day_used {
    type: number
    sql: ${TABLE}."DAY_USED" ;;
  }

  dimension:  day_used_mod {
    type: number
    sql: ${TABLE}."DAY_USED_MOD" ;;
  }

  # dimension: weekend_flag {
  #   type: number
  #   sql: ${TABLE}."WEEKEND_FLAG" ;;
  # }

  dimension: run_time {
    type: number
    sql: ${TABLE}."RUN_TIME" ;;
  }

  dimension: idle_time {
    type: number
    sql: ${TABLE}."IDLE_TIME" ;;
  }

  dimension: miles_driven {
    type: number
    sql: ${TABLE}."MILES_DRIVEN" ;;
  }

  dimension: on_time {
    type: number
    sql: ${TABLE}."ON_TIME" ;;
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

  dimension: estimated_gallons_per_day {
    type: number
    sql: ${TABLE}."ESTIMATED_GALLONS_PER_DAY" ;;
  }

  dimension: burn_rate_type {
    type: string
    sql: ${TABLE}."BURN_RATE_TYPE" ;;
  }

  dimension: fuel_data_source {
    type: string
    sql: ${TABLE}."FUEL_DATA_SOURCE" ;;
  }

  dimension_group: last_checkin_timestamp {
    type: time
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
  }

  dimension: address {
    label: "Last Address"
    type: string
    sql: ${TABLE}."ADDRESS_MAX" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

  dimension: geofence {
    label: "Last Geofence"
    type: string
    sql: ${TABLE}."GEOFENCE" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

  dimension_group: last_checkin_timestamp_end_date {
    group_label: "End Date"
    type: time
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP_END_DATE" ;;
  }

  dimension: address_end_date {
    group_label: "End Date"
    label: "Last Address"
    type: string
    sql: ${TABLE}."ADDRESS_MAX" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

  dimension: geofence_end_date {
    group_label: "End Date"
    label: "Last Geofence"
    type: string
    sql: ${TABLE}."GEOFENCE_MAX" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

  dimension: location_address {
    label: "Location"
    type: string
    sql: ${address} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

  dimension: location_address_end_date {
    group_label: "End Date"
    label: "Location"
    type: string
    sql: coalesce(${address_end_date},${geofence_end_date}) ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

  parameter: show_last_location_options {
    type: string
    allowed_value: { value: "Default"}
    allowed_value: { value: "Geofence"}
    allowed_value: { value: "Address"}
  }

  dimension: dynamic_last_location {
    label_from_parameter: show_last_location_options
    sql:{% if show_last_location_options._parameter_value == "'Default'" %}
      ${location_address}
    {% elsif show_last_location_options._parameter_value == "'Geofence'" %}
      ${geofence}
    {% elsif show_last_location_options._parameter_value == "'Address'" %}
      ${address}
    {% else %}
      NULL
    {% endif %} ;;
  }

  dimension: dynamic_last_location_end_date {
    label_from_parameter: show_last_location_options
    sql:{% if show_last_location_options._parameter_value == "'Default'" %}
      ${location_address_end_date}
    {% elsif show_last_location_options._parameter_value == "'Geofence'" %}
      ${geofence_end_date}
    {% elsif show_last_location_options._parameter_value == "'Address'" %}
      ${address_end_date}
    {% else %}
      NULL
    {% endif %} ;;
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
  }


  dimension: day_formatted {
    type: date
    group_label: "HTML Passed Date Format" label: "Date"
    sql: ${day} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: date_format_concat {
    type: string
    sql: to_varchar(${day}::date, 'mon dd, yyyy') ;;
  }

  dimension_group: last_checkin_timestamp_raw {
    type: time
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
  }

  dimension: last_checkin_timestamp_formatted {
    group_label: "HTML Format"
    label: "Last Check In"
    type: date_time
    sql: convert_timezone(('{{ _user_attributes['user_timezone'] }}'),${last_checkin_timestamp_raw}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
  }

  dimension: last_checkin_timestamp_formatted_end_date {
    group_label: "End Date"
    label: "Last Check In"
    type: date_time
    sql: convert_timezone(('{{ _user_attributes['user_timezone'] }}'),${last_checkin_timestamp_end_date_raw}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
  }

  dimension: date_with_name {
    type: string
    sql: concat(${date_format_concat}, ' ', '(', ${day_name}, ')') ;;
  }

  dimension: asset_custom_name_to_asset_info {
    group_label: "Link to T3"
    label: "Asset"
    type: string
    sql: ${asset};;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
  }

  measure: dummy {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [asset_details*]
  }

  dimension: view_asset_details {
    type: string
    sql: ${asset} ;;
    # fleet_utilization_asset_details_drilldown
    html: <a href="#drillmenu" target="_self"><font color="#0063f3">View Asset Detail <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    # drill_fields: [asset_details*]
    link: {
      label: "View Asset Details"
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
      \"header_font_size\":12,
      \"rows_font_size\":12,
      \"conditional_formatting_include_totals\":false,
      \"conditional_formatting_include_nulls\":false,
      \"type\":\"looker_grid\",
      \"defaults_version\":1,
      \"series_types\":{}}' %}

      {% assign dynamic_fields= '[]' %}

      {{dummy._link}}&f&vis={{vis | encode_uri}}&dynamic_fields={{dynamic_fields | encode_uri}}"
    }
  }

  set: asset_details {
    fields: [asset_custom_name_to_asset_info, make_and_model, category, asset_class, fleet_utilization_asset_details_drilldown.hours, fleet_utilization_asset_details_drilldown.odometer,
      fleet_utilization_asset_details_drilldown.location_geofence, fleet_utilization_asset_details_drilldown.location_address, fleet_utilization_asset_details_drilldown.last_location_timestamp_formatted,
      fleet_utilization_asset_details_drilldown.last_checkin_timestamp_formatted]
  }

  # measure: total_utilization_days {
  #   type: sum
  #   sql: ${possible_utilization_days} ;;
  # }

  dimension: drop_off_zip_code {
    type: string
    sql: ${TABLE}.drop_off_zip_code ;;
    description: "Zip code in which the asset was dropped off for use."
  }

  dimension: drop_off_state {
    type: string
    sql: ${TABLE}.drop_off_state ;;
    description: "State in which the asset was dropped off for use."
  }

  dimension: archived_status {
    type: string
    sql: CASE WHEN ${TABLE}.archived_status = 'true' THEN 'Archived' ELSE 'Active' END ;;
    description: "Determines if an asset has been archived from the fleet."
  }

  dimension: epa_subregion_code {
    type: string
    sql: ${TABLE}.subregion_code ;;
    group_label: "EPA Subregion"
    description: "Primary EPA subregion acronym (e.g., RFCW, SRSO, ERCT)"
  }

  dimension: epa_subregion_name {
    type: string
    sql: ${TABLE}.subregion_name ;;
    group_label: "EPA Subregion"
    description: "Full name of the primary EPA subregion (e.g., 'RFC West', 'SERC South')"
  }

  dimension: epa_subregion_code_2 {
    type: string
    sql: ${TABLE}.subregion_code_2 ;;
    group_label: "EPA Subregion"
    description: "Secondary EPA subregion acronym, when a zip code spans multiple subregions"
  }

  dimension: epa_subregion_name_2 {
    type: string
    sql: ${TABLE}.subregion_name_2 ;;
    group_label: "EPA Subregion"
    description: "Full name of the secondary EPA subregion"
  }

  dimension: epa_subregion_code_3 {
    type: string
    sql: ${TABLE}.subregion_code_3 ;;
    group_label: "EPA Subregion"
    description: "Tertiary EPA subregion acronym, when a zip code spans three subregions"
  }

  dimension: epa_subregion_name_3 {
    type: string
    sql: ${TABLE}.subregion_name_3 ;;
    group_label: "EPA Subregion"
    description: "Full name of the tertiary EPA subregion"
  }

  dimension: has_multiple_subregions {
    type: yesno
    sql: ${TABLE}.has_multiple_subregions ;;
    group_label: "EPA Subregion"
    description: "Whether this zip code spans more than one EPA subregion"
  }

  measure: total_utilization_days {
    type: count_distinct
    sql: ${day} ;;
  }

  measure: dummy_run_time {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [run_time_detail*]
  }

  measure: dummy_idle_time {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [idle_time_detail*]
  }

  measure: dummy_miles_driven {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [miles_driven_detail*]
  }

  measure: dummy_on_time {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [on_time_detail*]
  }

  measure: hours_end {
    label: "Hours"
    type: max
    sql: ${hours} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a> ;;
    # drill_fields: [detail*]
    value_format_name: decimal_1
  }

  measure: odometer_end {
    label: "Odometer"
    type: max
    sql: ${odometer} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} mi.</a> ;;
    # drill_fields: [detail*]
    value_format_name: decimal_1
  }

  measure: last_location_end {
    label: "Last Location Test"
    required_fields: [dynamic_last_location]
    type: string
    sql: ${dynamic_last_location} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}}</a> ;;
    # drill_fields: [detail*]
    value_format_name: decimal_2
  }

  measure: total_run_time_no_icon {
    type: string
    sql: coalesce(FLOOR(sum(${run_time})) || 'h ' ||  ROUND(((sum(${run_time}) - FLOOR(sum(${run_time}))) * 60)) || 'm', '0h 0m') ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} </a> ;;
    # drill_fields: [detail*]
    # value_format_name: decimal_2
  }

  measure: total_run_time_no_icon_calc {
    type: sum
    sql: ${run_time} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a> ;;
    # drill_fields: [detail*]
    value_format_name: decimal_2
  }

  #CONCAT(FLOOR(${hrs_in_geofence}), 'h ', ROUND(((${hrs_in_geofence} - FLOOR(${hrs_in_geofence})) * 60)), 'm')

  measure: total_run_time_old {
    type: sum
    sql: ${run_time} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View Run Time for Asset"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis= '{\"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
      \"show_view_names\":false,
      \"show_y_axis_labels\":true,
      \"show_y_axis_ticks\":true,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":true,
      \"show_x_axis_ticks\":true,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"limit_displayed_rows\":false,
      \"legend_position\":\"center\",
      \"point_style\":\"none\",
      \"show_value_labels\":false,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":false,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"type\":\"looker_column\",
      \"defaults_version\":1}' %}

      {{dummy_run_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    value_format_name: decimal_2
  }

  measure: total_run_time_calc {
    # view_label: "Total Run Time"
    type: sum
    sql: ${run_time} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View Run Time for Asset"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis= '{\"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
      \"show_view_names\":false,
      \"show_y_axis_labels\":true,
      \"show_y_axis_ticks\":true,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":true,
      \"show_x_axis_ticks\":true,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"limit_displayed_rows\":false,
      \"legend_position\":\"center\",
      \"point_style\":\"none\",
      \"show_value_labels\":false,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":false,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"type\":\"looker_column\",
      \"defaults_version\":1}' %}

      {{dummy_run_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    value_format_name: decimal_0
  }

  measure: total_run_time {
    type: string
    sql: coalesce(FLOOR(sum(${run_time})) || 'h ' ||  ROUND(((sum(${run_time}) - FLOOR(sum(${run_time}))) * 60)) || 'm', '0h 0m') ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View Run Time for Asset"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis= '{\"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
      \"show_view_names\":false,
      \"show_y_axis_labels\":true,
      \"show_y_axis_ticks\":true,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":true,
      \"show_x_axis_ticks\":true,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"limit_displayed_rows\":false,
      \"legend_position\":\"center\",
      \"point_style\":\"none\",
      \"show_value_labels\":false,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":false,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"type\":\"looker_column\",
      \"defaults_version\":1}' %}

      {{dummy_run_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    #value_format_name: decimal_2
  }

  measure: total_idle_time_no_icon_calc {
    type: sum
    sql: ${idle_time} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a> ;;
    # drill_fields: [detail*]
    value_format_name: decimal_2
  }

  measure: total_idle_time_no_icon {
    type: string
    sql: coalesce(FLOOR(sum(${idle_time})) || 'h ' ||  ROUND(((sum(${idle_time}) - FLOOR(sum(${idle_time}))) * 60)) || 'm', '0h 0m') ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} </a> ;;
    # drill_fields: [detail*]
    # value_format_name: decimal_2
  }

  measure: total_idle_time {
    type: string
    sql: coalesce(FLOOR(sum(${idle_time})) || 'h ' ||  ROUND(((sum(${idle_time}) - FLOOR(sum(${idle_time}))) * 60)) || 'm', '0h 0m') ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View Idle Time for Asset"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis= '{\"x_axis_gridlines\":false,
            \"y_axis_gridlines\":true,
            \"show_view_names\":false,
            \"show_y_axis_labels\":true,
            \"show_y_axis_ticks\":true,
            \"y_axis_tick_density\":\"default\",
            \"y_axis_tick_density_custom\":5,
            \"show_x_axis_label\":true,
            \"show_x_axis_ticks\":true,
            \"y_axis_scale_mode\":\"linear\",
            \"x_axis_reversed\":false,
            \"y_axis_reversed\":false,
            \"plot_size_by_field\":false,
            \"trellis\":\"\",
            \"stacking\":\"\",
            \"limit_displayed_rows\":false,
            \"legend_position\":\"center\",
            \"point_style\":\"none\",
            \"show_value_labels\":false,
            \"label_density\":25,
            \"x_axis_scale\":\"auto\",
            \"y_axis_combined\":true,
            \"ordering\":\"none\",
            \"show_null_labels\":false,
            \"show_totals_labels\":false,
            \"show_silhouette\":false,
            \"totals_color\":\"#808080\",
            \"type\":\"looker_column\",
            \"defaults_version\":1}' %}

            {{dummy_idle_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    # value_format_name: decimal_2
  }

  measure: total_idle_time_calc {
    #view_label: "Total Idle Time"
    type: sum
    sql: round(${idle_time}) ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View Idle Time for Asset"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis= '{\"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
      \"show_view_names\":false,
      \"show_y_axis_labels\":true,
      \"show_y_axis_ticks\":true,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":true,
      \"show_x_axis_ticks\":true,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"limit_displayed_rows\":false,
      \"legend_position\":\"center\",
      \"point_style\":\"none\",
      \"show_value_labels\":false,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":false,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"type\":\"looker_column\",
      \"defaults_version\":1}' %}

      {{dummy_idle_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    value_format_name: decimal_0
  }

  measure: total_miles_driven_no_icon {
    type: sum
    sql: ${miles_driven} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} mi.</a> ;;
    # drill_fields: [detail*]
    value_format_name: decimal_2
  }

  measure: total_miles_driven {
    type: sum
    sql: ${miles_driven} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} mi.
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View Miles Driven for Asset"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis= '{\"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
      \"show_view_names\":false,
      \"show_y_axis_labels\":true,
      \"show_y_axis_ticks\":true,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":true,
      \"show_x_axis_ticks\":true,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"limit_displayed_rows\":false,
      \"legend_position\":\"center\",
      \"point_style\":\"none\",
      \"show_value_labels\":false,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":false,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"type\":\"looker_column\",
      \"defaults_version\":1}' %}

      {{dummy_miles_driven._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    value_format_name: decimal_2
  }

  measure: total_on_time_no_icon_calc {
    type: sum
    sql: ${on_time} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a> ;;
    # drill_fields: [detail*]
    value_format_name: decimal_2
  }

  measure: total_on_time_no_icon {
    type: string
    sql: coalesce(FLOOR(sum(${on_time})) || 'h ' ||  ROUND(((sum(${on_time}) - FLOOR(sum(${on_time}))) * 60)) || 'm', '0h 0m') ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} </a> ;;
    # drill_fields: [detail*]
    # value_format_name: decimal_2
  }

  measure: total_on_time {
    type: string
    sql: coalesce(FLOOR(sum(${on_time})) || 'h ' ||  ROUND(((sum(${on_time}) - FLOOR(sum(${on_time}))) * 60)) || 'm', '0h 0m') ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View On Time for Asset"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis= '{\"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
      \"show_view_names\":false,
      \"show_y_axis_labels\":true,
      \"show_y_axis_ticks\":true,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":true,
      \"show_x_axis_ticks\":true,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"limit_displayed_rows\":false,
      \"legend_position\":\"center\",
      \"point_style\":\"none\",
      \"show_value_labels\":false,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":false,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"type\":\"looker_column\",
      \"defaults_version\":1}' %}

      {{dummy_on_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    value_format_name: decimal_2
  }

  measure: total_run_time_drill_down {
    group_label: "Drill Downs"
    label: "Total Run Time"
    type: sum
    sql: ${run_time} ;;
    html: {{rendered_value}} hrs. ;;
    drill_fields: [run_time_detail*]
    value_format_name: decimal_1
  }

  measure: total_idle_time_drill_down {
    group_label: "Drill Downs"
    label: "Total Idle Time"
    type: sum
    sql: ${idle_time} ;;
    html: {{rendered_value}} hrs. ;;
    drill_fields: [idle_time_detail*]
    value_format_name: decimal_0
  }

  measure: total_miles_driven_drill_down {
    group_label: "Drill Downs"
    label: "Total Miles Driven"
    type: sum
    sql: ${miles_driven} ;;
    html: {{rendered_value}} mi. ;;
    drill_fields: [miles_driven_detail*]
    value_format_name: decimal_0
  }

  measure: total_on_time_drill_down {
    group_label: "Drill Downs"
    label: "Total On Time"
    type: sum
    sql: ${on_time} ;;
    html: {{rendered_value}} hrs. ;;
    drill_fields: [on_time_detail*]
    value_format_name: decimal_0
  }

  measure: total_days_used {
    type: number
    sql: ceil(sum(${day_used_mod})) ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View by Day Breakdown of Asset"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis= '{\"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
      \"show_view_names\":false,
      \"show_y_axis_labels\":true,
      \"show_y_axis_ticks\":true,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":true,
      \"show_x_axis_ticks\":true,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"limit_displayed_rows\":false,
      \"legend_position\":\"center\",
      \"point_style\":\"none\",
      \"show_value_labels\":false,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":false,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"type\":\"looker_column\",
      \"defaults_version\":1}' %}
      {{dummy_run_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
  }

  measure: days_unused {
    type: number
    required_fields: [total_utilization_days]
    sql: coalesce(${total_utilization_days} - ${total_days_used},0) ;;
  }

  dimension: utilized_during_date {
    type: string
    sql: ${day_used_mod} ;;
    html:
      {% if value > 0 %}
      <font color="#00CB86">✔</font>
      {% elsif value < 0 %}
      <font color="#DA344D">✘</font>
      {% else %}
      <font color="black">-</font>
      {% endif %} ;;
  }

  measure: total_assets {
    type: count_distinct
    sql: ${asset_id} ;;
  }

  # measure: unused_asset_count {
  #   type: count_distinct
  #   sql: ${asset_id} ;;
  #   filters: [used_unused_designation: "unused"]
  # }

  measure: used_asset_count {
    type: count_distinct
    sql: CASE WHEN ${on_time} > 0 THEN ${asset_id} ELSE NULL END ;;
  }

  measure: unused_asset_count {
    type: number
    sql: ${total_assets} - ${used_asset_count} ;;
  }

  dimension: asset_summary {
    # group_label: "Asset Summary"
    # label: "Work Order Information"
    type: string
    sql: 'Asset Summary' ;;
    html:
    <br/>
    <table>
    <tr>
      <td width="200px"><h4>Total Assets</h4></td>
      <td width="125px"><h4>{{total_assets._rendered_value}}</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Number of Used Assets:</h4></td>
      <td width="125px"><h4>{{used_asset_count._rendered_value}}</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Number of Unused Assets:</h4></td>
      <td width="125px"><h4>{{unused_asset_count._rendered_value}}</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total Run Time:</h4></td>
      <td width="125px"><h4>{{total_run_time_drill_down._rendered_value}} hrs.</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total Idle Time:</h4></td>
      <td width="125px"><h4>{{total_idle_time_drill_down._rendered_value}} hrs.</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total On Time:</h4></td>
      <td width="125px"><h4>{{total_on_time_drill_down._rendered_value}} hrs.</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total Miles Driven:</h4></td>
      <td width="125px"><h4>{{total_miles_driven_drill_down._rendered_value}} mi.</h4></td>
    </tr>
    <tr>
      <td></td>
      <td></td>
    </tr>
    </table>
      ;;
  }

  dimension: make_and_model {
    type: string
    sql: concat(${make},' ',${model}) ;;
  }

  filter: date_filter {
    type: date_time
  }

  parameter: show_weekends {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }

  parameter: show_out_of_lock_assets {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }

  parameter: show_assets_no_contact_over_72_hrs {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }

  parameter: show_in_progress_trips {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }

  parameter: utilization_hours {
    type: string
    allowed_value: { value: "1 Hour"}
    allowed_value: { value: "2 Hours"}
    allowed_value: { value: "3 Hours"}
    allowed_value: { value: "4 Hours"}
    allowed_value: { value: "5 Hours"}
    allowed_value: { value: "6 Hours"}
    allowed_value: { value: "7 Hours"}
    allowed_value: { value: "8 Hours"}
    allowed_value: { value: "10 Hours"}
    allowed_value: { value: "12 Hours"}
    allowed_value: { value: "24 Hours"}
  }

  measure: dynamic_utilization_percentage {
    label_from_parameter: utilization_hours
    sql:{% if utilization_hours._parameter_value == "'8 Hours'" %}
      round(${utilization_percentage_eight_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'10 Hours'" %}
      round(${utilization_percentage_ten_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'12 Hours'" %}
      round(${utilization_percentage_twelve_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'24 Hours'" %}
      round(${utilization_percentage_twenty_four_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'1 Hour'" %}
      round(${utilization_percentage_one_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'2 Hours'" %}
      round(${utilization_percentage_two_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'3 Hours'" %}
      round(${utilization_percentage_three_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'4 Hours'" %}
      round(${utilization_percentage_four_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'5 Hours'" %}
      round(${utilization_percentage_five_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'6 Hours'" %}
      round(${utilization_percentage_six_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'7 Hours'" %}
      round(${utilization_percentage_seven_hours}*100,1)
    {% else %}
      NULL
    {% endif %} ;;
    html: {{value}}% ;;
    # value_format_name: percent_1
  }

  measure: utilization_percentage_one_hours {
    type: number
    sql: coalesce(${total_run_time_calc}/(1*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_two_hours {
    type: number
    sql: coalesce(${total_run_time_calc}/(2*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_three_hours {
    type: number
    sql: coalesce(${total_run_time_calc}/(3*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_four_hours {
    type: number
    sql: coalesce(${total_run_time_calc}/(4*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_five_hours {
    type: number
    sql: coalesce(${total_run_time_calc}/(5*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_six_hours {
    type: number
    sql: coalesce(${total_run_time_calc}/(6*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_seven_hours {
    type: number
    sql: coalesce(${total_run_time_calc}/(7*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_eight_hours {
    type: number
    sql: coalesce(${total_run_time_calc}/(8*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_ten_hours {
    type: number
    sql: coalesce(${total_run_time_calc}/(10*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_twelve_hours {
    type: number
    sql: coalesce(${total_run_time_calc}/(12*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_twenty_four_hours {
    type: number
    sql: coalesce(${total_run_time_calc}/(24*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  ###########################################################

  dimension: total_available_assets {
    group_label: "FMD - Fleet Management Dashboard"
    type: number
    sql: ${TABLE}."TOTAL_AVAILABLE_ASSETS" ;;
  }
  dimension: week_flag {
    group_label: "FMD - Fleet Management Dashboard"
    type: number
    sql: CASE
          when ${day} <= DATEADD(day, -1, CURRENT_DATE()) and ${day} >= DATEADD(day, -7, CURRENT_DATE())
          then 1
          when ${day} <= DATEADD(day, -8, CURRENT_DATE()) and ${day} >= DATEADD(day, -14, CURRENT_DATE())
          then 2
          else 0
        END;;
  }
  measure: current_week_selected_on_time {
    group_label: "FMD - Fleet Management Dashboard"
    label: "Total On Time"
    type: sum
    sql: coalesce(round(${on_time},0),0) ;;
    value_format_name: decimal_0
    filters: [week_flag: "1"]
  }

  measure: current_week_selected_available_assets {
    group_label: "FMD - Fleet Management Dashboard"
    label: "Total Available Assets"
    type: sum
    sql: ${total_available_assets};;
    filters: [week_flag: "1"]
  }

  measure: current_week_daily_utilization_kpi_eight_hours {
    group_label: "FMD - Fleet Management Dashboard"
    type: number
    sql:
    ((${current_week_selected_on_time})/(8))/(case when (${current_week_selected_available_assets}) = 0 then null else (${current_week_selected_available_assets}) end)
    ;;
    value_format_name: percent_1
  }

  measure: prev_week_selected_on_time {
    group_label: "FMD - Fleet Management Dashboard"
    label: "Total On Time"
    type: sum
    sql: coalesce(round(${on_time},0),0) ;;
    value_format_name: decimal_0
    filters: [week_flag: "2"]
  }

  measure: prev_week_selected_available_assets {
    group_label: "FMD - Fleet Management Dashboard"
    label: "Total Available Assets"
    type: sum
    sql: ${total_available_assets};;
    filters: [week_flag: "2"]
  }

  measure: prev_week_daily_utilization_kpi_eight_hours {
    group_label: "FMD - Fleet Management Dashboard"
    type: number
    sql:
    ((${prev_week_selected_on_time})/(8))/(case when (${prev_week_selected_available_assets}) = 0 then null else (${prev_week_selected_available_assets}) end)
    ;;
    value_format_name: percent_1
  }

  measure: week_over_week_change {
    group_label: "FMD - Fleet Management Dashboard"
    type: number
    sql: ${current_week_daily_utilization_kpi_eight_hours} - ${prev_week_daily_utilization_kpi_eight_hours};;
    value_format_name: percent_1
  }

  ###########################################################

  measure: total_run_time_date_range {
    group_label: "Run Time"
    label: "Total Run Time"
    type: sum
    sql: ${run_time} ;;
    html:
    {% if value >= 1000000 %}
    <a href="#drillmenu" target="_self">{{ value | divided_by: 1000000.0 | round: 1 }}M hrs. <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    {% elsif value >= 1000 %}
    <a href="#drillmenu" target="_self">{{ value | divided_by: 1000.0 | round: 1 }}K hrs. <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    {% else %}
    <a href="#drillmenu" target="_self">{{total_run_time_no_icon._rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    {% endif %} ;;
    # drill_fields: [run_time_detail*]
    value_format_name: decimal_1
    link: {
      label: "View Run Time for Asset"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis= '{\"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
      \"show_view_names\":false,
      \"show_y_axis_labels\":true,
      \"show_y_axis_ticks\":true,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":true,
      \"show_x_axis_ticks\":true,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"limit_displayed_rows\":false,
      \"legend_position\":\"center\",
      \"point_style\":\"none\",
      \"show_value_labels\":false,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":false,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"type\":\"looker_column\",
      \"defaults_version\":1}' %}

      {{dummy_run_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
  }

  measure: total_idle_time_date_range {
    group_label: "Idle Time"
    label: "Total Idle Time"
    type: sum
    sql: ${idle_time} ;;
    html:
    {% if value >= 1000000 %}
    <a href="#drillmenu" target="_self">{{ value | divided_by: 1000000.0 | round: 1 }}M hrs. <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    {% elsif value >= 1000 %}
    <a href="#drillmenu" target="_self">{{ value | divided_by: 1000.0 | round: 1 }}K hrs. <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    {% else %}
    <a href="#drillmenu" target="_self">{{total_idle_time_no_icon._rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    {% endif %} ;;
    # drill_fields: [idle_time_detail*]
    value_format_name: decimal_1
    link: {
      label: "View Idle Time for Asset"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis= '{\"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
      \"show_view_names\":false,
      \"show_y_axis_labels\":true,
      \"show_y_axis_ticks\":true,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":true,
      \"show_x_axis_ticks\":true,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"limit_displayed_rows\":false,
      \"legend_position\":\"center\",
      \"point_style\":\"none\",
      \"show_value_labels\":false,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":false,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"type\":\"looker_column\",
      \"defaults_version\":1}' %}

      {{dummy_idle_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
  }

  measure: total_on_time_date_range {
    group_label: "On Time"
    label: "Total On Time"
    type: sum
    sql: ${on_time} ;;
    html:
    {% if value >= 1000000 %}
    <a href="#drillmenu" target="_self">{{ value | divided_by: 1000000.0 | round: 1 }}M hrs. <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    {% elsif value >= 1000 %}
    <a href="#drillmenu" target="_self">{{ value | divided_by: 1000.0 | round: 1 }}K hrs. <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    {% else %}
    <a href="#drillmenu" target="_self">{{total_on_time._rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    {% endif %} ;;
    # drill_fields: [on_time_detail*]
    value_format_name: decimal_1
    link: {
      label: "View On Time for Asset"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis= '{\"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
      \"show_view_names\":false,
      \"show_y_axis_labels\":true,
      \"show_y_axis_ticks\":true,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":true,
      \"show_x_axis_ticks\":true,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"limit_displayed_rows\":false,
      \"legend_position\":\"center\",
      \"point_style\":\"none\",
      \"show_value_labels\":false,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":false,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"type\":\"looker_column\",
      \"defaults_version\":1}' %}

      {{dummy_on_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
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

  measure: total_idle_time_by_day {
    group_label: "Idle Time No Icon"
    label: "Total Idle Time"
    type: sum
    sql: ${idle_time} ;;
    html: {{total_idle_time_no_icon._rendered_value}} ;;
    # drill_fields: [idle_time_detail*]
    value_format_name: decimal_1
  }

  measure: total_on_time_by_day {
    group_label: "On Time No Icon"
    label: "Total On Time"
    type: sum
    sql: ${on_time} ;;
    html: {{total_on_time._rendered_value}} ;;
    # drill_fields: [on_time_detail*]
    value_format_name: decimal_1
  }
# ---- Emissions Reporting Dimensions ----

  dimension: year_val {
    group_label: "Emissions"
    label: "Year"
    description: "Calendar year derived from the activity date (DAY). Used for time-based aggregation of emissions and fuel usage."
    type: string
    sql: YEAR(${TABLE}."DAY") ;;
    value_format: "0"
  }

  dimension: quarter_val {
    group_label: "Emissions"
    label: "Quarter"
    description: "Calendar quarter (1–4) derived from the activity date (DAY)."
    type: number
    sql: QUARTER(${TABLE}."DAY") ;;
  }

  dimension: year_quarter {
    group_label: "Emissions"
    label: "Year-Quarter"
    description: "Combined year and quarter in YYYY-Q# format (e.g., 2025-Q1). Useful for quarterly reporting and trend analysis."
    type: string
    sql: CONCAT(YEAR(${TABLE}."DAY"), '-Q', QUARTER(${TABLE}."DAY")) ;;
    order_by_field: year_quarter_sort
  }

  dimension: year_quarter_sort {
    hidden: yes
    description: "Numeric sort key for Year-Quarter to ensure proper chronological ordering."
    type: number
    sql: YEAR(${TABLE}."DAY") * 10 + QUARTER(${TABLE}."DAY") ;;
  }

  dimension: has_gallons_reported {
    group_label: "Emissions"
    label: "Reporting Gallons"
    description: "Indicates whether an asset reported any fuel usage (used or idle gallons) on a given day."
    type: yesno
    sql: COALESCE(${TABLE}."GALLONS_USED_PER_DAY", 0) > 0
      OR COALESCE(${TABLE}."IDLE_GALLONS_PER_DAY", 0) > 0 ;;
  }

# ---- Emissions Reporting Measures ----

  measure: assets_reporting_gallons {
    group_label: "Emissions"
    label: "Assets Reporting Gallons"
    description: "Count of distinct assets that reported any fuel usage (used or idle gallons) during the selected time period."
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [has_gallons_reported: "Yes"]
  }

  measure: pct_assets_reporting_gallons {
    group_label: "Emissions"
    label: "% Assets Reporting Gallons"
    description: "Percentage of total assets that reported fuel usage (used or idle gallons). Calculated as reporting assets divided by total assets."
    type: number
    sql: ROUND(100.0 * ${assets_reporting_gallons} / NULLIF(${total_assets}, 0), 2) ;;
    value_format: "0.00\"%\""
  }

  measure: total_gallons_used {
    group_label: "Emissions"
    label: "Total Gallons Used"
    description: "Total fuel consumed during active asset operation, summed across the selected time period."
    type: sum
    sql: COALESCE(${TABLE}."GALLONS_USED_PER_DAY", 0) ;;
    value_format: "#,##0.00"
  }

  measure: total_idle_gallons {
    group_label: "Emissions"
    label: "Total Idle Gallons"
    description: "Total fuel consumed while assets were idling, summed across the selected time period."
    type: sum
    sql: COALESCE(${TABLE}."IDLE_GALLONS_PER_DAY", 0) ;;
    value_format: "#,##0.00"
  }

  measure: total_gallons_estimated {
    group_label: "Emissions"
    label: "Total Estimated Gallons"
    description: "Total fuel that was estimated to be consumed in the time period."
    type: sum
    sql: COALESCE(${TABLE}."ESTIMATED_GALLONS_PER_DAY", 0) ;;
    value_format: "#,##0.00"
  }

  measure: total_gallons_combined {
    group_label: "Emissions"
    label: "Total Actual Gallons (Used + Idle)"
    description: "Total fuel consumption including both active usage and idle time, summed across the selected time period."
    type: sum
    sql: COALESCE(${TABLE}."GALLONS_USED_PER_DAY", 0)
      + COALESCE(${TABLE}."IDLE_GALLONS_PER_DAY", 0) ;;
    value_format: "#,##0.00"
  }

  measure: total_gallons_all {
    group_label: "Emissions"
    label: "Total Gallons or KwH (Actual + Estimated)"
    description: "Total fuel consumption including both estimated usage and actual usage, summed across the selected time period."
    type: sum
    sql: COALESCE(
      ${TABLE}."GALLONS_USED_PER_DAY" + ${TABLE}."IDLE_GALLONS_PER_DAY",
      ${TABLE}."ESTIMATED_GALLONS_PER_DAY",
      ${TABLE}."ON_TIME" * ${TABLE}."BURN_RATE_GPH"
    );;
    value_format: "#,##0.00"
  }

  measure: total_emissions_kg_co2 {
    group_label: "Emissions"
    label: "Total Emissions (kg CO2)"
    description: "Total carbon emissions (kg CO2) generated from active fuel usage, summed across the selected time period."
    type: sum
    sql: COALESCE(${TABLE}."EMISSIONS_PER_DAY", 0) ;;
    html: {{rendered_value}} kg of CO2 ;;
    value_format: "#,##0.00"
  }

  measure: total_idle_emissions_kg_co2 {
    group_label: "Emissions"
    label: "Total Idle Emissions (kg CO2)"
    description: "Total carbon emissions (kg CO2) generated from idle fuel consumption, summed across the selected time period."
    type: sum
    sql: COALESCE(${TABLE}."IDLE_EMISSIONS_PER_DAY", 0) ;;
    html: {{rendered_value}} kg of CO2 ;;
    value_format: "#,##0.00"
  }

  measure: total_emissions_combined_kg_co2 {
    group_label: "Emissions"
    label: "Total Emissions (Used + Idle)"
    description: "Total carbon emissions (kg CO2) from both active usage and idle fuel consumption, summed across the selected time period."
    type: sum
    sql: COALESCE(${TABLE}."EMISSIONS_PER_DAY", 0)
      + COALESCE(${TABLE}."IDLE_EMISSIONS_PER_DAY", 0) ;;
    html: {{rendered_value}} kg of CO2 ;;
    value_format: "#,##0.00"
  }

  ##########################################################

  filter: custom_name_filter {
    suggest_explore: asset_utilization_by_day
    suggest_dimension: asset_utilization_by_day.asset
  }

  filter: groups_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.group_name
  }

  filter: ownership_filter {
    suggest_explore: asset_utilization_by_day
    suggest_dimension: asset_utilization_by_day.ownership
  }

  filter: asset_class_filter {
    suggest_explore: asset_utilization_by_day
    suggest_dimension: asset_utilization_by_day.asset_class
  }

  filter: branch_filter {
    suggest_explore: asset_utilization_by_day
    suggest_dimension: asset_utilization_by_day.branch
  }

  filter: category_filter {
    suggest_explore: asset_utilization_by_day
    suggest_dimension: asset_utilization_by_day.category
  }

  filter: asset_type_filter {
    suggest_explore: asset_utilization_by_day
    suggest_dimension: asset_utilization_by_day.asset_type
  }

  filter: tracker_grouping_filter {
    suggest_explore: asset_utilization_by_day
    suggest_dimension: asset_utilization_by_day.tracker_grouping
  }

  filter: job_name_filter {
    suggest_explore: job_list
    suggest_dimension: job_list.job_name
  }

  filter: phase_job_name_filter {
    suggest_explore: job_list
    suggest_dimension: job_list.phase_job_name
  }

  filter: make_filter {
    suggest_explore: asset_utilization_by_day
    suggest_dimension: asset_utilization_by_day.make
  }

  filter: model_filter {
    suggest_explore: asset_utilization_by_day
    suggest_dimension: asset_utilization_by_day.model
  }

  filter: sub_renting_company_filter {
    suggest_explore: asset_utilization_by_day
    suggest_dimension: asset_utilization_by_day.sub_renting_company
  }

  filter: sub_renting_contact_filter {
    suggest_explore: asset_utilization_by_day
    suggest_dimension: asset_utilization_by_day.sub_renting_contact
  }

  filter: rental_company_name_filter {
    type: string
  }

  filter: archived_status_filter {
    type: string
  }

  set: run_time_detail {
    fields: [day_formatted, asset, total_run_time, total_idle_time_drill_down, total_miles_driven_drill_down]
  }

  set: idle_time_detail {
    fields: [day_formatted, asset, total_idle_time_drill_down, total_run_time_drill_down, total_miles_driven_drill_down]
  }

  set: miles_driven_detail {
    fields: [day_formatted, asset, total_miles_driven_drill_down, total_run_time_drill_down, total_idle_time_drill_down]
  }

  set: on_time_detail {
    fields: [day_formatted, asset, total_on_time_drill_down, total_run_time_drill_down, total_idle_time_drill_down, total_miles_driven_drill_down]
  }

}
