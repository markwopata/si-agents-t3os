view: esassetdetails_wellsfargo_19701 {
  derived_table: {
    sql:
    with base as (
    select
        a.asset_id, a.make,
        a.model, a.vin, a.serial_number, round(ast.hours,2) as asset_hours,
        convert_timezone('America/Chicago', ast.last_location_timestamp) as last_location_timestamp,
        ast.street, ast.city, st.abbreviation as state, ast.zip_code,
        m.name as branch,
        convert_timezone('America/Chicago', ast.asset_inventory_status_timestamp) as asset_inventory_status_timestamp,
        ast.asset_inventory_status,
        concat('https://appcdn.equipmentshare.com/uploads/',p.filename) as photo_link
    from assets a join table(assetlist(29583)) L on L.asset_id = a.asset_id
        left JOIN asset_statuses ast on ast.asset_id = a.asset_id
        left join states st on st.state_id = ast.state_id
        left join markets m on a.inventory_branch_id = m.market_id
        left join photos p on p.photo_id = a.photo_id
    )
    , rental_customer as (
    select r.rental_id, ea.asset_id, c.company_id, c.name as rental_customer
    from base b left join equipment_assignments ea on ea.asset_id = b.asset_id
        join rentals r on ea.rental_id = r.rental_id
        join orders O on O.order_id = R.order_id
        join users U on U.user_id = O.user_id
        join companies C on u.company_id = c.company_id
    where R.rental_status_id = 5
        and (ea.end_date > current_timestamp() or ea.end_date is null)
    )
    select b.*, rc.rental_customer
    from base b left join rental_customer rc on rc.asset_id = b.asset_id
    ;;
  }

  dimension: asset_id {
    label: "Asset"
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

  dimension: zip_code {
    label: "Zipcode"
    type: string
    sql: ${TABLE}."ZIP_CODE" ;;
  }

  dimension: last_location_timestamp {
    label: "Last Location Timestamp"
    type: date_time
    sql: ${TABLE}."LAST_LOCATION_TIMESTAMP" ;;
  }

  dimension: branch {
    label: "Branch"
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

  dimension: rental_customer {
    label: "Rental Customer"
    type: string
    sql: ${TABLE}."RENTAL_CUSTOMER" ;;
  }

  dimension: photo_link {
    label: "Photo Link"
    type: string
    sql: ${TABLE}."PHOTO_LINK" ;;
    html: <font color="#0063f3"><u><a href="{{rendered_value}}" target="_blank">Click for Asset {{asset_id._filterable_value}}</a></font?</u>;;
  }

}
