view: general_liability_expired_with_active_rental {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    sql: with expired_general as (
      select
        cd.company_id,
        c.name,
        cd.valid_from,
        cd.valid_until,
        RANK() OVER(
          partition by cd.company_id order by valid_until desc) as most_recent_document,
        case when convert_timezone('America/Chicago',valid_until) >= current_timestamp() then 1 else 0 end as expired_past_today
      from
        ES_WAREHOUSE.PUBLIC.company_documents cd
        left join ES_WAREHOUSE.PUBLIC.companies c on cd.company_id = c.company_id
      where
         cd.company_document_type_id = 3
         and cd.voided = false
      ),
      active_renting_companies as (
      select
        c.company_id,
        c.name,
        count(ea.equipment_assignment_id) as active_rentals
      FROM
        ES_WAREHOUSE.PUBLIC.orders o
        INNER JOIN ES_WAREHOUSE.PUBLIC.rentals r ON r.order_id = o.order_id
        INNER JOIN ES_WAREHOUSE.PUBLIC.equipment_assignments ea ON ea.rental_id = r.rental_id
        INNER JOIN ES_WAREHOUSE.PUBLIC.assets a ON a.asset_id = ea.asset_id
        LEFT JOIN ES_WAREHOUSE.PUBLIC.users u ON o.user_id = u.user_id
        LEFT JOIN ES_WAREHOUSE.PUBLIC.companies c ON u.company_id = c.company_id
      where
        convert_timezone('America/Chicago',current_date()) <= coalesce(convert_timezone('America/Chicago',ea.end_date::date),'9999-12-31')
         and convert_timezone('America/Chicago',current_date()) >= convert_timezone('America/Chicago',ea.start_date::date)
       group by
         c.company_id,
         c.name
       )
       select
         e.company_id,
         e.name,
         e.valid_from,
         e.valid_until,
         case when e.expired_past_today = 0 then 'Yes' else 'No' end as expiration_date_past_today,
         ac.active_rentals
       from
         expired_general e
         join active_renting_companies ac on e.company_id = ac.company_id
       where
         e.most_recent_document = 1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ name._filterable_value | url_encode }}&Company%20ID="
    }
  }

  dimension_group: valid_from {
    type: time
    sql: ${TABLE}."VALID_FROM" ;;
  }

  dimension_group: valid_until {
    type: time
    sql: ${TABLE}."VALID_UNTIL" ;;
  }

  dimension: expiration_date_past_today {
    type: string
    sql: ${TABLE}."EXPIRATION_DATE_PAST_TODAY" ;;
  }

  dimension: active_rentals {
    type: number
    sql: ${TABLE}."ACTIVE_RENTALS" ;;
  }

  set: detail {
    fields: [
      company_id,
      name,
      valid_from_time,
      valid_until_time,
      expiration_date_past_today,
      active_rentals
    ]
  }
}
