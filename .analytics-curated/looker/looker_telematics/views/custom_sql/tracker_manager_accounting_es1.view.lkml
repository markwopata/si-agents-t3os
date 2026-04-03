view: tracker_manager_accounting_es1 {

derived_table: {
  sql:

      --ES1--

with ES1_results as (
    SELECT * FROM (
SELECT
    TRAC.TRACKER_ID,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(TRAC.DEVICE_SERIAL),'OEMDD-BT-NODE-',''),' ',''),'-',''),':',''),';',''),char(9),''),char(10),''),char(13),'') AS "SERIAL_FORMATTED",
    TRAC.TRACKER_TYPE_ID,
    CAST(CONVERT_TIMEZONE('America/Chicago',TRAC.CREATED) AS DATE) AS "TRACKER_CREATED",
    TRAC_FIRST_INST.TRACKER_FIRST_INSTALL,
    --TRACKER_SOLD.ASSET_ASSIGNED AS "TRACKER_SOLD",
    NULL AS "TRACKER_SOLD",
    CASE WHEN UNINSTALLED_TRACKER.LAST_UNINSTALLED <= '2025-10-31' THEN UNINSTALLED_TRACKER.LAST_UNINSTALLED ELSE NULL END AS "TRACKER_UNINSTALLED"
FROM
    "ES_WAREHOUSE"."PUBLIC"."TRACKERS" TRAC
LEFT JOIN
  (SELECT
      TRACKER_ID,
      MIN(CAST(CONVERT_TIMEZONE('America/Chicago',DATE_INSTALLED) AS DATE)) AS "TRACKER_FIRST_INSTALL"
   FROM
      "ES_WAREHOUSE"."PUBLIC"."ASSET_TRACKER_ASSIGNMENTS"
   GROUP BY
      TRACKER_ID) TRAC_FIRST_INST ON TRAC.TRACKER_ID = TRAC_FIRST_INST.TRACKER_ID
    LEFT JOIN
        (SELECT
            ATA.TRACKER_ID AS "TRACKER_ID",
            TRAC.DEVICE_SERIAL AS "Tracker_Serial",
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(TRAC.DEVICE_SERIAL),'OEMDD-BT-NODE-',''),' ',''),'-',''),':',''),';',''),char(9),''),char(10),''),char(13),'') AS "SERIAL_FORMATTED",
            SAC.ASSET_SCD_COMPANY_ID AS "ASSET_SCD_COMPANY_ID",
            SAC.ASSET_ID AS "Asset_ID",
            SAC.COMPANY_ID AS "Asset_Customer",
            COMP.NAME AS "Asset_Customer_Name",
            CAST(CONVERT_TIMEZONE('America/Chicago',SAC.DATE_START) AS DATE) AS "ASSET_ASSIGNED",
            AST.SERIAL_NUMBER AS "Asset_Serial",
            ATA.COMPANY_ID AS "Tracker_Customer",
            ATA.DATE_INSTALLED AS "Tracker_Installed",
            COMP2.NAME AS "Tracker_Customer_Name"
        FROM
            "ES_WAREHOUSE"."SCD"."SCD_ASSET_COMPANY" SAC
            LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."COMPANIES" COMP ON SAC.COMPANY_ID = COMP.COMPANY_ID
            LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."ASSET_TRACKER_ASSIGNMENTS" ATA
                ON SAC.ASSET_ID = ATA.ASSET_ID
                AND '2025-10-31' BETWEEN CONVERT_TIMEZONE('America/Chicago',DATE_INSTALLED) and coalesce(DATE_UNINSTALLED, '2099-12-31')
            LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."COMPANIES" COMP2 ON ATA.COMPANY_ID = COMP2.COMPANY_ID
            LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."TRACKERS" TRAC ON ATA.TRACKER_ID = TRAC.TRACKER_ID
            LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."ASSETS" AST ON SAC.ASSET_ID = AST.ASSET_ID
        WHERE
            '2025-10-31' BETWEEN CONVERT_TIMEZONE('America/Chicago',SAC.DATE_START) AND CONVERT_TIMEZONE('America/Chicago',SAC.DATE_END)
            AND SAC.COMPANY_ID NOT IN(1854, 155, 420, 11606, 42268, 31712)
            AND COMP.NAME NOT LIKE 'IES%'
            AND ATA.TRACKER_ID IS NOT NULL) TRACKER_SOLD ON TRAC.TRACKER_ID = TRACKER_SOLD.TRACKER_ID
    LEFT JOIN
        (SELECT
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(TRK.DEVICE_SERIAL),'OEMDD-BT-NODE-',''),' ',''),'-',''),':',''),';','') AS "SERIAL_FORMATTED",
            ATA.TRACKER_ID AS "TRACKER_ID",
            CAST(DATE_TRUNC('MONTH', CONVERT_TIMEZONE('America/Chicago',ATA.DATE_UNINSTALLED)) AS DATE) AS "LAST_UNINSTALLED",
            TRK.TRACKER_TYPE_ID AS "Tracker_Type_ID"
        FROM
            "ES_WAREHOUSE"."PUBLIC"."ASSET_TRACKER_ASSIGNMENTS" ATA
            JOIN
                (SELECT
                    TRACKER_ID,
                    MAX(ASSET_TRACKER_ID) AS "LAST_ASSET_TRACK_ID"
                FROM
                    "ES_WAREHOUSE"."PUBLIC"."ASSET_TRACKER_ASSIGNMENTS"
                GROUP BY
                    TRACKER_ID) LAST_ASSN ON ATA.ASSET_TRACKER_ID = LAST_ASSN.LAST_ASSET_TRACK_ID
            LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."TRACKERS" TRK ON ATA.TRACKER_ID = TRK.TRACKER_ID
        WHERE
            ATA.DATE_UNINSTALLED IS NOT NULL) UNINSTALLED_TRACKER ON TRAC.TRACKER_ID = UNINSTALLED_TRACKER.TRACKER_ID
