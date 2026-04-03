view: actively_renting_companies_and_assets {
  derived_table: {
    sql: SELECT
          concat(u.first_name,' ',u.last_name) as sales_rep,
          m.name as branch,
          c.name as company_name,
          count(distinct(ea.asset_id)) as assets_on_rent
      FROM
          ES_WAREHOUSE.PUBLIC.orders o
          JOIN ES_WAREHOUSE.PUBLIC.rentals r ON o.order_id = r.order_id
          JOIN ES_WAREHOUSE.PUBLIC.equipment_assignments ea ON r.rental_id = ea.rental_id
          JOIN ES_WAREHOUSE.PUBLIC.assets a ON ea.asset_id = a.asset_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.order_salespersons os ON os.order_id = o.order_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.users u ON coalesce(os.user_id,o.salesperson_user_id) = u.user_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.markets m ON o.market_id = m.market_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.assets_aggregate aa on aa.asset_id = a.asset_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.users uc ON o.user_id = uc.user_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.companies c on c.company_id = uc.company_id
      WHERE
          --r.rental_status_id = 5
          --AND
          {% condition branch_filter %} m.branch {% endcondition %}
          AND {% condition sales_rep_filter %} concat(u.first_name,' ',u.last_name) {% endcondition %}
          AND m.company_id = {{ _user_attributes['company_id'] }}
          AND u.company_id = {{ _user_attributes['company_id'] }}
          AND u.deleted = FALSE
          AND convert_timezone('{{ _user_attributes['user_timezone'] }}',current_date) BETWEEN (convert_timezone('{{ _user_attributes['user_timezone'] }}',ea.start_date)) AND coalesce((convert_timezone('{{ _user_attributes['user_timezone'] }}',ea.end_date)), '2099-12-31')
          --AND coalesce(os.user_id,o.salesperson_user_id) = 10883
      GROUP BY
          concat(u.first_name,' ',u.last_name),
          m.name,
          c.name
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: sales_rep {
    type: string
    sql: ${TABLE}."SALES_REP" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: assets_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  measure: total_assets_on_rent {
    type: sum
    sql: ${assets_on_rent} ;;
  }

  filter: sales_rep_filter {}

  filter: branch_filter {}

  set: detail {
    fields: [company_name, total_assets_on_rent]
  }
}
