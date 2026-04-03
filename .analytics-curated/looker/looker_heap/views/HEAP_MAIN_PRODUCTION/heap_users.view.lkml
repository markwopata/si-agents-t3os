view: heap_users {
  derived_table: {
    sql:
              {% if platform_app._parameter_value == 't3_main' %}
SELECT user_id,
       joindate,
       last_modified,
       identity,
       handle,
       _email AS email,
       company_id
  FROM heap_main_production.heap.users
 WHERE _email NOT LIKE '%support%'
   AND company_id IS NOT NULL
   AND company_id NOT IN (1854, 42268, 420, 43362, 16184, 6302)

              {% elsif platform_app._parameter_value == 'link_app' %}
SELECT user_id,
       joindate,
       last_modified,
       identity,
       handle,
       _email AS email,
       companyid as company_id
  FROM heap_link_production.heap.users
 WHERE _email NOT LIKE '%support%'
   AND companyid IS NOT NULL
   AND companyid NOT IN (1854, 42268, 420, 43362, 16184, 6302)

              {% elsif platform_app._parameter_value == 'rent_app' %}
SELECT user_id,
       joindate,
       last_modified,
       identity,
       handle,
       emailaddress AS email,
       companyid as company_id
  FROM heap_rent_mobile_production.heap.users
 WHERE emailaddress NOT LIKE '%support%'
   AND companyid IS NOT NULL
   AND companyid NOT IN (1854, 42268, 420, 43362, 16184, 6302)

              {% elsif platform_app._parameter_value == 'analytics_app' %}
SELECT user_id,
       joindate,
       last_modified,
       _user_id as identity,
       handle,
       _email AS email,
       company_id
  FROM heap_t3_analytics_app_production.heap.users
 WHERE _email NOT LIKE '%support%'
   AND company_id IS NOT NULL
   AND company_id NOT IN (1854, 42268, 420, 43362, 16184, 6302)

              {% elsif platform_app._parameter_value == 'all_apps' %}
select * from analytics.heap_adjunct.heap_users

{% else %}
select * from analytics.heap_adjunct.heap_users
{% endif %}
;;
  }

  parameter: platform_app {
    type: unquoted
    default_value: "all_apps"
    allowed_value: {
      label: "Fleet, ELogs, Timecards Web"
      value: "t3_main"
    }
    allowed_value: {
      label: "Link"
      value: "link_app"
    }
    allowed_value: {
      label: "Rent"
      value: "rent_app"
    }
    allowed_value: {
      label: "Analytics"
      value: "analytics_app"
    }
    allowed_value: {
      label: "All Apps"
      value: "all_apps"
    }
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: handle {
    type: string
    sql: ${TABLE}."HANDLE" ;;
  }

  dimension: identity {
    type: string
    sql: ${TABLE}."IDENTITY" ;;
  }

  dimension_group: joindate {
    type: time
    timeframes: [
      raw,
      time,
      date,
      day_of_week_index,
      day_of_week,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."JOINDATE" ;;
  }

  dimension_group: last_modified {
    type: time
    timeframes: [
      raw,
      time,
      date,
      day_of_week,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."LAST_MODIFIED" ;;
  }

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: es_app_name {
    type: string
    sql: ${TABLE}."ES_APP_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }


  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      admin_users.full_name,
      admin_users.email_address,
      heap_users.joindate_date,
      companies.name,
      all_events.count,
      sessions.count

]
  }
}