WHERE
    TRAC_FIRST_INST.TRACKER_FIRST_INSTALL IS NOT NULL
AND CAST(TRAC_FIRST_INST.TRACKER_FIRST_INSTALL AS DATE) <= '2025-10-31'
)
-- WHERE TRACKER_ID = '4453334'
ORDER BY TRACKER_ID
)


, date_parts as (
    select
        ES1_results.*,
        EXTRACT(MONTH from ES1_results.TRACKER_FIRST_INSTALL) as FIRST_INSTALL_MONTH,
        EXTRACT(YEAR from ES1_results.TRACKER_FIRST_INSTALL) as FIRST_INSTALL_YEAR,
        EXTRACT(MONTH from ES1_results.TRACKER_UNINSTALLED) as UNINSTALL_MONTH,
        EXTRACT(YEAR from ES1_results.TRACKER_UNINSTALLED) as UNINSTALL_YEAR
    from
        ES1_results
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
        case
            when date_string.TRACKER_TYPE_ID = '21' then 0.00
            when date_string.TRACKER_TYPE_ID = '1' then 119.43
            when date_string.TRACKER_TYPE_ID = '4' then 120.17
            when date_string.TRACKER_TYPE_ID = '8' then 135.35
            when date_string.TRACKER_TYPE_ID = '19' then 135.35
            when date_string.TRACKER_TYPE_ID = '20' then 162.97
            when date_string.TRACKER_TYPE_ID = '22' then 25.53
            when date_string.TRACKER_TYPE_ID = '23' then 218.86
            when date_string.TRACKER_TYPE_ID = '24' then 18.61
            when date_string.TRACKER_TYPE_ID = '25' then 68.66
            when date_string.TRACKER_TYPE_ID = '26' then 82.28
            when date_string.TRACKER_TYPE_ID = '34' then 143.71
            when date_string.TRACKER_TYPE_ID = '35' then 10.00
            when date_string.TRACKER_TYPE_ID = '36' then 19.31
            when date_string.TRACKER_TYPE_ID = '37' then 135.08
            when date_string.TRACKER_TYPE_ID = '38' then 55.00
            when date_string.TRACKER_TYPE_ID = '30' then 0.00
            when date_string.TRACKER_TYPE_ID = '41' then 0.00
            when date_string.TRACKER_TYPE_ID = '134' then 0.00
            else 85.54
        end as estimated_cost
    from
        date_string
)


