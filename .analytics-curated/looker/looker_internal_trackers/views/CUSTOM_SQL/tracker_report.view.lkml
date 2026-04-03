
view: tracker_report {

  derived_table: {
    sql: select
      et.device_serial,
      coalesce(tv.name, 'No tracker vendor') as vendor,
      coalesce(tt.config_version, 'No config found') as config,
      coalesce(tt.config_status, 'Unknown') as status,
      concat(coalesce(tt.script_version, '0'), '.', coalesce(tt.config_version, '0')) as version,
      tt.phone_number as tracker_phone,
      a.asset_id as asset_id,
      concat(a.custom_name, '.', a.model) as asset_name,
      c.name as company,
      c.company_id as company_id,
      u.username as email,
      concat(u.first_name, ' ', u.last_name) as owner,
      u.phone_number as phone,
      tt.firmware_version as firmware,
      aty.name as asset_type,
      KPAD.SERIAL_NUMBER AS keypad_serial,
      CAM.DEVICE_SERIAL AS camera_serial,
      CAMV.NAME AS camera_vendor
      from ES_WAREHOUSE.public.trackers et
          join ES_WAREHOUSE.trackers.trackers tt
              on et.device_serial = tt.device_serial
          join ES_WAREHOUSE.public.assets a
              on a.tracker_id = et.tracker_id
          join ES_WAREHOUSE.public.tracker_vendors tv
              on tv.tracker_vendor_id = et.vendor_id
          join ES_WAREHOUSE.public.companies c
              on c.company_id = a.company_id
          join ES_WAREHOUSE.public.users u
              on u.user_id = c.owner_user_id
          join ES_WAREHOUSE.public.asset_types aty
              on aty.asset_type_id = a.asset_type_id
          left join ES_WAREHOUSE.PUBLIC.KEYPAD_ASSET_ASSIGNMENTS KAA
              on A.ASSET_ID = KAA.ASSET_ID
                  and KAA.END_DATE is NULL
          left join ES_WAREHOUSE.PUBLIC.KEYPADS KPAD
              on KAA.KEYPAD_ID = KPAD.KEYPAD_ID
          left join ES_WAREHOUSE.PUBLIC.ASSET_CAMERA_ASSIGNMENTS CAMA
                   on A.ASSET_ID = CAMA.ASSET_ID
                       and CAMA.DATE_UNINSTALLED is NULL
          left join ES_WAREHOUSE.PUBLIC.CAMERAS CAM
              ON CAMA.CAMERA_ID = CAM.CAMERA_ID
          left join ES_WAREHOUSE.PUBLIC.CAMERA_VENDORS CAMV
              ON CAM.CAMERA_VENDOR_ID = CAMV.CAMERA_VENDOR_ID
           ;;
  }

  dimension: device_serial {
    type: string
    sql: ${TABLE}.device_serial ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}.vendor ;;
  }

  dimension: config {
    type: string
    sql: ${TABLE}.config ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: version {
    type: string
    sql: ${TABLE}.version ;;
  }

  dimension: tracker_phone {
    type: string
    sql: ${TABLE}.tracker_phone ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: asset_name{
    type: string
    sql: ${TABLE}.asset_name ;;
  }

  dimension: company{
    type: string
    sql: ${TABLE}.company ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: email{
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: owner{
    type: string
    sql: ${TABLE}.owner ;;
  }

  dimension: phone{
    type: string
    sql: ${TABLE}.phone ;;
  }

  dimension: firmware{
    type: string
    sql: ${TABLE}.firmware ;;
  }

  dimension: asset_type{
    type: string
    sql: ${TABLE}.asset_type ;;
  }

  dimension: keypad_serial{
    type: string
    sql: ${TABLE}.keypad_serial ;;
  }

  dimension: camera_serial{
    type: string
    sql: ${TABLE}.camera_serial ;;
  }

  dimension: camera_vendor{
    type: string
    sql: ${TABLE}.camera_vendor ;;
  }
}
