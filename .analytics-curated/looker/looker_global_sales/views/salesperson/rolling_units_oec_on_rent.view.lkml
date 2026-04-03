view: rolling_units_oec_on_rent {
  derived_table: {
    sql: WITH rental_day_list AS
      (
      select
      dateadd(
      day,'-' || row_number() over (order by null),
      dateadd(day, '+1', current_date())
      ) as rental_day
      from table (generator(rowcount => 120))
      )
      SELECT
          rdl.rental_day,
          concat(u.first_name,' ',u.last_name) as salesrep_name,
          coalesce(os.user_id,o.salesperson_user_id) as salesperson_id,
          count(a.asset_id) as on_rent_count,
          sum(aa.oec) as oec_on_rent
      FROM
          ES_WAREHOUSE.PUBLIC.orders o
          JOIN ES_WAREHOUSE.PUBLIC.rentals r ON o.order_id = r.order_id
          JOIN ES_WAREHOUSE.PUBLIC.equipment_assignments ea ON r.rental_id = ea.rental_id
          JOIN ES_WAREHOUSE.PUBLIC.assets a ON ea.asset_id = a.asset_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.order_salespersons os ON os.order_id = o.order_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.users u ON coalesce(os.user_id,o.salesperson_user_id) = u.user_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.markets m ON o.market_id = m.market_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.assets_aggregate aa on aa.asset_id = a.asset_id
          LEFT JOIN rental_day_list rdl ON rdl.rental_day BETWEEN (convert_timezone('{{ _user_attributes['user_timezone'] }}',ea.start_date)) AND coalesce((convert_timezone('{{ _user_attributes['user_timezone'] }}',ea.end_date)), '2099-12-31')
      WHERE
          m.company_id = {{ _user_attributes['company_id'] }}
          AND u.company_id = {{ _user_attributes['company_id'] }}
          --AND coalesce(os.user_id,o.salesperson_user_id) = 10883
          AND rdl.rental_day is not null
          AND {% condition branch_filter %} m.branch {% endcondition %}
          AND {% condition sales_rep_filter %} concat(u.first_name,' ',u.last_name) {% endcondition %}
      GROUP BY
          rdl.rental_day,
          concat(u.first_name,' ',u.last_name),
          coalesce(os.user_id,o.salesperson_user_id)
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_day {
    type: date
    sql: ${TABLE}."RENTAL_DAY" ;;
  }

  dimension: salesrep_name {
    type: string
    sql: ${TABLE}."SALESREP_NAME" ;;
  }

  dimension: salesperson_id {
    type: number
    sql: ${TABLE}."SALESPERSON_ID" ;;
  }

  dimension: on_rent_count {
    type: number
    sql: ${TABLE}."ON_RENT_COUNT" ;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  dimension: formatted_rental_day {
    group_label: "HTML Formatted Day"
    label: "Day"
    type: date
    sql: ${rental_day} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: total_assets_on_rent {
    type: sum
    sql: ${on_rent_count} ;;
  }

  measure: total_oec_on_rent {
    type: sum
    sql: ${oec_on_rent} ;;
  }

  filter: sales_rep_filter {}

  filter: branch_filter {}

  set: detail {
    fields: [rental_day, salesrep_name, salesperson_id, on_rent_count, oec_on_rent]
  }
}
