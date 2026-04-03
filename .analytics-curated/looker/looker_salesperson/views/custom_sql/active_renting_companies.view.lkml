view: active_renting_companies {
  derived_table: {
    sql: select
        c.company_id,
        c.name,
        count(ea.equipment_assignment_id) as active_rentals
      FROM
        ES_WAREHOUSE.PUBLIC.orders o
        INNER JOIN ES_WAREHOUSE.PUBLIC.rentals r ON r.order_id = o.order_id
        INNER JOIN ES_WAREHOUSE.PUBLIC.equipment_assignments ea ON ea.rental_id = r.rental_id
        INNER JOIN ES_WAREHOUSE.PUBLIC.assets a ON a.asset_id = ea.asset_id
        LEFT  JOIN ES_WAREHOUSE.PUBLIC.users u ON o.user_id = u.user_id
        LEFT  JOIN ES_WAREHOUSE.PUBLIC.companies c ON u.company_id = c.company_id
      where
        convert_timezone('America/Chicago',current_date()) <= coalesce(convert_timezone('America/Chicago',ea.end_date::date),'9999-12-31')
         and convert_timezone('America/Chicago',current_date()) >= convert_timezone('America/Chicago',ea.start_date::date)
       group by
         c.company_id,
         c.name ;;
  }

  measure: count {
    type: count
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ name._filterable_value | url_encode }}&Company%20ID="
    }
  }

  dimension: active_rentals {
    type: number
    sql: coalesce(${TABLE}."ACTIVE_RENTALS",0) ;;
  }

 }
