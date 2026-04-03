view: manager_hierarchy {
  # Description: "Employee-to-manager hierarchy with each employee's chain of managers.
  # Purpose of this model is to get, given a top level manager, all direct reports and their reports and so on."
  # Original Author: Vishesh
  # Notes: This view can definitely be a dbt model. We could materialize it as well. It will perform ok for now.
  #        - This only shows active employees right now.

  derived_table: {
    sql:
      with recursive
        org_up as (
            -- level = distance from employee (1 = direct manager)
            select e.employee_id,
                   e.work_email                 as employee_email,
                   1                            as level,
                   e.direct_manager_employee_id as manager_employee_id,
                   m.work_email                 as manager_email,
                   cast(m.nickname as string)   as manager_path
            from analytics.payroll.stg_analytics_payroll__company_directory e
                     join analytics.payroll.stg_analytics_payroll__company_directory m
                          on m.employee_id = e.direct_manager_employee_id
            where e.direct_manager_employee_id is not null
              and e.direct_manager_employee_id <> e.employee_id

            union all

            -- prepend so top dog ends up left-most
            select ou.employee_id,
                   ou.employee_email,
                   ou.level + 1                          as level,
                   m2.employee_id                        as manager_employee_id,
                   m2.work_email                         as manager_email,
                   m2.nickname || '/' || ou.manager_path as manager_path
            from org_up ou
                     join analytics.payroll.stg_analytics_payroll__company_directory m1
                          on m1.employee_id = ou.manager_employee_id
                     join analytics.payroll.stg_analytics_payroll__company_directory m2
                          on m2.employee_id = m1.direct_manager_employee_id
            where ou.level < 8
              and m1.direct_manager_employee_id is not null
              and m1.direct_manager_employee_id <> m1.employee_id),
        mx as (select employee_id,
                      max(level) as max_level
               from org_up
               group by employee_id),
        out as (select ou.employee_id::int           as employee_id,
                       ou.employee_email,
                       (mx.max_level - ou.level + 1) as level, -- 1 = top-most, increasing toward direct manager
                       ou.manager_employee_id::int   as manager_employee_id,
                       ou.manager_email,
                       ou.manager_path,
                       'hierarchy'                   as src
                from org_up ou
                         join mx
                              on mx.employee_id = ou.employee_id

                union
                -- union so we distinct between these

                -- Overrides. This should be a temporary solution to grant old access for now.
                select distinct pemo.employee_number::int as employee_id,
                                null                      as employee_email,
                                null                      as level,
                                null                      as manager_employee_id,
                                pemo.manager_email,
                                null                      as manager_path,
                                'overrides'               as src
                from analytics.gs.paycor_employees_managers_overrides pemo
                where pemo.employee_number is not null
                  and pemo.manager_email is not null)
    select *
    from out
    -- TESTS
    -- where out.manager_email = 'mandy.peters@equipmentshare.com' -- this should have 84 people as of 2026-01-29
    -- where out.employee_id = 3123 -- this line should have 2 people as of 2026-01-29 -- Mark and Jabbok
    -- END TESTS
    -- VM 2026-01-29: This is a stupid hack. There are overrides in the sheet that duplicate what company directory hierarchy covers.
    -- We can't directly union because some fields are ignored on the override
    qualify row_number() over (partition by manager_email, employee_id order by out.manager_email, out.employee_id, src) = 1
    order by employee_id, level ;;
  }

  dimension: employee_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.employee_id ;;
  }

  dimension: employee_email {
    type: string
    sql: ${TABLE}.employee_email ;;
  }

  dimension: level {
    type: number
    sql: ${TABLE}.level ;;
  }

  dimension: manager_employee_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.manager_employee_id ;;
  }

  dimension: manager_email {
    type: string
    sql: ${TABLE}.manager_email ;;
  }

  dimension: manager_path {
    type: string
    sql: ${TABLE}.manager_path ;;
  }
}
