view: asset_type_info {
  derived_table: {
    sql:
  WITH parent_categories AS (SELECT parent_category_id,
                                    name AS parent_category_name,
                                    category_id,
                                    company_division_id
                               FROM es_warehouse.public.categories c
                              WHERE active = TRUE AND parent_category_id IS NULL),
       sub_categories    AS (SELECT parent_category_id,
                                    name AS sub_category_name,
                                    category_id,
                                    company_division_id
                               FROM es_warehouse.public.categories c
                              WHERE active = TRUE)
SELECT a.asset_id,
       a.rental_branch_id,
       asst.name                                  AS equip_type,
       em.name                                    AS equip_model_name,
       ec.name                                    AS equip_class_name,
       sc.sub_category_name,
       pc.parent_category_name,
       bs.name                                    as business_segment,
       asst.name                                  AS asset_type,
       COALESCE(aph.oec, aph.purchase_price)      AS oec,
       CURRENT_DATE() - MIN(ais.date_start)::date AS days_in_service
  FROM es_warehouse.public.assets a
       LEFT JOIN es_warehouse.public.asset_types asst
                 ON a.asset_type_id = asst.asset_type_id
       LEFT JOIN es_warehouse.public.equipment_models em
                 ON a.equipment_model_id = em.equipment_model_id
       LEFT JOIN es_warehouse.public.equipment_classes_models_xref ecmx
                 ON em.equipment_model_id = ecmx.equipment_model_id
       LEFT JOIN es_warehouse.public.equipment_classes ec
                 ON ecmx.equipment_class_id = ec.equipment_class_id
       LEFT JOIN sub_categories sc
                 ON ec.category_id = sc.category_id
       LEFT JOIN parent_categories pc
                 ON sc.parent_category_id = pc.category_id AND sc.category_id = ec.category_id
       LEFT JOIN es_warehouse.public.asset_purchase_history aph
                 ON a.asset_id = aph.asset_id
       LEFT JOIN es_warehouse.scd.scd_asset_inventory_status ais
                 ON a.asset_id = ais.asset_id AND ais.asset_inventory_status = 'Ready To Rent'
       LEFT JOIN es_warehouse.public.business_segments bs
                 ON ec.business_segment_id = bs.business_segment_id
{% if es_owned_assets._parameter_value == 'Yes' %}
 WHERE a.company_id = 1854
{% else %}
{% endif %}
 GROUP BY a.asset_id, a.rental_branch_id, asst.name, em.name, ec.name, sc.sub_category_name, pc.parent_category_name,
          COALESCE(aph.oec, aph.purchase_price), bs.name

;;
  }

  parameter: es_owned_assets {
    label: "ES Owned Assets"
    type: unquoted
    default_value: "All"

    allowed_value: {
      label: "Only ES Owned"
      value: "Yes"
    }

    allowed_value: {
      label: "All Assets"
      value: "All"
    }
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: equipment_type {
    type: string
    sql: ${TABLE}."EQUIP_TYPE" ;;
  }

  dimension: equipment_model {
    type: string
    sql: ${TABLE}."EQUIP_MODEL_NAME" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIP_CLASS_NAME" ;;
  }

  dimension: sub_category {
    type: string
    sql: COALESCE(${TABLE}."SUB_CATEGORY_NAME",'Null') ;;
  }

  dimension: parent_category {
    type: string
    sql: COALESCE(${TABLE}."PARENT_CATEGORY_NAME",'Null') ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: days_in_service {
    type: number
    sql: ${TABLE}."DAYS_IN_SERVICE" ;;
  }

  dimension: business_segment {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT" ;;
  }

  # - - - - - MEASURES - - - - -

  measure: current_total_assets {
    type: count_distinct
    sql: ${asset_id} ;;
  }

  measure: total_oec {
    type: sum
    sql: ${oec} ;;
  }
}
