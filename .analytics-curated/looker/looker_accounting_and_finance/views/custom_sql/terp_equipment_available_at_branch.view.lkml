view: terp_equipment_available_at_branch {
  parameter: date_filter {
    type: date
  }
  parameter: branch_id {
    type: number
    default_value: "5"
  }
  derived_table: {
    sql:WITH yard_equipment AS (
  SELECT
    asset_id
  FROM
    ES_WAREHOUSE."PUBLIC".branch_asset_assignments
  WHERE
    branch_id = {% parameter branch_id %}
    AND branch_asset_assignment_type_id = 1
    and (
      CASE WHEN {% parameter date_filter %} IS NOT NULL
      THEN
      {% parameter date_filter %} BETWEEN start_date AND end_date
      or (end_date IS NULL AND {% parameter date_filter %} > start_date)
      ELSE
      CURRENT_TIMESTAMP() BETWEEN start_date AND end_date
      or (end_date IS NULL AND CURRENT_TIMESTAMP() > start_date)
      END
    )
)
, terp_equipment_model_ids as (
  SELECT
    equipment_model_id
  FROM
    ES_WAREHOUSE."PUBLIC".equipment_model_tag_xref emt
  WHERE
    tag_id = 2
)
SELECT
  distinct(a.asset_id), a.NAME AS asset_name, a.equipment_model_id, tags.name as tag_name
FROM
  ES_WAREHOUSE."PUBLIC".assets a
INNER JOIN yard_equipment ye ON a.asset_id = ye.asset_id
INNER JOIN terp_equipment_model_ids t ON a.equipment_model_id = t.equipment_model_id
INNER JOIN ES_WAREHOUSE."PUBLIC".equipment_model_tag_xref x ON a.equipment_model_id = x.equipment_model_id
INNER JOIN ES_WAREHOUSE."PUBLIC".tags ON x.tag_id = tags.tag_id
;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }
  dimension: asset_name {
    type: string
    sql: ${TABLE}.asset_name ;;
  }
  dimension: equipment_model_id {
    type: number
    sql: ${TABLE}.equipment_model_id ;;
  }
  dimension: tag_name {
    type: string
    sql: ${TABLE}.tag_name ;;
  }
}
