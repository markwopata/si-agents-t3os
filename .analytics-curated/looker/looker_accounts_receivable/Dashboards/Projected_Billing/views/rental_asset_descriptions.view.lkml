view: rental_asset_descriptions {
  derived_table: {
    sql: with rental_keys as (
    SELECT rental_id,
           equipment_class_id,
           part_type_id
    FROM ES_WAREHOUSE.PUBLIC.RENTALS),
    descriptions as (
    select rk.rental_id,
           rk.part_type_id as id,
           pt.description as description
    from rental_keys rk
    left join ES_WAREHOUSE.INVENTORY.PART_TYPES pt on rk.part_type_id = pt.part_type_id
    where rk.equipment_class_id is null
    UNION
    select rk.rental_id,
           rk.equipment_class_id as id,
           ec.name as description
    from rental_keys rk
    left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on rk.equipment_class_id = ec.equipment_class_id
    where rk.part_type_id is null)
    select rental_id, id, description from descriptions ;;
}

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: id {
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  }
