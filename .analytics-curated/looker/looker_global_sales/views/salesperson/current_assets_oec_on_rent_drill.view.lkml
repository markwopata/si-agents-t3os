view: current_assets_oec_on_rent_drill {
  derived_table: {
    sql: SELECT
        concat(u.first_name,' ',u.last_name) as sales_rep,
        m.name as branch,
        a.custom_name as asset,
        aa.oec as oec
    FROM
        ES_WAREHOUSE.PUBLIC.orders o
        JOIN ES_WAREHOUSE.PUBLIC.rentals r ON o.order_id = r.order_id
        LEFT JOIN ES_WAREHOUSE.PUBLIC.equipment_assignments ea ON r.rental_id = ea.rental_id
        LEFT JOIN ES_WAREHOUSE.PUBLIC.assets a ON ea.asset_id = a.asset_id
        LEFT JOIN ES_WAREHOUSE.PUBLIC.order_salespersons os ON os.order_id = o.order_id
        LEFT JOIN ES_WAREHOUSE.PUBLIC.users u ON coalesce(os.user_id,o.salesperson_user_id) = u.user_id
        LEFT JOIN ES_WAREHOUSE.PUBLIC.markets m ON o.market_id = m.market_id
        LEFT JOIN ES_WAREHOUSE.PUBLIC.assets_aggregate aa on aa.asset_id = a.asset_id
    WHERE
        --r.rental_status_id = 5
        --AND
        m.company_id = {{ _user_attributes['company_id'] }}
        AND u.company_id = {{ _user_attributes['company_id'] }}
        --AND coalesce(os.user_id,o.salesperson_user_id) = 10883
        AND {% condition branch_filter %} m.branch {% endcondition %}
        AND {% condition sales_rep_filter %} concat(u.first_name,' ',u.last_name) {% endcondition %}
        AND convert_timezone('{{ _user_attributes['user_timezone'] }}',current_date) BETWEEN (convert_timezone('{{ _user_attributes['user_timezone'] }}',ea.start_date)) AND coalesce((convert_timezone('{{ _user_attributes['user_timezone'] }}',ea.end_date)), '2099-12-31')
        AND u.deleted = FALSE
     ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset},${oec}) ;;
  }

  dimension: sales_rep {
    type: string
    sql: ${TABLE}."SALES_REP" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
    value_format_name: usd_0
  }

  measure: total_oec {
    group_label: "Drill Down OEC"
    label: "OEC"
    type: sum
    sql: coalesce(${oec},0) ;;
    value_format_name: usd_0
  }

  filter: sales_rep_filter {}

  filter: branch_filter {}

  set: detail {
    fields: [sales_rep, branch, asset, oec]
  }

}
