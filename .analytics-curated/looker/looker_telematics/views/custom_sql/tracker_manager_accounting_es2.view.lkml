view: tracker_manager_accounting_es2 {

  derived_table: {
    sql:

      --ES2--

with ES2_results as (
        SELECT DISTINCT * FROM (
            (
            SELECT
                KP.KEYPAD_ID,
                KP.SERIAL_NUMBER,
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(KP.SERIAL_NUMBER),'OEMDD-BT-NODE-',''),' ',''),'-',''),':',''),';',''),char(9),''),char(10),''),char(13),'') AS "KP_SERIAL_FORMATTED",
                CAST(CONVERT_TIMEZONE('America/Chicago',MIN(KAA.START_DATE)) AS DATE) AS "FIRST_INSTALLED",
                case when CAST(CONVERT_TIMEZONE('America/Chicago',(KP_UNINSTALL.END_DATE)) AS DATE) <= '2025-10-31' then CAST(CONVERT_TIMEZONE('America/Chicago',(KP_UNINSTALL.END_DATE)) AS DATE) else null end AS "UNINSTALLED"
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


, date_parts as (
    select
        ES2_results.*,
        EXTRACT(MONTH from ES2_results.FIRST_INSTALLED) as FIRST_INSTALL_MONTH,
        EXTRACT(YEAR from ES2_results.FIRST_INSTALLED) as FIRST_INSTALL_YEAR,
        EXTRACT(MONTH from ES2_results.UNINSTALLED) as UNINSTALL_MONTH,
        EXTRACT(YEAR from ES2_results.UNINSTALLED) as UNINSTALL_YEAR
    from
        ES2_results
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
        78.71 as estimated_cost
    from
        date_string
)


, es2_formatted_results_1 as (
    select
        estimated_costs.KEYPAD_ID as KEYPAD_ID,
        estimated_costs.KP_SERIAL_FORMATTED as SERIAL_FORMATTED,
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
        '' as SELL_PRICE_TOTAL_COST
    from
        estimated_costs
)

select
        ES2.KEYPAD_ID as KEYPAD_ID,
        ES2.SERIAL_FORMATTED as SERIAL_FORMATTED,
        ES2.KEYPAD_TYPE_ID as KEYPAD_TYPE_ID,
        ES2.FIRST_INSTALL as FIRST_INSTALL,
        ES2.UNINSTALLED as UNINSTALLED,
        CAST(ES2._01_FIRST_INSTALL as STRING)  as _01_FIRST_INSTALL,
        CAST(ES2._03_UNINSTALL_plus12 as STRING) as _03_UNINSTALL_plus12,
        ES2.DISPOSED as DISPOSED,
        TELE02.TOTAL_COST as ACTUAL_COST,
        ES2.EST_COST as EST_COST,
        case
            when TELE02.TOTAL_COST is null THEN ES2.EST_COST
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
    es2_formatted_results_1 ES2
left join
    analytics.t3_saas_billing.telematics_accounting_keypads_and_cameras TELE02
    on ES2.SERIAL_FORMATTED = TELE02.SERIAL_FORMATTED
      ;;
  }

  dimension: KEYPAD_ID {
    type:  string
    sql:${TABLE}.KEYPAD_ID ;;
  }

  dimension: SERIAL_FORMATTED {
    type: string
    sql: ${TABLE}.SERIAL_FORMATTED ;;
  }

  dimension: KEYPAD_TYPE_ID {
    type: string
    sql: ${TABLE}.KEYPAD_TYPE_ID ;;
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
