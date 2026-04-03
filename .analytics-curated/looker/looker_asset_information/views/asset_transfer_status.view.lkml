
view: asset_transfer_status {
  derived_table: {
    sql: WITH ranked_statuses AS (
  SELECT
    asset_id,
    status,
    _es_update_timestamp,
    ROW_NUMBER() OVER (
      PARTITION BY asset_id
      ORDER BY _es_update_timestamp DESC
    ) AS row_num
  FROM asset_transfer.public.transfer_orders
)
SELECT
  a.asset_id,
  rs.status,
  rs._es_update_timestamp,
  rs.row_num
FROM es_warehouse.public.assets AS a
LEFT JOIN ranked_statuses AS rs
  ON a.asset_id = rs.asset_id
  AND rs.row_num = 1;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: _es_update_timestamp {
    type: date
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: row_num{
    type: string
    sql: ${TABLE}."ROW_NUM" ;;
  }

  parameter: in_transit_selector {
    type: unquoted
    allowed_value: {
      label: "In Transit"
      value: "in_transit"
    }
    allowed_value: {
      label: "Requested"
      value: "requested"
    }
    allowed_value: {
      label: "Show All"
      value: "all"
    }
    default_value: "all"
  }

  dimension: in_transit_status {
    type: string
    sql: CASE
        WHEN ${status} = 'Requested' THEN 'Requested'
        WHEN ${status} = 'Approved' THEN 'Yes'
        ELSE 'No'
       END ;;
  }

  dimension: in_transit_display {
    type: yesno
    sql:
      {% if in_transit_selector._parameter_value == "in_transit" %}
        ${status} = 'Approved'
      {% elsif in_transit_selector._parameter_value == "requested" %}
        ${status} = 'Requested'
      {% else %}
        TRUE -- no filtering (show all)
      {% endif %} ;;
  }

  dimension: transit_status {
    type: string
    sql: case
          when ${status} = 'Requested' then 'Requested'
          when ${status} = 'Approved' then 'In Transit'
          else null
          end;;
  }



  set: detail {
    fields: [
        status,
        asset_id,
        _es_update_timestamp
    ]
  }
}
