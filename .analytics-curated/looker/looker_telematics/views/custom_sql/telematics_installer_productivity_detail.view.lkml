view: telematics_installer_productivity_detail {
    derived_table: {
      sql: select concat(u.first_name, ' ', u.last_name)  as installer,
       u.email_address,
       cd.MARKET_ID                            as User_Market_ID,
       mrx.MARKET_ID,
       ifnull(mrx.MARKET_NAME, tr.MARKET_NAME) as MARKET_NAME,
       tr.TELEMATICS_REGION_NAME,
       er.TIME_ENTRY_ID,
       er.START_DATE,
       er.END_DATE,
       er.WORK_ORDER_ID,
       er.JOB_ID,
       er.BRANCH_ID,
       er.ASSET_ID,
       er.APPROVAL_STATUS,
       sum(er.overtime_hours)                  as overtime_hours,
       sum(er.regular_hours)                   as regular_hours,
       sum(er.regular_hours + er.overtime_hours) as total_hours,
       n.content                               as time_entry_note,
       j.name                                  as job_description,
       IFF(er.work_order_id is NULL, 0, total_hours) as assigned_hours,
       IFF(er.work_order_id is NULL, total_hours, 0) as unassigned_hours
from es_warehouse.time_tracking.time_entries er
         join es_warehouse.public.users u on u.user_id = er.user_id
         left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
                   on cd.WORK_EMAIL = u.EMAIL_ADDRESS
                  AND CD.EMPLOYEE_STATUS NOT IN ('Inactive', 'Terminated')
         left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx
                   on cd.MARKET_ID = mrx.MARKET_ID
         left join ANALYTICS.LOOKER_INPUTS.TELEMATICS_REGIONS tr
                   on cd.MARKET_ID = tr.MARKET_ID
         left join es_warehouse.time_tracking.notes n
                   on n.note_id = er.note_id
    --new joins from old code
         left join es_warehouse.work_orders.work_orders wo
                   on er.work_order_id = wo.work_order_id
    --left join work_orders.urgency_levels ul on ul.urgency_level_id = wos.urgency_level_id
    --left join work_orders.billing_types bt on bt.billing_type_id = wos.billing_type_id
    --want to change join from assets -> markets to just markets and tie to users branch id
         left join es_warehouse.public.jobs j on j.job_id = er.job_id
         left join es_warehouse.time_tracking.time_entry_work_code_xref tewc
                   on er.time_entry_id = tewc.time_entry_id
         left join es_warehouse.public.organization_user_xref oux
                   on oux.user_id = er.user_id
         left join es_warehouse.public.organizations o
                   on o.organization_id = oux.organization_id
where
  --When the date selector parameter is blank/null, we are defaulting to last 90 days - PB
      er.start_date >= coalesce({% date_start date_filter %}, DATEADD(day, -90, CURRENT_DATE))
  AND er.end_date   <= coalesce({% date_end   date_filter %}, CURRENT_DATE())
  AND er.event_type_id = 1 --only pulling 'on duty' event types
  AND er.archived = false
  AND o.name = 'Telematics Installation'
  AND cd.employee_status in ('Active', 'Leave without Pay', 'Leave with Pay',
                             'Military Training Program', 'Work Comp Leave',
                             'External Payroll')
  and (cd.WORK_EMAIL like '%equipmentshare.com%' or
       cd.WORK_EMAIL like '%forgeandbuild.com%')
  and cd.DATE_HIRED <= current_date
group by er.TIME_ENTRY_ID, u.email_address, cd.MARKET_ID, mrx.MARKET_ID, ifnull(mrx.MARKET_NAME, tr.MARKET_NAME),
         tr.TELEMATICS_REGION_NAME, concat(u.first_name, ' ', u.last_name), er.START_DATE, er.END_DATE,
         er.WORK_ORDER_ID, er.JOB_ID, er.BRANCH_ID, er.ASSET_ID, er.APPROVAL_STATUS, n.content, j.name ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: installer {
      type: string
      sql: ${TABLE}."INSTALLER" ;;
    }

    dimension: email_address {
      type: string
      sql: ${TABLE}."EMAIL_ADDRESS" ;;
    }

    dimension: user_market_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."USER_MARKET_ID" ;;
    }

    dimension: market_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."MARKET_ID" ;;
    }

    dimension: market_name {
      type: string
      sql: ${TABLE}."MARKET_NAME" ;;
    }

    dimension: telematics_region_name {
      type: string
      sql: ${TABLE}."TELEMATICS_REGION_NAME" ;;
    }

    dimension: time_entry_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."TIME_ENTRY_ID" ;;
    }

    dimension_group: start_date {
      type: time
      sql: ${TABLE}."START_DATE" ;;
    }

    dimension_group: end_date {
      type: time
      sql: ${TABLE}."END_DATE" ;;
    }

    dimension: work_order_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."WORK_ORDER_ID" ;;
      html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
    }

    dimension: job_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."JOB_ID" ;;
    }

    dimension: branch_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."BRANCH_ID" ;;
    }

    dimension: asset_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."ASSET_ID" ;;
    }

    measure: overtime_hours {
      type: sum
      value_format_name: decimal_1
      html: {{rendered_value}} hrs. ;;
      sql: ${TABLE}."OVERTIME_HOURS" ;;
    }

    measure: regular_hours {
      type: sum
      value_format_name: decimal_1
      html: {{rendered_value}} hrs. ;;
      sql: ${TABLE}."REGULAR_HOURS" ;;
    }

    measure: total_hours {
      type: sum
      value_format_name: decimal_1
      html: {{rendered_value}} hrs. ;;
      sql: ${TABLE}."TOTAL_HOURS" ;;
    }

    measure: assigned_hours {
      type: sum
      value_format_name: decimal_1
      html: {{rendered_value}} hrs. ;;
      sql: ${TABLE}."ASSIGNED_HOURS" ;;
    }

    measure: unassigned_hours {
      type: sum
      value_format_name: decimal_1
      html: {{rendered_value}} hrs. ;;
      sql: ${TABLE}."UNASSIGNED_HOURS" ;;
    }

    measure: percent_unassigned {
      type: number
      value_format_name: percent_1
      sql: ${unassigned_hours}/nullifzero(${total_hours}) ;;
    }

    dimension: time_entry_note {
      type: string
      sql: ${TABLE}."TIME_ENTRY_NOTE" ;;
    }

    dimension: job_description {
      type: string
      sql: ${TABLE}."JOB_DESCRIPTION" ;;
    }

    dimension: approval_status {
      type: string
      sql: ${TABLE}."APPROVAL_STATUS" ;;
    }

    filter: date_filter {
      type: date
    }

    set: detail {
      fields: [
        installer,
        email_address,
        user_market_id,
        market_id,
        market_name,
        telematics_region_name,
        time_entry_id,
        start_date_time,
        end_date_time,
        work_order_id,
        job_id,
        branch_id,
        asset_id,
        overtime_hours,
        regular_hours,
        time_entry_note,
        job_description
      ]
    }
  }
