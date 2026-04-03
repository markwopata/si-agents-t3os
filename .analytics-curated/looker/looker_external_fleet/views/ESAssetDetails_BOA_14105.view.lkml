view: esassetdetails_boa_14105 {
  derived_table: {
    sql:
    with asset_groups as (
    select distinct L.asset_id, x.organization_id
    from table(assetlist(21915)) L
        left join organization_asset_xref x on x.asset_id = L.asset_id
    )
    select ag.organization_id, coalesce(o.name, 'Unassigned Assets') as schedule, ag.asset_id, a.make, a.model, a.vin, a.serial_number, round(ast.hours,2) as asset_hours,
        convert_timezone('America/Chicago', ast.last_location_timestamp) as last_location_timestamp,
        ast.street, ast.city, st.abbreviation as state, m.name as branch,
        convert_timezone('America/Chicago', ast.asset_inventory_status_timestamp) as asset_inventory_status_timestamp,
        ast.asset_inventory_status,
        convert_timezone('America/Chicago', ast.asset_rental_status_timestamp) as asset_rental_status_timestamp,
        ast.asset_rental_status
     from asset_groups ag left join asset_statuses ast on ast.asset_id = ag.asset_id
        join assets a on ag.asset_id = a.asset_id
        left join states st on st.state_id = ast.state_id
        join markets m on a.inventory_branch_id = m.market_id
        left join organizations o on o.organization_id = ag.organization_id
    where o.company_id = 14105 or o.company_id is null
    ;;
  }

  dimension: asset_id {
    label: "Asset ID"
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: organization_id {
    type: number
    sql: ${TABLE}."ORGANIZATION_ID" ;;
  }

  dimension: schedule {
    label: "Schedule No."
    type: string
    sql: ${TABLE}."SCHEDULE" ;;
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
    label: "Serial Number"
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

  dimension: asset_rental_status {
    label: "Rental Status"
    type: string
    sql: ${TABLE}."ASSET_RENTAL_STATUS" ;;
  }

  dimension: asset_rental_status_timestamp {
    label: "Rental Status Timestamp"
    type: date_time
    sql: ${TABLE}."ASSET_RENTAL_STATUS_TIMESTAMP" ;;
  }

 }
