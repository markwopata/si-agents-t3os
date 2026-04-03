view: warranty_work_orders_and_claims {
  derived_table: {
    sql:
with market_oec as (
    select dd.month
        , coalesce(rsp.rental_branch_id, isp.inventory_branch_id) as market_id
        , a.asset_equipment_make as make
        , sum(zeroifnull(a.asset_current_oec)) as oec
    from (select distinct date_month_start as month from FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT where dt_date between dateadd(month, -24, current_date) and current_date) dd
    join ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY isp
        on dd.month between isp.date_start and isp.date_end
    left join FLEET_OPTIMIZATION.GOLD.DIM_ASSET_RSP_PIT rsp
        on rsp.asset_id = isp.asset_id
            and dd.month between rsp.start_window and rsp.end_window
    join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
        on a.asset_id = isp.asset_id
    group by 1,2,3
)

, asset_hour_limits as ( --All assets over on hours
    select aa.asset_id
        , case
            --Allmand Light Towers/Heaters (1000 hours/1 Year)
            when aa.model in ('350 Night-Lite', 'MAXI-LITE II', 'NIGHT-LITE', 'Night-Lite Pro II', 'NLPROii-LD', 'NLV3GR', 'GR-Series') then 1000
            --Allmand Generators
            when aa.model in ('MA185', 'Maxi-Power 150', 'MP25', 'MP65') or aa.make in ('TAKEUCHI' , 'JOHN DEERE' , 'JCB') then 2000
            --Sany Telehandlers
            when aa.model in ('STH1256', 'STH1056', 'STH844', 'STH1056A') or aa.make in ('BOBCAT' , 'ATLAS COPCO') then 3000
            --Genie and JLG ultras, sany excavators and wheel loaders
            when aa.model in ('SX-125 XC', 'S-125', 'SX-150', 'SX-180', '1200SJP', '1350SJP', '1500SJ', '1850SJ', 'SW405K', 'SY135C', 'SY155', 'SY155U', 'SY16', 'SY215', 'SY225C', 'SY235C', 'SY26', 'SY265C LC', 'SY35U', 'SY365C LC', 'SY50', 'SY500', 'SY60C', 'SY75C', 'SY95C') then 5000
            else 1000000000 end as hour_limits
        , min(scd.date_start)::DATE as over_hour_limit
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    join ES_WAREHOUSE.SCD.SCD_ASSET_HOURS scd
        on scd.asset_id = aa.asset_id
    -- join warrantable_assets wa
    --     on wa.asset_id = aa.asset_id
    where hour_limits < scd.hours
    group by aa.asset_id, hour_limits
)

, warranty_oec as (
    select a.asset_id
        , a.asset_equipment_make make
        , a.asset_current_oec
        , case
            when a.asset_oem_delivery_date::DATE <> '0001-01-01' then a.asset_oem_delivery_date::DATE
            when add.delivery_date::DATE is not null then add.delivery_date::DATE
            when wo.first_wo::DATE is not null then wo.first_wo::DATE
            when a.asset_purchase_date::DATE <> '0001-01-01' then a.asset_purchase_date::DATE
          else null end as warranty_start_date
        , max(wi.time_value::NUMBER) warranty_length
        , case --This is written like this because on the 08/06/25 the normal dateadd stopped working. looked to be something with incompatible datatypes
            when a.asset_oem_delivery_date::DATE <> '0001-01-01' then dateadd(month, warranty_length,a.asset_oem_delivery_date::DATE)
            when add.delivery_date::DATE is not null then dateadd(month, warranty_length, add.delivery_date::DATE)
            when wo.first_wo::DATE is not null then dateadd(month, warranty_length, wo.first_wo::DATE)
            when a.asset_purchase_date::DATE <> '0001-01-01' then dateadd(month, warranty_length, a.asset_purchase_date::DATE)
          else null end as warranty_end_date
    from FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
    join ES_WAREHOUSE.PUBLIC.ASSET_WARRANTY_XREF x
        on x.asset_id = a.asset_id
            and x.date_deleted is null
    join ANALYTICS.WARRANTIES.REVIEWED_WARRANTY_ITEMS rwi
        on rwi.warranty_id = x.warranty_id
            and rwi.is_warrantable
    join ES_WAREHOUSE.PUBLIC.WARRANTY_ITEMS wi
        on wi.warranty_item_id = rwi.warranty_item_id
            AND wi.DATE_DELETED is null --previous table should be only active but just in case something gets deleted later
            AND (TIME_UNIT_ID is null or TIME_UNIT_ID = 20)
    left join ANALYTICS.PARTS_INVENTORY.ASSET_DELIVERY_DATE add
        on add.asset_id = a.asset_id
    left join (
            select asset_id, min(date_created::DATE) as first_wo
            from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS
            where archived_date is null
            group by 1) wo
        on wo.asset_id = a.asset_id
    left join asset_hour_limits ohl
        on ohl.asset_id = a.asset_id
    group by 1,2,3,a.asset_oem_delivery_date, add.delivery_date, wo.first_wo, a.asset_purchase_date, warranty_start_date, ohl.over_hour_limit
    -- having current_date between warranty_start_date and warranty_end_date
)

, month_market_make_oec as (
    select dd.month
        , market_id
        , woec.make
        , sum(zeroifnull(wo.work_orders_completed)) as work_orders_completed
        , sum(zeroifnull(woec.asset_current_oec)) as warranty_oec
    from (select distinct date_month_start as month from FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT where dt_date between '2019-01-01' and current_date) dd
    join warranty_oec woec
        on dd.month between woec.warranty_start_date and woec.warranty_end_date
    left join FLEET_OPTIMIZATION.GOLD.DIM_ASSET_RSP_PIT rsp
        on rsp.asset_id = woec.asset_id
            and dd.month between rsp.start_window and rsp.end_window
    left join ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY isp
        on isp.asset_id = woec.asset_id
            and dd.month between isp.date_start and isp.date_end
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
        on m.market_id = coalesce(rsp.rental_branch_id, isp.inventory_branch_id)
    left join (
            select date_trunc(month, dateadd(day, 15, wo.date_completed)) as month
                , asset_id
                , count(work_order_id) work_orders_completed
            from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
            group by 1,2 ) wo
        on wo.asset_id = woec.asset_id
            and wo.month = dd.month
    group by 1,2,3
)

, warranty_revenue as (
    select dd.date_month_start as month
        , market_region_name as region
        , market_district as district
        , market_id
        , market_name as market
        -- , u.user_full_name as invoice_creator --Might add in later, we'll see if they want it
        , a.asset_equipment_make make
        , sum(w.warranty_credits_pending_amount + w.warranty_credits_paid_amount + w.warranty_credits_denied_amount) as claim_total
        , datediff(day, dateadd(day, -1, date_month_start), date_month_end) as days_in_month
        , (claim_total / days_in_month) * 365 as annualized_claims
    from FLEET_OPTIMIZATION.GOLD.FACT_WARRANTY_CREDITS w
    join FLEET_OPTIMIZATION.GOLD.DIM_INVOICES_FLEET_OPT i
        on i.invoice_key = w.warranty_credits_invoice_key
            and i.invoice_credit_note_indicates_error = false
            and i.invoice_billing_approved
    join FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT dd
        on dd.dt_key = i.invoice_billing_approved_date_key
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
        on m.market_key = w.warranty_credits_market_key
    join FLEET_OPTIMIZATION.GOLD.DIM_USERS_FLEET_OPT u
        on u.user_key = i.invoice_creator_user_key
    join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
        on a.asset_key = w.warranty_credits_asset_key
    where dt_date between dateadd(month, -24, current_date) and current_date
    group by 1,2,3,4,5,6,8
)

, prep as (
    select coalesce(dd.month, wr.month) as month
        , coalesce(mmmo.market_id, wr.market_id) as market_id
        , coalesce(mmmo.make, wr.make) as make
        , zeroifnull(work_orders_completed) as work_orders_completed
        , zeroifnull(warranty_oec) as warranty_oec
        , zeroifnull(wr.claim_total) as claim_total
        , zeroifnull(wr.annualized_claims) as annualized_claims
    from (select distinct date_month_start as month from FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT where dt_date between dateadd(month, -24, current_date) and current_date) dd
    left join month_market_make_oec mmmo
        on mmmo.month = dd.month
    full outer join warranty_revenue wr
        on wr.market_id = mmmo.market_id
            and wr.month = dd.month
            and wr.make = mmmo.make
)

, final_prep as (
    select dd.month
        , dd.month_name
        , m.market_region_name  as region
        , m.market_district  as district
        , m.market_id
        , m.market_name as market
        , p.make as make
        , zeroifnull(mo.oec) as branch_oec --this is likely not complete at this time
        , zeroifnull(p.work_orders_completed) as potential_warranty_work_orders_completed
        , zeroifnull(p.warranty_oec) as warranty_oec
        , zeroifnull(p.claim_total) as warranty_claims
        , zeroifnull(p.annualized_claims) as annualized_claims
    from (select distinct date_month_start as month, dt_month_name as month_name from FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT where dt_date between dateadd(month, -24, current_date) and current_date) dd
    full outer join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
    join FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT c
        on c.company_id = m.market_company_id
            and c.company_is_equipmentshare_company
    left join prep p
        on p.month = dd.month
            and p.market_id = m.market_id
    left join market_oec mo --this is likely not complete at this time, needs to be a full outer join but that would require further testing
        on mo.month = dd.month
            and mo.market_id = m.market_id
            and p.make = mo.make
)

, bottom_markets as (
    select top {% parameter max_rank %}
        market_id, market
        , round((((sum(zeroifnull(warranty_oec)) * 0.02) - sum(zeroifnull(annualized_claims))) /  12), 2) as estimated_under_goal
        , TRUE as bottom_branches
    from final_prep fp
    where date_trunc(year, fp.month) = date_trunc(year, current_date)
      and fp.region ilike concat('%', {% parameter region_name_param %}, '%')
    group by 1,2
    order by estimated_under_goal desc
)

, actual_final as (
select month
    , month_name
    , region
    , district
    , fp.market_id
    , fp.market
    , make
    , branch_oec --this is likely not complete at this time
    , potential_warranty_work_orders_completed
    , warranty_oec
    , warranty_claims
    , annualized_claims
    , coalesce(bm.bottom_branches, FALSE) as bottom_market
from final_prep fp
left join bottom_markets bm
    on fp.market_id = bm.market_id
)

, market_performance as (
    select distinct market_id, bottom_market from actual_final
)

-- beginning of custom SQL view 1
, modern_reviews as (
    select wr.work_order_id
        , du.user_full_name as reviewed_by
        , wr.review_date::DATE as review_date
        , i.invoice_id
        , wr.claim_number
        , warranty_state
        , m.market_region_name as region
        , m.market_district as district
        , b.branch_id
        , m.market_name as market
        , a1.asset_id as asset_id
        , a1.asset_equipment_make as make
        , wr.pre_file_denial_code
        , wd.denial_reason as claim_denial_reason
        , iff(rc.child_invoice_no is not null, TRUE, FALSE) as is_child_invoice
        , iff(mo.work_order_id is not null, TRUE, FALSE) as is_missed_opp
        , coalesce(wr.note_added, wd.dispute_note) as retool_note_added
    from ANALYTICS.WARRANTIES.WARRANTY_REVIEWS wr
    join FLEET_OPTIMIZATION.GOLD.DIM_USERS_FLEET_OPT du
        on du.user_id = created_by
    left join FLEET_OPTIMIZATION.GOLD.DIM_INVOICES_FLEET_OPT i
        on i.invoice_no = trim(wr.invoice_no)
    left join FLEET_OPTIMIZATION.GOLD.FACT_WARRANTY_CREDITS w
        on w.warranty_credits_invoice_key = i.invoice_key
    left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS b
        on b.work_order_id = wr.work_order_id
    left join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
        on m.market_id = b.branch_id
    left join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a --invoice asset ID
        on a.asset_key = w.warranty_credits_asset_key
    left join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a1 --pulling combined work order and invoice asset info
        on a1.asset_id = coalesce(b.asset_id, a.asset_id)
    left join (select invoice_no, denial_reason, dispute_note from ANALYTICS.WARRANTIES.WARRANTY_DISPUTES where is_current) wd
        on wd.invoice_no = wr.invoice_no
    left join ANALYTICS.WARRANTIES.RETOOL_CLAIMS rc
        on rc.child_invoice_no = trim(wr.invoice_no)
    left join (select distinct work_order_id from ANALYTICS.WARRANTIES.WARRANTY_REVIEWS where warranty_state ilike 'Missed Opp Approved' or pre_file_denial_code ilike 'Q - Warranty Missed Opp Reviewed') mo
        on mo.work_order_id = wr.work_order_id
    where (wr.is_current = true
        and wr.warranty_state in ('Not Warranty'))
        or wr.warranty_state in ('Claim', 'Segmented Claim')
)

, wo_note_invoice as (
    select work_order_id
        , iff(upper(note) ilike '%MANUAL INVOICE #%'
            , replace(upper(note), 'MANUAL INVOICE #', '')
            , replace(upper(note), 'WARRANTY INVOICE #', '')
        )  as invoice_no
        , lead(date_created) over (partition by invoice_no order by date_created asc) next_note_date
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_NOTES
    where note ilike any ('%MANUAL INVOICE #%', 'WARRANTY INVOICE #%' )
    qualify next_note_date is null
)

, wo_note_claim as (
    select work_order_id
        , replace(upper(note), 'WARRANTY CLAIM #', '') as claim_number
        , lead(date_created) over (partition by work_order_id order by date_created asc) next_note_date
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_NOTES
    where note ilike 'Warranty Claim #%'
    qualify next_note_date is null --don't want this to fan. For any that are using the notes we want it to be 1:1
)

, old_denials as (
    select wo.work_order_id
        , iff(note ilike 'Claim was submitted passed the allotted time frame for consideration.'
            , '11'--Reclass for ones created before type 11 existed
            , coalesce(
                        TRIM(STRTOK(STRTOK(NOTE, ':', 2),';',1))
                , trim(left(note, 2)))) as dc
        , wdr.description
        , ROW_NUMBER() OVER(PARTITION BY wo.WORK_ORDER_ID ORDER BY DATE_CREATED DESC) as rank
    FROM es_warehouse.work_orders.work_order_notes wo
    join ANALYTICS.PARTS_INVENTORY.WARRANTY_DENIAL_REASONS wdr
        on wdr.denial_code::STRING = dc
    left join ANALYTICS.WARRANTIES.WARRANTY_REVIEWS wr
        on wr.work_order_id = wo.work_order_id
    where ((Note  like '"Warranty Denial Code:%'
        or Note ilike 'Warranty Denial Code:%' )
        or (note ilike '%1 - Out of Warranty%'
        or note ilike '%2 - Parts Not Returned%'
        or note ilike '%3 - Use of Non-OEM Parts%'
        or note ilike '%4 - Deemed Damage or Abuse%'
        or note ilike '%5 - Not a Warrantable Failure%'
        or note ilike '%6 - Referred to Engine Manufacture%'
        or note ilike '%7 - Repairs Not Authorized%'
        or note ilike '%8 - Parts Tested Good%'
        or note ilike '%9 - Other%'
        or note ilike '%10 - Lack of Maintenance%'
        or note ilike '%11 - Submission Time Expired%'
        or note ilike '%12 - Requested Info Not Provided%'
        or note ilike '%13 - Repair Not Made to OEM Standards%'
        or note ilike '%14 - Duplicate Work Order Created%'
        or note ilike '%15 - Training Opportunity%'
        or note ilike '%16 - Claim Error%'
        or note ilike '%17 - Filed by Vendor%'
        or note ilike '%18 - Dealer Only Repair%'
        or note ilike '%19 - Unfavorable OEM Policy%'
        or note ilike 'Claim was submitted passed the allotted time frame for consideration.'))
        and wr.work_order_id is null
    qualify rank = 1
)

, wo_to_inv as ( --All warranty invoices with an attempt to connect them to a work order
    select coalesce(mr.work_order_id, wo.work_order_id, wni.work_order_id) as work_order_id
        , mr.reviewed_by
        , coalesce(dt.dt_date, mr.review_date) as reference_date
        , i.invoice_id
        , coalesce(mr.claim_number, wnc.claim_number) as claim_number
        , c.company_name as billed_company
        , m.market_region_name as region
        , m.market_district as district
        , m.market_id as branch_id
        , m.market_name as market
        , a1.asset_id as asset_id --invoice asset first then work order
        , a1.asset_equipment_make as make
        , null as pre_file_denial_code --All claims here, no pre file denials
        , coalesce(mr.claim_denial_reason, odc.description) as claim_denial_reason
        , coalesce(mr.is_child_invoice, FALSE) as is_child_invoice
        , coalesce(mr.is_missed_opp, FALSE) as is_missed_opp
        , iff(warranty_state = 'Segmented Claim', TRUE, FALSE) is_leg_of_segmented_claim
        , datediff(day, b.date_completed::DATE, dt.dt_date) as days_to_file
        , u.user_full_name invoice_creator
        , woc.wo_cost as work_order_cost
        , mr.retool_note_added
    from FLEET_OPTIMIZATION.GOLD.DIM_INVOICES_FLEET_OPT i
    join FLEET_OPTIMIZATION.GOLD.FACT_WARRANTY_CREDITS w
        on w.warranty_credits_invoice_key = i.invoice_key
    join FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT c
        on c.company_key = i.invoice_company_key
    join FLEET_OPTIMIZATION.GOLD.DIM_USERS_FLEET_OPT u
        on u.user_key = i.invoice_creator_user_key
    join FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT dt
        on dt.dt_key = i.invoice_billing_approved_date_key
    left join modern_reviews mr
        on mr.invoice_id = i.invoice_id
    left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo --accurate but doesn't account for multi-segments or manually generated
        on wo.invoice_id = i.invoice_id
    left join wo_note_invoice wni
        on trim(wni.invoice_no) = i.invoice_no
    left join wo_note_claim wnc --pre retool claim number
        on wnc.work_order_id = coalesce(wo.work_order_id, wni.work_order_id) --Don't need retool work order id here
    left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS b --pulling work order branch and asset
        on b.work_order_id = coalesce(mr.work_order_id, wo.work_order_id, wni.work_order_id)
    left join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT invoice_market
        on invoice_market.market_key = w.warranty_credits_market_key
    left join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
        on m.market_id = coalesce(b.branch_id, invoice_market.market_id)
    left join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a --pulling invoice asset
        on a.asset_key = w.warranty_credits_asset_key
    left join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a1 --pulling combined work order and invoice asset info
        on a1.asset_id = coalesce(b.asset_id, a.asset_id)
    left join old_denials odc
        on odc.work_order_id = coalesce(wo.work_order_id, wni.work_order_id) -- no retool needed here
    left join (
            select dwo.work_order_id
                , sum(zeroifnull(wl.work_order_line_amount)) as wo_cost
            from PLATFORM.GOLD.DIM_WORK_ORDERS dwo
            join PLATFORM.GOLD.FACT_WORK_ORDER_LINES wl
                on wl.work_order_line_work_order_key = dwo.work_order_key
            group by 1
            ) woc
        on woc.work_order_id = coalesce(mr.work_order_id, wo.work_order_id, wni.work_order_id)
    where i.invoice_is_warranty_invoice and i.invoice_billing_approved = true
)

-- , end_custom_sql as ( --All warranty invoices + things marked not warranty in retool
    select region
        , district
        , branch_id
        , market
        , work_order_id
        , reviewed_by
        , reference_date
        , days_to_file
        , invoice_id
        , claim_number
        , asset_id
        , make
        , billed_company
        , pre_file_denial_code
        , claim_denial_reason
        , is_child_invoice
        , is_missed_opp
        , invoice_creator
        , is_leg_of_segmented_claim
        , mp.bottom_market
        , work_order_cost
        , retool_note_added
    from wo_to_inv
    left join market_performance mp
      on mp.market_id = branch_id
    where region ilike concat('%', {% parameter region_name_param %}, '%')

    union all

    select region
        , district
        , branch_id
        , market
        , mr.work_order_id
        , reviewed_by
        , review_date as reference_date
        , null as days_to_file
        , invoice_id
        , claim_number
        , asset_id
        , mr.make
        , null as billed_company
        , pre_file_denial_code
        , claim_denial_reason
        , is_child_invoice
        , is_missed_opp
        , null as invoice_creator
        , false as is_leg_of_segmented_claim
        , mp.bottom_market
        , woc.wo_cost as work_order_cost
        , mr.retool_note_added
    from modern_reviews mr
    left join market_performance mp
      on mp.market_id = branch_id
    left join (
            select dwo.work_order_id
                , sum(zeroifnull(wl.work_order_line_amount)) as wo_cost
            from PLATFORM.GOLD.DIM_WORK_ORDERS dwo
            join PLATFORM.GOLD.FACT_WORK_ORDER_LINES wl
                on wl.work_order_line_work_order_key = dwo.work_order_key
            group by 1
            ) woc
        on woc.work_order_id = mr.work_order_id
    where warranty_state = 'Not Warranty'
      and region ilike concat('%', {% parameter region_name_param %}, '%')
;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}.market ;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }

  dimension: reviewed_by {
    type: string
    sql: ${TABLE}.reviewed_by ;;
  }

  dimension_group: reference { #Billing approved for filed claims and review date for pre-file denials
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    sql: ${TABLE}.reference_date ;;
  }

  dimension: days_to_file {
    type: number
    sql: ${TABLE}.days_to_file ;;
  }

  measure: avg_days_to_file {
    type: average
    value_format_name: decimal_1
    sql: ${days_to_file} ;;
    drill_fields: [
      dynamic_axis
    , filter_admin
    , work_order_id
    , make
    , reference_date
    , pre_file_denial_code
    , dim_invoices_fleet_opt.invoice_no
    , claim_number
    , billed_company
    , days_to_file
    ]
  }

  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.invoice_id ;;
  }

  dimension: claim_number {
    type: string
    sql: ${TABLE}.claim_number ;;
  }

  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.branch_id ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: billed_company {
    type: string
    sql: ${TABLE}.billed_company ;;
  }

  dimension: pre_file_denial_code {
    type: string
    sql: ${TABLE}.pre_file_denial_code ;;
  }

  dimension: pfdc_branch_fault {
    type: yesno
    sql:
      case
        when ${pre_file_denial_code} is null then null
        when ${pre_file_denial_code} ilike any ('%Customer Damage;'
          , '%Non-OEM Parts Used;'
          , '%Requested Info Not Provided;'
          , '%Timeframe to File Expired;'
          , '%Training Opportunity;'
          , '%Outside Repair Not Authorized;'
          , '%Lack of Maintenance;'
          , '%Parts Not Retained;'
          , '%Repair not performed to OEM Standard;') then true
        else false end
        ;;
  }

  dimension: retool_review_decision {
    type: string
    sql: coalesce(RIGHT(${pre_file_denial_code}, LEN(${pre_file_denial_code}) - 3), 'Filed Claim') ;;
  }

  dimension: claim_denial_reason {
    type: string
    sql: ${TABLE}.claim_denial_reason ;;
  }

  dimension: claim_denial_branch_fault {
    type: yesno
    sql:
      case
        when ${claim_denial_reason} is null then null
        when ${claim_denial_reason} ilike any ('%Requested Info Not Provided%'
          , '%Deemed Damage or Abuse%'
          , '%Parts Not Returned%'
          , '%Submission Time Expired%'
          , '%Parts Tested Good%'
          , '%Unfavorable OEM Policy%'
          , '%Lack of Maintenance%'
          , '%Use of Non-OEM Parts%'
          , '%Repair Not Made to OEM Standards%') then true
        else false end
        ;;
  }

  parameter: max_rank {
    type: number
  }

  dimension: rank_limit {
    type:  number
    sql:  {% parameter max_rank %} ;;
  }

  parameter: drop_down_selection {
    type: string
    allowed_value: { value: "Warranty Admin"}
    allowed_value: { value: "OEM"}
    allowed_value: { value: "Billed Company"}
    allowed_value: { value: "Region"}
    allowed_value: { value: "District"}
    allowed_value: { value: "Market"}
  }

  dimension: dynamic_axis {
    label_from_parameter: drop_down_selection
    sql:
    {% if drop_down_selection._parameter_value == "'Warranty Admin'" %}
      ${filter_admin}
    {% elsif drop_down_selection._parameter_value == "'OEM'" %}
      ${make}
    {% elsif drop_down_selection._parameter_value == "'Billed Company'" %}
      ${billed_company}
    {% elsif drop_down_selection._parameter_value == "'Region'" %}
      ${region}
    {% elsif drop_down_selection._parameter_value == "'District'" %}
      ${district}
    {% elsif drop_down_selection._parameter_value == "'Market'" %}
      ${market}
    {% else %}
      NULL
    {% endif %} ;;
  }

  dimension: is_child_invoice {
    type: yesno
    sql: ${TABLE}.is_child_invoice;;
  }

  dimension: is_missed_opp {
    type: yesno
    sql: ${TABLE}.is_missed_opp ;;
  }

  dimension: missed_opp_result {
    type: string
    sql:
      case
        when ${TABLE}.is_missed_opp = false then 'Not Missed Opp'
        when ${TABLE}.is_missed_opp = true and ${pre_file_denial_code} is not null and ${pre_file_denial_code} <> 'Q - Warranty Missed Opp Reviewed' then 'Flipped Not Filed'
        when ${TABLE}.is_missed_opp = true and ${pre_file_denial_code} = 'Q - Warranty Missed Opp Reviewed' then 'Not Flipped'
        when ${TABLE}.is_missed_opp = true and ${invoice_id} is not null then 'Filed'
        else null end
      ;;
  }

  dimension: is_retool_entry {
    type: yesno
    sql: iff(${reviewed_by} is not null, TRUE, FALSE) ;;
  }

  dimension: is_leg_of_segmented_claim {
    type: yesno
    sql: ${TABLE}.is_leg_of_segmented_claim ;;
  }

  measure: count_reviewed {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [
      market
      , reviewed_by
      , work_order_id
      , make
      , reference_date
      , pre_file_denial_code
      , dim_invoices_fleet_opt.invoice_no
      , claim_number
      , billed_company
      , fact_warranty_credits.total_amt
      , fact_warranty_credits.warranty_credits_pending_amount
      , fact_warranty_credits.warranty_credits_paid_amount
      , fact_warranty_credits.warranty_credits_denied_amount
      , claim_denial_reason
      , fact_warranty_credits.child_invoice_no
      , fact_warranty_credits.child_invoice_paid_amt
    ]
  }

  measure: count_filed {
    type: sum
    sql: iff(${invoice_id} is not null and ${is_child_invoice} = FALSE, 1, 0) ;;
  }

  measure: count_filed_no_segmented {
    type: sum
    sql: iff(${invoice_id} is not null and ${is_child_invoice} = FALSE and ${is_leg_of_segmented_claim} = false, 1, 0) ;;
  }

  measure: file_rate {
    type: number
    value_format_name: percent_1
    sql: iff(${count_reviewed} <> 0, ${count_filed_no_segmented} / ${count_reviewed}, null) ;;
    drill_fields: [dynamic_axis
        , retool_review_decision
        , count_reviewed
      ]
  }

  dimension: primary_key {
    type: number
    value_format_name: id
    primary_key: yes
    sql: concat(${work_order_id}, ${invoice_id}) ;;
  }

  dimension: invoice_creator {
    type: string
    sql: ${TABLE}.invoice_creator ;;
  }

  dimension: filter_admin {
    type: string
    sql: coalesce(${reviewed_by}, ${invoice_creator}) ;;
  }

  dimension: rolling_recovery_percentage_goal {
    type: number
    value_format_name: percent_0
    sql:
      case
        when current_date() < dateadd(day, 30, ${reference_date}) then 0
        when current_date() < dateadd(day, 60, ${reference_date}) and current_date >= dateadd(day, 30, ${reference_date}) then 0.40
        when current_date() >= dateadd(day, 60, ${reference_date}) then 0.80
        else null
        end;;
  }

  measure: exp_recovery_percentage {
    type: average
    value_format_name: percent_1
    sql: ${rolling_recovery_percentage_goal} ;;
  }

  dimension: days_since_jan_1 {
    type: number
    sql: datediff(day, date_trunc(year, current_date), current_date) ;;
  }

  dimension: claim_date_to_jan_1 {
    type: number
    sql: datediff(day, date_trunc(year, ${TABLE}.reference_date), ${TABLE}.reference_date) ;;
  }

  dimension: show_in_ytd_comparison {
    type: yesno
    sql: ${claim_date_to_jan_1} <= ${days_since_jan_1} ;;
  }

  dimension: bottom_market {
    type: yesno
    sql: ${TABLE}.bottom_market;;
  }

  parameter: region_name_param {
    type: string
    allowed_value: {
      value: "Pacific"
    }
    allowed_value: {
      value: "Mountain West"
    }
    allowed_value: {
      value: "Southeast"
    }
    allowed_value: {
      value: "Southwest"
    }
    allowed_value: {
      value: "Midwest"
    }
    allowed_value: {
      value: "Southeast"
    }
    allowed_value: {
      value: "Northeast"
    }
    allowed_value: {
      value: "Industrial"
    }
    allowed_value: {
      label: "any value"
      value: "%"
    }
  }

  dimension: dynamic_region {
    label_from_parameter: drop_down_selection
    sql:
    {% if drop_down_selection._parameter_value <> "'Any Region'" %}
      ${region}
    {% else %}
      NULL
    {% endif %} ;;
  }

  dimension: work_order_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.work_order_cost ;;
  }

  measure: distinct_work_order_cost {
    type: sum_distinct
    sql_distinct_key: ${work_order_id} ;;
    value_format_name: usd_0
    sql: ${work_order_cost} ;;
    drill_fields: [
      market
      , reviewed_by
      , reference_date
      , work_order_id
      , make
      , pre_file_denial_code
      , work_order_cost
    ]
  }

  dimension: retool_note_added {
    type: string
    sql: ${TABLE}.retool_note_added ;;
  }
}
