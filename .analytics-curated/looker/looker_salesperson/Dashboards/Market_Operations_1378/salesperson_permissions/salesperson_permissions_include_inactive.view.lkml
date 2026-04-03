view: salesperson_permissions_include_inactive {

    derived_table: {
      sql:

with recursive org as(
select employee_id
     , direct_manager_employee_id as upstream_manager_id
     , 1 as level
     , to_varchar(employee_id) || '>' || to_varchar(direct_manager_employee_id) as path
 from analytics.payroll.company_directory
 where direct_manager_employee_id is not null

union all

select o.employee_id
     , cd.direct_manager_employee_id as upstream_manager_id
     , o.level + 1 as level
     , o.path || '>' || to_varchar(cd.direct_manager_employee_id) as path
 from org o
 join analytics.payroll.company_directory cd  on o.upstream_manager_id = cd.employee_id
 where cd.direct_manager_employee_id is not null
  and position('>' || to_varchar(cd.direct_manager_employee_id) || '>' in '>' || o.path || '>') = 0)

, list as(
select o.employee_id
     , cd.work_email as employee_email
     , o.level
     , o.upstream_manager_id
     , cdm.work_email as manager_access_email
 from org o
 left join analytics.payroll.company_directory cd on o.employee_id = cd.employee_id
 left join analytics.payroll.company_directory cdm on o.upstream_manager_id  = cdm.employee_id)

, pa_employee_access as(
select employee_id
     , employee_email
     , listagg(manager_access_email, ',') within group (order by level) as manager_access_emails
 from list
 group by all)

, tooling_managers AS (
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

        CASE WHEN dateadd(month, '6', si.first_date_as_TAM) > CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())::DATE THEN 'Under 6 Months' ELSE 'Older than 6 Months' END AS new_sp_flag_current,
        mrx.district,
        si.district_dated,
        mrx.region,
        si.region_name_dated,
        cd.employee_id

        from pa_employee_access ca
        join analytics.payroll.company_directory cd on ca.employee_id = cd.employee_id
        join ( select
        distinct EMPLOYEE_ID as manager_id,
        case when position(' ',coalesce(NICKNAME,FIRST_NAME)) = 0 then concat(coalesce(NICKNAME,FIRST_NAME), ' ', LAST_NAME)
        else concat(coalesce(NICKNAME,concat(FIRST_NAME, ' ',LAST_NAME))) end as manager_name,
        direct_manager_employee_id,
        work_email as manager_email
        from analytics.PAYROLL.COMPANY_DIRECTORY) mn on mn.manager_id = cd.direct_manager_employee_id
        join es_warehouse.public.users u on lower(u.email_address) = lower(cd.work_email)

        LEFT JOIN (SELECT user_id, district_dated, region_name_dated, first_date_as_TAM FROM analytics.bi_ops.salesperson_info where record_ineffective_date IS NULL) si ON si.user_id = u.user_id
        left join analytics.public.market_region_xwalk mrx on mrx.market_id = cd.market_id


        where
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
        ({{ _user_attributes['job_role'] }} = 'legal')
        OR
        ('bobbi.malone@equipmentshare.com' = '{{ _user_attributes['email'] }}')
        OR
        ('jay.mitchell@equipmentshare.com' = '{{ _user_attributes['email'] }}')
        OR
        ('kate.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}')
        OR
        ('mandy.peters@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (si.district_dated IN ('5-8', '5-4') OR (si.region_name_dated IN ('Southeast') and business_segment IN ('Advanced Solutions')))) --si specific just to tie in employees in the salesmanager info table
        OR
        ('victor.otalora@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (si.district_dated IN ('2-3') OR (si.region_name_dated IN ('Mountain West') and business_segment IN ('Advanced Solutions'))))
        OR
        ('mj.mason@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (si.district_dated IN ('1-4') OR (si.region_name_dated IN ('Pacific') and business_segment IN ('Advanced Solutions')))) -- requested by kyle stout in help looker
        OR
        ('mike.k.smith@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (si.district_dated IN ('1-4') OR (si.region_name_dated IN ('Pacific') and business_segment IN ('Advanced Solutions')))) -- requested by kyle stout in help looker
        OR
        ('kyle.stout@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (si.district_dated IN ('1-4') OR (si.region_name_dated IN ('Pacific') and business_segment IN ('Advanced Solutions')))) -- requested by kyle stout in help looker
        OR
        (case when 'conner.bradley@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (cd.employee_id IN ('3102', '3654', '12795', '18434', '10321', '14194', '4275', '18691', '13644', '3644', '18880', '18980')) then contains(ca.manager_access_emails,'toby.fischer@equipmentshare.com') OR contains(ca.manager_access_emails,'kyle.stout@equipmentshare.com') OR contains(ca.manager_access_emails,'brian.kniffen@equipmentshare.com') end) -- requested by conner bradley in help looker 10-24-25

        OR
        (case
        when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'zach@equipmentshare.com')
        when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'josh.helmstetler@equipmentshare.com') OR contains(ca.manager_access_emails,'karen.hubbard@equipmentshare.com')
        when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'zach@equipmentshare.com')
        when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'zach@equipmentshare.com')
        when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'justin.ingold@equipmentshare.com')
        when 'arianna.olson@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails, 'brian.kniffen@equipmentshare.com') OR contains(ca.manager_access_emails,'justin.ingold@equipmentshare.com')
        when business_segment = 'Tooling Solutions' AND '{{ _user_attributes['email'] }}' IN (SELECT * FROM tooling_managers) THEN contains(ca.manager_access_emails,'grant.reviere@equipmentshare.com')
        when 'mike.galvan@equipmentshare.com' = '{{ _user_attributes['email'] }}' and mrx.region = 2 then contains(ca.manager_access_emails,'justin.ingold@equipmentshare.com')
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

    dimension: employee_id {
      type: string
      sql: ${TABLE}."EMPLOYEE_ID" ;;
    }

    dimension: manager_name {
      type: string
      sql: ${TABLE}."MANAGER_NAME" ;;
    }

    dimension: manager_email {
      type: string
      sql: ${TABLE}."MANAGER_EMAIL" ;;
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

    dimension: business_segment {
      type: string
      sql: ${TABLE}."BUSINESS_SEGMENT" ;;
    }

    dimension: district {
      type: string
      sql: ${TABLE}."DISTRICT" ;;
    }

    dimension: district_dated {
      type: string
      sql: ${TABLE}."DISTRICT_DATED" ;;
    }

    dimension: region {
      type: string
      sql: ${TABLE}."REGION" ;;
    }

    dimension: region_name_dated {
      type: string
      sql: ${TABLE}."REGION_NAME_DATED" ;;
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
