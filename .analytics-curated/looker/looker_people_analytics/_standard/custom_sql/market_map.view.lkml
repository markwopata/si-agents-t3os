view: market_map {
#   # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: select m.market_id, round(l.LATITUDE,6) latitude, round(l.LONGITUDE,6) longitude, l.ZIP_CODE
          from es_warehouse.public.markets m
         join analytics.public.ES_COMPANIES EC
              on m.COMPANY_ID = ec.COMPANY_ID
                  and ec.OWNED
         join es_Warehouse.public.locations l
              on m.location_id = l.LOCATION_ID
         where m.active
             and (m.IS_PUBLIC_RSP or m.IS_PUBLIC_MSP)
      ;;
  }

  # Define your dimensions and measures here, like this:
  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
    primary_key: yes
  }

  dimension: location {
    type:  location
    sql_longitude: ${TABLE}."LONGITUDE" ;;
    sql_latitude: ${TABLE}."LATITUDE" ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}."ZIP_CODE" ;;
  }
}
