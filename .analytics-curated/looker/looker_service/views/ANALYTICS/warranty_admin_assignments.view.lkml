view: warranty_admin_assignments {
  derived_table: {
    sql:
select waa.warranty_admin
    , waa.user_id
    , coalesce(cd.work_phone, cd.HOME_PHONE) as phone_number
    , concat('(', left(coalesce(cd.work_phone, cd.HOME_PHONE)::STRING, 3), ') ', right(left(coalesce(cd.work_phone, cd.HOME_PHONE)::STRING, 6), 3), '-', right(coalesce(cd.work_phone, cd.HOME_PHONE)::STRING, 4)) as formatted_phone_number
    , coalesce(u.email_address, 'warranty.team@equipmentshare.com') as email_address, em.name as make, waa.make_id
from ANALYTICS.WARRANTIES.WARRANTY_ADMIN_ASSIGNMENTS waa
left join ES_WAREHOUSE.PUBLIC.USERS u
    on waa.user_id = u.user_id::string
join ES_WAREHOUSE.PUBLIC.EQUIPMENT_MAKES em
    on em.equipment_make_id = waa.make_id
left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
    on cd.employee_id = u.employee_id
where current_flag = 1;;
  }

  dimension: warranty_admin {
    type: string
    sql: ${TABLE}.warranty_admin ;;
  }

  dimension: user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.user_id ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}.email_address ;;
  }

  dimension: phone_number {
    type: number
    value_format: "(###) ###-####"
    sql: ${TABLE}.phone_number ;;
  }

  dimension: formatted_phone_number {
    type: string
    sql: ${TABLE}.formatted_phone_number;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: make_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.make_id ;;
  }

  dimension: display_name {
    type: string
  sql: {% if make._in_query %}
    ${warranty_admin}
    {% else %}
    'Select Make to Display Admin'
    {% endif %};;
  }

  dimension: display_email {
    type: string
    link: {
      label: "Contact Warranty Admin"
      url: "mailto:{{value}}"
    }
    sql: {% if make._in_query %}
          ${email_address}
          {% else %}
          'warranty.team@equipmentshare.com'
          {% endif %};;
  }

  dimension: display_phone_number {
    type: string
    link: {
      label: "Contact Warranty Admin"
      url: "tel:{{value}}"
    }
    sql: {% if make._in_query %}
          coalesce(${formatted_phone_number}, 'No Phone Available')
          {% else %}
          'No Phone Available'
          {% endif %};;
  }
}
