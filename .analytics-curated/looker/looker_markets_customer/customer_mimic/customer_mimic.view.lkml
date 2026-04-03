
view: customer_mimic {
  derived_table: {
    sql: with sales_rep_access as (
      select distinct
          c.company_id,
          c.name as customer,
          rep.user_id,
          case when {{ _user_attributes['job_role'] }} = 'tam' then rep.email_address else '{{ _user_attributes['email'] }}' end as email_address, --dynamically insert job role attribute value in at the beginning statement and for else dynmically insert logged in user to allow non reps to pull all companies
          --case when 'salesperson' = 'salesperson' then rep.email_address else 'michael.brown@equipmentshare.com' end as email_address, --dynamically insert job role attribute value in at the beginning statement and for else dynmically insert logged in user to allow non reps to pull all companies
          concat(rep.first_name,' ',rep.last_name) as rep_name
      from
          es_warehouse.public.orders o
          left join es_warehouse.public.order_salespersons os on o.order_id = os.order_id
          left join es_warehouse.public.users u on u.user_id = o.user_id
          left join es_warehouse.public.companies c on c.company_id = u.company_id
          left join es_warehouse.public.users rep on coalesce(os.user_id,o.user_id) = rep.user_id
          left join analytics.payroll.company_directory cd on cd.work_email = rep.email_address
      where
          o.order_status_id <> 8 --remove cancelled orders
          AND c.company_id <> 1854 --remove ES as a company
          AND cd.EMPLOYEE_STATUS not in ('Terminated', 'Never Started', 'Not In Payroll', 'On Leave', 'Temporary Worker', 'Contractor', 'Inactive') --remove non active employees
      )
      select
          stl.company_id,
          sra.customer,
          concat(stl.company_id,' - ',sra.customer) as company_id_and_name,
          stl.fleet_login_link,
          stl.analytics_login_link
      from
          es_warehouse.public.sales_track_logins stl
          join sales_rep_access sra on stl.company_id = sra.company_id
      where
          email_address = '{{ _user_attributes['email'] }}';;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER" ;;
  }

  dimension: company_id_and_name {
    type: string
    sql: ${TABLE}."COMPANY_ID_AND_NAME" ;;
  }

  dimension: fleet_login_link {
    type: string
    sql: ${TABLE}."FLEET_LOGIN_LINK" ;;
  }

  dimension: analytics_login_link {
    type: string
    sql: ${TABLE}."ANALYTICS_LOGIN_LINK" ;;
  }

  dimension: customer_name_with_link_to_customer_dashboard {
    group_label: "Formatted Customer Name"
    label: "Customer"
    type: string
    sql: ${company_id_and_name} ;;
    link: {
      label: "View Customer Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ customer._filterable_value | url_encode }}&Company%20ID="
    }
  }

  dimension: t3_link {
    group_label: "Formatted Links"
    label: " " #Don't need name to display in table column...link name is straightforward enough
    type: string
    html:<font color="0063f3 "><u><a href="{{ fleet_login_link._value }}" target="_blank">T3 Fleet ➔</a></font></u> ;;
    sql: ${company_id}  ;;
  }

  dimension: t3_analytics_link {
    group_label: "Formatted Links"
    label: " " #Don't need name to display in table column...link name is straightforward enough
    type: string
    html:<p><font color="0063f3 "><u><a href="{{ analytics_login_link._value }}" target="_blank">T3 Analytics ➔</a></font></u></p>;;
    sql: ${company_id}  ;;
  }

  set: detail {
    fields: [
        company_id,
  customer,
  company_id_and_name,
  fleet_login_link,
  analytics_login_link
    ]
  }
}
