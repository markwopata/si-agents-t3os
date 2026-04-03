view: tracker_manager_accounting_es2_and_es3_installs {

  derived_table: {
    sql:

      with ES3_results as (
    SELECT
            CAMERA_ID
            ,
            SERIAL_NUMBER
            ,
            SERIAL_FORMATTED
            ,
            FIRST_INSTALLED
            ,
            CASE
                WHEN FIRST_INSTALLED < UNINSTALLED THEN UNINSTALLED
                ELSE NULL
             END AS UNINSTALLED
        FROM
        (
        SELECT
            CAM.CAMERA_ID AS CAMERA_ID
            ,
            CAM.DEVICE_SERIAL AS SERIAL_NUMBER
            ,
            REPLACE(CAM.DEVICE_SERIAL, '-', '') AS SERIAL_FORMATTED
            ,
            to_date(ACA.DATE_INSTALLED) AS FIRST_INSTALLED
            ,
            CASE
                WHEN ACA.DATE_UNINSTALLED IS NOT NULL THEN to_date(ACA.DATE_UNINSTALLED)
--                 WHEN ACA.DATE_UNINSTALLED IS NULL AND ATA.DATE_UNINSTALLED IS NOT NULL THEN to_date(ATA.DATE_UNINSTALLED)
                ELSE to_date(ACA.DATE_UNINSTALLED)
            END AS UNINSTALLED
        FROM
            ES_WAREHOUSE.PUBLIC.CAMERAS CAM
        LEFT JOIN
            ES_WAREHOUSE.PUBLIC.ASSET_CAMERA_ASSIGNMENTS ACA
            ON ACA.CAMERA_ID = CAM.CAMERA_ID
--         LEFT JOIN
--             tm_plus_hist_distinct
--             on tm_plus_hist_distinct.CAMERA_ID = CAM.CAMERA_ID
--         LEFT JOIN
--             ES_WAREHOUSE.PUBLIC.ASSET_TRACKER_ASSIGNMENTS ATA
--             ON ATA.TRACKER_ID = tm_plus_hist_distinct.TRACKER_ID
        WHERE CAM.DEVICE_SERIAL IS NOT NULL
        AND ACA.DATE_INSTALLED IS NOT NULL
        AND ACA.DATE_INSTALLED <= '2025-10-31'
        )
)


, camera_date_parts as (
    select
        ES3_results.*,
        EXTRACT(MONTH from ES3_results.FIRST_INSTALLED) as FIRST_INSTALL_MONTH,
        EXTRACT(YEAR from ES3_results.FIRST_INSTALLED) as FIRST_INSTALL_YEAR,
        EXTRACT(MONTH from ES3_results.UNINSTALLED) as UNINSTALL_MONTH,
        EXTRACT(YEAR from ES3_results.UNINSTALLED) as UNINSTALL_YEAR
    from
        ES3_results
)


, camera_date_parts_to_string as (
    select
        camera_date_parts.*,
        case
            when camera_date_parts.FIRST_INSTALL_MONTH = 1 THEN 'Jan'
            when camera_date_parts.FIRST_INSTALL_MONTH = 2 THEN 'Feb'
            when camera_date_parts.FIRST_INSTALL_MONTH = 3 THEN 'Mar'
            when camera_date_parts.FIRST_INSTALL_MONTH = 4 THEN 'Apr'
            when camera_date_parts.FIRST_INSTALL_MONTH = 5 THEN 'May'
            when camera_date_parts.FIRST_INSTALL_MONTH = 6 THEN 'Jun'
            when camera_date_parts.FIRST_INSTALL_MONTH = 7 THEN 'Jul'
            when camera_date_parts.FIRST_INSTALL_MONTH = 8 THEN 'Aug'
            when camera_date_parts.FIRST_INSTALL_MONTH = 9 THEN 'Sep'
            when camera_date_parts.FIRST_INSTALL_MONTH = 10 THEN 'Oct'
            when camera_date_parts.FIRST_INSTALL_MONTH = 11 THEN 'Nov'
            when camera_date_parts.FIRST_INSTALL_MONTH = 12 THEN 'Dec'
        end as FIRST_INSTALL_MONTH_STRING,
        case
            when camera_date_parts.UNINSTALL_MONTH = 1 THEN 'Dec'
            when camera_date_parts.UNINSTALL_MONTH = 2 THEN 'Jan'
            when camera_date_parts.UNINSTALL_MONTH = 3 THEN 'Feb'
            when camera_date_parts.UNINSTALL_MONTH = 4 THEN 'Mar'
            when camera_date_parts.UNINSTALL_MONTH = 5 THEN 'Apr'
            when camera_date_parts.UNINSTALL_MONTH = 6 THEN 'May'
            when camera_date_parts.UNINSTALL_MONTH = 7 THEN 'Jun'
            when camera_date_parts.UNINSTALL_MONTH = 8 THEN 'Jul'
            when camera_date_parts.UNINSTALL_MONTH = 9 THEN 'Aug'
            when camera_date_parts.UNINSTALL_MONTH = 10 THEN 'Sep'
            when camera_date_parts.UNINSTALL_MONTH = 11 THEN 'Oct'
            when camera_date_parts.UNINSTALL_MONTH = 12 THEN 'Nov'
        end as UNINSTALL_MONTH_STRING,
        case
            when camera_date_parts.UNINSTALL_MONTH IN (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12) then camera_date_parts.UNINSTALL_YEAR + 1
            when camera_date_parts.UNINSTALL_MONTH = 1 then camera_date_parts.UNINSTALL_YEAR
        end as UNINSTALL_plus12_YEAR_STRING
    from
        camera_date_parts
)


, camera_date_string as (
    select
        camera_date_parts_to_string.*,
        CONCAT(camera_date_parts_to_string.FIRST_INSTALL_MONTH_STRING, ' ', camera_date_parts_to_string.FIRST_INSTALL_YEAR) as _01_FIRST_INSTALL,
        CONCAT(camera_date_parts_to_string.UNINSTALL_MONTH_STRING, ' ', camera_date_parts_to_string.UNINSTALL_plus12_YEAR_STRING) as _03_UNINSTALL_plus12
    from
        camera_date_parts_to_string
)


, camera_estimated_costs as (
    select
        camera_date_string.*,
        376.63 as estimated_cost
    from
        camera_date_string
)


, es3_formatted_results_1 as (
    select
        camera_estimated_costs.CAMERA_ID as CAMERA_ID,
        camera_estimated_costs.SERIAL_FORMATTED as SERIAL_FORMATTED,
        '' as KEYPAD_TYPE_ID,
        camera_estimated_costs.FIRST_INSTALLED as FIRST_INSTALL,
        camera_estimated_costs.UNINSTALLED as UNINSTALLED,
        camera_estimated_costs._01_FIRST_INSTALL as _01_FIRST_INSTALL,
        camera_estimated_costs._03_UNINSTALL_plus12 as _03_UNINSTALL_plus12,
        '' as DISPOSED,
        '' as ACTUAL_COST,
        camera_estimated_costs.estimated_cost as EST_COST,
        '' as TOTAL_COST,
        '' as CUST_GROUP,
        '' as CUST_NAME,
        '' as DELIVERY_NAME,
        '' as SO_NUMBER,
        '' as SELL_COST,
        '' as SELL_PRICE,
        '' as SELL_COST_TOTAL_COST,
        '' as SELL_PRICE_TOTAL_COST,
        ROW_NUMBER() OVER(PARTITION BY camera_estimated_costs.SERIAL_FORMATTED ORDER BY camera_estimated_costs.FIRST_INSTALLED) AS SERIAL_NUMBER_INSTALL_INSTANCE
    from
        camera_estimated_costs
)

, es3_formatted_results_distinct as (
    select
        es3_formatted_results_1.CAMERA_ID as CAMERA_ID,
        es3_formatted_results_1.SERIAL_FORMATTED as SERIAL_FORMATTED,
        es3_formatted_results_1.KEYPAD_TYPE_ID as CAMERA_TYPE_ID,
        es3_formatted_results_1.FIRST_INSTALL as FIRST_INSTALL,
        es3_formatted_results_1.UNINSTALLED as UNINSTALLED,
        es3_formatted_results_1._01_FIRST_INSTALL as _01_FIRST_INSTALL,
        es3_formatted_results_1._03_UNINSTALL_plus12 as _03_UNINSTALL_plus12,
        es3_formatted_results_1.DISPOSED as DISPOSED,
        es3_formatted_results_1.ACTUAL_COST as ACTUAL_COST,
        es3_formatted_results_1.EST_COST as EST_COST,
        es3_formatted_results_1.TOTAL_COST as TOTAL_COST,
        es3_formatted_results_1.CUST_GROUP as CUST_GROUP,
        es3_formatted_results_1.CUST_NAME as CUST_NAME,
        es3_formatted_results_1.DELIVERY_NAME as DELIVERY_NAME,
        es3_formatted_results_1.SO_NUMBER as SO_NUMBER,
        es3_formatted_results_1.SELL_COST as SELL_COST,
        es3_formatted_results_1.SELL_PRICE as SELL_PRICE,
        es3_formatted_results_1.SELL_COST_TOTAL_COST as SELL_COST_TOTAL_COST,
        es3_formatted_results_1.SELL_PRICE_TOTAL_COST as SELL_PRICE_TOTAL_COST
    from
        es3_formatted_results_1
    where
        es3_formatted_results_1.SERIAL_NUMBER_INSTALL_INSTANCE = 1
    )

, es3_installs as (select SERIAL_FORMATTED, FIRST_INSTALL, UNINSTALLED from es3_formatted_results_distinct)

, ES2_results as (
        SELECT DISTINCT * FROM (
            (
            SELECT
                KP.KEYPAD_ID,
                KP.SERIAL_NUMBER,
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(KP.SERIAL_NUMBER),'OEMDD-BT-NODE-',''),' ',''),'-',''),':',''),';',''),char(9),''),char(10),''),char(13),'') AS "KP_SERIAL_FORMATTED",
                CAST(CONVERT_TIMEZONE('America/Chicago',MIN(KAA.START_DATE)) AS DATE) AS "FIRST_INSTALLED",
                case when CAST(CONVERT_TIMEZONE('America/Chicago',(KP_UNINSTALL.END_DATE)) AS DATE) <= '2025-09-30' then CAST(CONVERT_TIMEZONE('America/Chicago',(KP_UNINSTALL.END_DATE)) AS DATE) else null end AS "UNINSTALLED"
            FROM
                "ES_WAREHOUSE"."PUBLIC"."KEYPADS" KP
                LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."KEYPAD_ASSET_ASSIGNMENTS" KAA ON KP.KEYPAD_ID = KAA.KEYPAD_ID
                LEFT JOIN
                    (SELECT
                        KP2.KEYPAD_ID,
                        KP2.END_DATE
                    FROM
                        "ES_WAREHOUSE"."PUBLIC"."KEYPAD_ASSET_ASSIGNMENTS" KP2
                        JOIN
                            (SELECT
                                KEYPAD_ID,
                                MAX(KEYPAD_ASSET_ASSIGNMENT_ID) AS "LAST_KP_AAI"
                            FROM
                                "ES_WAREHOUSE"."PUBLIC"."KEYPAD_ASSET_ASSIGNMENTS"
                            GROUP BY
                                KEYPAD_ID) KP1 ON KP2.KEYPAD_ASSET_ASSIGNMENT_ID = KP1.LAST_KP_AAI
                    WHERE
                        KP2.END_DATE IS NOT NULL) KP_UNINSTALL ON KP.KEYPAD_ID = KP_UNINSTALL.KEYPAD_ID
            GROUP BY
                KP.KEYPAD_ID,
                KP.SERIAL_NUMBER,
                UNINSTALLED
            HAVING
                FIRST_INSTALLED IS NOT NULL
            and FIRST_INSTALLED <= '2025-10-31'
            ORDER BY
                KP.KEYPAD_ID
            )
        )
        ORDER BY FIRST_INSTALLED
)


