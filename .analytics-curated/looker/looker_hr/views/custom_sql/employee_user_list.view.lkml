
view: employee_user_list {
  derived_table: {
    sql: with users as (
          select u.user_id,
                 cd.employee_id,
                 u.deleted,
                 u.first_name,
                 u.last_name,
                 u.email_address as t3_email_address,
                 cd.work_email as company_directory_email,
                 cd.employee_title,
                 u.date_created as user_created_date,
                 cd.date_hired,
                 cd.date_terminated,
                 cd.date_rehired
              from es_warehouse.public.users u
              left join analytics.payroll.company_directory cd on cd.work_email = u.email_address
              where u.company_id = 1854
      )
      , orders as (
          select user_id,
                 max(_es_update_timestamp) as last_order_date,
                 count(order_id) as order_count
              from es_warehouse.public.order_salespersons
              GROUP BY user_id
      )
      , invoices as (
          select salesperson_user_id,
                 max(date_created) as last_invoice_date,
                 count(invoice_id) as invoice_count
              from es_warehouse.public.invoices
              GROUP BY salesperson_user_id
      ),
          elogs as (
          select driver_id,
                 max(hist_timestamp) as last_elog_record,
                 count(driver_hist_id) as elog_record_count
          from es_warehouse.elogs.drivers_history
          GROUP BY driver_id
      ),
          time_tracking as (
              select USER_ID,
                     max(CREATED_DATE) as last_time_track_record,
                     count(distinct TIME_ENTRY_ID) as time_track_record_count
              from ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRIES
              where
            --      USER_ID = 76879
            --      and APPROVAL_STATUS like 'Approved' --- Keeping in unapproved incase the user has only unapproved time entries
                  BRANCH_ID is not null --- Assuming only people with a branch use time track
              group by USER_ID
          ),
      cost_capture as (
          with all_records as (select created_by_id as user_id,
                                      date_created,
                                      purchase_order_id as trans_id
          from procurement.public.purchase_orders
          where date_archived is null
          union
          select u.user_id,
                 transaction_date as date_created,
                 transaction_id as trans_id
              from analytics.public.cc_and_fuel_spend_all cc
              left join es_warehouse.public.users u on cc.employee_number = try_to_number(u.employee_id)
              )
          select user_id,
                 max(date_created) as last_cc_record,
                 count(trans_id) as cc_record_count
          from all_records
          group by user_id
      )
      select u.*,
             o.order_count,
             o.last_order_date,
             i.invoice_count,
             i.last_invoice_date,
             e.elog_record_count,
             e.last_elog_record,
             tt.time_track_record_count,
             tt.last_time_track_record,
             cc.cc_record_count,
             cc.last_cc_record
             from users u
      left join orders o on u.user_id = o.user_id
      left join invoices i on u.user_id = i.salesperson_user_id
      left join elogs e on u.user_id = e.driver_id
      left join time_tracking tt on u.user_id = tt.user_id
      left join cost_capture cc on u.user_id = cc.user_id ;;
  }

  measure: count {
    type: count
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: company_directory_email {
    type: string
    sql: ${TABLE}."COMPANY_DIRECTORY_EMAIL" ;;
  }

  dimension: user_email {
    type: string
    sql: ${TABLE}."T3_EMAIL_ADDRESS" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension_group: user_created {
    type: time
    sql: ${TABLE}."USER_CREATED_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: hired {
    type: time
    sql: ${TABLE}."DATE_HIRED" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: terminated {
    type: time
    sql: ${TABLE}."DATE_TERMINATED" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: rehired {
    type: time
    sql: ${TABLE}."DATE_REHIRED" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: order_count {
    type: number
    sql: ${TABLE}."ORDER_COUNT" ;;
  }

  dimension_group: last_order {
    type: time
    sql: ${TABLE}."LAST_ORDER_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: invoice_count {
    type: number
    sql: ${TABLE}."INVOICE_COUNT" ;;
  }

  dimension_group: last_invoice {
    type: time
    sql: ${TABLE}."LAST_INVOICE_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: elog_record_count {
    type: number
    sql: ${TABLE}."ELOG_RECORD_COUNT" ;;
  }

  dimension_group: last_elog_record {
    type: time
    sql: ${TABLE}."LAST_ELOG_RECORD" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: time_track_record_count {
    type: number
    sql: ${TABLE}."TIME_TRACK_RECORD_COUNT" ;;
  }

  dimension_group: last_time_track_record {
    type: time
    sql: ${TABLE}."LAST_TIME_TRACK_RECORD" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: cc_record_count {
    type: number
    sql: ${TABLE}."CC_RECORD_COUNT" ;;
  }

  dimension_group: last_cc_record {
    type: time
    sql: ${TABLE}."LAST_CC_RECORD" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

}
