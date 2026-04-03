
view: location_permissions {
  derived_table: {
    sql:
      select
          mrx.market_id,
          mrx.market_name,
          mrx.district,
          mrx.region_name,
          mrx.market_type,
          mrx.division_name,
          mrx.is_open_over_12_months,
          CASE WHEN mrx.market_name ILIKE '%Landmark%' THEN 'Landmark'
        when mrx.market_name ILIKE '%Mobile Tool Trailer%' THEN 'Mobile Tool Trailer'
        WHEN mrx.market_name ILIKE '%Onsite Yard%' THEN 'Onsite Yard'
        WHEN mrx.market_name ILIKE '%Containers%' then 'Containers'
        WHEN right(mrx.market_name, 9) = 'Hard Down' THEN 'Hard Down' ELSE mrx.market_type END as special_locations_type,
          mrx.branch_earnings_start_month as market_start_month,
          case when mrx.market_type = 'Hard Down' then true else false end as hard_down,
          --vmt.is_current_months_open_greater_than_twelve as months_open_over_12,
          IFF(
          ({{ _user_attributes['job_role'] }} = 'developer')
          OR
          ({{ _user_attributes['job_role'] }} = 'regional_ops')
          OR
          ({{ _user_attributes['job_role'] }} = 'training')
          OR
          ({{ _user_attributes['job_role'] }} = 'regional_service_mgr' AND (substr(split_part(default_cost_centers_full_path, '/', 2),2,1) = mrx.region OR substr(split_part(default_cost_centers_full_path, '/', 2),2,1) = 'N' OR mrx.region_name in ({{ _user_attributes['region'] }})))
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'region'
          )
          OR

          ({{ _user_attributes['hierarchy_level_access'] }} = 'district' AND

           IFF(substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = 'C',100,
          NULLIF(SUBSTR(SPLIT_PART(default_cost_centers_full_path,'/',3), 1, 1), '')) = TO_VARCHAR(mrx.region)
          OR mrx.region_name in ({{ _user_attributes['region'] }}))


          OR (
            {{ _user_attributes['hierarchy_level_access'] }} = 'market'
            AND (
              IFF(
                SUBSTR(SPLIT_PART(default_cost_centers_full_path,'/',3), 1, 1) = 'C',
                '100',
                SUBSTR(SPLIT_PART(default_cost_centers_full_path,'/',3), 1, 1)
              ) = TO_VARCHAR(mrx.region)
              OR TO_VARCHAR(mrx.region_name) IN ({{ _user_attributes['region'] }})
            )
          )
          OR
          (substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = 'N')
          OR
          (substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = 'C')
          ,
          TRUE,
          FALSE
          ) as region_access,
         IFF(
          ({{ _user_attributes['job_role'] }} = 'developer')
          OR
          ({{ _user_attributes['job_role'] }} = 'training')
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'region' AND ((split_part(default_cost_centers_full_path, '/', 3) = mrx.district OR mrx.district in ({{ _user_attributes['district'] }})) OR region_access = TRUE))
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'district' AND ((split_part(default_cost_centers_full_path, '/', 3) = mrx.district OR mrx.district in ({{ _user_attributes['district'] }})) OR region_access = TRUE))
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'market' AND (split_part(default_cost_centers_full_path, '/', 3) = mrx.district OR mrx.district in ({{ _user_attributes['district'] }}) ))
          OR (mrx.district = '1-1' AND lower('{{ _user_attributes['email'] }}') = 'ky.steincipher@equipmentshare.com')
          ,
          TRUE,
          FALSE
          ) as district_access,


          IFF(
          ({{ _user_attributes['job_role'] }} = 'developer')
          OR
          ({{ _user_attributes['job_role'] }} = 'training')
          --OR
          --{{ _user_attributes['hierarchy_level_access'] }} = 'market' AND ((cd.market_id = mrx.market_id) OR mrx.market_id in ({{ _user_attributes['market_id'] }}) OR mrx.district in ({{ _user_attributes['district'] }})) --limited market code for gms
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'market' AND (split_part(default_cost_centers_full_path, '/', 3) = mrx.district OR mrx.district in ({{ _user_attributes['district'] }}) OR (mrx.market_id in ({{ _user_attributes['market_id'] }})) )) --allow GMs to see all markets in a district **and their specified markets in looker
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'region' AND (district_access = TRUE OR (mrx.market_id in ({{ _user_attributes['market_id'] }}))))
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'district' AND (district_access = TRUE OR (mrx.market_id in ({{ _user_attributes['market_id'] }}))))
          OR

            (mrx.market_id = 90850 AND lower('{{ _user_attributes['email'] }}') = 'ky.steincipher@equipmentshare.com')
          OR

            (mrx.market_id IN (156979, 145364, 34742, 55507, 128118, 15975, 129940)
              AND lower('{{ _user_attributes['email'] }}') = 'mario.robles@equipmentshare.com')

          ,TRUE,FALSE) as market_access
      from
          analytics.public.market_region_xwalk mrx
          left join analytics.payroll.company_directory cd on 1=1
          --left join market_open_length mol on mol.market_id = mrx.market_id
         -- left join (select market_id, market_name, state, region, region_name, --is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
      --group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt on vmt.market_id = mrx.market_id
      where
          lower(cd.work_email) = lower('{{ _user_attributes['email'] }}')
          AND (mrx.division_name <> 'Materials' OR mrx.division_name is null)
          AND cd.employee_status NOT IN ('Terminated', 'Inactive', 'Never Started') --'On Leave' taken out 11/11/2025
      /*              # '{{ _user_attributes['email'] }}'
          # 'josh.helmstetler@equipmentshare.com'
          # lower(cd.work_email) = lower('aaron.creson@equipmentshare.com') --gm testing
          #--lower('aaron.langston@equipmentshare.com')
          #--lower('franco.vallabriga@equipmentshare.com')
          */
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

#Original Query
# with max_update_date as (
#       select
#           max(hlfs.gl_date) as max_date
#       from
#           analytics.public.high_level_financials_snap hlfs
#           JOIN analytics.gs.plexi_periods pp on pp.trunc::date = hlfs.gl_date::date
#       where
#           period_published = 'published'
#       )
#       , market_open_length as (
#       select
#           market_id,
#           IFF(datediff(months,branch_earnings_start_month,max_date)+1 > 12,TRUE,FALSE) as months_open_over_12
#       from
#           ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE
#           CROSS JOIN max_update_date
#       where
#           market_id BETWEEN 0 AND 500000
#           AND market_id != 15967
#       )
#       , user_perms as (
#       select
#           case
#           when {{ _user_attributes['job_role'] }} = 'regional_ops' then substr(split_part(default_cost_centers_full_path, '/', 3),0,1)
#           when {{ _user_attributes['job_role'] }} = 'regional_service_mgr' then substr(split_part(default_cost_centers_full_path, '/', 2),2,1)
#           when {{ _user_attributes['hierarchy_level_access'] }} = 'region' then '1'
#           when {{ _user_attributes['hierarchy_level_access'] }} = 'district' then substr(split_part(default_cost_centers_full_path, '/', 3),0,1)
#           when {{ _user_attributes['hierarchy_level_access'] }} = 'market' then substr(split_part(default_cost_centers_full_path, '/', 3),0,1)
#           end
#           as region_priv,
#           case when {{ _user_attributes['hierarchy_level_access'] }} = 'region' then '1'
#           when {{ _user_attributes['hierarchy_level_access'] }} = 'district' then substr(split_part(default_cost_centers_full_path, '/', 3),0,2)
#           when {{ _user_attributes['hierarchy_level_access'] }} = 'market' then split_part(default_cost_centers_full_path, '/', 3)
#           end
#           as district_priv,
#           case when {{ _user_attributes['hierarchy_level_access'] }} = 'region' then '1'
#           when {{ _user_attributes['hierarchy_level_access'] }} = 'district' then substr(split_part(default_cost_centers_full_path, '/', 3),0,3)
#           when {{ _user_attributes['hierarchy_level_access'] }} = 'market' then '0'
#           end
#           as district_access,
#           case
#           when {{ _user_attributes['hierarchy_level_access'] }} = 'market' then cd.market_id
#           else 1
#           end
#           as market_access
#       from
#           analytics.payroll.company_directory cd
#       where
#           work_email = '{{ _user_attributes['email'] }}'
#       )
#       select
#           mrx.market_id,
#           mrx.market_name,
#           mrx.district,
#           mrx.region_name,
#           mrx.market_type,
#           case when market_access = 1 then TRUE
#           else
#           iff(mrx.market_id = up.market_access OR mrx.market_id in ({{ _user_attributes['market_id'] }}),TRUE,FALSE) --Company Directory Perms or Looker Perms
#           end
#           as market_access,
#           case
#           when district_access = '1' then TRUE
#           when district_access = '0' then FALSE
#           else
#           iff(mrx.district = up.district_access OR mrx.district in ({{ _user_attributes['district'] }}),TRUE,FALSE) --Company Directory Perms or Looker Perms
#           end
#           as district_access,
#           case
#           when region_priv = '1' then TRUE
#           when region_priv = 'N' then TRUE
#           when region_priv = '0' then FALSE
#           else
#           iff(mrx.region = case when up.region_priv = 'N' then 1 else up.region_priv end
#           OR mrx.region_name in ({{ _user_attributes['region'] }}),TRUE,FALSE)
#           end
#           as region_access,
#           mol.months_open_over_12
#       from
#           user_perms up
#           join analytics.public.market_region_xwalk mrx on
#                                                           case when {{ _user_attributes['hierarchy_level_access'] }} = 'region' then 1=1
#                                                           when {{ _user_attributes['hierarchy_level_access'] }} = 'district' then substr(mrx.district,0,2) = up.district_priv
#                                                           when {{ _user_attributes['hierarchy_level_access'] }} = 'market' then mrx.district = up.district_priv
#                                                           end
#           join market_open_length mol on mol.market_id = mrx.market_id
