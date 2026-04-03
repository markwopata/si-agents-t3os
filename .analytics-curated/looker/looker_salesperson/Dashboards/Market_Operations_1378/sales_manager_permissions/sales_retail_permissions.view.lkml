view: sales_retail_permissions {

    derived_table: {
      sql: WITH tooling_managers AS (
            select work_email
            from analytics.payroll.company_directory
            where employee_title ILIKE '%Regional Manager - Industrial%')

        select
        case
        when position(' ',coalesce(cd.nickname,cd.first_name)) = 0 then concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
        else
        concat(coalesce(nickname,concat(cd.first_name, ' ',cd.last_name))) end as rep,
        mn.manager_name,
        mn.manager_email,
        ca.manager_access_emails,
        employee_status,
        employee_title,
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
        IFF(manager_email = '{{ _user_attributes['email'] }}',TRUE,FALSE) as direct_report, --will pass in looker email then can count this field for true reporting kpi

        CASE WHEN dateadd(month, '6', si.first_date_as_TAM) > CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE THEN 'Under 6 Months' ELSE 'Older than 6 Months' END AS new_sp_flag_current,
        mrx.district,
        si.district_dated
        from
        analytics.payroll.pa_employee_access ca
        join analytics.payroll.company_directory cd on ca.employee_id = cd.employee_id
        join
        (
        select
        distinct EMPLOYEE_ID as manager_id,
        case when position(' ',coalesce(NICKNAME,FIRST_NAME)) = 0 then concat(coalesce(NICKNAME,FIRST_NAME), ' ', LAST_NAME)
        else concat(coalesce(NICKNAME,concat(FIRST_NAME, ' ',LAST_NAME))) end as manager_name,
        direct_manager_employee_id,
        work_email as manager_email
        from
        analytics.PAYROLL.COMPANY_DIRECTORY
        where
        employee_status not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated')
        ) mn on mn.manager_id = cd.direct_manager_employee_id
        join es_warehouse.public.users u on lower(u.email_address) = lower(cd.work_email)

        LEFT JOIN (SELECT user_id, first_date_as_TAM, district_dated, region_name_dated FROM analytics.bi_ops.salesperson_info where record_ineffective_date IS NULL) si ON si.user_id = u.user_id
        left join analytics.public.market_region_xwalk mrx on mrx.market_id = cd.market_id


        where employee_status not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated') AND
        ((contains(ca.manager_access_emails,'{{ _user_attributes['email'] }}'))
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
        (case
        when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'zach@equipmentshare.com')
        when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'josh.helmstetler@equipmentshare.com') OR contains(ca.manager_access_emails,'karen.hubbard@equipmentshare.com')
        when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'zach@equipmentshare.com')
        when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'zach@equipmentshare.com')
        when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'justin.ingold@equipmentshare.com')
        when 'arianna.olson@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails, 'brian.kniffen@equipmentshare.com') OR contains(ca.manager_access_emails,'justin.ingold@equipmentshare.com')
        when business_segment = 'Tooling Solutions' AND '{{ _user_attributes['email'] }}' IN (SELECT * FROM tooling_managers) THEN contains(ca.manager_access_emails,'grant.reviere@equipmentshare.com')
        END
        )
        )
        --contains(ca.manager_access_emails,'{{ _user_attributes['email'] }}')
        --contains(ca.manager_access_emails,'jacob.allen@equipmentshare.com')
        ;;
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

    dimension: business_segment {
      type:  string
      sql:  ${TABLE}."BUSINESS_SEGMENT" ;;
    }

    dimension: employee_email {
      type: string
      sql: ${TABLE}."EMPLOYEE_EMAIL" ;;
    }

    dimension: manager_access_emails {
      type: string
      sql: ${TABLE}."MANAGER_ACCESS_EMAILS" ;;
    }

    dimension: employee_hire_date {
      type: string
      sql: ${TABLE}."EMPLOYEE_HIRE_DATE" ;;
    }

    dimension: employee_user_id {
      type: number
      sql: ${TABLE}."EMPLOYEE_USER_ID" ;;
    }

    dimension: direct_report {
      type: yesno
      sql: ${TABLE}."DIRECT_REPORT" ;;
    }

    dimension: district {
      type: string
      sql: ${TABLE}."DISTRICT" ;;
    }

    measure: total_reports {
      type: count
      drill_fields: [detail*]
      filters: [employee_title: "Territory Account Manager, Rental Territory Manager, Market Consultant Manager, Strategic Account Manager"]
    }

    measure: total_direct_reports {
      type: count
      filters: [direct_report: "Yes"]
      drill_fields: [detail*]
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

    dimension: new_sp_flag_current {
      type: string
      sql: ${TABLE}."NEW_SP_FLAG_CURRENT" ;;
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
