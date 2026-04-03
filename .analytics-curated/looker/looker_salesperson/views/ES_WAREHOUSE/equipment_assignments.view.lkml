view: equipment_assignments {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_ASSIGNMENTS"
  ;;
  drill_fields: [equipment_assignment_id]

  dimension: equipment_assignment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EQUIPMENT_ASSIGNMENT_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: drop_off_delivery_id {
    type: number
    sql: ${TABLE}."DROP_OFF_DELIVERY_ID" ;;
  }

  dimension_group: end {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: return_delivery_id {
    type: number
    sql: ${TABLE}."RETURN_DELIVERY_ID" ;;
  }

  dimension_group: start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }


  dimension: view_assets_on_rent {
    type: string
    sql: CASE WHEN ${asset_id} is not null THEN 'View Assets On Rent' END ;;

    link: {
      label: "View Assets On Rent"
      url: "https://equipmentshare.looker.com/dashboards-next/238?Asset+ID=&District={{ _filters['market_region_xwalk.district_text'] | url_encode }}&Market={{ _filters['markets.name'] | url_encode }}&Region={{ _filters['market_region_xwalk.region_name'] | url_encode}}&Salesperson={{ _filters['users.Full_Name_with_ID'] | url_encode}}"
    }
  }

  measure: count {
    type: count
    drill_fields: [detail*]

    link: {
      label: "View or Download Assets On Rent"
      url: "https://equipmentshare.looker.com/dashboards-next/238?Asset+ID=&District={{ _filters['market_region_xwalk.district_text'] | url_encode }}&Market={{ _filters['markets.name'] | url_encode }}&Region={{ _filters['market_region_xwalk.region_name'] | url_encode}}&Salesperson={{ _filters['users.Full_Name_with_ID'] | url_encode}}"
    }

    link: {
      label: "View Rental History"
      url: "https://equipmentshare.looker.com/dashboards-next/330?Asset+ID=&District={{ _filters['market_region_xwalk.district_text'] | url_encode }}&Market={{ _filters['markets.name'] | url_encode }}&Region={{ _filters['market_region_xwalk.region_name'] | url_encode}}&Salesperson={{ _filters['users.Full_Name_with_ID'] | url_encode}}"
    }
  }

  dimension: asset_id_link_to_asset_dashboard {
    type: number
    sql: ${asset_id} ;;

    link: {
      label: "View Asset Details Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/169?Asset+ID={{ value | url_encode }}"
    }
  }

  measure: most_recent_start {
    sql: MAX(${start_date}) ;;
  }

  set: detail {
    fields: [
      asset_id,
      rentals.rental_id,
      companies.company_name_with_T3_link,
      market_region_xwalk.market_name,
      equipment_classes.name,
      assets.make_and_model,
      assets.name,
      asset_company.name,
      last_complete_delivery.nickname,
      last_complete_delivery.jobsite_link,
      requested_by_user.requested_by,
      last_complete_delivery.contact_name,
      start_date,
      end_date,
      order_salespersons_pivot.secondary_rep_ind
    ]
  }
}
