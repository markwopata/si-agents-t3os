view: unbilled_work_orders {
  derived_table: {
    sql:
    WITH post_deadline_time as (
    select *
    from ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRIES te
    where ARCHIVED_DATE is null
      and NEEDS_REVISION = false
      and WORK_ORDER_ID is not null
      and START_DATE > '2022-10-01'
      and te.EVENT_TYPE_ID = 1
      and te.APPROVAL_STATUS like 'Approved'
      and datediff('day', te.START_DATE, te.END_DATE) <= 1 -- historical time entry has instances where it exceed 24 consecutive hours
      and datediff('hour', te.START_DATE, te.END_DATE) < 24
)

, pre_deadline_parts as (
    select *,
           IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID) as work_order_id,
           IFF(TRANSACTION_TYPE_ID = 7, ti.QUANTITY_RECEIVED, 0 - ti.QUANTITY_RECEIVED) as qty
    from ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
    join ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
        on t.TRANSACTION_ID = ti.TRANSACTION_ID
    where t.TRANSACTION_TYPE_ID in (7,9)
        and t.date_completed is not null
        and t.date_cancelled is null
)

--Connecting each part on a work order to it's master part id
, parts_per_work_order as (
    select pdp.work_order_id
         , p1.master_part_id as current_part_ID
         , sum(pdp.qty) as quantity
         , wo.BRANCH_ID as market_id
         , iff(wo.date_completed is not null, wo.DATE_COMPLETED, wo.DATE_CREATED) as ref_date
    from pre_deadline_parts pdp
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        on pdp.work_order_id = wo.WORK_ORDER_ID
    JOIN analytics.parts_inventory.parts p1
        on pdp.part_ID = p1.part_ID
    group by pdp.work_order_id
           , current_part_ID
           , wo.BRANCH_ID
           , iff(wo.date_completed is not null, wo.DATE_COMPLETED, wo.DATE_CREATED)
    having  sum(pdp.qty) <> 0
)
--select count(distinct work_order_id) from parts_per_work_order ;

, wac_prep as (
select *
    from es_warehouse.inventory.weighted_average_cost_snapshots wacs
    where date_applied::date <= current_date
        qualify
                row_number() over (
                    partition by wacs.inventory_location_id, wacs.product_id, date_applied
                    order by wacs.date_created desc)
                = 1
        and
                max(date_applied) over (
                    partition by PRODUCT_ID, INVENTORY_LOCATION_ID
                    order by date_applied desc)
                = date_applied
    order by product_id, INVENTORY_LOCATION_ID, date_applied desc)

--Aggregating WAC's for each part by the master part id across branch
, wac as (
    select il.branch_id
        , p.master_part_id as current_part_id
        , avg(wac.weighted_average_cost) as avg_cost
    from wac_prep wac
    join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
        on wac.inventory_location_id = il.inventory_location_id
    join analytics.parts_inventory.parts p
        on p.part_id = wac.product_id
    group by current_part_id
        , il.branch_id
)

--Company wide average backup
, wac_backup as (
    select p.master_part_id as current_part_id
        , avg(wac.weighted_average_cost) as avg_cost
    from wac_prep wac
    join analytics.parts_inventory.parts p
        on p.part_id = wac.product_id
    group by current_part_id
)

, parts_per_wo_w_cost_market as (
    select wo.work_order_id
         , wo.CURRENT_PART_ID
         , quantity * (acss.avg_cost * 1.27) as line_total
    FROM parts_per_work_order wo
    JOIN wac acss
        ON wo.current_part_ID = acss.CURRENT_PART_ID
            AND wo.market_ID = acss.branch_id
    ORDER BY work_order_ID
)

--Pulling company wide where market is not present
, parts_per_wo_w_cost_company as (
    select wo.work_order_id
         , wo.CURRENT_PART_ID
         , quantity * (acss.avg_cost * 1.27) as line_total
    FROM parts_per_work_order wo
    join wac_backup acss
        ON wo.current_part_ID = acss.CURRENT_PART_ID
    left join parts_per_wo_w_cost_market m
        on m.work_order_id = wo.work_order_id
            and m.current_part_id = wo.current_part_id
    where m.work_order_id is null
        and m.current_part_id is null
    ORDER BY work_order_ID
)

, parts_per_wo_w_cost as (
    select work_order_id
        , current_part_id
        , line_total
        , 'market' as c
    from parts_per_wo_w_cost_market
    --)select count(work_order_id, current_part_id) from parts_per_wo_w_cost; -- validate

    union

    select work_order_id
        , current_part_id
        , line_total
        , 'company' as c
    from parts_per_wo_w_cost_company
)
-- select count(work_order_id, current_part_id) from parts_per_wo_w_cost; --validate

