view: tracker_manager_accounting_es3 {

  derived_table: {
    sql:

      -- ES3 --

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


, date_parts as (
    select
        ES3_results.*,
        EXTRACT(MONTH from ES3_results.FIRST_INSTALLED) as FIRST_INSTALL_MONTH,
        EXTRACT(YEAR from ES3_results.FIRST_INSTALLED) as FIRST_INSTALL_YEAR,
        EXTRACT(MONTH from ES3_results.UNINSTALLED) as UNINSTALL_MONTH,
        EXTRACT(YEAR from ES3_results.UNINSTALLED) as UNINSTALL_YEAR
    from
        ES3_results
)


, date_parts_to_string as (
    select
        date_parts.*,
        case
            when date_parts.FIRST_INSTALL_MONTH = 1 THEN 'Jan'
            when date_parts.FIRST_INSTALL_MONTH = 2 THEN 'Feb'
            when date_parts.FIRST_INSTALL_MONTH = 3 THEN 'Mar'
            when date_parts.FIRST_INSTALL_MONTH = 4 THEN 'Apr'
            when date_parts.FIRST_INSTALL_MONTH = 5 THEN 'May'
            when date_parts.FIRST_INSTALL_MONTH = 6 THEN 'Jun'
            when date_parts.FIRST_INSTALL_MONTH = 7 THEN 'Jul'
            when date_parts.FIRST_INSTALL_MONTH = 8 THEN 'Aug'
            when date_parts.FIRST_INSTALL_MONTH = 9 THEN 'Sep'
            when date_parts.FIRST_INSTALL_MONTH = 10 THEN 'Oct'
            when date_parts.FIRST_INSTALL_MONTH = 11 THEN 'Nov'
            when date_parts.FIRST_INSTALL_MONTH = 12 THEN 'Dec'
        end as FIRST_INSTALL_MONTH_STRING,
        case
            when date_parts.UNINSTALL_MONTH = 1 THEN 'Dec'
            when date_parts.UNINSTALL_MONTH = 2 THEN 'Jan'
            when date_parts.UNINSTALL_MONTH = 3 THEN 'Feb'
            when date_parts.UNINSTALL_MONTH = 4 THEN 'Mar'
            when date_parts.UNINSTALL_MONTH = 5 THEN 'Apr'
            when date_parts.UNINSTALL_MONTH = 6 THEN 'May'
            when date_parts.UNINSTALL_MONTH = 7 THEN 'Jun'
            when date_parts.UNINSTALL_MONTH = 8 THEN 'Jul'
            when date_parts.UNINSTALL_MONTH = 9 THEN 'Aug'
            when date_parts.UNINSTALL_MONTH = 10 THEN 'Sep'
            when date_parts.UNINSTALL_MONTH = 11 THEN 'Oct'
            when date_parts.UNINSTALL_MONTH = 12 THEN 'Nov'
        end as UNINSTALL_MONTH_STRING,
        case
            when date_parts.UNINSTALL_MONTH IN (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12) then date_parts.UNINSTALL_YEAR + 1
            when date_parts.UNINSTALL_MONTH = 1 then date_parts.UNINSTALL_YEAR
        end as UNINSTALL_plus12_YEAR_STRING
    from
        date_parts
)


, date_string as (
    select
        date_parts_to_string.*,
        CONCAT(date_parts_to_string.FIRST_INSTALL_MONTH_STRING, ' ', date_parts_to_string.FIRST_INSTALL_YEAR) as _01_FIRST_INSTALL,
        CONCAT(date_parts_to_string.UNINSTALL_MONTH_STRING, ' ', UNINSTALL_plus12_YEAR_STRING) as _03_UNINSTALL_plus12
    from
        date_parts_to_string
)


, estimated_costs as (
    select
        date_string.*,
        376.63 as estimated_cost
    from
        date_string
)


, es3_formatted_results_1 as (
    select
        estimated_costs.CAMERA_ID as CAMERA_ID,
        estimated_costs.SERIAL_FORMATTED as SERIAL_FORMATTED,
        '' as KEYPAD_TYPE_ID,
        estimated_costs.FIRST_INSTALLED as FIRST_INSTALL,
        estimated_costs.UNINSTALLED as UNINSTALLED,
        estimated_costs._01_FIRST_INSTALL as _01_FIRST_INSTALL,
        estimated_costs._03_UNINSTALL_plus12 as _03_UNINSTALL_plus12,
        '' as DISPOSED,
        '' as ACTUAL_COST,
        estimated_costs.estimated_cost as EST_COST,
        '' as TOTAL_COST,
        '' as CUST_GROUP,
        '' as CUST_NAME,
        '' as DELIVERY_NAME,
        '' as SO_NUMBER,
        '' as SELL_COST,
        '' as SELL_PRICE,
        '' as SELL_COST_TOTAL_COST,
        '' as SELL_PRICE_TOTAL_COST,
        ROW_NUMBER() OVER(PARTITION BY estimated_costs.SERIAL_FORMATTED ORDER BY estimated_costs.FIRST_INSTALLED) AS SERIAL_NUMBER_INSTALL_INSTANCE
    from
        estimated_costs
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

select
        ES3.CAMERA_ID as CAMERA_ID,
        ES3.SERIAL_FORMATTED as SERIAL_FORMATTED,
        ES3.CAMERA_TYPE_ID as CAMERA_TYPE_ID,
        ES3.FIRST_INSTALL as FIRST_INSTALL,
        ES3.UNINSTALLED as UNINSTALLED,
        CAST(ES3._01_FIRST_INSTALL as STRING)  as _01_FIRST_INSTALL,
        CAST(ES3._03_UNINSTALL_plus12 as STRING) as _03_UNINSTALL_plus12,
        ES3.DISPOSED as DISPOSED,
        TELE02.TOTAL_COST as ACTUAL_COST,
        ES3.EST_COST as EST_COST,
        case
            when TELE02.TOTAL_COST is null THEN ES3.EST_COST
            when TELE02.TOTAL_COST is not null THEN TELE02.TOTAL_COST
        end as TOTAL_COST,
        TELE02.CUST_GROUP as CUST_GROUP,
        TELE02.CUST_NAME as CUST_NAME,
        TELE02.DELIVERY_NAME as DELIVERY_NAME,
        TELE02.SO_NUMBER as SO_NUMBER,
        TELE02.SELL_PRICE as SELL_PRICE,
        TELE02.SELL_COST as SELL_COST,
        case
            when TELE02.SELL_PRICE is null then 0.00
            when TELE02.SELL_PRICE = 0.00 then 0.00
            else TELE02.NON_TRACKER_COST_PER_UNIT
        end as SELL_PRICE_NON_TRACKER_COST,
        case
            when TELE02.SELL_COST is null then 0.00
            when TELE02.SELL_COST = 0.00 then 0.00
            else TELE02.NON_TRACKER_COST_PER_UNIT
        end as SELL_COST_NON_TRACKER_COST,
        TELE02.SELL_PRICE_TOTAL_COST as SELL_PRICE_TOTAL_COST,
        TELE02.SELL_COST_TOTAL_COST as SELL_COST_TOTAL_COST
from
    es3_formatted_results_distinct ES3
left join
    analytics.t3_saas_billing.telematics_accounting_keypads_and_cameras TELE02
    on ES3.SERIAL_FORMATTED = TELE02.SERIAL_FORMATTED
      ;;
  }

  dimension: CAMERA_ID {
    type:  string
    sql:${TABLE}.CAMERA_ID ;;
  }

  dimension: SERIAL_FORMATTED {
    type: string
    sql: ${TABLE}.SERIAL_FORMATTED ;;
  }

  dimension: CAMERA_TYPE_ID {
    type: string
    sql: ${TABLE}.CAMERA_TYPE_ID ;;
  }

  dimension: FIRST_INSTALL {
    type: date
    sql: ${TABLE}.FIRST_INSTALL ;;
  }

  dimension: UNINSTALLED {
    type:  date
    sql: ${TABLE}.UNINSTALLED ;;
  }

  dimension: _01_FIRST_INSTALL {
    type:  string
    sql: ${TABLE}._01_FIRST_INSTALL ;;
  }

  dimension: _03_UNINSTALL_PLUS12 {
    type:  string
    sql: ${TABLE}._03_UNINSTALL_PLUS12 ;;
  }

  dimension: DISPOSED {
    type:  string
    sql: ${TABLE}.DISPOSED ;;
  }

  dimension: ACTUAL_COST {
    type:  number
    sql: ${TABLE}.ACTUAL_COST ;;
  }

  dimension: EST_COST {
    type:  number
    sql: ${TABLE}.EST_COST ;;
  }

  dimension: TOTAL_COST {
    type:  number
    sql: ${TABLE}.TOTAL_COST ;;
  }

  dimension: CUST_GROUP {
    type:  string
    sql: ${TABLE}.CUST_GROUP ;;
  }

  dimension: CUST_NAME {
    type:  string
    sql: ${TABLE}.CUST_NAME ;;
  }

  dimension: DELIVERY_NAME {
    type:  string
    sql: ${TABLE}.DELIVERY_NAME ;;
  }

  dimension: SO_NUMBER {
    type:  string
    sql: ${TABLE}.SO_NUMBER ;;
  }

  dimension: SELL_COST {
    type:  number
    sql: ${TABLE}.SELL_COST ;;
  }

  dimension: SELL_PRICE {
    type:  number
    sql: ${TABLE}.SELL_PRICE ;;
  }

  dimension: SELL_COST_NON_TRACKER_COST {
    type:  number
    sql: ${TABLE}.SELL_COST_NON_TRACKER_COST ;;
  }

  dimension: SELL_PRICE_NON_TRACKER_COST {
    type:  number
    sql: ${TABLE}.SELL_PRICE_NON_TRACKER_COST ;;
  }

  dimension: SELL_COST_TOTAL_COST {
    type:  number
    sql: ${TABLE}.SELL_COST_TOTAL_COST ;;
  }

  dimension: SELL_PRICE_TOTAL_COST {
    type:  number
    sql: ${TABLE}.SELL_PRICE_TOTAL_COST ;;
  }

}
