view: time_tracking_work_code {
  derived_table: {
    sql:
    with ccc_date as (
      select
          ccl.work_order_id,
          ccl.description,
          ccsl.cluster_label_id,
          ccsl.cluster_label,
          ccsl.cluster_group,
      from data_science.wokb.ccc_cluster_labels ccl
      join data_science.wokb.ccc_cluster_string_labels ccsl
          on ccl.cluster_label_id = ccsl.cluster_label_id and ccl.model_version = ccsl.model_version and ccl.description = ccsl.description
      where ccl.model_version = (select max(model_version) from data_science.wokb.ccc_cluster_labels)
    ), three_c_clusters as (
        select wo.work_order_id
            --complaint
            , cpt.cluster_label_id as complaint_cluster_label_id
            , cpt.CLUSTER_LABEL
            , cpt.cluster_group as complaint_group
            --cause
            , cause.cluster_label_id as cause_cluster_label_id
            , cause.CLUSTER_LABEL
            , cause.cluster_group as cause_group
            --correction
            , cor.cluster_label_id as correction_cluster_label_id
            , cor.CLUSTER_LABEL
            , cor.cluster_group as correction_group
            , case
                when cause_group = correction_group then correction_group
                when cause_group = 'UNINFORMATIVE' then correction_group
                when correction_group = 'UNINFORMATIVE' then cause_group
                when correction_group = 'OTHER' and cause_group not in ('OTHER','UNINFORMATIVE') and cause_group is not null then cause_group
                when cause_group in ('OTHER','UNINFORMATIVE') and correction_group in ('OTHER','UNINFORMATIVE') then 'Indescript Work Order'
                else coalesce(correction_group,cause_group,complaint_group)
              end as problem_group
        from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        left join ccc_date as cpt
            on cpt.work_order_id = wo.work_order_id
                and cpt.description = 'complaint'
        left join ccc_date as cause
            on cause.work_order_id = wo.work_order_id
                and cause.description = 'cause'
        left join ccc_date as cor
            on cor.work_order_id = wo.work_order_id
                and cor.description = 'correction'
        where coalesce(coalesce(cpt.work_order_id, cause.work_order_id), cor.work_order_id) is not null
    )
    SELECT t.user_id,
           t.event_type_id,
           t.start_date,
           t.end_date,
           t.work_order_id as wo_id,
           t.job_id,
           c.WORK_CODE_ID as wc_id,
           t.branch_id              time_entries_branch_id,
           cd.market_id             tech_home_branch_id,
           xwalk.DISTRICT,
           xwalk.REGION,
           xwalk.REGION_NAME,
           xwalk.MARKET_NAME,
           t.regular_hours,
           t.overtime_hours,
           t.regular_hours + t.overtime_hours as total_hours,
           t.approval_status,
           c.name work_code,
           j.name job,
           u.first_name||' '||u.last_name as employee_name,
           cd.employee_title,
           case
                when cd.EMPLOYEE_TITLE ilike '%shop tech%' or
                     cd.EMPLOYEE_TITLE ilike '%shop mech%'
                  then 'Shop Tech'
                when cd.EMPLOYEE_TITLE ilike '%field tech%' or
                     cd.EMPLOYEE_TITLE ilike '%field mech%' or
                     cd.EMPLOYEE_TITLE ilike '%traveling tech%' or
                     cd.EMPLOYEE_TITLE ilike '%road mech%'
                  then 'Field Tech'
                when cd.EMPLOYEE_TITLE ilike '%telematics%'
                  then 'Telematics Tech'
                when cd.EMPLOYEE_TITLE ilike '%yard technician%'
                  then 'Yard Tech'
                when (cd.EMPLOYEE_TITLE ilike '%tech%' or cd.EMPLOYEE_TITLE ilike '%mech%')
                  then 'General Mechanic'
                else 'Non-Technician'
           end as tech_position,
           case
                when wo_id is not null then 'Work Order'
                when job is not null then job
                when wc_id is not null then work_code
                else 'Unassigned'
           end job_code,
           case
                when wc_id is not null then c.name
                when (wo_id is not null or t.job_id is not null) and ccc.work_order_id is null then 'Missing Work Code'
                when wo_id is not null or t.job_id is not null
                  then
                  case
                       when ccc.problem_group in ('OTHER','UNINFORMATIVE')
                         or ccc.problem_group is null then 'Indescript Work Order'
                       else ccc.problem_group
                  end
                else 'Unassigned'
           end as cost_code,
           case when t.user_id is null then 'Unassigned'
                when time_entries_branch_id is null then 'Branch Tech'
                else iff(t.BRANCH_ID = cd.MARKET_ID, 'Branch Tech', 'Traveling Tech')
           end as wo_emp_branch_match
    from ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRIES as t
    left join ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRY_WORK_CODE_XREF as w
        on t.time_entry_id = w.time_entry_id
    left join ES_WAREHOUSE.TIME_TRACKING.WORK_CODES as c
        on w.work_code_id = c.work_code_id
    left join ES_WAREHOUSE.PUBLIC.JOBS as j
        on t.job_id = j.job_id
    join ES_WAREHOUSE.PUBLIC.USERS as u
        on t.user_id = u.user_id
    inner join ANALYTICS.PAYROLL.COMPANY_DIRECTORY as cd
        on U.EMPLOYEE_ID::VARCHAR = CD.EMPLOYEE_ID::VARCHAR
    JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK AS xwalk
        ON cd.MARKET_ID = xwalk.MARKET_ID
    left join three_c_clusters as ccc
        on t.work_order_id = ccc.work_order_id
    where t.approval_status ='Approved' and
          t.START_DATE >= '2022-01-01' and
          t.EVENT_TYPE_ID = 1 and
          cd.EMPLOYEE_TITLE ilike any ('%technician%', '%mechanic%', '%telematics%') and
          cd.EMPLOYEE_TITLE not ilike '%yard technician%'-- Mark W says don't include yard techs
;;
}
  parameter: drop_down_selection_with_tech {
    type: string
    allowed_value: {value: "Company"}
    allowed_value: {value: "Region"}
    allowed_value: {value: "District"}
    allowed_value: {value: "Market"}
    allowed_value: {value: "Technician"}
  }

  dimension: dynamic_location_with_tech {
    description: "Allows user to pick between Company, Region, District, and Market Axis."
    label_from_parameter: drop_down_selection_with_tech
    sql:
    {% if drop_down_selection_with_tech._parameter_value == "'Region'" %}
      ${region_name}
    {% elsif drop_down_selection_with_tech._parameter_value == "'District'" %}
      ${district}
    {% elsif drop_down_selection_with_tech._parameter_value == "'Market'" %}
      ${market_name}
    {% elsif drop_down_selection_with_tech._parameter_value == "'Technician'" %}
      case when ${employee_name} is null then ${market_name} else ${employee_name} end
    {% else %}
      NULL
    {% endif %} ;;
  }
  parameter: include_traveling_techs {
    label: "Include Traveling Techs"
    type: string
    allowed_value: {value: "Yes"}
    allowed_value: {value: "No"}
    default_value: "Yes"
  }
    # Market / region (from xwalk)
    dimension: region                   { type: string sql: ${TABLE}.REGION ;; }
    dimension: region_name              { type: string sql: ${TABLE}.REGION_NAME ;; }
    dimension: district                 { type: string sql: ${TABLE}.DISTRICT ;; }
    dimension: market_name              { type: string sql: ${TABLE}.MARKET_NAME ;; }

    dimension: include_traveling_techs_filter {
      label_from_parameter: include_traveling_techs
      # type: string
      # hidden: yes
      sql:{% if include_traveling_techs._parameter_value == "'Yes'" %}
            'Yes'
          {% else %}
            case when ${tech_location} = 'Branch Tech' then 'Yes'
                 when ${tech_location} = 'Indeterminate Branch' then 'Yes'
                 when ${tech_location} = 'Traveling Tech' then 'No'
            end
          {% endif %}
       ;;
    }

    dimension: user_id {
      type:  string
      sql:  ${TABLE}."USER_ID" ;;
    }
  dimension: wo_emp_branch_match {
    hidden: yes
    type: string
    sql: ${TABLE}.WO_EMP_BRANCH_MATCH ;;
  }
    dimension: tech_location {
      description: "Determines if the tech is a branch tech or a traveling tech.  Traveling techs are technicians with time on a work order other than their home branch."
      label_from_parameter: drop_down_selection_with_tech
      # type: string
      sql:${wo_emp_branch_match};;
    }

    dimension: tech_position{
      type: string
      sql: ${TABLE}."TECH_POSITION" ;;
    }

    dimension: event_type_id {
      type:  string
      sql:  ${TABLE}."EVENT_TYPE_ID";;
    }

    dimension_group: start_date {
      type: time
      timeframes: [raw,date,time,week,month,quarter,year]
      sql: ${TABLE}."START_DATE" ;;
    }

    dimension: end_date {
      type: date
      sql: ${TABLE}."END_DATE" ;;
    }

    dimension: wo_id {
      type: string
      sql: ${TABLE}."WO_ID" ;;
    }

    dimension: job_id {
      type: string
      sql: ${TABLE}."JOB_ID" ;;
    }

    dimension: wc_id {
      type: string
      sql: ${TABLE}."WC_ID" ;;
    }

    dimension: branch_id {
      type: string
      sql: ${TABLE}."TECH_HOME_BRANCH_ID" ;;
    }

    dimension: regular_hours {
      type: number
      sql: ${TABLE}."REGULAR_HOURS" ;;
    }

    dimension: overtime_hours {
      type: number
      sql: ${TABLE}."OVERTIME_HOURS" ;;
    }

    dimension: total_hours {
      type: number
      sql: ${TABLE}."TOTAL_HOURS" ;;
    }

    dimension: approval_status {
      type: string
      sql: ${TABLE}."APPROVAL_STATUS" ;;
    }

    dimension: work_code {
      type: string
      sql: ${TABLE}."WORK_CODE" ;;
    }

    dimension: job {
      type: string
      sql: ${TABLE}."JOB" ;;
    }

    dimension: employee_name {
      type: string
      sql: ${TABLE}."EMPLOYEE_NAME" ;;
    }

    dimension: cost_code {
      type: string
      sql: ${TABLE}."COST_CODE" ;;
    }

    dimension: employee_title {
      type: string
      sql: ${TABLE}."EMPLOYEE_TITLE" ;;
    }

    dimension: job_code {
      type: string
      sql: ${TABLE}."JOB_CODE" ;;
    }

    measure: total_hour {
      type: sum
      sql: ${total_hours} ;;
      value_format: "0.##"
      drill_fields: [detail*]
    }

    measure: assigned_hours {
      type: sum
      filters: [job_code: "-Unassigned"]
      value_format: "0.##"
      sql: ${total_hours};;
    }

    measure: unassigned_hours {
      type: sum
      filters: [job_code: "Unassigned"]
      value_format: "0.##"
      sql: ${total_hours} ;;
      drill_fields: [employee_name, employee_title, unassigned_hours, assigned_hours, total_hours]
    }

    measure: percent_unassigned {
      type: number
      value_format: "0.##%"
      sql: ${unassigned_hours}/nullifzero(${total_hour}) ;;
      drill_fields: [detail*]
    }

    measure: percent_assigned {
      type: number
      value_format: "0.##%"
      sql: ${assigned_hours}/nullifzero(${total_hour}) ;;
    }

  set: detail {
    fields: [
              employee_name,
              employee_title,
              tech_location,
              job_code,
              cost_code,
              wc_id,
              wo_id,
              assigned_hours,
              unassigned_hours
            ]
  }
}
