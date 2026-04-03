# Table is Fivetran'd from this sheet: https://docs.google.com/spreadsheets/d/1dZnMXgWN0fIUT2JvjSmABw-B64Zd3VJScoI5zC0cuoE/edit#gid=0
view: national_account_coordinators {
  derived_table: {
    sql:
      select
        distinct u.user_id
      from
        es_warehouse.public.users u
      inner join
        analytics.payroll.company_directory cd
      on cd.employee_id = TRY_TO_NUMBER(NULLIF(u.employee_id, ''))
      where
        cd.employee_title IN ('National Account Coordinator', 'National Accounts Coordinator')
        and cd.employee_status = 'Active'
        and cd.employee_id IS not null
        and cd.employee_status IS not null ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: is_national_account_coordinator {
    type: yesno
    sql: IFF(${user_id} is not null, TRUE, FALSE) ;;
  }

}
