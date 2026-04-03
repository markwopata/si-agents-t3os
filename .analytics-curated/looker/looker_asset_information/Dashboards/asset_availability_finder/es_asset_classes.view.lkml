
view: es_asset_classes {
  derived_table: {
    sql:
      select
        distinct(REPLACE(ec.name, ',', '')) as asset_class,
        UPPER(a.make) as make,
        UPPER(a.model) as model
      from
        es_warehouse.public.assets a
        join analytics.bi_ops.asset_ownership ao on a.asset_id = ao.asset_id
        left join es_warehouse.public.equipment_models em on em.equipment_model_id = a.equipment_model_id
        left join es_warehouse.public.equipment_classes_models_xref ecm on ecm.equipment_model_id = em.equipment_model_id
        left join es_warehouse.public.equipment_classes ec on ec.equipment_class_id = ecm.equipment_class_id
      where
          a.company_id = 1854
          AND a.deleted = FALSE
          AND ao.ownership in ('ES', 'OWN')
          ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  set: detail {
    fields: [
        asset_class
    ]
  }
}
