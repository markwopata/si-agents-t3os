view: locations_by_job_view {
   derived_table: {
    sql: select jo.JOB_ID, jo._FIVETRAN_SYNCED, o.ID, o.NAME, o.LOCATION_NAME, lrx.REGION, lrx.DISTRICT, lrx.MARKET_ID, lrx.MARKET_TYPE,
       CASE
           WHEN SPLIT_PART(o.NAME, ',',2) = '' and SPLIT_PART(o.NAME,' ',3) = '' then SPLIT_PART(o.NAME,' ',2)
           WHEN SPLIT_PART(o.NAME, ',',2) = '' and SPLIT_PART(o.NAME,' ',3) = '-' and SPLIT_PART(o.LOCATION_NAME,',',2) = ' Texas' then 'TX'
           WHEN SPLIT_PART(o.NAME, ',',2) = '' and SPLIT_PART(o.NAME,' ',3) = '-' and SPLIT_PART(o.LOCATION_NAME,',',2) = ' Missouri' then 'MO'
           WHEN SPLIT_PART(o.NAME, ',',2) = '' and SPLIT_PART(o.NAME,' ',3) = '-' and SPLIT_PART(o.LOCATION_NAME,',',2) = ' Florida' then 'FL'
           WHEN SPLIT_PART(o.NAME, ',',2) = '' then SPLIT_PART(o.NAME,' ',3)
           ELSE SPLIT_PART(SPLIT_PART(o.NAME, ',',2),' ',2)
END as "STATE"
from GREENHOUSE.JOB_OFFICE jo
left join GREENHOUSE.OFFICE o on o.ID = jo.OFFICE_ID
left join GREENHOUSE.LOCATION_REGION_XWALK lrx on lrx.LOCATION = o.LOCATION_NAME
;;
  }


  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: location_name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }


  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: state {
    label: "State"
    type: string
    map_layer_name: us_states
    sql: ${TABLE}."STATE" ;;
  }

}