--Aggregate work orders
, part_cost_per_work_order_final as (
    select
         work_order_id
         , sum(line_total) as part_cost
    FROM parts_per_wo_w_cost wo
    group by
           work_order_id
)

, es_owned as (
    select aa.asset_id
        , scdc.COMPANY_ID
        , aa.company_id as current_owner
        , scdc.DATE_START
        , scdc.DATE_END
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    join ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY AS SCDC
        ON aa.ASSET_ID = SCDC.ASSET_ID
    where scdc.COMPANY_ID in (
        SELECT COMPANY_ID
        FROM ANALYTICS.PUBLIC.ES_COMPANIES)
)

, own_program as (
    select ppa.asset_ID
        , ppa.payout_program_id
    from ES_WAREHOUSE.PUBLIC.PAYOUT_PROGRAM_ASSIGNMENTS ppa
    where ppa.PAYOUT_PROGRAM_ID in (
        11 --Advantage Max Premium (Indirectly Billed maintenance agreement)
        , 8 --Flex 50 (Paid maintenance)
        , 38 --Crockett Partners II (Indirectly Billed maintenance agreement)
        , 12 -- Flex 55 (Paid maintenance)
        )
        AND CURRENT_TIMESTAMP < COALESCE(ppa.END_DATE, '2099-12-31')
)

--select count(asset_id), count(distinct asset_id) from own_program;

--Different Conditions
--Assets ES owns or maintains (payout program)
, draft_part_1 as (
    select aa.OWNER
        , aa.COMPANY_ID
        , aa.asset_id
        , aa.MAKE
        , aa.MODEL
        , aa.YEAR
        , wo.WORK_ORDER_ID
        , wo.INVOICE_ID
        , wo.invoice_number
        , coalesce(pcpwof.part_cost, 0)        as the_part_cost
        , coalesce(sum(pdt.REGULAR_HOURS), 0)  as reg_hours
        , coalesce(sum(pdt.OVERTIME_HOURS), 0) as ot_hours
        , reg_hours + ot_hours                 as total_time
        , wo.DATE_CREATED::date as created_date
        , wo.DATE_COMPLETED::date as completed_date
        , wo.DATE_BILLED::date as billed_date
        , es.asset_id  as es_asset_id
        , own.asset_id as own_asset_id
        , own.payout_program_id
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    join ES_WAREHOUSE.PUBLIC.MARKETS m
        on wo.BRANCH_ID = m.MARKET_ID
    join ES_WAREHOUSE.PUBLIC.COMPANIES c
        on m.COMPANY_ID = c.COMPANY_ID
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on wo.ASSET_ID = aa.ASSET_ID
    left join post_deadline_time pdt
        on wo.WORK_ORDER_ID = pdt.WORK_ORDER_ID
    left join part_cost_per_work_order_final pcpwof
        on wo.WORK_ORDER_ID = pcpwof.work_order_id
    left join es_owned es
        on es.asset_id = aa.asset_id
            and wo.date_completed < es.DATE_END
            and wo.date_completed >= es.date_start
    left join own_program own
        on own.asset_id = aa.asset_id
    where
         wo.WORK_ORDER_ID not in (                                    --Non-Warranty Work Orders
            select WORK_ORDER_ID
            from ANALYTICS.WARRANTIES.WARRANTY_ACCRUAL)
        and wo.billing_type_id = 2                                    --Customer Damaged when ES Owned
        and wo.DATE_CREATED::date <= current_date                      --Work Order Created before end of month
        and wo.ARCHIVED_DATE is null                                  --Not Archived
        and c.COMPANY_ID in (                                         --ES Did the Work
            SELECT COMPANY_ID
            FROM ES_WAREHOUSE.public.companies
            WHERE name REGEXP 'IES\\d+ .*'
                OR COMPANY_ID = 420           -- Demo Units
                OR COMPANY_ID = 62875         -- ES Owned special events - still owned by us
                OR COMPANY_ID IN (1854, 1855) -- ES Owned
                OR COMPANY_ID = 61036)
        and coalesce(es.asset_id, own.asset_id) is not null           --ES Owned Asset or OWN Program Asset
        and (billed_date is NULL or billed_date > current_date)        --A bill has not been sent or was sent out after the end of the month
        and completed_date <= current_date                            --Completed before end of month
    group by aa.OWNER
        , aa.COMPANY_ID
        , aa.asset_id
        , aa.MAKE
        , aa.MODEL
        , aa.YEAR
        , wo.WORK_ORDER_ID
        , wo.INVOICE_ID
        , wo.invoice_number
        , pcpwof.part_cost
        , wo.DATE_CREATED
        , wo.DATE_COMPLETED
        , wo.DATE_BILLED
        , es.asset_id
        , own.asset_id
        , own.payout_program_id
)

