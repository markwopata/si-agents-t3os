view: generator_engine_active {

  derived_table: {
    sql:
      SELECT askv.asset_id as asset_id, askv.NAME as name, askv.value as value
FROM ES_WAREHOUSE.public.assets AS a
left join ES_WAREHOUSE.public.equipment_makes AS mk
on a.equipment_make_id = mk.equipment_make_id
left join ES_WAREHOUSE.public.equipment_classes_models_xref AS x
on a.equipment_model_id = x.equipment_model_id
left join ES_WAREHOUSE.public.equipment_models AS md
on a.equipment_model_id = md.equipment_model_id
left join ES_WAREHOUSE.public.equipment_classes AS cl
ON x.equipment_class_id = cl.equipment_class_id
LEFT JOIN ES_WAREHOUSE."PUBLIC".asset_status_key_values AS askv
ON a.asset_id = askv.ASSET_ID
WHERE cl.company_division_id = 2
AND askv.NAME = 'engine_active' AND lower(askv.value) = 'true'
                         ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: value {
    type: string
    sql: ${TABLE}.value ;;
  }}