, es1_formatted_results_1 as (
    select
        estimated_costs.TRACKER_ID as TRACKER_ID,
        estimated_costs.SERIAL_FORMATTED as SERIAL_FORMATTED,
        estimated_costs.TRACKER_TYPE_ID as TRACKER_TYPE_ID,
        estimated_costs.TRACKER_FIRST_INSTALL as FIRST_INSTALL,
        estimated_costs.TRACKER_UNINSTALLED as UNINSTALLED,
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

, es1_formatted_results_2 as (
select
        ES1.TRACKER_ID as TRACKER_ID,
        ES1.SERIAL_FORMATTED as SERIAL_FORMATTED,
        ES1.TRACKER_TYPE_ID as TRACKER_TYPE_ID,
        ES1.FIRST_INSTALL as FIRST_INSTALL,
        ES1.UNINSTALLED as UNINSTALLED,
        CAST(ES1._01_FIRST_INSTALL as STRING)  as _01_FIRST_INSTALL,
        CAST(ES1._03_UNINSTALL_plus12 as STRING) as _03_UNINSTALL_plus12,
        ES1.DISPOSED as DISPOSED,
        TELE01.TOTAL_COST as ACTUAL_COST,
        ES1.EST_COST as EST_COST,
        case
            when TELE01.TOTAL_COST is null THEN ES1.EST_COST
            when TELE01.TOTAL_COST is not null THEN TELE01.TOTAL_COST
        end as TOTAL_COST,
        TELE01.CUST_GROUP as CUST_GROUP,
        TELE01.CUST_NAME as CUST_NAME,
        TELE01.DELIVERY_NAME as DELIVERY_NAME,
        TELE01.SO_NUMBER as SO_NUMBER,
        TELE01.SELL_PRICE as SELL_PRICE,
        TELE01.SELL_COST as SELL_COST,
        case
            when TELE01.SELL_PRICE is null then 0.00
            when TELE01.SELL_PRICE = 0.00 then 0.00
            else TELE01.NON_TRACKER_COST_PER_UNIT
        end as SELL_PRICE_NON_TRACKER_COST,
        case
            when TELE01.SELL_COST is null then 0.00
            when TELE01.SELL_COST = 0.00 then 0.00
            else TELE01.NON_TRACKER_COST_PER_UNIT
        end as SELL_COST_NON_TRACKER_COST,
        TELE01.SELL_PRICE_TOTAL_COST as SELL_PRICE_TOTAL_COST,
        TELE01.SELL_COST_TOTAL_COST as SELL_COST_TOTAL_COST
from
    es1_formatted_results_1 ES1
left join
    analytics.t3_saas_billing.telematics_accounting_trackers TELE01
    on ES1.SERIAL_FORMATTED = TELE01.SERIAL_FORMATTED
)

select *
    from es1_formatted_results_2
    ;;
}

dimension: TRACKER_ID {
  type:  string
  sql:${TABLE}.TRACKER_ID ;;
}

dimension: SERIAL_FORMATTED {
  type: string
  sql: ${TABLE}.SERIAL_FORMATTED ;;
}

dimension: TRACKER_TYPE_ID {
  type: string
  sql: ${TABLE}.TRACKER_TYPE_ID ;;
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