--For Assets we do not own and are not in the payout program
, draft_part_2 as (
    select aa.OWNER
        , aa.COMPANY_ID
        , aa.asset_id
        , aa.MAKE
        , aa.MODEL
        , aa.YEAR
        , wo.WORK_ORDER_ID
        , wo.INVOICE_ID
        , wo.invoice_number
        , coalesce(pcpwof.part_cost, 0)        as the_part_cost
        , coalesce(sum(pdt.REGULAR_HOURS), 0)  as reg_hours
        , coalesce(sum(pdt.OVERTIME_HOURS), 0) as ot_hours
        , reg_hours + ot_hours                 as total_time
        , wo.DATE_CREATED::date as created_date
        , wo.DATE_COMPLETED::date as completed_date
        , wo.DATE_BILLED::date as billed_date
        , es.asset_id  as es_asset_id
        , wo.billing_type_id
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    join ES_WAREHOUSE.PUBLIC.MARKETS m
        on wo.BRANCH_ID = m.MARKET_ID
    join ES_WAREHOUSE.PUBLIC.COMPANIES c
        on m.COMPANY_ID = c.COMPANY_ID
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on wo.ASSET_ID = aa.ASSET_ID
    left join post_deadline_time pdt
        on wo.WORK_ORDER_ID = pdt.WORK_ORDER_ID
    left join part_cost_per_work_order_final pcpwof
        on wo.WORK_ORDER_ID = pcpwof.work_order_id
    left join es_owned es
        on es.asset_id = aa.asset_id
            and wo.date_completed < es.DATE_END
            and wo.date_completed >= es.date_start
    where
        wo.WORK_ORDER_ID not in (                                       --Non-warranty
            select WORK_ORDER_ID
            from ANALYTICS.WARRANTIES.WARRANTY_ACCRUAL)
        --and wo.billing_type_id = 2                                    --Customer Damaged, We don't care if these are customer billed. Just that it is not warranty
        and wo.DATE_CREATED::date <= current_date                        --Created and Completed before the end of the month
        and wo.ARCHIVED_DATE is null
        and c.COMPANY_ID in (                                           --ES did the work
            SELECT COMPANY_ID
            FROM ES_WAREHOUSE.public.companies
            WHERE name REGEXP 'IES\\d+ .*'
                OR COMPANY_ID = 420           -- Demo Units
                OR COMPANY_ID = 62875         -- ES Owned special events - still owned by us
                OR COMPANY_ID IN (1854, 1855) -- ES Owned
                OR COMPANY_ID = 61036)
        and es.asset_id is NULL                                         --We do not own the asset
        and (billed_date is NULL or billed_date > current_date)          --A bill has not been sent or was sent out after the end of the month
        and completed_date <= current_date                             --Created and Completed before the end of the month
        and aa.asset_id not in (                                        --it is not in the payout program
            select ppa.asset_ID
            from ES_WAREHOUSE.PUBLIC.PAYOUT_PROGRAM_ASSIGNMENTS ppa
            where ppa.PAYOUT_PROGRAM_ID in (
                11 --Advantage Max Premium (Indirectly Billed maintenance agreement)
                , 8 --Flex 50 (Paid maintenance)
                , 38 --Crockett Partners II (Indirectly Billed maintenance agreement)
                , 12 -- Flex 55 (Paid maintenance)
                )
            AND CURRENT_TIMESTAMP < COALESCE(ppa.END_DATE, '2099-12-31')
        )
    group by aa.OWNER
        , aa.COMPANY_ID
        , aa.asset_id
        , aa.MAKE
        , aa.MODEL
        , aa.YEAR
        , wo.WORK_ORDER_ID
        , wo.INVOICE_ID
        , wo.invoice_number
        , pcpwof.part_cost
        , wo.DATE_CREATED
        , wo.DATE_COMPLETED
        , wo.DATE_BILLED
        , es.asset_id
        , wo.billing_type_id
)

