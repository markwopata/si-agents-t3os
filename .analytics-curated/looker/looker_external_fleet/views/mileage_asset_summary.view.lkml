view: mileage_asset_summary {

  derived_table: {
    sql:
    with fuel_purchases_by_asset as (
      select
        fp.asset_id,
        a.custom_name as asset,
        listagg(distinct s.abbreviation, ', ') as states_w_fuel_purchases
      from public.fuel_purchases fp
      left join public.assets a on a.asset_id = fp.asset_id
      join public.states s on s.state_id = fp.state_id
        where fp.company_id = {{ _user_attributes['company_id'] }}::numeric
            and fp.purchase_date >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
            and fp.purchase_date <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
      group by a.custom_name, fp.asset_id
    ),
          daily_state_mileage as (
        WITH ranked_data AS (
            SELECT *,
                ROW_NUMBER() OVER (PARTITION BY asset_id, custom_name, make, model, vin, company_id ORDER BY state_entry_raw) AS overall_row,
                ROW_NUMBER() OVER (PARTITION BY asset_id, custom_name, make, model, vin, company_id, name ORDER BY state_entry_raw) AS state_row
            FROM BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__DAILY_STATE_MILEAGE
            where state_exit_raw between convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz)::timestamptz
                  and convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz)::timestamptz
                  and company_id in (select company_id from es_warehouse.public.users where user_id = {{ _user_attributes['user_id'] }}::numeric)
        ),
        grouped_data AS (
            SELECT *,
                (overall_row - state_row) AS group_id
            FROM ranked_data
        )
        SELECT
            asset_id,
            custom_name,
            make,
            model,
            vin,
            company_id,
            name,
            ifta_reporting,
            MIN_BY(state_entry, state_entry_raw) AS state_entry,
            MAX_BY(state_exit, state_entry_raw) AS state_exit,
            MIN_BY(start_odometer, state_entry_raw) AS start_odometer,
            Max_BY(end_odometer, state_entry_raw) AS end_odometer,
            ROUND(SUM(miles_driven),2) AS miles_driven,
            MIN_BY(start_lat, state_entry_raw) AS start_lat,
            MIN_BY(start_lon, state_entry_raw) AS start_lon,
            MAX_BY(end_lat, state_entry_raw) AS end_lat,
            MAX_BY(end_lon, state_entry_raw) AS end_lon,
            MIN(state_entry_raw) AS state_entry_raw,
            MAX(state_entry_raw) AS state_exit_raw
        FROM grouped_data
        GROUP BY asset_id, custom_name, make, model, vin, company_id, name, ifta_reporting, group_id
        ORDER BY asset_id, company_id
    )
, vehicle_usage_by_asset as (
    select * FROM daily_state_mileage
    )
, mileage_summary as (
    select asset_id, name, sum(miles_driven) as total_miles
    from vehicle_usage_by_asset
    group by 1,2
    )
    select a.custom_name as asset,
             ms.asset_id as asset_id,
            --at.name as asset_type,
            --a.asset_class,
             concat(a.make, ' ', a.model) as make_model,
             coalesce(fpa.states_w_fuel_purchases, 'None') as states_w_fuel_purchases,
             s.name as usage_state,
             ms.total_miles,
             a.vin
      from fuel_purchases_by_asset fpa
        right join mileage_summary ms on ms.asset_id = fpa.asset_id
        left join public.assets a on a.asset_id = ms.asset_id
        left join public.asset_settings ast on a.asset_settings_id = ast.asset_settings_id
        left join public.states s on lower(ms.name) = lower(s.name)
        LEFT JOIN ORGANIZATION_ASSET_XREF OA ON A.ASSET_ID = OA.ASSET_ID
        LEFT JOIN ORGANIZATIONS O ON OA.ORGANIZATION_ID = O.ORGANIZATION_ID
        left join company_dot_numbers d on a.dot_number_id = d.dot_number_id
        --left join public.asset_types at on a.asset_type_id = at.asset_type_id
      where
        ms.total_miles > 0
      and a.asset_type_id = 2
      and
          {% if include_ifta_only_assets._parameter_value == "'Yes'" %}
          (ast.ifta_reporting = TRUE)
          {% else %}
          (ast.ifta_reporting = TRUE OR ast.ifta_reporting = FALSE OR ast.ifta_reporting is null)
          {% endif %}
      AND {% condition dot_number_filter %} d.dot_number {% endcondition %}
      AND {% condition groups_filter %} o.name {% endcondition %}
      AND {% condition asset_filter %} a.custom_name {% endcondition %}
      group by a.custom_name, ms.asset_id, a.make, a.model, fpa.states_w_fuel_purchases, s.name, ms.total_miles, a.vin;;
      # order by length(asset), asset, vau.total_miles desc
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  # dimension: asset_type {
  #   type: string
  #   sql: ${TABLE}."ASSET_TYPE" ;;
  # }

  # dimension: asset_class {
  #   type: string
  #   sql: ${TABLE}."ASSET_CLASS" ;;
  # }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: make_model {
    label: "Make/Model"
    type: string
    sql: ${TABLE}."MAKE_MODEL" ;;
  }

  dimension: states_with_fuel_purchases {
    type: string
    sql: ${TABLE}."STATES_W_FUEL_PURCHASES" ;;
  }

  dimension: usage_state {
    type: string
    sql: ${TABLE}."USAGE_STATE" ;;
  }

  dimension: total_miles {
    type: number
    sql: ${TABLE}."TOTAL_MILES" ;;
    # value_format: "0.00"
    value_format_name: decimal_2
  }

  dimension: VIN {
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  measure: fleet_total_miles {
    label: "Total Miles"
    type: sum
    sql: ${total_miles} ;;
    value_format_name: decimal_2
  }

  parameter: include_ifta_only_assets {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }

  filter: date_filter {
    type: date_time
  }

  filter: groups_filter {
    type: string
  }

  filter: dot_number_filter {
    type: string
  }

  filter: asset_filter {
    type: string
  }

}
