include: "rentals.view"

view: rentals_current {
  extends: [rentals]

  derived_table: {
    sql:
      SELECT
        asset_id,
        rental_id,
        start_date,
        end_date,
        order_id,
        END_DATE_ESTIMATED,
        RENTAL_PURCHASE_OPTION_ID,
        rank() over (PARTITION BY asset_id order by rental_id desc) as rental_rank
        from public.rentals
      ;;
  }
  dimension: rental_rank {
    type: number
    sql: ${TABLE}.rental_rank ;;
  }
}