, final_part_1 as (
    select d.OWNER as asset_owner
        , d.company_id as asset_owner_id
        , d.asset_id
        , iff(es_asset_id is not NULL or own_asset_id is not NULL , true, false) ES_OWNED_OR_MAINTAINED
        , d.WORK_ORDER_ID
        , d.invoice_id
        , d.invoice_number
        , d.the_part_cost
        , d.reg_hours
        , d.ot_hours
        , d.total_time * 125 as hours_expense
        , hours_expense + the_part_cost as total_cost
        , d.created_date    as wo_created
        , d.completed_date  as wo_completed
        , d.billed_date
        , iff(es_asset_id is not NULL, true, false) as es_owned
        , iff(payout_program_id = 8, true, false) as flex_50
        , iff(payout_program_id = 12, true, false) as flex_55
        , iff(payout_program_id = 11, true, false) as ad_max_prem
        , iff(payout_program_id = 38, true, false) as crockett_partners_ii
        , 125 as estimated_labor_rate
    from draft_part_1 d
    where total_time + the_part_cost != 0
    order by d.completed_date asc
)

, final_part_2 as (
    select d.OWNER as asset_owner
        , d.company_id as asset_owner_id
        , d.asset_id
        , false as ES_OWNED_OR_MAINTAINED
        , d.WORK_ORDER_ID
        , d.invoice_id
        , d.invoice_number
        , d.the_part_cost
        , d.reg_hours
        , d.ot_hours
        , d.total_time * 105 as hours_expense
        , hours_expense + the_part_cost as total_cost
        , d.created_date    as wo_created
        , d.completed_date  as wo_completed
        , d.billed_date
        , false as es_owned
        , false as flex_50
        , false as flex_55
        , false as ad_max_prem
        , false as crockett_partners_ii
        , 105 as estimated_labor_rate
    from draft_part_2 d
    where total_time + the_part_cost != 0
    order by d.completed_date asc
)

, test as (
SELECT wo.*
FROM final_part_1 wo

UNION

SELECT wo.*
FROM final_part_2 wo
)

, all_own_program as (
    SELECT DISTINCT AA.asset_id, vpp.payout_program_name
        FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
        JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
            ON VPP.ASSET_ID = AA.ASSET_ID
        WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
            AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31')
)

--, test2 as (
select asset_owner
    , asset_owner_id
    , t.asset_id
    , aop.payout_program_name
    , ES_OWNED_OR_MAINTAINED
    , t.WORK_ORDER_ID
    , t.the_part_cost
    , t.reg_hours
    , t.ot_hours
    , t.hours_expense
    , t.total_cost
    , t.wo_created
    , t.wo_completed
    , t.estimated_labor_rate
    , wo.branch_id
    , m.name as market_name
    , listagg( distinct concat(cd.first_name, ' ', cd.last_name), ' / ') as GM
    , listagg( distinct cd.employee_title, ' / ') as title
    , listagg( distinct cd.work_email, ' / ') as email
from test t
join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    on wo.work_order_id = t.work_order_id
join ES_WAREHOUSE.PUBLIC.MARKETS m
    on m.market_id = wo.branch_id
join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
    on cd.market_id = m.market_id
left join all_own_program aop
    on aop.asset_id = t.asset_id
where cd.employee_title ilike 'general manager%' and cd.date_terminated is null
group by asset_owner
        , asset_owner_id
        , t.asset_id
        , ES_OWNED_OR_MAINTAINED
        , t.WORK_ORDER_ID
        , t.the_part_cost
        , t.reg_hours
        , t.ot_hours
        , t.hours_expense
        , t.total_cost
        , t.wo_created
        , t.wo_completed
        , t.estimated_labor_rate
        , wo.branch_id
        , aop.payout_program_name
        , market_name;;
  }

  dimension: asset_owner {
    type: string
    sql: ${TABLE}.asset_owner ;;
  }

  dimension: asset_owner_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_owner_id ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id;;
  }

  dimension: es_owned_or_maintained {
    type: yesno
    sql: ${TABLE}.ES_OWNED_OR_MAINTAINED;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.WORK_ORDER_ID;;
  }

  dimension: the_part_cost {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.the_part_cost;;
  }

  dimension: reg_hours {
    type: number
    sql: ${TABLE}.reg_hours;;
  }

  dimension: ot_hours {
    type: number
    sql: ${TABLE}.ot_hours;;
  }

  dimension: hours_expense {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.hours_expense;;
  }

  dimension: total_cost {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_cost ;;
  }

  dimension: wo_created {
    type: date
    sql: ${TABLE}.wo_created ;;
  }

  dimension: wo_completed {
    type: date
    sql: ${TABLE}.wo_completed ;;
  }

  dimension: estimated_labor_rate {
    type: number
    sql: ${TABLE}.estimated_labor_rate;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}.branch_id;;
  }

  dimension: payout_program_name {
    type: string
    sql: ${TABLE}.payout_program_name ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: GM {
    type: string
    sql: ${TABLE}.gm ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}.title;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email;;
  }
}
