include: "/views/ES_WAREHOUSE/rentals.view.lkml"

view: bulk_rentals {
  extends: [rentals]
  sql_table_name: (select * from es_warehouse.public.rentals where rental_type_id = 3) ;;

  dimension: is_bulk {
    type: yesno
    sql: ${rental_type_id} = 3;;
    }

}
