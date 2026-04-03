view: manager_location_permissions {
  derived_table: {
    sql: select
          mrx.market_id,
          mrx.market_name,
          mrx.district,
          mrx.region_name,
          mrx.market_type,
          mrx.division_name,
          IFF(
          ({{ _user_attributes['job_role'] }} = 'developer')
          OR
          ({{ _user_attributes['job_role'] }} = 'leadership')
          OR
          ({{ _user_attributes['department'] }} = 'fleet')
          OR
          ({{ _user_attributes['job_role'] }} = 'regional_ops')
          --AND
          --(case when
          --TRY_TO_NUMBER(substr(split_part(default_cost_centers_full_path, '/', 2),2,1)) is null then mrx.region_name in ({{ _user_attributes['region'] }})
          --else
          --substr(split_part(default_cost_centers_full_path, '/', 2),2,1) = mrx.region OR mrx.region_name in ({{ _user_attributes['region'] }})
          --end
          --))
          --AND (substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = mrx.region OR substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = 'N' OR mrx.region_name in ({{ _user_attributes['region'] }})))
          OR
          ({{ _user_attributes['job_role'] }} = 'regional_service_mgr' AND (substr(split_part(default_cost_centers_full_path, '/', 2),2,1) = mrx.region OR substr(split_part(default_cost_centers_full_path, '/', 2),2,1) = 'N' OR mrx.region_name in ({{ _user_attributes['region'] }})))
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'region'
          --AND
          --(case when
          --TRY_TO_NUMBER(substr(split_part(default_cost_centers_full_path, '/', 3),0,1)) is null then mrx.region_name in ({{ _user_attributes['region'] }})
          --else
          --substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = mrx.region OR mrx.region_name in ({{ _user_attributes['region'] }})
          --end
          --)
          )
          --({{ _user_attributes['hierarchy_level_access'] }} = 'region' )
          --OR
          --({{ _user_attributes['hierarchy_level_access'] }} = 'district' AND substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = mrx.region OR mrx.region_name in ({{ _user_attributes['region'] }}))
          --OR
          --({{ _user_attributes['hierarchy_level_access'] }} = 'market' AND substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = mrx.region OR mrx.region_name in ({{ _user_attributes['region'] }}))
          OR
          (substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = 'N')
          ,
          TRUE,
          FALSE
          ) as region_access,


         IFF(
          ({{ _user_attributes['job_role'] }} = 'developer')
          OR
          ({{ _user_attributes['job_role'] }} = 'leadership')
          OR
          ({{ _user_attributes['department'] }} = 'fleet')
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'region' AND (split_part(default_cost_centers_full_path, '/', 3) = mrx.district OR mrx.district in ({{ _user_attributes['district'] }})) OR region_access = TRUE)
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'district' AND (split_part(default_cost_centers_full_path, '/', 3) = mrx.district OR mrx.district in ({{ _user_attributes['district'] }})) OR region_access = TRUE)
          --OR
          --({{ _user_attributes['hierarchy_level_access'] }} = 'market' AND (split_part(default_cost_centers_full_path, '/', 3) = mrx.district OR mrx.district in ({{ _user_attributes['district'] }})))
          ,
          TRUE,
          FALSE
          ) as district_access,


          IFF(
          ({{ _user_attributes['job_role'] }} = 'developer')
          OR
          ({{ _user_attributes['job_role'] }} = 'leadership')
          OR
          ({{ _user_attributes['department'] }} = 'fleet')
          OR
          {{ _user_attributes['hierarchy_level_access'] }} = 'market' AND {{ _user_attributes['job_role'] }} not in ('tam','nam') AND ((cd.market_id = mrx.market_id) OR mrx.market_id in ({{ _user_attributes['market_id'] }}) OR mrx.district in ({{ _user_attributes['district'] }}))
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'region' AND (district_access = TRUE OR (mrx.market_id in ({{ _user_attributes['market_id'] }}))))
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'district' AND (district_access = TRUE OR (mrx.market_id in ({{ _user_attributes['market_id'] }}))))
          ,TRUE,FALSE) as market_access
      from
          analytics.public.market_region_xwalk mrx
          left join analytics.payroll.company_directory cd on 1=1
      where
          lower(work_email) = lower('{{ _user_attributes['email'] }}')
          ;;
          # '{{ _user_attributes['email'] }}'  ;;
          # 'josh.helmstetler@equipmentshare.com'
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

  dimension: division_name {
    type: string
    sql: ${TABLE}."DIVISION_NAME" ;;
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
