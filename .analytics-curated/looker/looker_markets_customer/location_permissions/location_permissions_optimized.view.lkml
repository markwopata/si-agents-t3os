
view: location_permissions_optimized {
  derived_table: {
    sql:
      WITH user_info AS (
          SELECT
              SPLIT_PART(default_cost_centers_full_path, '/', 2) AS path_part2,
              SPLIT_PART(default_cost_centers_full_path, '/', 3) AS path_part3,
              SUBSTR(SPLIT_PART(default_cost_centers_full_path, '/', 2), 2, 1) AS path2_pos2_len1,
              SUBSTR(SPLIT_PART(default_cost_centers_full_path, '/', 3), 0, 1) AS path3_pos0_len1,
              SUBSTR(SPLIT_PART(default_cost_centers_full_path, '/', 3), 1, 1) AS path3_pos1_len1
          FROM analytics.payroll.company_directory
          WHERE LOWER(work_email) = LOWER('{{ _user_attributes['email'] }}')
            AND employee_status NOT IN ('Terminated', 'Inactive', 'Never Started')
      ),
      access_flags AS (
          SELECT
              {{ _user_attributes['job_role'] }} IN ('developer', 'training') AS is_full_access,
              {{ _user_attributes['job_role'] }} = 'regional_ops' AS is_regional_ops,
              {{ _user_attributes['job_role'] }} = 'regional_service_mgr' AS is_regional_svc_mgr,
              {{ _user_attributes['hierarchy_level_access'] }} AS hierarchy_level
      )
      SELECT
          mrx.market_id,
          mrx.market_name,
          mrx.district,
          mrx.region_name,
          mrx.market_type,
          mrx.division_name,
          mrx.is_open_over_12_months,
          mrx.market_type AS special_locations_type,
          mrx.branch_earnings_start_month AS market_start_month,
          IFF(mrx.market_type = 'Hard Down', TRUE, FALSE) AS hard_down,

          IFF(
              af.is_full_access
              OR af.is_regional_ops
              OR (af.is_regional_svc_mgr AND (ui.path2_pos2_len1 = mrx.region OR ui.path2_pos2_len1 = 'N' OR mrx.region_name IN ({{ _user_attributes['region'] }})))
              OR af.hierarchy_level = 'region'
              OR (af.hierarchy_level = 'district' AND
                  IFF(ui.path3_pos0_len1 = 'C', 100,
                  NULLIF(ui.path3_pos1_len1, '')) = TO_VARCHAR(mrx.region)
                  OR mrx.region_name IN ({{ _user_attributes['region'] }}))
              OR (af.hierarchy_level = 'market' AND (
                  IFF(ui.path3_pos1_len1 = 'C', '100', ui.path3_pos1_len1) = TO_VARCHAR(mrx.region)
                  OR TO_VARCHAR(mrx.region_name) IN ({{ _user_attributes['region'] }})))
              OR ui.path3_pos0_len1 = 'N'
              OR ui.path3_pos0_len1 = 'C',
              TRUE, FALSE
          ) AS region_access,

          IFF(
              af.is_full_access
              OR (af.hierarchy_level IN ('region', 'district') AND ((ui.path_part3 = mrx.district OR mrx.district IN ({{ _user_attributes['district'] }})) OR region_access = TRUE))
              OR (af.hierarchy_level = 'market' AND (ui.path_part3 = mrx.district OR mrx.district IN ({{ _user_attributes['district'] }})))
              OR (mrx.district = '1-1' AND LOWER('{{ _user_attributes['email'] }}') = 'ky.steincipher@equipmentshare.com'),
              TRUE, FALSE
          ) AS district_access,

          IFF(
              af.is_full_access
              OR (af.hierarchy_level = 'market' AND (ui.path_part3 = mrx.district OR mrx.district IN ({{ _user_attributes['district'] }}) OR mrx.market_id IN ({{ _user_attributes['market_id'] }})))
              OR (af.hierarchy_level IN ('region', 'district') AND (district_access = TRUE OR mrx.market_id IN ({{ _user_attributes['market_id'] }})))
              OR (mrx.market_id = 90850 AND LOWER('{{ _user_attributes['email'] }}') = 'ky.steincipher@equipmentshare.com')
              OR (mrx.market_id = 11007 AND LOWER('{{ _user_attributes['email'] }}') = 'aaron.creson@equipmentshare.com')
              OR (mrx.market_id IN (156979, 145364, 34742, 55507, 128118, 15975, 129940) AND LOWER('{{ _user_attributes['email'] }}') = 'mario.robles@equipmentshare.com'),
              TRUE, FALSE
          ) AS market_access
      FROM analytics.public.market_region_xwalk mrx
      CROSS JOIN user_info ui
      CROSS JOIN access_flags af
      WHERE mrx.division_name <> 'Materials' OR mrx.division_name IS NULL
      ;;

  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
    # suggest_persist_for: "1 minute"
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
    suggest_persist_for: "1 minute"
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
    suggest_persist_for: "1 minute"
  }

  measure: district_count {
    type: count_distinct
    sql: ${district} ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
    # suggest_persist_for: "1 minute"
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
    # suggest_persist_for: "1 minute"
  }

  dimension: division_name {
    type: string
    sql: ${TABLE}."DIVISION_NAME" ;;
  }

  dimension: market_start_month {
    type: string
    sql: ${TABLE}."MARKET_START_MONTH"::DATE ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: hard_down {
    type: yesno
    sql: ${TABLE}."HARD_DOWN" ;;
  }

  dimension: special_locations_type {
    type: string
    sql: ${TABLE}."SPECIAL_LOCATIONS_TYPE";;
  }

  dimension: market_access {
    type: yesno
    sql: ${TABLE}."MARKET_ACCESS" ;;
    # suggest_persist_for: "1 minute"
  }

  dimension: district_access {
    type: yesno
    sql: ${TABLE}."DISTRICT_ACCESS" ;;
    # suggest_persist_for: "1 minute"
  }

  dimension: region_access {
    type: yesno
    sql: ${TABLE}."REGION_ACCESS" ;;
    # suggest_persist_for: "1 minute"
  }

  dimension: is_open_over_12_months {
    type: yesno
    sql: ${TABLE}."IS_OPEN_OVER_12_MONTHS" ;;
    # suggest_persist_for: "1 minute"
  }

  dimension: market_permissions {
    type: string
    sql: case when ${market_access} = TRUE then ${market_name}
    else ' '
    end;;
    suggest_persist_for: "1 minute"
  }

  dimension: district_permissions {
    type: string
    sql: case when ${district_access} = TRUE then ${district}
          else ' '
          end;;
    # suggest_persist_for: "1 minute"
  }

  dimension: region_permissions {
    type: string
    sql: case when ${region_access} = TRUE then ${region}
          else ' '
          end;;
    # suggest_persist_for: "1 minute"
  }

  dimension: region_district_navigation {
    group_label: "Navigation Grouping"
    label: "View Region District Breakdowns"
    type: string
    sql: ${region_permissions} ;;
    html:
    <button style="background-color: rgba(49, 140, 231, 0.25); border-radius: 5px; border: none; width: 75%; height: 40px; margin-bottom: 15px; margin-top: 5px; border: 1px solid #318CE7;"><font color="#202020"><u>
    <a href="https://equipmentshare.looker.com/dashboards/1321?Region={{ region_permissions._filterable_value | url_encode }}" target="_blank">
    <b> {{rendered_value}} District Breakdown ➔ </b></a></font></u> <tr> <font color="#202020"> {{count._value}} Markets  </tr> </button>
     ;;
  }

  dimension: district_market_navigation {
    group_label: "Navigation Grouping"
    label: "View District Market Breakdowns"
    type: string
    sql: ${district_permissions} ;;
    html:
    <button style="background-color: rgba(49, 140, 231, 0.25); border-radius: 5px; border: none; width: 75%; height: 40px; margin-bottom: 15px; margin-top: 5px; border: 1px solid #318CE7;"><font color="#202020"><u>
    <a href="https://equipmentshare.looker.com/dashboards/1322?District={{ district_permissions._filterable_value | url_encode }}" target="_blank">
    <b> {{rendered_value}} Market Breakdown ➔ </b></a></font></u> <tr> <font color="#202020"> {{count._value}} Markets </tr> </button>
     ;;
  }

  dimension: market_navigation {
    group_label: "Navigation Grouping"
    label: "View Market Breakdowns"
    type: string
    sql: ${market_permissions} ;;
    html:
    <button style="background-color: rgba(49, 140, 231, 0.25); border-radius: 5px; border: none; width: 75%; height: 30px; margin-bottom: 10px; margin-top: 5px; border: 1px solid #318CE7;"><font color="#202020"><u>
    <a href="https://equipmentshare.looker.com/dashboards/2288?Market={{ market_permissions._filterable_value | url_encode }}" target="_blank">
    <b> {{rendered_value}} ➔ </b></a></font></u></button>
     ;;
  }


  dimension: region_district_navigation_3 {
    group_label: "Navigation Grouping"
    label: "View Region District Rankings"
    type: string
    sql: ${region_permissions} ;;
    html:
    <button style="background-color: rgba(49, 140, 231, 0.25); border-radius: 5px; border: none; width: 75%; height: 40px; margin-bottom: 15px; margin-top: 5px; border: 1px solid #318CE7;"><font color="#202020"><u>
    <a href="
    https://equipmentshare.looker.com/dashboards/2339?Months+Open+Over+12+%28Yes+%2F+No%29=&amp;District+Highlight=&amp;Region={{ region_permissions._filterable_value | url_encode }}&amp;Included+Market+Types=Advanced+Solutions%2CContainers%2CCore+Solutions%2CITL%2CLandmark%2CMobile+Tool+Trailer%2COnsite+Yard" target="_blank">
    <b> {{rendered_value}} ➔ </b></a></font></u> <tr> <font color="#202020"> {{district_count._value}} Districts  </tr> </button>
     ;;
  }

  dimension: district_market_navigation_3 {
    group_label: "Navigation Grouping"
    label: "View District Market Rankings"
    type: string
    sql: ${district_permissions} ;;
    html:
    <button style="background-color: rgba(49, 140, 231, 0.25); border-radius: 5px; border: none; width: 75%; height: 40px; margin-bottom: 15px; margin-top: 5px; border: 1px solid #318CE7;"><font color="#202020"><u>
    <a href="https://equipmentshare.looker.com/dashboards/2337?Months%20Open%20Over%2012%20(Yes%20%2F%20No)=&amp;Market%20Highlight=&amp;District={{ district_permissions._filterable_value | url_encode }}&amp;Included%20Market%20Types=Containers,ITL,Core%20Solutions,Onsite%20Yard,Advanced%20Solutions,Mobile%20Tool%20Trailer,Landmark" target="_blank">
    <b> District {{rendered_value}} ➔ </b></a></font></u> <tr> <font color="#202020"> {{count._value}} Markets </tr> </button>
     ;;
  }

  dimension: market_navigation_3 {
    group_label: "Navigation Grouping"
    label: "View Market Dashboard 3.0"
    type: string
    sql: ${market_permissions} ;;
    html:
    <button style="background-color: rgba(49, 140, 231, 0.25); border-radius: 5px; border: none; width: 75%; height: 30px; margin-bottom: 10px; margin-top: 5px; border: 1px solid #318CE7;"><font color="#202020"><u>
    <a href="https://equipmentshare.looker.com/dashboards/2288?Market={{ market_permissions._filterable_value | url_encode }}&amp;District=&amp;Region=&amp;Market+Type=&amp;Months+Open+Over+12+%28Yes+%2F+No%29=" target="_blank">
    <b> {{rendered_value}} ➔ </b></a></font></u></button>
     ;;
  }



  measure: total_markets_selected {
    type: count_distinct
    sql: TRIM(${market_id}) ;;
    filters: [market_access: "Yes"]
  }

  measure: total_districts_selected {
    type: count_distinct
    sql: TRIM(${district}) ;;
    filters: [district_access: "Yes"]
  }

  measure: total_regions_selected {
    type: count_distinct
    sql: TRIM(${region}) ;;
    filters: [region_access: "Yes"]
  }

  measure: selection_label {
    type: string
    sql:
    CASE
      -- More than one market → first market + count-1 markets
      WHEN COUNT(DISTINCT ${market_id}) > 1 THEN
        SPLIT_PART(
          LISTAGG(DISTINCT ${market_name}, '||')
            WITHIN GROUP (ORDER BY ${market_name}),
          '||', 1
        )
        || ' + ' ||
        TO_VARCHAR(COUNT(DISTINCT ${market_id}) - 1) ||
        CASE
          WHEN (COUNT(DISTINCT ${market_id}) - 1) = 1 THEN ' market'
          ELSE ' markets'
        END

      -- Exactly one market → just its name
      WHEN COUNT(DISTINCT ${market_id}) = 1 THEN
      MIN(${market_name})

      ELSE 'All Company'
      END
      ;;
      html: {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="20" width="20"> ;;
      drill_fields: [market_gm_sm_detail*]
  }

  set: detail {
    fields: [
      market_type,
      region,
      district,
      market_id,
      market_name,
      market_start_month
    ]
  }

  set: market_gm_sm_detail {
    fields: [
      market_type,
      region,
      district,
      market_name,
      market_start_month,
      gm_sm_info.general_manager,
      gm_sm_info.service_manager

    ]
  }
}
