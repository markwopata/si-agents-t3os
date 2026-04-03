view: salesperson_permissions {

  derived_table: {
    sql:

        WITH tooling_managers AS (
      select work_email
      from analytics.payroll.company_directory
      where employee_title ILIKE '%Regional Manager - Industrial%' OR employee_title ILIKE '%Director of Tooling%')

      select
      case
      when position(' ',coalesce(cd.nickname,cd.first_name)) = 0 then concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
      else
      concat(coalesce(nickname,concat(cd.first_name, ' ',cd.last_name))) end as rep,
      mn.manager_name,
      mn.manager_email,
      cd.employee_id,
      employee_status,
      employee_title,
      ca.manager_access_emails,
      location as employee_location,

      CASE
      WHEN employee_location ILIKE '%tooling%' THEN 'Tooling Solutions'
      WHEN employee_location ILIKE '%Core Solutions%' THEN 'Core Solutions'
      WHEN employee_location ILIKE '%Advanced Solutions%' THEN 'Advanced Solutions'
      ELSE NULL END as business_segment,

      work_email as employee_email,
      date_hired as employee_hire_date,
      u.user_id as employee_user_id,

      --IFF(manager_email = 'jacob.allen@equipmentshare.com',TRUE,FALSE) as direct_report, --will pass in looker email then can count this field for true reporting kpi
      --IFF(manager_email = '{{ _user_attributes['email'] }}',TRUE,FALSE) as direct_report, --will pass in looker email then can count this field for true reporting kpi

      mrx.district
      from analytics.payroll.pa_employee_access ca
      join analytics.payroll.company_directory cd on ca.employee_id = cd.employee_id
      join ( select
      distinct EMPLOYEE_ID as manager_id,
      case when position(' ',coalesce(NICKNAME,FIRST_NAME)) = 0 then concat(coalesce(NICKNAME,FIRST_NAME), ' ', LAST_NAME)
      else concat(coalesce(NICKNAME,concat(FIRST_NAME, ' ',LAST_NAME))) end as manager_name,
      direct_manager_employee_id,
      work_email as manager_email
      from analytics.PAYROLL.COMPANY_DIRECTORY
      where employee_status not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated')
      ) mn on mn.manager_id = cd.direct_manager_employee_id
      join es_warehouse.public.users u on lower(u.email_address) = lower(cd.work_email)


      left join analytics.public.market_region_xwalk mrx on mrx.market_id = cd.market_id


      where employee_status not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated') AND
      ((contains(ca.manager_access_emails,'{{ _user_attributes['email'] }}'))
      OR
      (contains(employee_email,'{{ _user_attributes['email'] }}')) -- difference between sales manager and salesperson.. hopefully this gives reps access to their own page
      OR
      ({{ _user_attributes['job_role'] }} = 'developer')
      OR
      ({{ _user_attributes['job_role'] }} = 'hrbp')
      OR
      ({{ _user_attributes['job_role'] }} = 'leadership')
      OR
      ('bobbi.malone@equipmentshare.com' = '{{ _user_attributes['email'] }}')
      OR
      ('jay.mitchell@equipmentshare.com' = '{{ _user_attributes['email'] }}')
      OR
      ('kate.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}')
      OR
      (case
      when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'zach@equipmentshare.com')
      when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'josh.helmstetler@equipmentshare.com') OR contains(ca.manager_access_emails,'karen.hubbard@equipmentshare.com')
      when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'zach@equipmentshare.com')
      when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'zach@equipmentshare.com')
      when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'justin.ingold@equipmentshare.com')
      when 'chad.pilawski@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'chad.pilawski@equipmentshare.com')
      when business_segment = 'Tooling Solutions' AND '{{ _user_attributes['email'] }}' IN (SELECT * FROM tooling_managers) THEN contains(ca.manager_access_emails,'grant.reviere@equipmentshare.com')
      when 'ronny.robinson@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND employee_title ilike '%national account%' then contains(ca.manager_access_emails,'jabbok@equipmentshare.com')
      END
      )
      )
      ;;
  }

  dimension: user_email_filter {
    hidden: yes
    sql:   CASE
      WHEN lower(employee_email) = lower('{{ _user_attributes['email'] }}')
      THEN concat(rep, ' - ', employee_location)
      ELSE NULL
    END  ;;
  }

  filter: default_name_location {
    type: string
    default_value: "{{ _user_attributes['email'] }}"
  }



  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rep {
    type: string
    sql: ${TABLE}."REP" ;;
  }

  dimension: manager_name {
    type: string
    sql: ${TABLE}."MANAGER_NAME" ;;
  }

  dimension: manager_email {
    type: string
    sql: ${TABLE}."MANAGER_EMAIL" ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

  dimension: employee_location {
    type: string
    sql: ${TABLE}."EMPLOYEE_LOCATION" ;;
  }

  dimension: employee_email {
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL" ;;
  }

  dimension: employee_hire_date {
    type: string
    sql: ${TABLE}."EMPLOYEE_HIRE_DATE" ;;
  }

  dimension: manager_access_emails {
    type: string

    sql: ${TABLE}."MANAGER_ACCESS_EMAILS" ;;
  }

  dimension: employee_user_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_USER_ID" ;;
  }

  dimension: rep_home_market {
    type: string
    sql: concat(${rep}, ' - ',${employee_location}) ;;
  }

  dimension: hire_date {
    group_label: "HTML Formatted Date"
    label: "Employee ES Hire Date"
    type: date
    sql: ${employee_hire_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }


  set: detail {
    fields: [
      rep,
      employee_title,
      employee_location,
      employee_email,
      hire_date
    ]
  }
}
