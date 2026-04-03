
 view: equipment_classes_active {
   # Or, you could make this view a derived table, like this:
   derived_table: {
     sql: SELECT class name,
       equipment_class_id
FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE
WHERE COMPANY_ID = 1854
and RENTAL_BRANCH_ID is not NULL
group by class, equipment_class_id
       ;;
   }

   # Define your dimensions and measures here, like this:
   dimension: name {
     type: string
     sql: ${TABLE}."NAME" ;;
   }

  dimension: equipment_class_id {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

}
