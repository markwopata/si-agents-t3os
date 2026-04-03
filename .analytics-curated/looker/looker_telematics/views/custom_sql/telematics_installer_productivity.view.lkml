view: telematics_installer_productivity {
    derived_table: {
      sql: with telematics_installer_reg_ot_hours as (select concat(u.first_name, ' ', u.last_name) as installer,
                                                  u.email_address,
                                                  cd.MARKET_ID                           as User_Market_ID,
                                                  mrx.MARKET_ID,
                                                  ifnull(mrx.MARKET_NAME, tr.MARKET_NAME)as MARKET_NAME,
                                                  tr.TELEMATICS_REGION_NAME,
                                                  sum(er.overtime_hours)                 as overtime_hours,
                                                  sum(er.regular_hours)                  as regular_hours,
                                                  sum(coalesce(er.overtime_hours, 0)) +
                                                  sum(coalesce(er.regular_hours, 0))     as total_hours,
                                                  count(distinct (er.work_order_id))     as total_work_orders
                                           from es_warehouse.time_tracking.time_entries er
                                                    join es_warehouse.public.users u on u.user_id = er.user_id
                                                    left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
                                                              on UPPER(cd.WORK_EMAIL) = UPPER(u.EMAIL_ADDRESS)
                                                              AND CD.EMPLOYEE_STATUS NOT IN ('Inactive', 'Terminated')
                                                    left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx
                                                              on cd.MARKET_ID = mrx.MARKET_ID
                                                    left join ANALYTICS.LOOKER_INPUTS.TELEMATICS_REGIONS tr
                                                              on cd.MARKET_ID = tr.MARKET_ID
                                                    left join es_warehouse.time_tracking.notes n
                                                              on n.note_id = er.note_id
                                                    left join es_warehouse.work_orders.work_orders wo
                                                              on er.work_order_id = wo.work_order_id
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
                                           group by concat(u.first_name, ' ', u.last_name),
                                                    u.email_address, cd.MARKET_ID, mrx.MARKET_ID, mrx.MARKET_NAME,
                                                    tr.MARKET_NAME, tr.TELEMATICS_REGION_NAME)
   , installer_travel_time as (select concat(u.first_name, ' ', u.last_name) as installer,
                                      u.email_address,
                                      sum(coalesce(er.overtime_hours, 0)) +
                                      sum(coalesce(er.regular_hours, 0))     as total_travel_hours
                               from es_warehouse.time_tracking.time_entries er
                                        join es_warehouse.public.users u on u.user_id = er.user_id
                                        left join es_warehouse.time_tracking.notes n on n.note_id = er.note_id
                                        left join es_warehouse.work_orders.work_orders wo
                                                  on er.work_order_id = wo.work_order_id
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
                                 AND j.name in ('T3 Travel', 'Telematics Travel')
                               group by concat(u.first_name, ' ', u.last_name),
                                        u.email_address)
   , installer_unassigned_time as (select concat(u.first_name, ' ', u.last_name) as installer,
                                          u.email_address,
                                          sum(coalesce(er.overtime_hours, 0)) +
                                          sum(coalesce(er.regular_hours, 0))     as total_unassigned_hours
                                   from es_warehouse.time_tracking.time_entries er
                                            join es_warehouse.public.users u on u.user_id = er.user_id
                                            left join es_warehouse.time_tracking.notes n on n.note_id = er.note_id
                                            left join es_warehouse.work_orders.work_orders wo
                                                      on er.work_order_id = wo.work_order_id
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
                                     AND er.JOB_ID is null
                                     --AND j.name in ('T3 Travel', 'Telematics Travel')
                                   group by concat(u.first_name, ' ', u.last_name),
                                            u.email_address)
select th.installer,
       th.email_address,
       th.User_Market_ID,
       th.MARKET_ID,
       ifnull(th.MARKET_NAME, 'Unknown Market')            as MARKET_NAME,
       ifnull(th.TELEMATICS_REGION_NAME, 'Unknown Region') as TELEMATICS_REGION_NAME,
       th.overtime_hours,
       th.regular_hours,
       th.total_hours,
       th.total_work_orders,
       coalesce(itt.total_travel_hours, 0)                 as total_travel_hours,
       coalesce(iut.total_unassigned_hours, 0)             as total_unassigned_hours
from telematics_installer_reg_ot_hours th
         left join installer_travel_time itt on th.installer = itt.installer
         left join installer_unassigned_time iut on th.installer = iut.installer
;;
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
          primary_key: yes
          sql: ${TABLE}."EMAIL_ADDRESS" ;;
        }

        dimension: market_name {
          type: string
          sql: ${TABLE}."MARKET_NAME" ;;
        }

        dimension: telematics_region_name {
          type: string
          sql: ${TABLE}."TELEMATICS_REGION_NAME" ;;
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

        measure: total_work_orders {
          type: sum
          value_format_name: decimal_0
          sql: ${TABLE}."TOTAL_WORK_ORDERS" ;;
        }

        measure: total_travel_hours {
          type: sum
          value_format_name: decimal_1
          html: {{rendered_value}} hrs. ;;
          sql: ${TABLE}."TOTAL_TRAVEL_HOURS" ;;
        }

        measure: total_unassigned_hours {
          type: sum
          value_format_name: decimal_1
          html: {{rendered_value}} hrs. ;;
          sql: ${TABLE}."TOTAL_UNASSIGNED_HOURS" ;;
        }

        measure: overtime_percentage {
          type: number
          value_format_name: percent_1
        sql: sum(${TABLE}."OVERTIME_HOURS") / sum(${TABLE}."TOTAL_HOURS") ;;
        }

        measure: productivity_per_hour {
          label: "Avg # of WO's Per Hour"
          type: number
         value_format: "0.##"
          sql: sum(${TABLE}."TOTAL_WORK_ORDERS") / (sum(${TABLE}."TOTAL_HOURS") - sum(${TABLE}."TOTAL_TRAVEL_HOURS")) ;;
        }

        measure: travel_percentage {
          type: number
          value_format_name: percent_1
        sql: sum(${TABLE}."TOTAL_TRAVEL_HOURS") / sum(${TABLE}."TOTAL_HOURS") ;;
        }

        filter: date_filter {
          type: date
        }

        set: detail {
          fields: [
            installer,
            email_address,
            market_name,
            telematics_region_name,
            overtime_hours,
            regular_hours,
            total_hours,
            total_work_orders,
            total_travel_hours,
            overtime_percentage,
            productivity_per_hour,
            travel_percentage
          ]
        }
      }
