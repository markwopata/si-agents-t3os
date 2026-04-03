view: no_general_liability_actively_renting {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    sql: with active_renting_companies as (
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
          convert_timezone('America/Chicago',current_date()) <=  coalesce(convert_timezone('America/Chicago',ea.end_date),'9999-12-31')
       and convert_timezone('America/Chicago',current_date()) >= convert_timezone('America/Chicago',ea.start_date::date)
         group by
           c.company_id,
           c.name
         ),
         rental_floater as (
         select
           company_id,
           RANK() OVER(
          partition by cd.company_id order by valid_until desc) as most_recent_document
         from
           ES_WAREHOUSE.PUBLIC.company_documents cd
         where
           company_document_type_id = 3
           and voided = false
         )
         select
           ac.company_id,
           ac.name,
           ac.active_rentals
         from
           active_renting_companies ac
           left join rental_floater rf on ac.company_id = rf.company_id
         where
           rf.company_id is null
 ;;
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
    sql: ${TABLE}."ACTIVE_RENTALS" ;;
  }

  set: detail {
    fields: [company_id, name, active_rentals]
  }
}
