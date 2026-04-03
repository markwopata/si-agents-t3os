
view: voze_company_export {
  derived_table: {
    sql: with rep_selection as (
      select
          case
          when position(' ',coalesce(cd.nickname,cd.first_name)) = 0 then concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name,' - ',employee_id)
          else
          concat(coalesce(nickname,concat(cd.first_name, ' ',cd.last_name)), ' - ', employee_id) end as rep,
          work_email
      from
          analytics.payroll.company_directory cd
      where
          --rep = 'Katie Laxson' --dynamic email based on selection
          {% condition rep_name_filter %} rep {% endcondition %}
      )
      select distinct
          c.company_id,
          c.name as customer,
          case when l.street_1 is null then 'No address on file' else coalesce((l.street_1), '') || coalesce((l.street_2), '') || ', ' || coalesce((l.city), '') || ', ' || coalesce((s.abbreviation), '') || ' ' || LPAD(coalesce((l.zip_code), 0), 5, 0) end as company_address,
          case when l.street_1 is null then 'No address on file' else coalesce(l.street_1, '')  end as address1,
          coalesce(l.street_2, '') as address2,
          coalesce(l.city, '') as city,
          coalesce(s.abbreviation, '') as state,
          LPAD(coalesce(l.zip_code, 0), 5, 0) as zip,
          owner.email_address as owner_email
      from
          es_warehouse.public.orders o
          left join es_warehouse.public.order_salespersons os on o.order_id = os.order_id
          left join es_warehouse.public.users u on u.user_id = o.user_id
          left join es_warehouse.public.companies c on c.company_id = u.company_id
          left join es_warehouse.public.locations l on l.location_id = c.billing_location_id
          left join es_warehouse.public.states s on s.state_id = l.state_id
          left join es_warehouse.public.users rep on coalesce(os.user_id,o.user_id) = rep.user_id
          left join es_warehouse.public.users owner on c.owner_user_id = owner.user_id
          join rep_selection rs on rs.work_email = rep.email_address
      where
          o.order_status_id <> 8 --remove cancelled orders
          AND c.company_id <> 1854 --remove ES as a company
          AND rep.email_address = work_email ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER" ;;
  }

  dimension: company_address {
    type: string
    sql: ${TABLE}."COMPANY_ADDRESS" ;;
  }

  dimension: address1 {
    type: string
    sql: ${TABLE}."ADDRESS1" ;;
  }

  dimension: address2 {
    type: string
    sql: ${TABLE}."ADDRESS2" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: zip {
    type: string
    sql: ${TABLE}."ZIP" ;;
  }

  dimension: owner_email {
    type: string
    sql: ${TABLE}."OWNER_EMAIL" ;;
  }

  filter: rep_name_filter {
  }

  set: detail {
    fields: [
        company_id,
  customer,
  company_address
    ]
  }
}
