view: branch_window_location_perm {

    derived_table: {
      sql:
      --Different by the original location permissions to have market level people (gms) only see their own dash.
      -- To make branch window easier
      select
          mrx.market_id,
          mrx.market_name,
          mrx.district,
          mrx.region_name,
          mrx.market_type,
          case when right(mrx.market_name, 9) = 'Hard Down' then true else false end as hard_down,
          vmt.is_current_months_open_greater_than_twelve as months_open_over_12,
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
          ({{ _user_attributes['hierarchy_level_access'] }} = 'district' AND substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = mrx.region OR mrx.region_name in ({{ _user_attributes['region'] }}))
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'market' AND substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = mrx.region OR mrx.region_name in ({{ _user_attributes['region'] }}))
          OR
          (substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = 'N')
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
          ({{ _user_attributes['hierarchy_level_access'] }} = 'market' AND (split_part(default_cost_centers_full_path, '/', 3) = mrx.district OR mrx.district in ({{ _user_attributes['district'] }})))
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
          ({{ _user_attributes['hierarchy_level_access'] }} = 'market' AND (split_part(default_cost_centers_full_path, '/', 4) = mrx.market_name OR mrx.district in ('0')))
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'region' AND (district_access = TRUE OR (mrx.market_id in ({{ _user_attributes['market_id'] }}))))
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'district' AND (district_access = TRUE OR (mrx.market_id in ({{ _user_attributes['market_id'] }}))))
          ,TRUE,FALSE) as market_access
      from
          analytics.public.market_region_xwalk mrx
          left join analytics.payroll.company_directory cd on 1=1
          --left join market_open_length mol on mol.market_id = mrx.market_id
          left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
      group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt on vmt.market_id = mrx.market_id
      where
          lower(cd.work_email) = lower('{{ _user_attributes['email'] }}')
          AND (mrx.division_name <> 'Materials' OR mrx.division_name is null)
          ;;
          # '{{ _user_attributes['email'] }}'  ;;
          # 'josh.helmstetler@equipmentshare.com'
          # lower(cd.work_email) = lower('aaron.creson@equipmentshare.com') --gm testing
      }

      measure: count {
        type: count
        drill_fields: [detail*]
      }

      dimension: market_id {
        type: number
        sql: ${TABLE}."MARKET_ID" ;;
      }

      dimension: market_name {
        type: string
        sql: ${TABLE}."MARKET_NAME" ;;
      }

      dimension: district {
        type: string
        sql: ${TABLE}."DISTRICT" ;;
      }

      dimension: region {
        type: string
        sql: ${TABLE}."REGION_NAME" ;;
      }

      dimension: market_type {
        type: string
        sql: ${TABLE}."MARKET_TYPE" ;;
      }

      dimension: hard_down {
        type: yesno
        sql: ${TABLE}."HARD_DOWN" ;;
      }

      dimension: market_access {
        type: yesno
        sql: ${TABLE}."MARKET_ACCESS" ;;
      }

      dimension: district_access {
        type: yesno
        sql: ${TABLE}."DISTRICT_ACCESS" ;;
      }

      dimension: region_access {
        type: yesno
        sql: ${TABLE}."REGION_ACCESS" ;;
      }

      dimension: months_open_over_12 {
        type: yesno
        sql: ${TABLE}."MONTHS_OPEN_OVER_12" ;;
      }

      dimension: market_permissions {
        type: string
        sql: case when ${market_access} = TRUE then ${market_name}
              else ' '
              end;;
      }

      dimension: district_permissions {
        type: string
        sql: case when ${district_access} = TRUE then ${district}
          else ' '
          end;;
      }

      dimension: region_permissions {
        type: string
        sql: case when ${region_access} = TRUE then ${region}
          else ' '
          end;;
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
            <a href="https://equipmentshare.looker.com/dashboards/1328?Market={{ market_permissions._filterable_value | url_encode }}" target="_blank">
            <b> {{rendered_value}} ➔ </b></a></font></u></button>
             ;;
      }

      set: detail {
        fields: [
          market_id,
          market_name,
          district,
          region,
          market_type,
          market_access
        ]
      }
    }
