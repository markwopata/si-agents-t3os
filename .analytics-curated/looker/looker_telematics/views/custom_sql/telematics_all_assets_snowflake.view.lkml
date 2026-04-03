view: telematics_all_assets_snowflake {

  derived_table: {
    sql: select a.asset_id as asset_id,
        a.serial_number as serial_number,
        cat.name as category,
        a.make as make,
        a.model as model,
        a.tracker_id as tracker_id,
        a.company_id as company_id,
        r.rental_id as rental_id,
        rs.name as rental_status,
        m.name as inventory_branch,
        l.nickname as job_site,
        l.street_1 as street_address_1,
        l.city as city,
        s.name as state,
        l.zip_code as zip_code,
        l.latitude as latitude,
        l.longitude as longitude,
        a.tracker_id as tracker_on_asset_table,
        ata.tracker_id as tracker_from_assignments,
        ata.date_installed as date_installed,
        ata.date_uninstalled as date_uninstalled,
        ea2.start_date::date as start_date,
        ea2.start_date::time as start_date_time
        from ES_WAREHOUSE."PUBLIC".assets a
          join (select max(equipment_assignment_id) max_id, asset_id from ES_WAREHOUSE."PUBLIC".equipment_assignments group by asset_id) as ea on ea.asset_id = a.asset_id
          join ES_WAREHOUSE."PUBLIC".equipment_assignments ea2 on ea2.equipment_assignment_id = ea.max_id
          join ES_WAREHOUSE."PUBLIC".rentals r on r.rental_id = ea2.rental_id
          join analytics."PUBLIC".rental_statuses rs on rs.rental_status_id = r.rental_status_id
          join (select max(rental_location_assignment_id) max_rla_id, rental_id from ES_WAREHOUSE."PUBLIC".rental_location_assignments group by rental_id) as rla on rla.rental_id = r.rental_id
          join ES_WAREHOUSE."PUBLIC".rental_location_assignments rla2 on rla2.rental_location_assignment_id = rla.max_rla_id
          join ES_WAREHOUSE."PUBLIC".locations l on l.location_id = rla2.location_id
          join ES_WAREHOUSE."PUBLIC".states s on s.state_id = l.state_id
          left join ES_WAREHOUSE."PUBLIC".categories cat on a.category_id = cat.category_id
          left join ES_WAREHOUSE."PUBLIC".equipment_classes_models_xref x on a.equipment_model_id = x.equipment_model_id
          left join ES_WAREHOUSE."PUBLIC".asset_tracker_assignments ata on a.asset_id=ata.asset_id
          left join ES_WAREHOUSE."PUBLIC".markets m on a.inventory_branch_id = m.market_id
          where lower(l.nickname) NOT LIKE '%auckland%'
          and s.name NOT LIKE '%New Zealand%'
                     ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}.serial_number ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}.tracker_id ;;
  }


  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}.rental_id ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}.rental_status ;;
  }

  dimension: inventory_branch {
    type: string
    sql: ${TABLE}.inventory_branch ;;
  }

  dimension:job_site {
    type: string
    sql: ${TABLE}.job_site ;;
  }

  dimension:street_address_1 {
    type: string
    sql: ${TABLE}.street_address_1 ;;
  }

  dimension:city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension:state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension:zip_code {
    type: number
    sql: ${TABLE}.zip_code ;;
  }

  dimension:latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension:longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: location {
    type:  location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }

  dimension:tracker_on_asset_table {
    type: number
    sql: ${TABLE}.tracker_on_asset_table ;;
  }

  dimension:tracker_from_assignments {
    type: number
    sql: ${TABLE}.tracker_from_assignments ;;
  }

  dimension:date_installed {
    type: date_time
    sql: ${TABLE}.date_installed ;;
  }

  dimension:date_uninstalled {
    type: date_time
    sql: ${TABLE}.date_uninstalled ;;
  }

  dimension:start_date {
    type: date_time
    sql: ${TABLE}.start_date ;;
  }

  #dimension: start_date_time {
  #  type: time
  #  sql: ${TABLE}."start_date_time" ;;
#  }


  set: telematics_db_details {
    fields: [asset_id,serial_number,category,make,model,tracker_id,company_id,rental_id,rental_status,inventory_branch,job_site,street_address_1,city,state,zip_code,
      latitude,longitude,tracker_on_asset_table,tracker_from_assignments,date_installed,start_date]
  }

  measure: asset_count {
    type: count_distinct
    drill_fields: [telematics_db_details*]
    sql: ${asset_id} ;;
  }



}
