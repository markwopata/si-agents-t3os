WITH AERE_DATES AS (SELECT ASSET_ID,
                           NET_BOOK_VALUE,
                           cost_with_attachments                 as OEC,
                           LOWER_SALE_CUTOFF                     as ACTUAL_FLOOR_RATE,
                           FOUR_PCT_COMMISSION_BOUND             as ACTUAL_BENCHMARK_RATE,
                           FIVE_PCT_COMMISSION_BOUND             as ACTUAL_ONLINE_RATE,
                           round(LOWER_SALE_CUTOFF)              as ROUNDED_FLOOR_RATE,
                           round(FOUR_PCT_COMMISSION_BOUND)      as ROUNDED_BENCHMARK_RATE,
                           round(FIVE_PCT_COMMISSION_BOUND)      as ROUNDED_ONLINE_RATE,
                           CASE
                               when
                                   row_number() over (partition by asset_id order by date_created) = 1 then '2024-05-10'::timestamp_ntz
                               else DATE_CREATED end             as date_created,

                           coalesce(LEAD(DATE_CREATED) OVER (PARTITION BY ASSET_ID ORDER BY DATE_CREATED),
                                    '2099-12-31'::timestamp_ntz) AS NEXT_DATE_CREATED
                    FROM {{ ref("base_data_science_fleet_opt__all_equipment_rouse_estimates")}}
),

     commission_data as (select i.invoice_no,
                                i.invoice_id,
                                li.line_item_id,

                                i.SALESPERSON_USER_ID,
                                null                                                         as credit_note_line_item_id,
                                null                                                         as manual_adjustment_id,
                                1                                                            as transaction_type,
                                3                                                            as commission_type,
                                i.paid_date                                                  as transaction_date,
                                eci.COMMISSION_TYPE_ID,


                                -- indicators
                                iff(i.DATE_CREATED > '2024-05-10', true, false)              as NEW_CALC_IND,
                                CASE
                                    WHEN li._es_update_timestamp < '2025-05-14 07:58:16.688' 
                                        AND li.LINE_ITEM_TYPE_ID IN (81, 111, 123, 50) THEN TRUE
                                    WHEN li._es_update_timestamp >= '2025-05-14 07:58:16.688' 
                                        AND li.LINE_ITEM_TYPE_ID IN (81, 110, 123, 50) THEN TRUE
                                    ELSE FALSE
                                END AS USED,
                                -- iff(li.LINE_ITEM_TYPE_ID in (81, 111, 123), true, false)     as USED, -- previously used before the line item type id swap

                                CASE
                                    WHEN li._es_update_timestamp < '2025-05-14 07:58:16.688' 
                                        AND li.LINE_ITEM_TYPE_ID IN (24, 80, 110, 141) THEN TRUE
                                    WHEN li._es_update_timestamp >= '2025-05-14 07:58:16.688' 
                                        AND li.LINE_ITEM_TYPE_ID IN (24, 80, 111, 141) THEN TRUE
                                    ELSE FALSE
                                END AS NEW,
                                
                                -- iff(li.LINE_ITEM_TYPE_ID in (24, 80, 110, 141), true, false)      as NEW,  -- previously used before the line item type id swap

                                -- other calculations
                                Coalesce(AERE.NET_BOOK_VALUE, nbv.nbv)::decimal(12, 2)       as NBV,
                                (li.amount - COALESCE(cnli.total_credit, 0))::decimal(12, 2) as NET_SALE_PRICE,

                                case
                                    when Coalesce(AERE.NET_BOOK_VALUE, nbv.nbv) = 0 then 0
                                    else coalesce((li.amount - Coalesce(AERE.NET_BOOK_VALUE, nbv.nbv)), 0)::decimal(12, 2)
                                    end                                                      as PROFIT,

                                profit / nullifzero(NET_SALE_PRICE)                          as PROFIT_MARGIN,


                                CASE
                                    WHEN i.DATE_CREATED between '2024-10-01' and '2024-11-08' --accommodating for rounding on Looker dashboard
                                        then ROUNDED_FLOOR_RATE
                                    else ACTUAL_FLOOR_RATE end                               as FLOOR_RATE,

                                CASE
                                    WHEN i.DATE_CREATED between '2024-10-01' and '2024-11-08' --accommodating for rounding on Looker dashboard
                                        then ROUNDED_BENCHMARK_RATE
                                    else ACTUAL_BENCHMARK_RATE end                           as BENCHMARK_RATE,

                                CASE
                                    WHEN i.DATE_CREATED between '2024-10-01' and '2024-11-08' --accommodating for rounding on Looker dashboard
                                        then ROUNDED_ONLINE_RATE
                                    else ACTUAL_ONLINE_RATE end                              as ONLINE_RATE,


                                CASE
                                    -- USED - Zero amount or negative profit
                                    WHEN USED AND (li.AMOUNT = 0 OR profit < 0) THEN 0

                                    -- USED - Missing NBV or Asset ID (default rate)
                                    WHEN USED AND (
                                        li.ASSET_ID IS NULL OR
                                        COALESCE(AERE.NET_BOOK_VALUE, nbv.nbv) IS NULL OR
                                        COALESCE(AERE.NET_BOOK_VALUE, nbv.nbv) = 0
                                        ) THEN 53 -- Default per Mark


                                    -- OLD CALCULATIONS
                                    WHEN i.date_created::date <= '2024-05-10' THEN
                                        CASE
                                            -- USED - Old structure rates
                                            WHEN USED AND eci.COMMISSION_TYPE_ID IN (1, 2, 3, 6, 7) THEN 999 -- TAMs
                                            WHEN USED AND eci.COMMISSION_TYPE_ID NOT IN (1, 2, 3, 6, 7)
                                                THEN 999 -- Retail reps

                                        -- NEW - Old structure for TAMs
                                            WHEN NEW_CALC_IND = false AND NEW AND eci.COMMISSION_TYPE_ID IN (1, 2, 3, 6, 7)
                                                THEN 999

                                            ELSE 0
                                            END

                                    -- NEW CALCULATIONS
                                    ELSE
                                        CASE
                                            -- USED - New structure, based on amount
                                            WHEN USED AND li.AMOUNT >= ONLINE_RATE THEN 50
                                            WHEN USED AND li.AMOUNT >= BENCHMARK_RATE AND li.AMOUNT < ONLINE_RATE
                                                THEN 51

                                            -- NEW - Profit margin-based rates
                                            WHEN NEW AND PROFIT_MARGIN > 0.2000 THEN 60
                                            WHEN NEW AND PROFIT_MARGIN BETWEEN 0.1401 AND 0.2000 THEN 61
                                            WHEN NEW AND PROFIT_MARGIN BETWEEN 0.1201 AND 0.1400 THEN 62
                                            WHEN NEW AND PROFIT_MARGIN > 0.0000 AND PROFIT_MARGIN <= 0.1200 THEN 63
                                            WHEN NEW AND PROFIT_MARGIN <= 0.0000 THEN 64

                                            -- Fallback: Percentage of profit capped at 4%
                                            ELSE 52
                                            END
                                    END                                                      AS rate_tier_id,
                                i.date_created,

                                CASE
                                    -- USED - Zero amount or negative profit
                                    WHEN USED AND li.AMOUNT = 0 THEN 0
                                    WHEN USED AND profit < 0 THEN 0

                                    -- USED - Missing NBV or Asset ID (default rate)
                                    WHEN USED AND (
                                        li.ASSET_ID IS NULL OR
                                        COALESCE(AERE.NET_BOOK_VALUE, nbv.nbv) IS NULL OR
                                        COALESCE(AERE.NET_BOOK_VALUE, nbv.nbv) = 0
                                        ) THEN 0.025 -- Default per Mark


                                -- OLD CALCULATIONS
                                    WHEN i.date_created::date <= '2024-05-10' THEN
                                        CASE
                                            -- USED - Old structure rates
                                            WHEN USED AND eci.COMMISSION_TYPE_ID IN (1, 2, 3, 6, 7) THEN 0.04 -- TAMs
                                            WHEN USED AND eci.COMMISSION_TYPE_ID NOT IN (1, 2, 3, 6, 7)
                                                THEN 0.015 -- Retail reps

                                        -- NEW - Old structure for TAMs
                                            WHEN NEW_CALC_IND = false AND NEW AND eci.COMMISSION_TYPE_ID IN (1, 2, 3, 6, 7)
                                                THEN 0.25

                                            ELSE 0
                                            END

                                    -- NEW CALCULATIONS
                                    ELSE
                                        CASE
                                            -- USED - New structure, based on amount
                                            WHEN USED AND li.AMOUNT >= ONLINE_RATE THEN 0.05
                                            WHEN USED AND li.AMOUNT >= BENCHMARK_RATE AND li.AMOUNT < ONLINE_RATE
                                                THEN 0.04

                                            -- NEW - Profit margin-based rates
                                            WHEN NEW AND PROFIT_MARGIN > 0.2000 THEN 0.05
                                            WHEN NEW AND PROFIT_MARGIN BETWEEN 0.1401 AND 0.2000 THEN 0.04
                                            WHEN NEW AND PROFIT_MARGIN BETWEEN 0.1201 AND 0.1400 THEN 0.03
                                            WHEN NEW AND PROFIT_MARGIN > 0.0000 AND PROFIT_MARGIN <= 0.1200 THEN 0.02
                                            WHEN NEW AND PROFIT_MARGIN <= 0.0000 THEN 0

                                            -- Fallback: Percentage of profit capped at 4%
                                            ELSE LEAST(((profit * 0.25) / NULLIFZERO(li.AMOUNT)), 0.04)
                                            END
                                    END                                                      AS COMMISSION_RATE,


                                1                                                            as split,
                                null                                                         as reimbursement_factor,
                                null                                                         as override_rate,
                                false                                                        as exception,
                                li.amount::decimal(12, 2)                                    as AMOUNT

                         FROM {{ ref("stg_es_warehouse_public__line_items")}} li
                                  LEFT JOIN {{ ref("stg_es_warehouse_public__invoices")}}  i
                                            ON i.INVOICE_ID = li.INVOICE_ID
                                  LEFT JOIN AERE_DATES AERE ON
                             li.ASSET_ID = AERE.ASSET_ID
                                 AND i.DATE_CREATED::date >= AERE.DATE_CREATED::date
                                 AND i.DATE_CREATED::date < AERE.NEXT_DATE_CREATED::date
                                  LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS u ON i.SALESPERSON_USER_ID = u.USER_ID
                                  LEFT JOIN (select line_item_id,
                                                    sum(credit_amount) as total_credit
                                             from {{ ref("stg_es_warehouse_public__credit_note_line_items")}}
                                             group by line_item_id) cnli
                                            ON CNLI.LINE_ITEM_ID = li.LINE_ITEM_ID
                                  LEFT JOIN {{ ref("stg_analytics_commission__employee_commission_info")}} eci on
                             i.SALESPERSON_USER_ID = eci.USER_ID and
                             i.BILLING_APPROVED_DATE >= coalesce(eci.guarantee_start, eci.COMMISSION_START) and
                             i.BILLING_APPROVED_DATE <= eci.COMMISSION_END
                                  LEFT JOIN analytics.debt.asset_nbv_all_owners nbv on li.ASSET_ID = nbv.ASSET_ID --what's this table

                        WHERE (i.paid_date is null OR  i.paid_date >= '2024-06-01') -- get all the invoices for accruals too...
                            and li.invoice_id is not null
                            and
                            (
                                
                                li.LINE_ITEM_TYPE_ID in (24, 50, 81, 110, 111, 123) -- only pull out used equipments, as of 2025-09-09
                                OR  (
                                    li.LINE_ITEM_TYPE_ID in (80, 140, 141, 152, 153) -- dealerships prior retool app
                                    AND i.date_created < '2025-04-01'  -- if created before the retool app
                                    AND i.invoice_id not in (select invoice_id from {{ ref("int_retail_sales_commissions") }})  -- make sure it's not in the retool app
                                )
                            )
                        )

