view: safety_observation_responses {
  derived_table: {
    sql: WITH user_info AS (
          SELECT
            cd.employee_id,
            cd.market_id,
            IFF(REGEXP_LIKE(LEFT(split_part(cd.default_cost_centers_full_path, '/', 1), 2), 'R[0-9]+'),
                       2, 1) as DCCFP_type,
            COALESCE(mrx.region::varchar,
                    CASE WHEN DCCFP_type = 1
                            THEN IFF(REGEXP_LIKE(LEFT(split_part(cd.default_cost_centers_full_path, '/', 2), 2), 'R[0-9]+'),
                                     IFF(split_part(cd.default_cost_centers_full_path, '/', 2) NOT LIKE '% %',
                                         RIGHT(split_part(cd.default_cost_centers_full_path, '/', 2),
                                               len(split_part(cd.default_cost_centers_full_path, '/', 2)) - 1
                                              ),
                                         SUBSTR(split_part(cd.default_cost_centers_full_path, '/', 2), 2,
                                                CHARINDEX(' ', split_part(cd.default_cost_centers_full_path, '/', 2)) - 1
                                               )
                                        ),
                                     split_part(cd.default_cost_centers_full_path, '/', 2)
                                    )
                         WHEN DCCFP_type = 2
                            THEN IFF(split_part(cd.default_cost_centers_full_path, '/', 1) NOT LIKE '% %',
                                     RIGHT(split_part(cd.default_cost_centers_full_path, '/', 1),
                                           len(split_part(cd.default_cost_centers_full_path, '/', 1)) - 1
                                          ),
                                     SUBSTR(split_part(cd.default_cost_centers_full_path, '/', 1), 2,
                                            CHARINDEX(' ', split_part(cd.default_cost_centers_full_path, '/', 1)) - 1
                                           )
                                    )
                    END
                   ) as region,
            COALESCE(mrx.district,
                    CASE WHEN DCCFP_type = 1 THEN IFF(REGEXP_LIKE(split_part(DEFAULT_COST_CENTERS_FULL_PATH, '/', 3), '[0-9]+-[0-9]+'),
                                                      split_part(DEFAULT_COST_CENTERS_FULL_PATH, '/', 3), null
                                                     )
                         WHEN DCCFP_type = 2 THEN IFF(REGEXP_LIKE(split_part(DEFAULT_COST_CENTERS_FULL_PATH, '/', 2), '[0-9]+-[0-9]+'),
                                                      split_part(DEFAULT_COST_CENTERS_FULL_PATH, '/', 2), null
                                                     )
                    END
                   ) as district,
            cd.employee_title
          FROM analytics.payroll.company_directory cd
          LEFT JOIN analytics.public.market_region_xwalk mrx ON cd.market_id = mrx.market_id
          WHERE lower(cd.work_email) = lower('{{ _user_attributes['email'] }}')
            AND cd.employee_status NOT IN ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated')
          QUALIFY ROW_NUMBER() OVER(PARTITION BY employee_id ORDER BY date_hired) = 1
        )

        SELECT
            sod.SOR_ID,
            sod.SUBMISSION_DATE,
            sod.EMPLOYEE_EMAIL,
            sod.EMPLOYEE_NAME,
            sod.BRANCH_LOCATION,
            sod.MARKET_ID,
            sod.MARKET_TYPE,
            sod.DISTRICT,
            sod.REGION,
            sod.OBSERVATION_CATEGORY,
            sod.OBSERVATION_TYPE,
            sod.OBSERVATION_DATE,
            sod.OBSERVATION_TIME,
            sod.OBSERVATION_LOCATION,
            sod.OBSERVATION_DESCRIPTION_SUMMARY,
            sod.FULL_OBSERVATION_DESCRIPTION,
            sod.PHOTOS_PRESENT,
            sod.CORRECTIVE_ACTION,
            sod.CORRECTIVE_ACTION_TYPE,
            sod.SAFETY_MANAGER_ELEVATION
         FROM "ANALYTICS"."BI_OPS"."SAFETY_OBSERVATION_DETAILS" sod
         CROSS JOIN user_info
         WHERE ({{ _user_attributes['job_role'] }} IN ('safety', 'developer', 'leadership')
                OR user_info.employee_title = 'Regional Safety Manager')
            OR (
                {{ _user_attributes['job_role'] }} IN ('general_mgr', 'service_mgr')
                AND (sod.market_id = user_info.market_id OR sod.market_id::varchar IN ( {{ _user_attributes['market_id'] }} ) )
               )
            OR (
                ({{ _user_attributes['job_role'] }} = 'district_ops' OR {{ _user_attributes['job_role'] }} = 'district_sales_manager')
                AND (sod.district = user_info.district OR sod.district IN ( {{_user_attributes['district']}} ) )
               )
            OR (
                ({{ _user_attributes['job_role'] }} = 'regional_ops'
                 OR {{ _user_attributes['job_role'] }} = 'regional_service_mgr'
                 OR {{ _user_attributes['job_role'] }} = 'hrbp'
                )
                AND (TRY_TO_NUMBER(sod.region) = TRY_TO_NUMBER(user_info.region)
                     OR user_info.region = 'National'
                     OR user_info.region = 'Corp'
                    )
               )
            -- hard code access for Luis Johnson to Albuquerque Core
            OR (user_info.employee_id = 7113 AND sod.market_id = 24079)
            OR (user_info.employee_id = 17460 AND sod.market_id = 157305)
            OR (user_info.employee_id = 4408 AND sod.region = 7)
            OR (user_info.employee_id = 15653 AND sod.market_id = 111298);;
 }
  measure: count {
    type: count
    drill_fields: [employee_detail*]
  }

  measure: count_detail {
    label: "Observation Count"
    type: count
    drill_fields: [detail*]
  }

  dimension: sor_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."SOR_ID" ;;
  }

  dimension_group: submission_date {
    type: time
    sql: ${TABLE}."SUBMISSION_DATE" ;;
    convert_tz: no
  }

  dimension: employee_email {
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL" ;;
  }

  dimension: employee_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
    html: <font color="#000000">
    {{rendered_value}}
    <br />
    <font style="color: #8C8C8C; text-align: right;">{{employee_email._rendered_value}}</font>
    </font> ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH_LOCATION";;
  }

  dimension: branch_location {
    type: string
    sql: ${TABLE}."BRANCH_LOCATION" ;;
    html: <font color="#000000">
    {{rendered_value}}
    <br />
    <font style="color: #8C8C8C; text-align: right;">District {{district._rendered_value}}</font>
    </font> ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: CONCAT('Region', ' ', CAST(${TABLE}."REGION" as varchar)) ;;
  }

  dimension: observation_category {
    type: string
    sql: ${TABLE}."OBSERVATION_CATEGORY" ;;
    html: <font color="#000000">
    {{rendered_value}}
    <br />
    <font style="color: #8C8C8C; text-align: right;">{{observation_type._rendered_value}}</font>
    </font> ;;
  }

  dimension: observation_type {
    type: string
    sql: ${TABLE}."OBSERVATION_TYPE" ;;
  }

  dimension: observation_date {
    type: date
    sql: ${TABLE}."OBSERVATION_DATE" ;;
    convert_tz: no
    html: <font color="#000000">
    {{value}}
    <br />
    <font style="color: #8C8C8C; text-align: right;">{{observation_time._rendered_value}}</font>
    </font> ;;
  }

  dimension: observation_time {
    type: string
    sql: ${TABLE}."OBSERVATION_TIME" ;;
  }

  dimension: observation_location {
    type: string
    sql: ${TABLE}."OBSERVATION_LOCATION" ;;
  }

  dimension: observation_description_summary {
    type: string
    sql: ${TABLE}."OBSERVATION_DESCRIPTION_SUMMARY" ;;
    html:
      {% if rendered_value == full_observation_description._rendered_value %}
      {{rendered_value}}
      {% else %}
      <font color="#0000FF">
      <a href="https://equipmentshare.looker.com/dashboards/1746?Observation+ID={{sor_id._filterable_value | url_encode}}" target="_blank">
      {{rendered_value}}
      </a></font>
      {% endif %};;
  }

  dimension: full_observation_description {
    type: string
    sql: ${TABLE}."FULL_OBSERVATION_DESCRIPTION" ;;
  }

  dimension: photos_present {
    type: yesno
    sql: ${TABLE}."PHOTOS_PRESENT";;
  }

  dimension: photos {
    type: string
    sql: '' ;;
    html:
      {% if photos_present._rendered_value == 'No' %}
      {% else %}
      <font color="#0000FF">
      <a href="https://equipmentshare.looker.com/dashboards/1746?Observation+ID={{sor_id._filterable_value | url_encode}}" target="_blank">
      See Photos ➔
      </a></font>
      {% endif %};;
  }

  dimension: corrective_action {
    type: string
    sql: ${TABLE}."CORRECTIVE_ACTION" ;;
    html: <font color="#000000">
    {{rendered_value}}
    <br />
    <font style="color: #8C8C8C; text-align: right;">{{corrective_action_type._rendered_value}}</font>
    </font> ;;
  }

  dimension: corrective_action_type {
    type: string
    sql: ${TABLE}."CORRECTIVE_ACTION_TYPE" ;;
  }

  dimension: safety_manager_elevation {
    type: string
    sql: ${TABLE}."SAFETY_MANAGER_ELEVATION" ;;
  }

  measure: positive_recognition_count {
    type: count
    filters: [observation_category: "Positive Recognition"]
    drill_fields: [employee_detail*]
  }

  measure: unsafe_condition_count {
    type: count
    filters: [observation_category: "Unsafe Condition"]
    drill_fields: [employee_detail*]
  }

  measure: near_miss_count {
    type: count
    filters: [observation_category: "Near-Miss"]
    drill_fields: [employee_detail*]
  }

  measure: unsafe_act_count {
    type: count
    filters: [observation_category: "Unsafe Act"]
    drill_fields: [employee_detail*]
  }

  measure: unspecified_count {
    type: count
    filters: [observation_category: "Unspecified"]
    drill_fields: [employee_detail*]
  }

  set: detail {
    fields: [
      employee_name,
      district,
      branch_location,
      observation_date,
      observation_time,
      observation_location,
      observation_category,
      observation_type,
      observation_description_summary,
      photos,
      corrective_action,
      corrective_action_type,
      safety_manager_elevation
    ]
  }

  set: employee_detail {
    fields: [
      employee_name,
      district,
      branch_location,
      count_detail
    ]
  }
}
