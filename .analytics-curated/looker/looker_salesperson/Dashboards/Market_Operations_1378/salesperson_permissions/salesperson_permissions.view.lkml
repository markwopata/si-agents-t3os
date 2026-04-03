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
          mn.manager_title,
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
          cd.date_rehired as employee_rehired_date,
          bi.user_id as employee_user_id,
          bi.user_key,

          --IFF(manager_email = 'jacob.allen@equipmentshare.com',TRUE,FALSE) as direct_report, --will pass in looker email then can count this field for true reporting kpi
          --IFF(manager_email = '{{ _user_attributes['email'] }}',TRUE,FALSE) as direct_report, --will pass in looker email then can count this field for true reporting kpi

          CASE WHEN dateadd(month, '6', si.first_date_as_TAM) > CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())::DATE THEN 'Under 6 Months' ELSE 'Older than 6 Months' END AS new_sp_flag_current,
          mrx.market_name,
          mrx.district,
          mrx.district as district_dated,
          --si.district_dated,
          mrx.region,
          mrx.region_name as region_name_dated,
         -- si.region_name_dated,
          cd.employee_id,
          si.salesperson_key,
          concat(trim(bi.user_first_name), ' ', trim(bi.user_last_name), ' - ', bi.user_id) as full_name_id_users

      from analytics.payroll.pa_employee_access ca
          join analytics.payroll.company_directory cd on ca.employee_id = cd.employee_id
          join ( select
              distinct EMPLOYEE_ID as manager_id,
                case when position(' ',coalesce(NICKNAME,FIRST_NAME)) = 0 then concat(coalesce(NICKNAME,FIRST_NAME), ' ', LAST_NAME)
                     else concat(coalesce(NICKNAME,concat(FIRST_NAME, ' ',LAST_NAME))) end as manager_name,
                direct_manager_employee_id,
                employee_title as manager_title,
                work_email as manager_email
          from analytics.PAYROLL.COMPANY_DIRECTORY
          where employee_status not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated')
          ) mn on mn.manager_id = cd.direct_manager_employee_id

          join business_intelligence.gold.dim_users_bi bi on lower(trim(bi.user_username)) = lower(trim(cd.work_email))

          LEFT JOIN (SELECT user_id, market_district_hist as district_dated, market_region_name_hist as region_name_dated, first_TAM_date as first_date_as_TAM, salesperson_key FROM business_intelligence.gold.dim_salesperson_enhanced where _is_current) si ON si.user_id = bi.user_id
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
          ('kevin.stobb@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (si.district_dated IN ('4-9') OR (cd.employee_id IN ('15499', '18442', '14046', '17959', '15703')) and business_segment IN ('Core Solutions'))) -- help looker request for these markets, not necessarily whole district
          OR
          ('mj.mason@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (si.district_dated IN ('1-4') OR (si.region_name_dated IN ('Pacific') and business_segment IN ('Advanced Solutions')))) -- requested by kyle stout in help looker
          OR
          ('mike.k.smith@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (si.district_dated IN ('1-4') OR (si.region_name_dated IN ('Pacific') and business_segment IN ('Advanced Solutions')))) -- requested by kyle stout in help looker
          OR
          ('kyle.stout@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (si.district_dated IN ('1-4') OR (si.region_name_dated IN ('Pacific') and business_segment IN ('Advanced Solutions')))) -- requested by kyle stout in help looker
          OR
          ('jason.jones@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (si.region_name_dated IN ('Florida')))
          OR
          (case when 'conner.bradley@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (cd.employee_id IN ('3102', '3654', '12795', '18434', '10321', '14194', '4275', '18691', '13644', '3644', '18880', '18980', '7271')) then contains(ca.manager_access_emails,'toby.fischer@equipmentshare.com') OR contains(ca.manager_access_emails,'kyle.stout@equipmentshare.com') OR contains(ca.manager_access_emails,'brian.kniffen@equipmentshare.com') end) -- requested by conner bradley in help looker 10-24-25

          OR
          (case
            when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'zach@equipmentshare.com')
            when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'josh.helmstetler@equipmentshare.com') OR contains(ca.manager_access_emails,'karen.hubbard@equipmentshare.com')
            when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'zach@equipmentshare.com')
            when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'zach@equipmentshare.com')
            WHEN 'matt.dunn_c@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'brett.claycamp@equipmentshare.com')
            when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails,'justin.ingold@equipmentshare.com')
            when 'arianna.olson@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(ca.manager_access_emails, 'brian.kniffen@equipmentshare.com') OR contains(ca.manager_access_emails,'justin.ingold@equipmentshare.com')
            when business_segment = 'Tooling Solutions' AND '{{ _user_attributes['email'] }}' IN (SELECT * FROM tooling_managers) THEN contains(ca.manager_access_emails,'grant.reviere@equipmentshare.com')
            when 'mike.galvan@equipmentshare.com' = '{{ _user_attributes['email'] }}' and mrx.region = 2 then contains(ca.manager_access_emails,'justin.ingold@equipmentshare.com')
            END
          )
          )
          AND NOT ('leann.thomas@equipmentshare.com' = '{{ _user_attributes['email'] }}' and si.district_dated IN ('8-4'))
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

  dimension: user_key {
    type: string
    sql: ${TABLE}."USER_KEY" ;;
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

  dimension: manager_title {
    type: string
    sql: ${TABLE}."MANAGER_TITLE" ;;
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

  dimension: employee_rehired_date {
    type: string
    sql: ${TABLE}."EMPLOYEE_REHIRED_DATE" ;;
  }

  dimension: manager_access_emails {
    type: string

    sql: ${TABLE}."MANAGER_ACCESS_EMAILS" ;;
  }

    dimension: employee_user_id {
      type: number
      sql: ${TABLE}."EMPLOYEE_USER_ID" ;;
    }

  dimension: full_name_id_users {
    type: string
    sql: ${TABLE}."FULL_NAME_ID_USERS" ;;
  }


    dimension: rep_home_market {
      label: "Rep Home Market"
      type: string
      sql: concat(${rep}, ' - ',${employee_location}) ;;
    }

  dimension: rep_home_market_fmt {
    label: "Salesperson - Current Home"
    type: string
    sql: concat(${rep}, ' - ',${employee_location}) ;;
    html: <font color="#000000">
    {{rep._value}} </font>
    <br />
    <font style="color: #8C8C8C; text-align: right;">{{employee_location._rendered_value}} </font>;;
}

  dimension: rep_home_market_fmt_individual_tam {
    label: "Salesperson - Home"
    type: string
    sql: concat(${rep}, ' - ',${employee_location}) ;;
    html: <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/1409?Rep={{rep_home_market._filterable_value}}"target="_blank">
    {{rep._value}} ➔</a>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Home: {{ employee_location._rendered_value }} </font>;;
  }

  dimension: rep_link {
    type: string
    group_label: "Links"
    label: "TAM"
    sql: ${rep_home_market} ;;
    html:
    <a href="https://equipmentshare.looker.com/dashboards/1409?Rep={{ value | prepend:'"' | append:'"' | url_encode }}&amp;History+Timeframe=90"
       target="_blank"
       style="color:#0063f3;">
      {{ rep }} ➔
    </a>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Home: {{employee_location._rendered_value }} </font>;;
  }

    dimension: hire_date {
      group_label: "HTML Formatted Date"
      label: "Employee ES Hire Date"
      type: date
      sql: ${employee_hire_date} ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

  dimension: tenure_years {
    type: number
    sql: FLOOR(DATEDIFF('day', ${employee_hire_date_filled}, CURRENT_DATE) / 365.25) ;;
  }

  dimension: employee_hire_date_filled {
    type: number
    sql: coalesce(${employee_rehired_date}, ${employee_hire_date});;
  }

  dimension: tenure_display {
    type: string
    sql: CAST(${employee_hire_date_filled} AS STRING) ;;

    html:
      {% assign t = tenure_years._value %}
      {% assign hire = employee_hire_date_filled | date: "%m/%d/%Y" %}

      {% if t < 1 %}
      <div style="line-height:1.2;">
      <div style="color:#d97706; font-weight:600;">0–1 year</div>
      <div style="color:#6b7280; font-size:12px;">Hire date: {{ hire }}</div>
      </div>
      {% elsif t < 2 %}
      <div style="line-height:1.2;">
      <div style="color:#2563eb; font-weight:600;">1–2 years</div>
      <div style="color:#6b7280; font-size:12px;">Hire date: {{ hire }}</div>
      </div>
      {% elsif t < 3 %}
      <div style="line-height:1.2;">
      <div style="color:#16a34a; font-weight:600;">2–3 years</div>
      <div style="color:#6b7280; font-size:12px;">Hire date: {{ hire }}</div>
      </div>
      {% else %}
      <div style="line-height:1.2;">
      <div style="color:#15803d; font-weight:600;">3+ years</div>
      <div style="color:#6b7280; font-size:12px;">Hire date: {{ hire }}</div>
      </div>
      {% endif %}
      ;;
  }

  dimension: business_segment {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
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