select cd.invoice_no,
       cd.invoice_id,
       cd.line_item_id,
       cd.SALESPERSON_USER_ID,
       cd.credit_note_line_item_id,
       cd.manual_adjustment_id,
       cd.transaction_type,
       cd.commission_type,
       cd.transaction_date,
       cd.NEW_CALC_IND,
       cd.USED,
       cd.NEW,
       cd.NBV,
       cd.NET_SALE_PRICE,
       cd.PROFIT,
       cd.PROFIT_MARGIN,
       cd.FLOOR_RATE,
       cd.BENCHMARK_RATE,
       cd.ONLINE_RATE,
       cd.rate_tier_id,
       crt.name as rate_tier_name,
       cd.date_created,
       cd.split,
       cd.reimbursement_factor,
       case
           when crt.COMMISSION_PERCENTAGE is not null then crt.COMMISSION_PERCENTAGE
           when crt.RATE_TIER_ID = 999 then
               CASE
                   -- USED - Old structure rates
                   WHEN USED AND cd.COMMISSION_TYPE_ID IN (1, 2, 3, 6, 7) THEN 0.04 -- TAMs
                   WHEN USED AND cd.COMMISSION_TYPE_ID NOT IN (1, 2, 3, 6, 7) THEN 0.015 -- Retail reps

               -- NEW - Old structure for TAMs
                   WHEN NEW_CALC_IND = false AND NEW AND cd.COMMISSION_TYPE_ID IN (1, 2, 3, 6, 7) THEN 0.25
                   ELSE 0
                   END
           when crt.RATE_TIER_ID = 52 THEN GREATEST(
                LEAST((profit * 0.25) / NULLIFZERO(AMOUNT), 0.04) -- gives max 4% which is the between rate
                , 0) -- greatest handles if the calculated amount goes below 0%

           else cd.COMMISSION_RATE end as commission_rate,
       cd.override_rate,
       cd.exception,
       cd.AMOUNT
from commission_data cd
    LEFT JOIN {{ ref('stg_analytics_rate_achievement__commission_rate_tiers')}} crt on cd.rate_tier_id = crt.rate_tier_id
where invoice_id is not null