, keypad_date_parts as (
    select
        ES2_results.*,
        EXTRACT(MONTH from ES2_results.FIRST_INSTALLED) as FIRST_INSTALL_MONTH,
        EXTRACT(YEAR from ES2_results.FIRST_INSTALLED) as FIRST_INSTALL_YEAR,
        EXTRACT(MONTH from ES2_results.UNINSTALLED) as UNINSTALL_MONTH,
        EXTRACT(YEAR from ES2_results.UNINSTALLED) as UNINSTALL_YEAR
    from
        ES2_results
)


, keypad_date_parts_to_string as (
    select
        keypad_date_parts.*,
        case
            when keypad_date_parts.FIRST_INSTALL_MONTH = 1 THEN 'Jan'
            when keypad_date_parts.FIRST_INSTALL_MONTH = 2 THEN 'Feb'
            when keypad_date_parts.FIRST_INSTALL_MONTH = 3 THEN 'Mar'
            when keypad_date_parts.FIRST_INSTALL_MONTH = 4 THEN 'Apr'
            when keypad_date_parts.FIRST_INSTALL_MONTH = 5 THEN 'May'
            when keypad_date_parts.FIRST_INSTALL_MONTH = 6 THEN 'Jun'
            when keypad_date_parts.FIRST_INSTALL_MONTH = 7 THEN 'Jul'
            when keypad_date_parts.FIRST_INSTALL_MONTH = 8 THEN 'Aug'
            when keypad_date_parts.FIRST_INSTALL_MONTH = 9 THEN 'Sep'
            when keypad_date_parts.FIRST_INSTALL_MONTH = 10 THEN 'Oct'
            when keypad_date_parts.FIRST_INSTALL_MONTH = 11 THEN 'Nov'
            when keypad_date_parts.FIRST_INSTALL_MONTH = 12 THEN 'Dec'
        end as FIRST_INSTALL_MONTH_STRING,
        case
            when keypad_date_parts.UNINSTALL_MONTH = 1 THEN 'Dec'
            when keypad_date_parts.UNINSTALL_MONTH = 2 THEN 'Jan'
            when keypad_date_parts.UNINSTALL_MONTH = 3 THEN 'Feb'
            when keypad_date_parts.UNINSTALL_MONTH = 4 THEN 'Mar'
            when keypad_date_parts.UNINSTALL_MONTH = 5 THEN 'Apr'
            when keypad_date_parts.UNINSTALL_MONTH = 6 THEN 'May'
            when keypad_date_parts.UNINSTALL_MONTH = 7 THEN 'Jun'
            when keypad_date_parts.UNINSTALL_MONTH = 8 THEN 'Jul'
            when keypad_date_parts.UNINSTALL_MONTH = 9 THEN 'Aug'
            when keypad_date_parts.UNINSTALL_MONTH = 10 THEN 'Sep'
            when keypad_date_parts.UNINSTALL_MONTH = 11 THEN 'Oct'
            when keypad_date_parts.UNINSTALL_MONTH = 12 THEN 'Nov'
        end as UNINSTALL_MONTH_STRING,
        case
            when keypad_date_parts.UNINSTALL_MONTH IN (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12) then keypad_date_parts.UNINSTALL_YEAR + 1
            when keypad_date_parts.UNINSTALL_MONTH = 1 then keypad_date_parts.UNINSTALL_YEAR
        end as UNINSTALL_plus12_YEAR_STRING
    from
        keypad_date_parts
)


