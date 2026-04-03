view: cost_to_maintain {
  derived_table: {
     sql:
--SET BEG_OF_YR = '2022-01-01';
--SET END_OF_YR = '2024-03-31'; -- "trusted" date range
with classes as (select aa.asset_id
                      , avg(oec) over (partition by equipment_class_id) as class_oec -- we don't want to look at classes with an avg OEC under a certain $$
                 from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
--                           join analytics.public.ES_COMPANIES ec --filtering to ES assets
--                                on aa.COMPANY_ID = ec.COMPANY_ID
                 where oec is not null
                   and oec > 0
                   and aa.ASSET_TYPE_ID = 1
                     qualify class_oec >= 10000)
   , rental_assets as (select distinct hu.asset_id
                                     , aa.make
                                     , aa.model
                                     , aa.class
                                     , aa.company_id
                                     , hu.FIRST_RENTAL

                                     , min(dte) over (partition by hu.asset_id)                      asset_entry
                                     , max(dte) over (partition by hu.asset_id)                      asset_exit
                                     --, --starting_hours at first rental.
                                     --, datediff(year, HU.FIRST_RENTAL, DTE)                              asset_age_rev
                                     , sum(hu.DAY_RATE) over (partition by hu.ASSET_ID)           as revenue
                                     , count(*) over (partition by HU.ASSET_ID)                   as asset_days_in_fleet
                                     , (asset_days_in_fleet / 365)                                as year_portion
                                     , aa.oec * year_portion                                      as oec_portion
                                     , sum(hu.DAY_RATE) over (partition by aa.EQUIPMENT_CLASS_ID) as class_revenue
                                     , count(*) over (partition by aa.EQUIPMENT_CLASS_ID)         as class_days_in_fleet
                                     , class_revenue / class_days_in_fleet                        as class_daily_revenue
                       from ANALYTICS.PUBLIC.HISTORICAL_UTILIZATION HU
                                left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
                                          on hu.ASSET_ID = aa.ASSET_ID
                                join classes c --filtering to classes 10K+
                                     on hu.ASSET_ID = c.ASSET_ID
                                join es_warehouse.scd.scd_asset_rsp r
                                     on hu.asset_id = r.asset_id
                                         and hu.dte >= r.date_start and hu.dte < r.date_end
                       where DTE between '2022-01-01' and '2024-03-31'
                         and r.rental_branch_id is not null --this is in place of in_rental_fleet
)
   , rental_rev as (select r.*, zeroifnull(he.hours) - zeroifnull(hs.hours) hours_consumed
                    from rental_assets r
                             left join ES_WAREHOUSE.SCD.SCD_ASSET_HOURS hs
                                       on hs.asset_id = r.asset_id
                                           and r.asset_entry::timestamp >= hs.date_start and
                                          r.asset_entry::timestamp <
                                          hs.date_end --this would get the hours at first rental
                             left join ES_WAREHOUSE.SCD.SCD_ASSET_HOURS he
                                       on he.asset_id = r.asset_id
                                           and r.asset_exit >= he.date_start and
                                          r.asset_exit::timestamp < he.date_end)
   , wac_prep as ( -- suppressing overridden wac snapshots based on date_applied values
    select *
    from es_warehouse.inventory.weighted_average_cost_snapshots wacs
    where date_applied::date < '2024-01-03'
      and date_applied::date > '2023-12-09'
        qualify
                    row_number() over (
                        partition by wacs.inventory_location_id, wacs.product_id, date_applied
                        order by wacs.date_created desc)
                    = 1
                and
                    min(wacs.DATE_APPLIED) over (partition by wacs.PRODUCT_ID, wacs.INVENTORY_LOCATION_ID)
                        = wacs.DATE_APPLIED
    order by product_id, INVENTORY_LOCATION_ID, date_applied desc)
   , wac_test as (select distinct wp.product_id
                                , k.MASTER_PART_ID
                                , p.DUPLICATE_OF_ID
                                , avg(wp.WEIGHTED_AVERAGE_COST) over (partition by k.master_part_id) as avg_cost_master_cw
                                , avg(wp.WEIGHTED_AVERAGE_COST) over (partition by wp.product_id)    as avg_cost_part_cw --pretty sure i can take this out
                  from wac_prep wp
                           join ANALYTICS.PARTS_INVENTORY.PARTS k -- superceded loop logic
                                on wp.PRODUCT_ID = k.PART_ID
                           join ES_WAREHOUSE.INVENTORY.PARTS p
                                on wp.PRODUCT_ID = p.PART_ID
                  where wp.WEIGHTED_AVERAGE_COST not in (0, 0.01))
   , parts_per_WO AS (SELECT IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID)                              as work_order_id
                           , t.DATE_COMPLETED::date                                                        as date_completed
                           , k.MASTER_PART_ID                                                              as part_id
                           , wt.PRODUCT_ID
                           , sum(IFF(transaction_type_id = 7, ti.quantity_received, 0 -
                                                                                    ti.quantity_received)) AS final_qty
                           , coalesce(wt.avg_cost_master_cw, wt2.avg_cost_part_cw, 0)                      as ac --pretty sure this is unnecessary
                           , final_qty * ac                                                                   parts_cost
                      FROM ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
                               LEFT JOIN ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
                                         ON t.TRANSACTION_ID = ti.TRANSACTION_ID
                               left join ANALYTICS.PARTS_INVENTORY.PARTS k -- superceded loop logic
                                         on ti.PART_ID = k.PART_ID
                               left join ANALYTICS.PARTS_INVENTORY.TELEMATICS_PART_IDS tpi
                                         on ti.PART_ID = tpi.PART_ID
                               left join ES_WAREHOUSE.INVENTORY.PROVIDERS pr
                                         on k.PROVIDER_ID = pr.PROVIDER_ID
                               join analytics.public.ES_COMPANIES c
                                    on pr.company_id = c.COMPANY_ID
                               left join wac_test wt
                                         on k.MASTER_PART_ID = wt.PRODUCT_ID
                               left join wac_test wt2
                                         on ti.part_id = wt2.PRODUCT_ID
                      WHERE TRANSACTION_TYPE_ID IN (7, 9)
                        and t.DATE_CANCELLED is null
                        and t.DATE_COMPLETED::date between  '2022-01-01' and '2024-03-31'
                        and tpi.PART_ID is null -- suppress telematics parts
                      group by WORK_ORDER_ID, t.date_completed::date, k.MASTER_PART_ID, wt.PRODUCT_ID, ac
    --having final_qty > 0
)
   , wo_pop
    as ( --this is for joining to avoid having to refilter multiple ctes. population for the expected hours calc, the pop that its applied to will be smaller
        select wo.*,
               class,
               make,
               model,
               iff(woct.work_order_id is not null or ot.ORIGINATOR_TYPE_ID = 3, 'Yes', 'No') exclude_mtbf
        from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo --change this to specific fields at some point
                 join ES_WAREHOUSE.PUBLIC.MARKETS m
                      on wo.BRANCH_ID = m.MARKET_ID
                 join ANALYTICS.PUBLIC.ES_COMPANIES c
                      on m.COMPANY_ID = c.COMPANY_ID
                 join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
                      on wo.asset_id = aa.asset_id
                 left join es_warehouse.WORK_ORDERS.WORK_ORDER_ORIGINATORS woo
                           on wo.WORK_ORDER_ID = woo.WORK_ORDER_ID
                 left join es_warehouse.WORK_ORDERS.ORIGINATOR_TYPES ot
                           on woo.ORIGINATOR_TYPE_ID = ot.ORIGINATOR_TYPE_ID
                 LEFT JOIN (SELECT DISTINCT work_order_id -- this is customer damage
                            FROM ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS
                            WHERE COMPANY_TAG_ID IN (23)) woct
                           ON wo.WORK_ORDER_ID = woct.WORK_ORDER_ID
                 LEFT JOIN (SELECT DISTINCT work_order_id -- this is telematics and customer error
                            FROM ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS
                            WHERE COMPANY_TAG_ID IN (41, 7624, 54, 985, 980, 888, 393, 486, 400, 401, 1396, 1209)) wott
                           ON wo.WORK_ORDER_ID = wott.WORK_ORDER_ID

        where                                     --wo.DATE_BILLED between $BEG_OF_YR and $END_OF_YR -- taking out for the BE comparison
          -- and wo.date_completed is not null -- taking out for BE comparison
            wo.ARCHIVED_DATE is null              --taking out for the BE comparison
          and wo.ASSET_ID is not null
          and aa.FIRST_RENTAL < wo.DATE_COMPLETED --getting rid of MMRs
          and WORK_ORDER_TYPE_ID = 1              --general work orders, no inspections --taking out for the BE comparison
          and wott.work_order_id is null --taking out telematics and customer error work orders
    )
   , mean_time_between as (select work_order_id
                                , asset_id
                                , class
                                , make
                                , model
                                , date_completed                                                          last_repair
                                , lead(date_created) over (partition by asset_id order by date_completed) next_repair
                                , datediff(day, last_repair, next_repair)                                 time_between
                           from wo_pop wo
                           where wo.exclude_mtbf = 'No'
                             and ((wo.DATE_created between  '2022-01-01' and '2024-03-31') or
                                  (wo.DATE_completed between  '2022-01-01' and '2024-03-31')) --is this right?
                               qualify next_repair is not null
                           order by asset_id, date_created)
   , mtbf as (select asset_id
                   , avg(time_between) mtbf
              from mean_time_between
              group by asset_id)
   , wo_parts as (select --wo.WORK_ORDER_ID,
                      wo.asset_id
                       -- , datediff(years, aa.FIRST_RENTAL, p.date_completed) asset_age_parts --changed to this date for BE
                       , sum(final_qty)  as wo_part_qty
                       , sum(parts_cost) as wo_part_cost
                  from parts_per_WO p
                           join wo_pop wo
                                on p.work_order_id = wo.WORK_ORDER_ID
                           join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
                                on wo.asset_id = aa.asset_id
                  group by --wo.work_order_id,
                           wo.asset_id)
   , wo_hours as (select --te.work_order_id,
                      wo.ASSET_ID
                       --, datediff(years, aa.FIRST_RENTAL, te.END_DATE)                     asset_age_labor --will this align with BE? or are they using pay dates?
                       , sum(zeroifnull(te.regular_hours) + zeroifnull(te.overtime_hours)) total_hours
                  from ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRIES te
                           join wo_pop wo
                                on te.work_order_id = wo.WORK_ORDER_ID
                           join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
                                on wo.asset_id = aa.asset_id
                  where te.EVENT_TYPE_ID = 1 -- ON DUTY
                    and te.APPROVAL_STATUS like 'Approved'
                    and te.work_order_id is not null
                    and datediff('hour'
                            , te.START_DATE
                            , te.END_DATE)
                      <= 12                  --??
                    and te.END_DATE between  '2022-01-01' and '2024-03-31'
                  group by --te.work_order_id,
                           wo.asset_id)
   , customer_damage_recovery as ( --may need to add asset ownership scd
    select sum(amount) customer_rev
         , v.asset_id
         --, datediff(year, aa.FIRST_RENTAL, i.billing_approved_date) asset_age_invoice
    from ANALYTICS.PUBLIC.V_LINE_ITEMS v
             join ES_WAREHOUSE.PUBLIC.INVOICES i
                  on v.invoice_id = i.invoice_id
             join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
                  on v.asset_id = aa.asset_id
             left join analytics.public.es_companies c
                       on i.company_id = c.company_id
    where line_item_type_id in (25, 26)
      and i.billing_approved_date is not null
      and c.company_id is null --getting rid of internal bills, this will still get OWN bills
      and i.BILLING_APPROVED_DATE between  '2022-01-01' and '2024-03-31'
    group by v.asset_id)
   , invoice_amt as (select li.invoice_id,
                            max(branch_id)       as branch_id,
                            sum(amount)          as total_amt,
                            max(li.date_created) as date_created
                     from ES_WAREHOUSE.PUBLIC.line_items li
                              JOIN ES_Warehouse.PUBLIC.Invoices i
                                   ON li.invoice_id = i.invoice_id
                              left join analytics.public.es_companies c
                                        on i.company_id = c.company_id
                     where line_item_type_id in (22, 23)
                       AND c.company_id is null --getting rid of internal bills
                     group by li.invoice_id)
   , invoice_asset_info as (select invoice_id, --may need to add asset ownership scd here
                                   max(asset_id) as asset_id
                            from ES_WAREHOUSE.PUBLIC.line_items li
                            where asset_id is not null
                            group by invoice_id)
   , credit_payments as (select p.invoice_id
                              , sum(amount)   as credit_amt
                              , DENIED_AMOUNT as denied_amt
                         from ES_WAREHOUSE.PUBLIC.payment_applications p
                                  LEFT JOIN (SELECT SUM(PAY_APPLY.AMOUNT) AS DENIED_AMOUNT
                                                  , ADMINV.INVOICE_NO
                                                  , ADMINV.INVOICE_ID
                                             FROM ES_WAREHOUSE.PUBLIC.PAYMENTS ARPAY
                                                      LEFT JOIN ES_WAREHOUSE.PUBLIC.BANK_ACCOUNT_ERP_REFS BANK_ERP
                                                                ON ARPAY.BANK_ACCOUNT_ID = BANK_ERP.BANK_ACCOUNT_ID
                                                      LEFT JOIN ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS PAY_APPLY
                                                                ON ARPAY.PAYMENT_ID = PAY_APPLY.PAYMENT_ID
                                                      LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES ADMINV
                                                                ON PAY_APPLY.INVOICE_ID = ADMINV.INVOICE_ID
                                                      left join analytics.public.es_companies c
                                                                on adminv.company_id = c.company_id
                                                      LEFT JOIN (SELECT DISTINCT SUBSTR(APR.DOCNUMBER, 12, 100) AS PAYMENT_ID
                                                                 FROM ANALYTICS.INTACCT.APRECORD APR
                                                                 WHERE APR.RECORDTYPE = 'apbill'
                                                                   AND APR.DOCNUMBER LIKE ('WTY_PMT_ID:%')) PMT_ID_SYNCED
                                                                ON TO_VARCHAR(ARPAY.PAYMENT_ID) = PMT_ID_SYNCED.PAYMENT_ID
                                             WHERE BANK_ERP.INTACCT_UNDEPFUNDSACCT IN ('5316', '1212')
                                               AND ARPAY.STATUS != 1    --PAYMENT NOT REVERSED
                                               AND c.COMPANY_ID is null --internal
                                             GROUP BY ADMINV.INVOICE_NO
                                                    , ADMINV.INVOICE_ID) d
                                            ON p.invoice_id = d.invoice_id
                         GROUP BY p.INVOICE_ID
                                , d.denied_amount)
   , credit_memo as (SELECT ARH.CUSTOMERID  AS CUSTOMER_ID,
                            ARH.DOCNUMBER   AS INVOICE_NO,
                            I.INVOICE_ID,
                            SUM(ARD.AMOUNT) AS CM_AMOUNT
                     FROM ANALYTICS.INTACCT.ARRECORD ARH
                              LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD
                                        ON ARH.RECORDNO = ARD.RECORDKEY
                              LEFT JOIN ES_WAREHOUSE.Public.Invoices I
                                        ON ARH.DOCNUMBER = I.INVOICE_NO
                              left join analytics.public.es_companies c
                                        on i.company_id = c.company_id
                     WHERE ARH.RECORDTYPE = 'aradjustment'
                       AND ARD.AMOUNT != 0
                       AND c.company_id is null --internal bills
                     GROUP BY ARH.CUSTOMERID
                            , ARH.DOCNUMBER
                            , I.Invoice_ID)
   , invoice_credited as (select invoice_id, invoice_no, billing_approved_date, paid
                          from ES_WAREHOUSE.PUBLIC.invoices i
                          where billing_approved_date is not null)
   , warranty_summary_draft as (select ia.invoice_id,
                                       ia.branch_id,
                                       ia.date_created,
                                       ai.asset_id,
                                       ia.total_amt,
                                       CASE
                                           when ic.paid = 'Yes' THEN ia.total_amt - zeroIFNULL(cp.denied_amt) -
                                                                     zeroIFNULL(ABS(cm.cm_amount))
                                           ELSE 0
                                           END AS Paid_amt,
                                       cp.credit_amt,
                                       ic.invoice_no,
                                       ic.paid,
                                       ic.billing_approved_date
                                from invoice_amt ia
                                         left join invoice_asset_info ai
                                                   on ia.invoice_id = ai.invoice_id
                                         left join credit_payments cp on ia.invoice_id = cp.invoice_id
                                         left join invoice_credited ic on ia.invoice_id = ic.invoice_id
                                         left join credit_memo cm on ia.invoice_id = cm.invoice_id
                                where ic.BILLING_APPROVED_DATE between  '2022-01-01' and '2024-03-31')
   , asset_warranty_payments_summary as (select wsd.asset_id
                                              , sum(wsd.paid_amt) warranty_rev
                                              --, datediff(year, aa.FIRST_RENTAL, wsd.billing_approved_date) as asset_age_warranty --  does not include make ready
                                         from warranty_summary_draft wsd
                                                  join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
                                                       on wsd.asset_id = aa.ASSET_ID
                                         where wsd.paid_amt > 0
                                         group by wsd.asset_id)
  select rr.asset_id
                          , rr.make
                          , rr.model
                          , rr.class
                          --  , rr.asset_age_rev   asset_age
                          , rr.revenue
                          , rr.year_portion
                          , rr.oec_portion
                          , wp.warranty_rev
                          , cp.customer_rev
                          , p.wo_part_cost           parts_cost
                          , h.total_hours * 45       labor_cost
                          , hours_consumed
                          , mtbf
                          , zeroifnull(parts_cost) + zeroifnull(labor_cost) - zeroifnull(warranty_rev) -
                            zeroifnull(customer_rev) cost_to_own
--, cost_to_own/hours_consumed cost_per_hour
                     from rental_rev rr
                              left join asset_warranty_payments_summary wp
                                        on rr.asset_id = wp.asset_id
                         --and rr.asset_age_rev = wp.asset_age_warranty
                              left join customer_damage_recovery cp
                                        on rr.ASSET_ID = cp.ASSET_ID
                         -- and rr.asset_age_rev = cp.asset_age_invoice
                              left join wo_hours h
                                        on rr.asset_id = h.ASSET_ID
                         -- and rr.asset_age_rev = h.asset_age_labor
                              left join wo_parts p
                                        on rr.ASSET_ID = p.asset_id
                         -- and rr.asset_age_rev = p.asset_age_parts
                              left join mtbf f
                                        on rr.asset_id = f.asset_id
                                        where hours_consumed>0 -- only wanting to see cost on rented assets
--where rr.asset_id = 178155
 ;;
  }
 dimension: asset_id {
   type: string
  sql: ${TABLE}.asset_id ;;
 }
  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}.class ;;
  }

  measure: distinct_asset_count {
    type: count_distinct
    sql: ${TABLE}.asset_id ;;
  }

  measure: assets_years { #this is for scaling to per asset per year cost
    type: sum
    sql: ${TABLE}.year_portion ;;
  }

  measure: oec_years {
    type: sum
    sql: ${TABLE}.oec_portion ;;
  }

  measure: mean_time_between_failures {
    type: average
    sql: ${TABLE}.mtbf ;;
  }

  measure: rental_rev {
    type: sum
    sql: ${TABLE}.revenue ;;
  }

  measure: warranty_rev {
    type: sum
    sql: ${TABLE}.warranty_rev ;;
  }

  measure: damage_rev {
    type: sum
    sql: ${TABLE}.customer_rev ;;
  }

  measure: parts_exp {
    type: sum
    sql: ${TABLE}.parts_cost ;;
  }

  measure: labor_exp {
    type: sum
    sql: ${TABLE}.labor_cost ;;
  }

  measure: hours_used {
    type: sum
    sql: ${TABLE}.hours_consumed ;;
  }

  measure: cost_to_maintain {
    type: number
    sql: zeroifnull(${parts_exp}) + zeroifnull(${labor_exp}) - zeroifnull(${warranty_rev}) -
           zeroifnull(${damage_rev}) ;;
  }

  measure: cost_per_usage_hour {
    type: number
    sql: ${cost_to_maintain}/coalesce(${hours_used},1) ;;
  }

  measure: weighted_cost {
    type: number
    sql: ${cost_to_maintain}/${assets_years} ;;
  }

 }
