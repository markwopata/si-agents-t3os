view: fleetcam_driver_scoring {
    derived_table: {
      sql:
      WITH EVENT_TYPES AS (SELECT *
                     FROM INBOUND.FTSGPS_VIEW.FLEETCAM_EVENTS_TYPE FET
                         QUALIFY ROW_NUMBER() OVER (PARTITION BY FET.EVENTTYPEID ORDER BY FET.FILE_DATE DESC) =
                                 1),
     VEHICLE_INFO AS (SELECT *
                      FROM INBOUND.FTSGPS_VIEW.FLEETCAM_VEHICLES FV
                          QUALIFY ROW_NUMBER() OVER (PARTITION BY FV.VEHICLEID ORDER BY FV.FILE_DATE DESC) =
                                  1)
SELECT FE.EVENTID                                             AS EVENT_ID,
       TO_DATE(FE.EVENTDATE)                                  AS EVENT_DATE,
       FE.EVENTTYPEID                                         AS EVENT_TYPE_ID,
       ET.EVENTTYPENAME                                       AS EVENT_TYPE_NAME,
       COALESCE(COALESCE(U.FIRST_NAME || ' ' || U.LAST_NAME, A.DRIVER_NAME),
                'NO ASSIGNED DRIVER')                         AS COALESCED_DRIVER_NAME,
       COALESCE(IFF(U.FIRST_NAME || U.LAST_NAME IS NOT NULL, 'E-LOGS DRIVER',
                    'ASSET ASSIGMENT'), 'NO ASSIGNED DRIVER') AS DRIVER_SOURCE,
       U.FIRST_NAME || ' ' || U.LAST_NAME                     AS ELOGS_DRIVER_NAME,
       U.USER_ID                                              AS ELOGS_DRIVER_USER_ID,
       VI.VEHICLENAME                                         AS FLEETCAM_VEHICLENAME,
       A.DRIVER_NAME                                          AS ASSETS_DRIVER_NAME,
       CD.EMPLOYEE_ID                                         AS ELOGS_DRIVER_EMPLOYEE_ID,
       CD.WORK_EMAIL                                          AS ELOGS_DRIVER_WORK_EMAIL,
       COALESCE(IM.NAME, CDM.NAME)                            AS COALESCED_MARKET_NAME,
       A.INVENTORY_BRANCH_ID                                  AS ASSETS_INVENTORY_MARKET_ID,
       IM.NAME                                                AS ASSETS_INVENTORY_MARKET,
       CD.MARKET_ID                                           AS EMPLOYEE_MARKET_ID,
       CDM.NAME                                               AS EMPLOYEE_MARKET_NAME,
       VI.GPSDEVICEID                                         AS FLEETCAM_SERIAL,
       CAM.DEVICE_SERIAL                                      AS ES_DEVICE_SERIAL,
       ACA.ASSET_ID                                           AS ES_ASSET_ID,
       A.MAKE,
       A.MODEL,
       A.COMPANY_ID,
       CASE
           WHEN FE.EVENTTYPEID = 14 -- DRIVER DISTRACTED
               THEN 3.5
           WHEN FE.EVENTTYPEID = 13 -- DRIVER SMOKING
               THEN 7
           WHEN FE.EVENTTYPEID = 12 -- DRIVER USING CELL PHONE
               THEN 17.5
           WHEN FE.EVENTTYPEID = 16 -- FOLLOWING DISTANCE WARNING
               THEN 8.3
           WHEN FE.EVENTTYPEID = 9 -- FORWARD COLLISION WARNING
               THEN 8.3
           WHEN FE.EVENTTYPEID = 22 -- HARSH BRAKING
               THEN 8.3
           ELSE 0
           END                                                AS EVENT_POINTS
        ,
       CASE
           WHEN FE.EVENTTYPEID = 31 -- NO SEAT BELT
               THEN 1
           WHEN FE.EVENTTYPEID = 3 -- CAMERA COVERED
               THEN 1
           ELSE 0
           END                                                AS CRITICAL_EVENT
        ,
       IFF(FE.EVENTTYPEID = 31
           , 1
           , 0)                                               AS NO_SEAT_BELT_EVENT
        ,
       IFF(FE.EVENTTYPEID = 3
           , 1
           , 0)                                               AS CAMERA_COVERED_EVENT
        ,
       IFF(FE.EVENTTYPEID = 14
           , 1
           , 0)                                               AS DRIVER_DISTRACTED_EVENT
        ,
       IFF(FE.EVENTTYPEID = 13
           , 1
           , 0)                                               AS DRIVER_SMOKING_EVENT
        ,
       IFF(FE.EVENTTYPEID = 12
           , 1
           ,
           0)                                                 AS DRIVER_USING_CELL_PHONE_EVENT
        ,
       IFF(FE.EVENTTYPEID = 16
           , 1
           , 0)                                               AS FOLLOWING_DISTANCE_EVENT
        ,
       IFF(FE.EVENTTYPEID = 9
           , 1
           , 0)                                               AS FORWARD_COLLISION_EVENT
        ,
       IFF(FE.EVENTTYPEID = 22
           , 1
           , 0)                                               AS HARSH_BRAKING_EVENT
FROM INBOUND.FTSGPS_VIEW.FLEETCAM_EVENTS FE
         LEFT JOIN EVENT_TYPES ET
                   ON FE.EVENTTYPEID = ET.EVENTTYPEID
         LEFT JOIN VEHICLE_INFO VI
                   ON FE.VEHICLEID = VI.VEHICLEID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.CAMERAS CAM
                   ON VI.DVR_RECORDERID = CAM.DEVICE_SERIAL
         LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSET_CAMERA_ASSIGNMENTS ACA
                   ON CAM.CAMERA_ID = ACA.CAMERA_ID AND
                      (FE.EVENTDATE BETWEEN ACA.DATE_INSTALLED AND ACA.DATE_UNINSTALLED OR
                       FE.EVENTDATE > ACA.DATE_INSTALLED AND ACA.DATE_UNINSTALLED IS NULL)
         LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS A
                   ON ACA.ASSET_ID = A.ASSET_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS IM
                   ON A.INVENTORY_BRANCH_ID = IM.MARKET_ID
         LEFT JOIN ES_WAREHOUSE.ELOGS.DRIVER_ASSET_PAIRING_HISTORY DAPH
                   ON ACA.ASSET_ID = DAPH.ASSET_ID AND
                      FE.EVENTDATE BETWEEN DAPH.START_DATE AND DAPH.END_DATE
         LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS U
                   ON DAPH.DRIVER_ID = U.USER_ID
         LEFT JOIN ANALYTICS.PAYROLL.COMPANY_DIRECTORY CD
                   ON CD.EMPLOYEE_ID = TRY_TO_NUMBER(U.EMPLOYEE_ID)
         LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS CDM
                   ON CDM.MARKET_ID = CD.MARKET_ID;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: event_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."EVENT_ID" ;;
    }

    dimension_group: event_date {
      type: time
      timeframes: [time, date, week, month, raw]
      sql: ${TABLE}."EVENT_DATE" ;;
    }

    dimension: event_type_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."EVENT_TYPE_ID" ;;
    }

    dimension: event_type_name {
      type: string
      sql: ${TABLE}."EVENT_TYPE_NAME" ;;
    }

    dimension: coalesced_driver_name {
      type: string
      sql: ${TABLE}."COALESCED_DRIVER_NAME" ;;
    }

    dimension: driver_source {
      type: string
      sql: ${TABLE}."DRIVER_SOURCE" ;;
    }

    dimension: elogs_driver_name {
      type: string
      sql: ${TABLE}."ELOGS_DRIVER_NAME" ;;
    }

    dimension: elogs_driver_user_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."ELOGS_DRIVER_USER_ID" ;;
    }

    dimension: fleetcam_vehiclename {
      type: string
      sql: ${TABLE}."FLEETCAM_VEHICLENAME" ;;
    }

    dimension: assets_driver_name {
      type: string
      sql: ${TABLE}."ASSETS_DRIVER_NAME" ;;
    }

    dimension: elogs_driver_employee_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."ELOGS_DRIVER_EMPLOYEE_ID" ;;
    }

    dimension: elogs_driver_work_email {
      type: string
      sql: ${TABLE}."ELOGS_DRIVER_WORK_EMAIL" ;;
    }

    dimension: coalesced_market_name {
      type: string
      sql: ${TABLE}."COALESCED_MARKET_NAME" ;;
    }

    dimension: assets_inventory_market_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."ASSETS_INVENTORY_MARKET_ID" ;;
    }

    dimension: assets_inventory_market {
      type: string
      sql: ${TABLE}."ASSETS_INVENTORY_MARKET" ;;
    }

    dimension: employee_market_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."EMPLOYEE_MARKET_ID" ;;
    }

    dimension: employee_market_name {
      type: string
      sql: ${TABLE}."EMPLOYEE_MARKET_NAME" ;;
    }

    dimension: fleetcam_serial {
      type: string
      sql: ${TABLE}."FLEETCAM_SERIAL" ;;
    }

    dimension: es_device_serial {
      type: string
      sql: ${TABLE}."ES_DEVICE_SERIAL" ;;
    }

    dimension: es_asset_id {
      type: string
      sql: ${TABLE}."ES_ASSET_ID" ;;
    }

    dimension: es_asset_id_t3_link {
      type: number
      value_format_name: id
      sql: ${TABLE}."ES_ASSET_ID" ;;
      html: <u><p style="color:Blue;"><a href="https://app.estrack.com/#/assets/all/asset/{{es_asset_id._value | url_encode }}/edit" target="_blank">Edit Driver in T3</a></p></u>;;
    }

    dimension: make {
      type: string
      sql: ${TABLE}."MAKE" ;;
    }

    dimension: model {
      type: string
      sql: ${TABLE}."MODEL" ;;
    }

    dimension: company_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."COMPANY_ID" ;;
    }

    dimension: event_points {
      type: number
      sql: ${TABLE}."EVENT_POINTS" ;;
    }

    dimension: critical_event {
      type: number
      sql: ${TABLE}."CRITICAL_EVENT" ;;
    }

    dimension: no_seat_belt_event {
      type: number
      sql: ${TABLE}."NO_SEAT_BELT_EVENT" ;;
    }

    dimension: camera_covered_event {
      type: number
      sql: ${TABLE}."CAMERA_COVERED_EVENT" ;;
    }

    dimension: driver_distracted_event {
      type: number
      sql: ${TABLE}."DRIVER_DISTRACTED_EVENT" ;;
    }

    dimension: driver_smoking_event {
      type: number
      sql: ${TABLE}."DRIVER_SMOKING_EVENT" ;;
    }

    dimension: driver_using_cell_phone_event {
      type: number
      sql: ${TABLE}."DRIVER_USING_CELL_PHONE_EVENT" ;;
    }

    dimension: following_distance_event {
      type: number
      sql: ${TABLE}."FOLLOWING_DISTANCE_EVENT" ;;
    }

    dimension: forward_collision_event {
      type: number
      sql: ${TABLE}."FORWARD_COLLISION_EVENT" ;;
    }

    dimension: harsh_braking_event {
      type: number
      sql: ${TABLE}."HARSH_BRAKING_EVENT" ;;
    }

    dimension: view_event {
      type: string
       sql: ${TABLE}."EVENT_ID" ;;
      html: <u><p style="color:Blue;"><a href="https://fleetcam.estrack.com/gps/gtcoaching/?section1=driverbehavior&mode=0&tab=events&sdate={{event_date_date._value | date: "%m/%d/%Y" }}&edate={{event_date_date._value | date: "%m/%d/%Y" }}&ampsection2=fcplayer&eventid={{event_id._value | url_encode }}" target="_blank">View Event</a></p></u>;;
    }

    measure: total_event_points {
      type: sum
      drill_fields: [event_type_name, total_event_points_detail]
      sql: ${TABLE}."EVENT_POINTS" ;;
    }

    measure: total_event_points_detail {
      type: sum
      drill_fields: [detail*]
      sql: ${TABLE}."EVENT_POINTS" ;;
    }

    measure: critical_event_count {
      type: sum
      drill_fields: [event_type_name, critical_event_count_detail]
      sql: ${TABLE}."CRITICAL_EVENT" ;;
    }

    measure: critical_event_count_detail {
      type: sum
      drill_fields: [detail*]
      sql: ${TABLE}."CRITICAL_EVENT" ;;
    }

    set: detail {
      fields: [
        event_date_week,
        event_date_date,
        event_id,
        view_event,
        # event_type_id,
        event_type_name,
        coalesced_driver_name,
        driver_source,
        elogs_driver_name,
        es_asset_id,
        es_asset_id_t3_link,
        # elogs_driver_user_id,
        fleetcam_vehiclename,
        assets_driver_name,
        # elogs_driver_employee_id,
        coalesced_market_name,
        # assets_inventory_market_id,
        assets_inventory_market,
        # employee_market_id,
        employee_market_name,
        fleetcam_serial,
        # es_device_serial,
        make,
        model,
        company_id,
        event_points,
        critical_event,
        no_seat_belt_event,
        camera_covered_event,
        driver_distracted_event,
        driver_smoking_event,
        driver_using_cell_phone_event,
        following_distance_event,
        forward_collision_event,
        harsh_braking_event
      ]
    }
  }
