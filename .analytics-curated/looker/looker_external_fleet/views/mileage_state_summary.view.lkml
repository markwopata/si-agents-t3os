view: mileage_state_summary {

  derived_table: {
    sql:
    with
    asset_list as (
        SELECT distinct a.asset_id, a.custom_name
          from assets A
          JOIN ASSET_SETTINGS AA ON A.ASSET_SETTINGS_ID = AA.ASSET_SETTINGS_ID
          LEFT JOIN ORGANIZATION_ASSET_XREF OA ON A.ASSET_ID = OA.ASSET_ID
          LEFT JOIN ORGANIZATIONS O ON OA.ORGANIZATION_ID = O.ORGANIZATION_ID
          left join company_dot_numbers d on a.dot_number_id = d.dot_number_id
          join (select distinct asset_id from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_INFO where company_id in (select company_id from users where user_id = {{ _user_attributes['user_id'] }}::numeric)) L on L.asset_id = a.asset_id
      WHERE a.asset_type_id = 2
      and
              {% if include_ifta_only_assets._parameter_value == "'Yes'" %}
              (aa.ifta_reporting = TRUE)
              {% else %}
              (aa.ifta_reporting = TRUE OR aa.ifta_reporting = FALSE OR aa.ifta_reporting is null)
              {% endif %}
      AND {% condition dot_number_filter %} d.dot_number {% endcondition %}
      AND {% condition groups_filter %} o.name {% endcondition %}
      AND {% condition asset_filter %} a.custom_name {% endcondition %}
      GROUP BY a.asset_id, a.custom_name
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
    ),
      fuel_purchases_by_state as (
        select f.state_id,st.name as state,
          sum(f.gallons_purchased) as total_gallons_purchased,
          sum(f.purchase_price) as total_fuel_cost,
          listagg(distinct al.custom_name, ', ') as assets_w_fuel_purchases
         from fuel_purchases f
         join asset_list al on al.asset_id = f.asset_id
         left join states st on st.state_id = f.state_id
          where f.company_id = {{ _user_attributes['company_id'] }}::numeric
              and f.purchase_date >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
              and f.purchase_date <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
        group by f.state_id,st.name
      ),
     cte as (
      SELECT M.STATE, custom_name,
      sum(m.miles_driven)::decimal(15,2) AS miles_driven
      FROM (
          SELECT
          AL.ASSET_ID,
          al.custom_name,
          F."NAME" AS STATE,
          F.MILES_DRIVEN
        FROM asset_list al
        JOIN daily_state_mileage F ON al.asset_id = f.asset_id
        ) M
      GROUP BY m.state, custom_name
    ), vehicle_usage_by_state as (select
            state,
            sum(miles_driven) as total_miles,
            listagg(distinct custom_name, ', ') as assets_w_usage
          from cte
          group by 1
      ) select s.name as state,
               coalesce(fp.total_gallons_purchased, 0) as gallons_purchased,
               coalesce(fp.total_fuel_cost, 0) as fuel_cost,
               vsu.total_miles as total_miles,
               coalesce(fp.assets_w_fuel_purchases, 'None') as assets_w_fuel_purchases,
               vsu.assets_w_usage as assets_w_usage,
               round(coalesce((vsu.total_miles / (tm.total_miles_cross / tf.total_gallons_purchased_cross)),0),1) as gallons_used
          from fuel_purchases_by_state fp
            right join vehicle_usage_by_state vsu on vsu.state = fp.state
            CROSS JOIN (SELECT SUM(total_miles) AS total_miles_cross FROM vehicle_usage_by_state) tm
            CROSS JOIN (SELECT SUM(total_gallons_purchased) AS total_gallons_purchased_cross from fuel_purchases_by_state) tf
            join public.states s on lower(s.name) = lower(vsu.state);;
            # order by fp.total_fuel_cost, s.abbreviation asc ;;

  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
    primary_key: yes
  }

  dimension: gallons_purchased {
    type: number
    sql: ${TABLE}."GALLONS_PURCHASED" ;;
    value_format: "0.0"
  }

  dimension: fuel_cost {
    type: number
    sql: ${TABLE}."FUEL_COST" ;;
    value_format: "0.00"
  }

  dimension: total_miles {
    type: number
    sql: ${TABLE}."TOTAL_MILES" ;;
    value_format: "0.0"
  }

  measure: fleet_total_miles {
    label: "Total Miles"
    type: sum
    sql: ${total_miles} ;;
    value_format_name: decimal_2
  }

  dimension: assets_with_fuel_purchases {
    type: string
    sql: ${TABLE}."ASSETS_W_FUEL_PURCHASES" ;;
  }

  dimension: assets_with_usage {
    type: string
    sql: ${TABLE}."ASSETS_W_USAGE" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: gallons_used {
    type: number
    sql: ${TABLE}."GALLONS_USED" ;;
  }

  # dimension: asset_type {
  #   type: string
  #   sql: ${TABLE}."ASSET_TYPE" ;;
  # }

  # dimension: asset_class {
  #   type: string
  #   sql: ${TABLE}."ASSET_CLASS" ;;
  # }

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
