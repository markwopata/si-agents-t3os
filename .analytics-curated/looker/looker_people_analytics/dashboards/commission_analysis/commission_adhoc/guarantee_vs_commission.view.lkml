view: guarantee_vs_commission {

  derived_table: {
    sql:
      with dbt_table AS (-- dbt finalized data
        SELECT SALESPERSON_USER_ID,
               FULL_NAME,
               EMPLOYEE_ID::varchar as employee_id,
               LINE_ITEM_ID,
               COMMISSION_MONTH,
               SALESPERSON_TYPE,
               MARKET_ID,
               MARKET_NAME,
               PARENT_MARKET_ID,
               PARENT_MARKET_NAME,
               REGION,
               REGION_NAME,
               DISTRICT,
               COMPANY_ID,
               COMPANY_NAME,
               ASSET_ID,
               INVOICE_ASSET_MAKE,
               INVOICE_CLASS_ID,
               INVOICE_CLASS,
               RENTAL_CLASS_ID_FROM_RENTAL,
               LINE_ITEM_AMOUNT,
               commission_amount,
               commission_rate,
               override_rate,
               BUSINESS_SEGMENT_ID,
               is_payable
        FROM ANALYTICS.COMMISSION_DBT.COMMISSION_FINAL_ALL
        WHERE
            SALESPERSON_TYPE IN ('Primary Salesperson', 'Secondary Salesperson') -- filtering out NAMs
          AND COMMISSION_MONTH >= '2024-10-01'                                   -- above October because that's around when we implemented DBT
        ),
         old_commission_table as (with old_data as (SELECT split,
                                                           USER_ID                                  AS salesperson_user_id,
                                                           FULL_NAME,
                                                           EMPLOYEE_ID::VARCHAR                     AS employee_id,
                                                           LINE_ITEM_ID,
                                                           COMMISSION_MONTH,
                                                           CASE
                                                               WHEN SALESPERSON_TYPE = 1
                                                                   THEN 'Primary Salesperson'
                                                               WHEN SALESPERSON_TYPE = 2
                                                                   THEN 'Secondary Salesperson'
                                                               END                                  AS SALESPERSON_TYPE,
                                                           SALESPERSON_TYPE                         AS salesperson_type_num,
                                                           BRANCH_ID                                AS MARKET_ID,
                                                           MARKET_NAME,
                                                           COALESCE(pm.parent_market_id, BRANCH_ID) AS PARENT_MARKET_ID,
                                                           mrx.MARKET_NAME                          AS PARENT_MARKET_NAME,
                                                           REGION,
                                                           REGION_NAME,
                                                           DISTRICT,
                                                           cd.COMPANY_ID,
                                                           COMPANY_NAME,
                                                           cd.ASSET_ID,
                                                           aa.MAKE                                  AS INVOICE_ASSET_MAKE,
                                                           aa.EQUIPMENT_CLASS_ID                    AS INVOICE_CLASS_ID,
                                                           aa.CLASS                                 AS INVOICE_CLASS,
                                                           cd.EQUIPMENT_CLASS_ID                    AS RENTAL_CLASS_ID_FROM_RENTAL,
                                                           LINE_ITEM_AMOUNT,
                                                           commission_amount,
                                                           COMMISSION_PERCENTAGE                    AS commission_rate,
                                                           null                                     as override_rate,
                                                           ec.BUSINESS_SEGMENT_ID,
                                                           is_finalized                             AS is_payable,
                                                    FROM analytics.commission.COMMISSION_DETAILS cd
                                                             LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
                                                                       ON ec.EQUIPMENT_CLASS_ID = cd.EQUIPMENT_CLASS_ID
                                                             LEFT JOIN analytics.branch_earnings.parent_market pm
                                                                       ON pm.MARKET_ID = cd.BRANCH_ID
                                                             LEFT JOIN analytics.public.MARKET_REGION_XWALK mrx
                                                                       ON mrx.MARKET_ID = COALESCE(pm.market_id, cd.BRANCH_ID)
                                                             LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
                                                                       ON aa.ASSET_ID = cd.ASSET_ID
                                                    WHERE
                                                        SALESPERSON_TYPE IN (1, 2)
                                                      AND COMMISSION_MONTH < '2024-10-01'),
                                       salesperson_counts AS (SELECT LINE_ITEM_ID,
                                                                     SUM(CASE WHEN salesperson_type_num = 1 THEN 1 ELSE 0 END) AS count_primary,
                                                                     SUM(CASE WHEN salesperson_type_num = 2 THEN 1 ELSE 0 END) AS count_secondary
                                                              FROM old_data
                                                              GROUP BY LINE_ITEM_ID),

      fixed as
      (SELECT o.salesperson_user_id,
      o.FULL_NAME,
      o.employee_id,
      o.LINE_ITEM_ID,
      o.COMMISSION_MONTH,
      o.SALESPERSON_TYPE,
      o.salesperson_type_num,
      o.MARKET_ID,
      o.MARKET_NAME,
      o.PARENT_MARKET_ID,
      o.PARENT_MARKET_NAME,
      o.REGION,
      o.REGION_NAME,
      o.DISTRICT,
      o.COMPANY_ID,
      o.COMPANY_NAME,
      o.ASSET_ID,
      o.INVOICE_ASSET_MAKE,
      o.INVOICE_CLASS_ID,
      o.INVOICE_CLASS,
      o.RENTAL_CLASS_ID_FROM_RENTAL,
      o.LINE_ITEM_AMOUNT,
      o.commission_rate,
      override_rate,
      o.BUSINESS_SEGMENT_ID,
      o.is_payable,
      CASE
      WHEN sc.count_primary = 0
      THEN 1.0 -- If no primary salesperson, split is 1
      ELSE 0.5 / (sc.count_secondary + 1) -- If primary exists, distribute 0.5
      END AS split


      FROM old_data o
      LEFT JOIN salesperson_counts sc
      ON o.LINE_ITEM_ID = sc.LINE_ITEM_ID)
      select salesperson_user_id,
      FULL_NAME,
      employee_id,
      LINE_ITEM_ID,
      COMMISSION_MONTH,
      SALESPERSON_TYPE,
      MARKET_ID,
      MARKET_NAME,
      PARENT_MARKET_ID,
      PARENT_MARKET_NAME,
      REGION,
      REGION_NAME,
      DISTRICT,
      COMPANY_ID,
      COMPANY_NAME,
      ASSET_ID,
      INVOICE_ASSET_MAKE,
      INVOICE_CLASS_ID,
      INVOICE_CLASS,
      RENTAL_CLASS_ID_FROM_RENTAL,
      LINE_ITEM_AMOUNT,
      LINE_ITEM_AMOUNT * coalesce(override_rate, commission_rate) * split as commission_amount,
      commission_rate,
      override_rate,
      BUSINESS_SEGMENT_ID,
      is_payable
      from fixed),
      combined_commission AS (

      SELECT SALESPERSON_USER_ID,
      FULL_NAME,
      EMPLOYEE_ID,
      c.LINE_ITEM_ID::varchar   as LINE_ITEM_ID,
      COMMISSION_MONTH,
      SALESPERSON_TYPE,
      MARKET_ID::VARCHAR        AS MARKET_ID,
      MARKET_NAME,
      PARENT_MARKET_ID::VARCHAR AS PARENT_MARKET_ID,
      PARENT_MARKET_NAME,
      REGION::VARCHAR           AS REGION,
      REGION_NAME,
      DISTRICT::VARCHAR         AS DISTRICT,
      COMPANY_ID::VARCHAR       AS COMPANY_ID,
      COMPANY_NAME,
      ASSET_ID::VARCHAR         AS ASSET_ID,
      INVOICE_ASSET_MAKE,
      INVOICE_CLASS_ID::VARCHAR AS INVOICE_CLASS_ID,
      INVOICE_CLASS,
      RENTAL_CLASS_ID_FROM_RENTAL,
      LINE_ITEM_AMOUNT,
      commission_amount,
      commission_rate,
      BUSINESS_SEGMENT_ID,
      is_payable
      from (
      SELECT *
      FROM dbt_table
      UNION ALL
      SELECT *
      FROM old_commission_table) c
      ),
      commission_data as (select SALESPERSON_USER_ID::integer as SALESPERSON_USER_ID,
      FULL_NAME,
      EMPLOYEE_ID,
      DISTRICT,
      COMMISSION_MONTH,
      sum(LINE_ITEM_AMOUNT)        as AMOUNT,
      sum(commission_amount)       as COMMISSION_AMOUNT
      from combined_commission
      group by SALESPERSON_USER_ID,
      FULL_NAME,
      EMPLOYEE_ID,
      COMMISSION_MONTH),
      guarantee_data as (select *
      from analytics.COMMISSION.EMPLOYEE_COMMISSION_INFO eci
      where COMMISSION_TYPE_ID <= 5
      and coalesce(GUARANTEE_AMOUNT, 0) > 0),

      ranked_data AS (SELECT cd.SALESPERSON_USER_ID,
      cd.FULL_NAME,
      cd.DISTRICT,
      cd.EMPLOYEE_ID,
      gd.EMPLOYEE_COMMISSION_INFO_ID,
      gd.COMMISSION_TYPE_ID,
      cd.COMMISSION_MONTH,
      CASE
      WHEN cd.COMMISSION_MONTH BETWEEN GUARANTEE_START AND DATEADD('month', 1, GUARANTEE_END)
      THEN TRUE
      ELSE FALSE
      END                               AS guarantee_paid,
      gd.GUARANTEE_AMOUNT,
      cd.COMMISSION_AMOUNT,
      SUM(CASE WHEN cd.COMMISSION_AMOUNT < gd.GUARANTEE_AMOUNT THEN 1 ELSE 0 END)
      OVER (PARTITION BY cd.SALESPERSON_USER_ID, gd.EMPLOYEE_COMMISSION_INFO_ID
      ORDER BY cd.COMMISSION_MONTH) AS months_under_guarantee,
      DENSE_RANK() OVER (
      PARTITION BY cd.SALESPERSON_USER_ID, gd.EMPLOYEE_COMMISSION_INFO_ID
      ORDER BY cd.COMMISSION_MONTH
      )                                 AS normalized_month, -- Normalize the month numbers per salesrep + commission structure
      GUARANTEE_START,
      GUARANTEE_END,
      COMMISSION_END
      FROM commission_data cd
      JOIN guarantee_data gd
      ON gd.USER_ID =
      cd.SALESPERSON_USER_ID -- Ensures all commission structures are included
      AND
      cd.COMMISSION_MONTH BETWEEN gd.GUARANTEE_START AND dateadd('month', +1, gd.COMMISSION_END)
      and GUARANTEE_START >= '2023-01-01')
      ,
      first_last_months AS (SELECT SALESPERSON_USER_ID,
      FULL_NAME,
      EMPLOYEE_ID,
      DISTRICT,
      EMPLOYEE_COMMISSION_INFO_ID,
      COMMISSION_TYPE_ID,
      GUARANTEE_AMOUNT,
      MIN(COMMISSION_MONTH)                                                          AS first_commission_month, -- First month in dataset
      MIN(CASE WHEN COMMISSION_AMOUNT >= GUARANTEE_AMOUNT THEN COMMISSION_MONTH END) AS first_exceed_month,     -- First month commission exceeded guarantee
      MAX(months_under_guarantee)                                                    AS months_under_guarantee,
      COUNT(CASE WHEN COMMISSION_AMOUNT >= GUARANTEE_AMOUNT THEN 1 END)              AS months_over_guarantee,
      COUNT(DISTINCT COMMISSION_MONTH)                                               AS total_months,
      div0null(COUNT(CASE WHEN COMMISSION_AMOUNT >= GUARANTEE_AMOUNT THEN 1 END),
      COUNT(DISTINCT COMMISSION_MONTH))                                                                            as over_guarantee_perc,
      GUARANTEE_START,
      GUARANTEE_END,
      COMMISSION_END
      FROM ranked_data
      GROUP BY COMMISSION_TYPE_ID, SALESPERSON_USER_ID, FULL_NAME, EMPLOYEE_ID,
      EMPLOYEE_COMMISSION_INFO_ID,
      GUARANTEE_AMOUNT, GUARANTEE_START, GUARANTEE_END,
      COMMISSION_END)

      -- select *
      -- from ranked_data
      -- where guarantee_paid = False
      -- ;
      select SALESPERSON_USER_ID,
      FULL_NAME,
      EMPLOYEE_ID,
      DISTRICT,
      EMPLOYEE_COMMISSION_INFO_ID,
      COMMISSION_TYPE_ID,
      GUARANTEE_AMOUNT,
      first_commission_month,
      first_exceed_month,
      months_under_guarantee,
      months_over_guarantee,
      total_months,
      over_guarantee_perc,
      GUARANTEE_START,
      GUARANTEE_END,
      COMMISSION_END
      from first_last_months

      ;;
  }


  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}.SALESPERSON_USER_ID ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}.FULL_NAME ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}.EMPLOYEE_ID ;;
  }

  dimension: district {
    type: string
    sql:  ${TABLE}.DISTRICT ;;
  }

  dimension: employee_commission_info_id {
    type: number
    sql: ${TABLE}.EMPLOYEE_COMMISSION_INFO_ID ;;
  }

  dimension: commission_type_id {
    type: number
    sql: ${TABLE}.COMMISSION_TYPE_ID ;;
  }

  dimension: guarantee_amount {
    type: number
    value_format_name: usd  # Or decimal_2 if you prefer
    sql: ${TABLE}.GUARANTEE_AMOUNT ;;
  }

  dimension_group: first_commission_month {
    type: time
    timeframes: [raw, month, quarter, year]
    sql: ${TABLE}.FIRST_COMMISSION_MONTH ;;
  }

  dimension: first_exceed_month {
    type: date
    sql: ${TABLE}.FIRST_EXCEED_MONTH ;;
  }

  dimension: months_under_guarantee {
    type: number
    sql: ${TABLE}.MONTHS_UNDER_GUARANTEE ;;
  }

  dimension: months_over_guarantee {
    type: number
    sql: ${TABLE}.MONTHS_OVER_GUARANTEE ;;
  }

  dimension: total_months {
    type: number
    sql: ${TABLE}.TOTAL_MONTHS ;;
  }

  dimension: over_guarantee_perc {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.OVER_GUARANTEE_PERC ;;
  }

  measure: avg_over_guarantee_perc {
    type: average
    sql: ${over_guarantee_perc} ;;
    value_format_name: percent_2
  }

  dimension_group: guarantee_start {
    type: time
    timeframes: [raw, month, quarter, year]
    sql: ${TABLE}.GUARANTEE_START ;;

  }


  dimension: guarantee_end {
    type: date
    sql: ${TABLE}.GUARANTEE_END ;;
  }

  dimension: commission_end {
    type: date
    sql: ${TABLE}.COMMISSION_END ;;
  }
}
