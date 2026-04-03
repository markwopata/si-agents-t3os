view: retail_invoice_sales_reps {
derived_table: {
  sql:
        WITH names AS (
        SELECT
          os.order_id,
          os.salesperson_type_id,
          CONCAT(u.first_name,' ', u.last_name) AS full_name
        FROM es_warehouse.public.order_salespersons os
        JOIN es_warehouse.public.users u
          ON u.user_id = os.user_id
      )
      SELECT
        order_id,
        IFF(COUNT_IF(salesperson_type_id = 1 AND full_name IS NOT NULL) = 0, NULL,
          LISTAGG(
            DISTINCT CASE WHEN salesperson_type_id = 1 THEN full_name END, ', ')
            WITHIN GROUP (
            ORDER BY CASE WHEN salesperson_type_id = 1 THEN full_name END)) AS primary_rep_names,
        IFF(COUNT_IF(salesperson_type_id = 2 AND full_name IS NOT NULL) = 0, NULL,
          LISTAGG(
            DISTINCT CASE WHEN salesperson_type_id = 2 THEN full_name END, ', ')
            WITHIN GROUP (
            ORDER BY CASE WHEN salesperson_type_id = 2 THEN full_name END)) AS secondary_rep_names
      FROM names
      GROUP BY order_id
        ;;
}


  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: primary_rep_names {
    type: string
    sql: ${TABLE}."PRIMARY_REP_NAMES" ;;
  }

  dimension: secondary_rep_name {
    type: string
    sql: ${TABLE}."SECONDARY_REP_NAMES" ;;
  }


}
