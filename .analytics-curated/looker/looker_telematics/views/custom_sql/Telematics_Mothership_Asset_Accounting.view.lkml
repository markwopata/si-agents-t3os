view: Telematics_Mothership_Asset_Accounting {
  derived_table: {
    sql:
    with TM_primary_trackers_full as (
    select
        'TRACKER' as DEVICE_TYPE,
        REPLACE(TRACKER_SERIAL, '-', '') as SERIAL_FORMATTED,
        TRACKER_ID as DEVICE_ID,
        ASSET_ID as ASSET_ID,
        COMPANY_ID as COMPANY_ID,
        COMPANY_NAME as COMPANY_NAME,
        MARKET_NAME as MARKET_NAME,
        DATE(TRACKER_LAST_DATE_INSTALLED) as LAST_DATE_INSTALLED,
        DATE(LAST_CHECKIN_TIMESTAMP) as LAST_CHECK_IN,
        ASSET_HEALTH_STATUS as ASSET_HEALTH_STATUS,
        ASSET_HEALTH_DETAIL as DEVICE_HEALTH_STATUS,
        'PRIMARY TRACKER' as "MAIN_MOVER"
    from
        ANALYTICS.BI_OPS.TELEMATICS_MOTHERSHIP
    )

, TM_primary_trackers as (
    select
        *
    from
        TM_primary_trackers_full
    where
        TM_primary_trackers_full.SERIAL_FORMATTED is not null
    )

, TM_secondary_trackers_full as (
    select
        'TRACKER' as DEVICE_TYPE,
        REPLACE(SECONDARY_TRACKER_SERIAL, '-', '') as SERIAL_FORMATTED,
        SECONDARY_TRACKER_ID as DEVICE_ID,
        ASSET_ID as ASSET_ID,
        COMPANY_ID as COMPANY_ID,
        COMPANY_NAME as COMPANY_NAME,
        MARKET_NAME as MARKET_NAME,
        DATE(TRACKER_LAST_DATE_INSTALLED) as LAST_DATE_INSTALLED,
        DATE(SECONDARY_TRACKER_LAST_CHECKIN) as LAST_CHECK_IN,
        ASSET_HEALTH_STATUS as ASSET_HEALTH_STATUS,
        SECONDARY_TRACKER_HEALTH_STATUS as DEVICE_HEALTH_STATUS,
        'SECONDARY TRACKER' as "MAIN_MOVER"
    from
        ANALYTICS.BI_OPS.TELEMATICS_MOTHERSHIP
)

, TM_secondary_trackers as (
    select
        *
    from
        TM_secondary_trackers_full
    where
        TM_secondary_trackers_full.SERIAL_FORMATTED is not null
    )

, tracker_choice as (
select
    case
        when TM_primary_trackers.LAST_DATE_INSTALLED >= TM_secondary_trackers.LAST_DATE_INSTALLED then 'PRIMARY TRACKER'
        when TM_primary_trackers.LAST_DATE_INSTALLED < TM_secondary_trackers.LAST_DATE_INSTALLED then 'SECONDARY TRACKER'
    end as choice,
    TM_primary_trackers.SERIAL_FORMATTED
from
    TM_primary_trackers
join
    TM_secondary_trackers
    on TM_primary_trackers.SERIAL_FORMATTED = TM_secondary_trackers.SERIAL_FORMATTED
)

, TM_secondary_trackers_choice as (
select
    TM_secondary_trackers.*
from
    TM_secondary_trackers
left join
    tracker_choice
    on tracker_choice.SERIAL_FORMATTED = TM_secondary_trackers.SERIAL_FORMATTED
where
    tracker_choice.choice = 'SECONDARY TRACKER'
)

, TM_primary_trackers_choice as (
select
    TM_primary_trackers.*
from
    TM_primary_trackers
where
    TM_primary_trackers.SERIAL_FORMATTED not in (select distinct SERIAL_FORMATTED from TM_secondary_trackers_choice)
)

, TM_primary_trackers_null as (
select
    TM_primary_trackers.*
from
    TM_primary_trackers
where
    TM_primary_trackers.SERIAL_FORMATTED not in (select SERIAL_FORMATTED from TM_primary_trackers_choice)
)

, TM_trackers_union as (
select
    *
from
    TM_primary_trackers_choice
union
select
    *
from
    TM_primary_trackers_null
union
select
    *
from
    TM_secondary_trackers_choice
)

, camera_install_dates_full as (
    select
        REPLACE(CAM.DEVICE_SERIAL, '-', '') as DEVICE_SERIAL,
        MAX(ACA.DATE_INSTALLED) as DATE_INSTALLED
    from
        ES_WAREHOUSE.PUBLIC.CAMERAS CAM
    left join
        ES_WAREHOUSE.PUBLIC.ASSET_CAMERA_ASSIGNMENTS ACA
        on ACA.CAMERA_ID = CAM.CAMERA_ID
    group by
        CAM.DEVICE_SERIAL
)

, camera_install_dates as (
    select
        *
    from
        camera_install_dates_full
    where
        DATE_INSTALLED is not null
)

, TM_cameras_full as (
    select
        'CAMERA' as DEVICE_TYPE,
        REPLACE(CAMERA_SERIAL, '-', '') as SERIAL_FORMATTED,
        CAMERA_ID as DEVICE_ID,
        ASSET_ID as ASSET_ID,
        COMPANY_ID as COMPANY_ID,
        COMPANY_NAME as COMPANY_NAME,
        MARKET_NAME as MARKET_NAME,
        '' as LAST_DATE_INSTALLED,
        DATE(LAST_CAMERA_HEARTBEAT) as LAST_CHECK_IN,
        ASSET_HEALTH_STATUS as ASSET_HEALTH_STATUS,
        CAMERA_HEALTH as DEVICE_HEALTH_STATUS,
        'CAMERA' as "MAIN_MOVER"
    from
        ANALYTICS.BI_OPS.TELEMATICS_MOTHERSHIP TM
)

, TM_cameras as (
    select
        TM_cameras_full.DEVICE_TYPE as DEVICE_TYPE,
        TM_cameras_full.SERIAL_FORMATTED as SERIAL_FORMATTED,
        TM_cameras_full.DEVICE_ID as DEVICE_ID,
        TM_cameras_full.ASSET_ID as ASSET_ID,
        TM_cameras_full.COMPANY_ID as COMPANY_ID,
        TM_cameras_full.COMPANY_NAME as COMPANY_NAME,
        TM_cameras_full.MARKET_NAME as MARKET_NAME,
        camera_install_dates.DATE_INSTALLED as LAST_DATE_INSTALLED,
        TM_cameras_full.LAST_CHECK_IN as LAST_CHECK_IN,
        TM_cameras_full.ASSET_HEALTH_STATUS as ASSET_HEALTH_STATUS,
        TM_cameras_full.DEVICE_HEALTH_STATUS as DEVICE_HEALTH_STATUS,
        TM_cameras_full."MAIN_MOVER" as "MAIN_MOVER"
    from
        TM_cameras_full
    left join
        camera_install_dates
        on TM_cameras_full.SERIAL_FORMATTED = camera_install_dates.DEVICE_SERIAL
    where
        TM_cameras_full.SERIAL_FORMATTED is not null
)

, keypad_install_dates_full as (
    select
        REPLACE(KPD.SERIAL_NUMBER, '-', '') as DEVICE_SERIAL,
        MAX(AKA.START_DATE) as DATE_INSTALLED
    from
        ES_WAREHOUSE.PUBLIC.KEYPADS KPD
    left join
        ES_WAREHOUSE.PUBLIC.KEYPAD_ASSET_ASSIGNMENTS AKA
        on AKA.KEYPAD_ID = KPD.KEYPAD_ID
    group by
        KPD.SERIAL_NUMBER
)

, keypad_install_dates as (
    select
        *
    from
        keypad_install_dates_full
    where
        DATE_INSTALLED is not null
)

, TM_keypads_full as (
    select
         'KEYPAD' as DEVICE_TYPE,
        REPLACE(KEYPAD_SERIAL, '-', '') as SERIAL_FORMATTED,
        KEYPAD_ID as DEVICE_ID,
        ASSET_ID as ASSET_ID,
        COMPANY_ID as COMPANY_ID,
        COMPANY_NAME as COMPANY_NAME,
        MARKET_NAME as MARKET_NAME,
        '' as LAST_DATE_INSTALLED,
        LAST_KEYPAD_ENTRY_DATE as LAST_CHECK_IN,
        ASSET_HEALTH_STATUS as ASSET_HEALTH_STATUS,
        KEYPAD_VS_TRIP_HEALTH as DEVICE_HEALTH_STATUS,
        'KEYPAD' as "MAIN_MOVER"
    from
        ANALYTICS.BI_OPS.TELEMATICS_MOTHERSHIP TM
)

, TM_keypads as (
    select
        TM_keypads_full.DEVICE_TYPE as DEVICE_TYPE,
        TM_keypads_full.SERIAL_FORMATTED as SERIAL_FORMATTED,
        TM_keypads_full.DEVICE_ID as DEVICE_ID,
        TM_keypads_full.ASSET_ID as ASSET_ID,
        TM_keypads_full.COMPANY_ID as COMPANY_ID,
        TM_keypads_full.COMPANY_NAME as COMPANY_NAME,
        TM_keypads_full.MARKET_NAME as MARKET_NAME,
        keypad_install_dates.DATE_INSTALLED as LAST_DATE_INSTALLED,
        TM_keypads_full.LAST_CHECK_IN as LAST_CHECK_IN,
        TM_keypads_full.ASSET_HEALTH_STATUS as ASSET_HEALTH_STATUS,
        TM_keypads_full.DEVICE_HEALTH_STATUS as DEVICE_HEALTH_STATUS,
        TM_keypads_full."MAIN_MOVER" as "MAIN_MOVER"
    from
        TM_keypads_full
    left join
        keypad_install_dates
        on TM_keypads_full.SERIAL_FORMATTED = keypad_install_dates.DEVICE_SERIAL
    where
        TM_keypads_full.SERIAL_FORMATTED is not null
)

, TM_devices_union as (
    select
        *
    from
        TM_trackers_union
    union
    select
        *
    from
        TM_cameras
    union
    select
        *
    from
        TM_keypads
    )

select * from TM_devices_union
      ;;
  }


  dimension: DEVICE_TYPE {
    type: string
    sql: ${TABLE}.DEVICE_TYPE ;;
  }

  dimension: SERIAL_FORMATTED {
    type: string
    sql: ${TABLE}.SERIAL_FORMATTED ;;
  }

  dimension: DEVICE_ID {
    type: string
    sql: ${TABLE}.DEVICE_ID ;;
  }

  dimension: ASSET_ID {
    type: string
    sql: ${TABLE}.ASSET_ID ;;
  }

  dimension: COMPANY_ID {
    type: string
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: COMPANY_NAME {
    type: string
    sql: ${TABLE}.COMPANY_NAME ;;
  }

  dimension: MARKET_NAME {
    type: string
    sql: ${TABLE}.MARKET_NAME ;;
  }

  dimension: LAST_DATE_INSTALLED {
    type: date
    sql: ${TABLE}.LAST_DATE_INSTALLED ;;
  }

  dimension: LAST_CHECK_IN {
    type: date
    sql: ${TABLE}.LAST_CHECK_IN ;;
  }

  dimension: ASSET_HEALTH_STATUS {
    type: string
    sql: ${TABLE}.ASSET_HEALTH_STATUS ;;
  }

  dimension: DEVICE_HEALTH_STATUS {
    type: string
    sql: ${TABLE}.DEVICE_HEALTH_STATUS ;;
  }

  dimension: MAIN_MOVER {
    type: string
    sql: ${TABLE}.MAIN_MOVER ;;
  }

}
