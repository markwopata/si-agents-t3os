view: guarantee_vs_commission_monthly {

  derived_table: {
    sql:
with dbt_table AS (-- dbt finalized data
    SELECT SALESPERSON_USER_ID,
           FULL_NAME,
           EMPLOYEE_ID::varchar as employee_id,
           EMPLOYEE_TITLE,
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
           SPLIT,
           AMOUNT,
           commission_amount,
           commission_rate,
           override_rate,
           BUSINESS_SEGMENT_ID,
           is_payable
    FROM ANALYTICS.COMMISSION_DBT.COMMISSION_FINAL_ALL
    WHERE SALESPERSON_TYPE IN ('Primary Salesperson', 'Secondary Salesperson') -- filtering out NAMs
      AND COMMISSION_MONTH >= '2024-10-01'                                     -- above October because that's around when we implemented DBT
      and MANUAL_ADJUSTMENT_ID = 0),
     old_commission_table as (with old_data as (SELECT USER_ID                                  AS salesperson_user_id,
                                                       FULL_NAME,
                                                       EMPLOYEE_ID::VARCHAR                     AS employee_id,
                                                       EMPLOYEE_TITLE,
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
                                                       SPLIT,
                                                       LINE_ITEM_AMOUNT,
                                                       commission_amount,
                                                       COMMISSION_PERCENTAGE                    AS commission_rate,
                                                       null                                     as override_rate,
                                                       ec.BUSINESS_SEGMENT_ID,
                                                       is_finalized                             AS is_payable
                                                FROM analytics.commission.COMMISSION_DETAILS cd
                                                         LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
                                                                   ON ec.EQUIPMENT_CLASS_ID = cd.EQUIPMENT_CLASS_ID
                                                         LEFT JOIN analytics.branch_earnings.parent_market pm
                                                                   ON pm.MARKET_ID = cd.BRANCH_ID
                                                         LEFT JOIN analytics.public.MARKET_REGION_XWALK mrx
                                                                   ON mrx.MARKET_ID = COALESCE(pm.market_id, cd.BRANCH_ID)
                                                         LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
                                                                   ON aa.ASSET_ID = cd.ASSET_ID
                                                WHERE SALESPERSON_TYPE IN (1, 2)
                                                  AND COMMISSION_MONTH < '2024-10-01'),
                                   salesperson_counts AS (SELECT LINE_ITEM_ID,
                                                                 SUM(CASE WHEN salesperson_type_num = 1 THEN 1 ELSE 0 END) AS count_primary,
                                                                 SUM(CASE WHEN salesperson_type_num = 2 THEN 1 ELSE 0 END) AS count_secondary
                                                          FROM old_data
                                                          GROUP BY LINE_ITEM_ID)
                                      ,
                                   fixed as
                                       (SELECT o.salesperson_user_id,
                                               o.FULL_NAME,
                                               o.employee_id,
                                               EMPLOYEE_TITLE,
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
                                                   WHEN SALESPERSON_TYPE = 'Primary Salesperson' THEN
                                                       CASE
                                                           WHEN sc.count_secondary > 0 THEN 0.5
                                                           ELSE 1.0
                                                           END
                                                   WHEN SALESPERSON_TYPE = 'Secondary Salesperson' THEN
                                                       CASE
                                                           WHEN sc.count_secondary > 0
                                                               THEN div0(0.5, sc.count_secondary)
                                                           ELSE 0 -- or NULL, depending on your business rule
                                                           END
                                                   END AS split
                                        FROM old_data o
                                                 LEFT JOIN salesperson_counts sc
                                                           ON o.LINE_ITEM_ID = sc.LINE_ITEM_ID)
                              select salesperson_user_id,
                                     FULL_NAME,
                                     employee_id,
                                     EMPLOYEE_TITLE,
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
                                     SPLIT,
                                     LINE_ITEM_AMOUNT as AMOUNT,
                                     LINE_ITEM_AMOUNT * coalesce(override_rate, commission_rate) *
                                     split            as commission_amount,
                                     commission_rate,
                                     override_rate,
                                     BUSINESS_SEGMENT_ID,
                                     is_payable
                              from fixed),
     combined_commission AS (SELECT SALESPERSON_USER_ID,
                                    FULL_NAME,
                                    EMPLOYEE_ID,
                                    EMPLOYEE_TITLE,
                                    c.LINE_ITEM_ID::varchar     as LINE_ITEM_ID,
                                    COMMISSION_MONTH,
                                    SALESPERSON_TYPE,
                                    MARKET_ID::VARCHAR          AS MARKET_ID,
                                    MARKET_NAME,
                                    PARENT_MARKET_ID::VARCHAR   AS PARENT_MARKET_ID,
                                    PARENT_MARKET_NAME,
                                    REGION::VARCHAR             AS REGION,
                                    REGION_NAME,
                                    DISTRICT::VARCHAR           AS DISTRICT,
                                    COMPANY_ID::VARCHAR         AS COMPANY_ID,
                                    COMPANY_NAME,
                                    ASSET_ID::VARCHAR           AS ASSET_ID,
                                    INVOICE_ASSET_MAKE,
                                    INVOICE_CLASS_ID::VARCHAR   AS INVOICE_CLASS_ID,
                                    INVOICE_CLASS,
                                    RENTAL_CLASS_ID_FROM_RENTAL,
                                    AMOUNT,
                                    coalesce(AMOUNT * split, 0) as revenue_w_split,
                                    commission_amount,
                                    commission_rate,
                                    BUSINESS_SEGMENT_ID,
                                    is_payable
                             from (SELECT *
                                   FROM dbt_table
                                   UNION ALL
                                   SELECT *
                                   FROM old_commission_table) c),
     commission_data as (select SALESPERSON_USER_ID::integer as SALESPERSON_USER_ID,
                                FULL_NAME,
                                EMPLOYEE_ID,
                                EMPLOYEE_TITLE,
                                DISTRICT,
                                COMMISSION_MONTH,
                                sum(AMOUNT)                  as AMOUNT,
                                sum(revenue_w_split)         as REVENUE_W_SPLIT,
                                sum(commission_amount)       as COMMISSION_AMOUNT
                         from combined_commission
                         group by SALESPERSON_USER_ID,
                                  FULL_NAME,
                                  EMPLOYEE_ID,
                                  EMPLOYEE_TITLE,
                                  DISTRICT,
                                  COMMISSION_MONTH),

     months AS (SELECT DATE_TRUNC('month', DATEADD('month', seq4(), '2017-01-01')) AS month
                FROM TABLE (GENERATOR(ROWCOUNT => 200))
                where month <= (select max(commission_month) from commission_data)),

     eci_qualified as (WITH ordered_commissions AS (SELECT *,
                                                           ROW_NUMBER() OVER (PARTITION BY USER_ID, COMMISSION_TYPE_ID ORDER BY COMMISSION_START) AS rn,
                                                           LAG(COMMISSION_END)
                                                               OVER (PARTITION BY USER_ID, COMMISSION_TYPE_ID ORDER BY COMMISSION_START)          AS prev_commission_end
                                                    FROM analytics.commission.employee_commission_info
                                                    WHERE USER_ID IN (SELECT USER_ID
                                                                      FROM analytics.commission.employee_commission_info
                                                                      GROUP BY USER_ID
                                                                      HAVING COUNT(*) > 1)),
                            gap_flagged AS (SELECT *,
                                                   CASE
                                                       WHEN prev_commission_end IS NOT NULL AND (
                                                           DATEDIFF(DAY, prev_commission_end,
                                                                    COALESCE(GUARANTEE_START, COMMISSION_START)) < 2
                                                           )
                                                           THEN 0 -- same group as previous
                                                       ELSE 1 -- start of a new group
                                                       END AS new_group_flag
                                            FROM ordered_commissions),
                            grouped AS (SELECT *,
                                               SUM(new_group_flag)
                                                   OVER (PARTITION BY USER_ID, COMMISSION_TYPE_ID ORDER BY rn) AS merge_group
                                        FROM gap_flagged),
                            group_agg AS (SELECT USER_ID,
                                                 COMMISSION_TYPE_ID,
                                                 merge_group,
                                                 max(GUARANTEE_AMOUNT)                            as guarantee_amount,
                                                 MIN(EMPLOYEE_COMMISSION_INFO_ID)                 AS EMPLOYEE_COMMISSION_INFO_ID,
                                                 min(coalesce(GUARANTEE_START, COMMISSION_START)) as plan_start,
                                                 MAX(COMMISSION_END)                              as plan_end,
                                                 MIN(GUARANTEE_START)                             AS GUARANTEE_START,
                                                 MAX(GUARANTEE_END)                               AS GUARANTEE_END,
                                                 MIN(COMMISSION_START)                            AS COMMISSION_START,
                                                 MAX(COMMISSION_END)                              AS COMMISSION_END,
                                                 COUNT(*)                                         AS group_size
                                          -- Add other fields/aggregations here as needed
                                          FROM grouped
                                          GROUP BY USER_ID, COMMISSION_TYPE_ID, merge_group)
                               ,
                            cleaned_all as ((SELECT EMPLOYEE_COMMISSION_INFO_ID,
                                                    USER_ID,
                                                    COMMISSION_TYPE_ID,
--        merge_group,
                                                    coalesce(GUARANTEE_START, COMMISSION_START) as plan_start,
                                                    (COMMISSION_END)                            as plan_end,
                                                    guarantee_amount,
                                                    GUARANTEE_START,
                                                    GUARANTEE_END,
                                                    COMMISSION_START,
                                                    COMMISSION_END,
                                                    group_size,
                                                    CASE
                                                        WHEN group_size > 1 THEN TRUE
                                                        ELSE FALSE
                                                        END                                     AS was_consolidated
                                             FROM group_agg)
                                            union all

                                            (select EMPLOYEE_COMMISSION_INFO_ID,
                                                    USER_ID,
                                                    COMMISSION_TYPE_ID,
                                                    coalesce(GUARANTEE_START, COMMISSION_START) as plan_start,
                                                    (COMMISSION_END)                            as plan_end,
                                                    GUARANTEE_AMOUNT,
                                                    GUARANTEE_START,
                                                    GUARANTEE_END,
                                                    COMMISSION_START,
                                                    COMMISSION_END,
                                                    0                                           as group_size,
                                                    false                                       as was_consolidated
                                             from analytics.commission.employee_commission_info
                                             WHERE USER_ID IN (SELECT USER_ID
                                                               FROM analytics.commission.employee_commission_info
                                                               GROUP BY USER_ID
                                                               HAVING COUNT(*) = 1)))
                       select *
                       from (select *
                             from cleaned_all
                             where COMMISSION_TYPE_ID <= 5
                             QUALIFY ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY plan_start) =
                                     1
                             ORDER BY USER_ID, plan_start)
                       where date_trunc('month', plan_start) >= '2023-01-01'),
     data as (SELECT EMPLOYEE_COMMISSION_INFO_ID,
                     SALESPERSON_USER_ID,
                     employee_id,
                     FULL_NAME,
                     EMPLOYEE_TITLE,
                     DISTRICT,
                     COMMISSION_TYPE_ID,
                     plan_start,
                     plan_end,
                     m.month,
                     DENSE_RANK() OVER (
                         PARTITION BY USER_ID, EMPLOYEE_COMMISSION_INFO_ID
                         ORDER BY m.month
                         )                                   AS normalized_month,
                     left(date_trunc('year', plan_start), 4) AS guarantee_year,
                     CASE
                         WHEN (GUARANTEE_AMOUNT = 0 OR GUARANTEE_AMOUNT is null) THEN '0'
                         WHEN GUARANTEE_AMOUNT <= 5000 THEN '$1-$5,000'
                         WHEN GUARANTEE_AMOUNT <= 10000 THEN '$5,001-$10,000'
                         ELSE '$10,000+'
                         END                                 AS guarantee_range,
                     guarantee_amount,
                     coalesce(COMMISSION_AMOUNT, 0)          as COMMISSION_AMOUNT,
                     coalesce(REVENUE_W_SPLIT, 0)            AS REVENUE_W_SPLIT,
                     coalesce(AMOUNT, 0)                     AS AMOUNT

              from eci_qualified
                       JOIN months m
                            ON (
                                DATE_TRUNC('month', m.month) >= DATE_TRUNC('month', plan_start)
                                    AND DATE_TRUNC('month', m.month) <= DATE_TRUNC('month', plan_end)
                                )
                       join commission_data
                            on USER_ID = SALESPERSON_USER_ID and month = COMMISSION_MONTH)

select EMPLOYEE_COMMISSION_INFO_ID,
       SALESPERSON_USER_ID,
       data.EMPLOYEE_ID,
       FULL_NAME,
       data.EMPLOYEE_TITLE,
       DISTRICT,
       COMMISSION_TYPE_ID,
       PLAN_START,
       PLAN_END,
       MONTH as COMMISSION_MONTH,
       NORMALIZED_MONTH,
       GUARANTEE_YEAR,
       GUARANTEE_RANGE,
       GUARANTEE_AMOUNT,
       COMMISSION_AMOUNT,
       REVENUE_W_SPLIT,
       AMOUNT
from data
         left join analytics.PAYROLL.COMPANY_DIRECTORY cd
                   on data.EMPLOYEE_ID = cd.EMPLOYEE_ID
where guarantee_range != '0'
  AND CASE
          WHEN NULLIF(TRIM(DATE_HIRED), '') IS NOT NULL
              THEN TRY_TO_DATE(DATE_HIRED)
    END BETWEEN DATEADD('day', -15, plan_start)
    AND DATEADD('day', 15, plan_start)

      ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}.EMPLOYEE_ID ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}.FULL_NAME ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}.EMPLOYEE_TITLE ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.DISTRICT ;;
  }

  dimension_group: commission_month {
    type: time
    timeframes: [raw, month, quarter, year]
    sql: ${TABLE}.COMMISSION_MONTH ;;
  }

  dimension_group: plan_start {
    type: time
    timeframes: [raw, month, quarter, year]
    sql: ${TABLE}.PLAN_START ;;
  }
  dimension_group: plan_end {
    type: time
    timeframes: [raw, month, quarter, year]
    sql: ${TABLE}.PLAN_END ;;
  }

  dimension: normalized_month {
    type: number
    sql: ${TABLE}.NORMALIZED_MONTH ;;
  }

  dimension: employee_commission_info_id {
    type: number
    sql: ${TABLE}.EMPLOYEE_COMMISSION_INFO_ID ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}.SALESPERSON_USER_ID ;;
  }

  dimension: commission_type_id {
    type: number
    sql: ${TABLE}.COMMISSION_TYPE_ID ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.TYPE ;;
  }

  dimension: guarantee_range {
    type: string
    sql: ${TABLE}.GUARANTEE_RANGE ;;
  }
  dimension: guarantee_year {
    type: number
    sql: ${TABLE}.GUARANTEE_YEAR ;;
  }

  dimension: guarantee_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}.GUARANTEE_AMOUNT ;;
  }

  dimension: commission_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}.COMMISSION_AMOUNT ;;
  }
  dimension: revenue_w_split {
    type: number
    value_format_name: usd
    sql: ${TABLE}.REVENUE_W_SPLIT ;;
  }

  dimension: commission_to_guarantee_ratio {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.COMMISSION_TO_GUARANTEE_RATIO ;;
  }

  dimension: revenue_to_guarantee_ratio {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.REVENUE_TO_GUARANTEE_RATIO ;;
  }

  dimension: months_under_guarantee {
    type: number
    sql: ${TABLE}.MONTHS_UNDER_GUARANTEE ;;
  }

  measure: commission_amount_sum {
    type: sum
    value_format_name: usd
    sql: ${commission_amount} ;;
  }

  measure: revenue_w_split_sum {
    type: sum
    value_format_name: usd
    sql: ${revenue_w_split} ;;
  }

  measure: avg_commission_to_guarantee_ratio {
    type: average
    value_format_name: percent_2
    sql:
    CASE
      WHEN ${guarantee_amount} = 0 THEN NULL
      ELSE ${commission_amount} / ${guarantee_amount}
    END ;;

  }

  measure: avg_revenue_to_guarantee_ratio {
    type: average
    value_format: "###.#"
    sql:
    CASE
      WHEN ${guarantee_amount} = 0 THEN NULL
      ELSE ${revenue_w_split} / ${guarantee_amount}
    END ;;

  }

}
