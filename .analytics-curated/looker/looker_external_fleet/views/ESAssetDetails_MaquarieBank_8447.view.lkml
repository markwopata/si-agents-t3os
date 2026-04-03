view: esassetdetails_maquariebank_8447 {
   derived_table: {
    sql:
      select a.asset_id, a.make, a.model, a.vin, a.serial_number, round(ast.hours,2) as asset_hours,
        convert_timezone('America/Chicago', ast.last_location_timestamp) as last_location_timestamp,
        ast.street, ast.city, st.abbreviation as state, m.name as branch,
        convert_timezone('America/Chicago', ast.asset_inventory_status_timestamp) as asset_inventory_status_timestamp,
        ast.asset_inventory_status,
        convert_timezone('America/Chicago', ast.asset_rental_status_timestamp) as asset_rental_status_timestamp,
        ast.asset_rental_status
     from assets a join table(assetlist(12719)) L on L.asset_id = a.asset_id
         left join asset_statuses ast on ast.asset_id = a.asset_id
        left join states st on st.state_id = ast.state_id
        join markets m on a.inventory_branch_id = m.market_id
    ;;
  }

  dimension: asset_id {
    label: "Asset ID"
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: make {
    label: "Make"
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    label: "Model"
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: vin {
    label: "VIN"
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  dimension: serial_number {
    label: "Serial No."
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: asset_hours {
    label: "Asset Hours"
    type: number
    sql: ${TABLE}."ASSET_HOURS" ;;
  }

  dimension: street {
    label: "Street"
    type: string
    sql: ${TABLE}."STREET" ;;
  }

  dimension: city {
    label: "City"
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    label: "State"
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: last_location_timestamp {
    label: "Last Location Timestamp"
    type: date_time
    sql: ${TABLE}."LAST_LOCATION_TIMESTAMP" ;;
  }

  dimension: branch {
    label: "Inventory Branch"
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: asset_inventory_status {
    label: "Inventory Status"
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: asset_inventory_status_timestamp {
    label: "Inventory Status Timestamp"
    type: date_time
    sql: ${TABLE}."ASSET_INVENTORY_STATUS_TIMESTAMP" ;;
  }

  }
