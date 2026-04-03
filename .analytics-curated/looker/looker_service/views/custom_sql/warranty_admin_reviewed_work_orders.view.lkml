view: warranty_admin_reviewed_work_orders {
  derived_table: {
    sql:
select waa.user_id
    , waa.warranty_admin
    , ca.parameters:work_order_id work_order_id
    , max(ca.date_created::DATE) as last_interaction
from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT ca
join (
        select u.user_id::STRING as user_id, coalesce(waa.warranty_admin, cd.nickname) as warranty_admin
        from ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
        join ES_WAREHOUSE.PUBLIC.USERS u
          on u.employee_id::STRING = cd.employee_id::STRING
        left join (select distinct warranty_admin, user_id from ANALYTICS.WARRANTIES.WARRANTY_ADMIN_ASSIGNMENTS) waa
          on waa.user_id::STRING = u.user_id::STRING
        where cd.employee_title ilike '%warranty%'
          and cd.employee_status = 'Active'
          and cd.location = 'Corporate Service'

        union

        select user_id::STRING as user_id, concat(first_name, ' ', last_name) as warranty_admin
        from ES_WAREHOUSE.PUBLIC.USERS u
        where user_id in (28868, 159621) --Charles and Dave in order

        union

        select user_id::STRING as user_id, concat(first_name, ' ', last_name) as warranty_admin
        from ES_WAREHOUSE.PUBLIC.USERS u
        where user_id in (222408, 29401) --shane morgan and steven davis, supporting lacy's team now but not technically admins
      ) waa
    on waa.user_id::STRING = ca.user_id::STRING
group by waa.user_id
    , waa.warranty_admin
    , work_order_id
order by last_interaction desc ;;
  }
  dimension: user_id {
  type: string #There is text in here
  sql: ${TABLE}.user_id ;;
 }

  dimension: warranty_admin {
    type: string
    sql: ${TABLE}.warranty_admin ;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }

  measure: wo_reviewed {
    type: count
    drill_fields: [
        work_order_id
        , reviewed_date
      ]
  }

  dimension: reviewed_date {
    type: date
    sql: ${TABLE}.last_interaction;;
  }
}