, keypad_date_string as (
    select
        keypad_date_parts_to_string.*,
        CONCAT(keypad_date_parts_to_string.FIRST_INSTALL_MONTH_STRING, ' ', keypad_date_parts_to_string.FIRST_INSTALL_YEAR) as _01_FIRST_INSTALL,
        CONCAT(keypad_date_parts_to_string.UNINSTALL_MONTH_STRING, ' ', keypad_date_parts_to_string.UNINSTALL_plus12_YEAR_STRING) as _03_UNINSTALL_plus12
    from
        keypad_date_parts_to_string
)


, keypad_estimated_costs as (
    select
        keypad_date_string.*,
        78.71 as estimated_cost
    from
        keypad_date_string
)


, es2_formatted_results_1 as (
    select
        keypad_estimated_costs.KEYPAD_ID as KEYPAD_ID,
        keypad_estimated_costs.KP_SERIAL_FORMATTED as SERIAL_FORMATTED,
        '' as KEYPAD_TYPE_ID,
        keypad_estimated_costs.FIRST_INSTALLED as FIRST_INSTALL,
        keypad_estimated_costs.UNINSTALLED as UNINSTALLED,
        keypad_estimated_costs._01_FIRST_INSTALL as _01_FIRST_INSTALL,
        keypad_estimated_costs._03_UNINSTALL_plus12 as _03_UNINSTALL_plus12,
        '' as DISPOSED,
        '' as ACTUAL_COST,
        keypad_estimated_costs.estimated_cost as EST_COST,
        '' as TOTAL_COST,
        '' as CUST_GROUP,
        '' as CUST_NAME,
        '' as DELIVERY_NAME,
        '' as SO_NUMBER,
        '' as SELL_COST,
        '' as SELL_PRICE,
        '' as SELL_COST_TOTAL_COST,
        '' as SELL_PRICE_TOTAL_COST
    from
        keypad_estimated_costs
)

, es2_installs as (select SERIAL_FORMATTED, FIRST_INSTALL, UNINSTALLED from es2_formatted_results_1)

, union_results as (
    select * from es2_installs
    union
    select * from es3_installs
)

select * from union_results
      ;;
  }

  dimension: SERIAL_FORMATTED {
    type: string
    sql: ${TABLE}.SERIAL_FORMATTED ;;
  }

  dimension: FIRST_INSTALL {
    type: date
    sql: ${TABLE}.FIRST_INSTALL ;;
  }

  dimension: UNINSTALLED {
    type:  date
    sql: ${TABLE}.UNINSTALLED ;;
  }

}
