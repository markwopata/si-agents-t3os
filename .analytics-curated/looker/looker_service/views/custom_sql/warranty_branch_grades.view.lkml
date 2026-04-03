view: warranty_branch_grades {
  derived_table: {
    sql: -- percent of OEC under warranty?
with generated_qtrs as (
    SELECT dateadd(quarter, '-' || row_number() over (order by null), dateadd('quarter', +1, date_trunc('quarter', current_date()))
        ) as generated_date
    FROM table(generator(rowcount => 32))
)

-- OEC every qtr
, own as ( --OWN Program Assignments
    select aa.asset_id, vpp.start_date, coalesce(vpp.end_date, '2099-12-31') as end_date
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    join ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS vpp
        on vpp.asset_id = aa.asset_id
    WHERE (aa.ASSET_TYPE_ID = 1  /*equipment*/ or  (aa.equipment_make_id = 11333 and aa.category_id = 514))
)

, es as ( --ES Ownership
    select aa.asset_id, scd.date_start, scd.date_end --all assets owned by es at the end of the year
    from ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY scd
    join ANALYTICS.PUBLIC.ES_COMPANIES esc
        on esc.company_id = scd.company_id
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on scd.asset_id = aa.asset_id
    where (aa.ASSET_TYPE_ID = 1  /*equipment*/ or  (aa.equipment_make_id = 11333 and aa.category_id = 514))
        and esc.owned = true
)

, warrantable_assets as ( --List of relevant assets, may be useful
    select distinct asset_id
    from own

    union

    select distinct asset_id
    from es
)

, asset_hour_limits as ( --All warrantable assets over on hours
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
    join warrantable_assets wa
        on wa.asset_id = aa.asset_id
    where hour_limits < scd.hours
    group by aa.asset_id, hour_limits
)

, warranty_final as (
    SELECT DISTINCT eppa.asset_id
        , eppa.oec
        , ad.delivery_date::DATE as warranty_start_date
        , DATEADD(month, (MIN(TIME_VALUE) OVER (PARTITION BY eppa.ASSET_ID )), ad.delivery_date::DATE) as Warranty_End_Date_prep
        , iff(Warranty_End_Date_prep > coalesce(over_hour_limit, '2099-12-31'), over_hour_limit, Warranty_End_Date_prep) as warranty_end_date
        , listagg(distinct w.description, ', ') over (partition by eppa.ASSET_ID) as warranties
        , listagg(wd.description, ', ') over (partition by eppa.ASSET_ID) as warranties_description
    FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE eppa
    join warrantable_assets wa
        on wa.asset_id = eppa.asset_id
    left join asset_hour_limits ahl
        on ahl.asset_id = eppa.asset_id
    JOIN es_warehouse.public.asset_warranty_xref awx
        On eppa.asset_id = awx.asset_id
    LEFT JOIN es_warehouse.public.equipment_classes ec
        On ec.equipment_class_id = eppa.equipment_class_id
    LEFT JOIN es_warehouse.public.companies c ON c.company_id = eppa.company_id
    JOIN es_warehouse.public.warranties w ON w.warranty_id = awx.warranty_id
     JOIN (
            select ad.asset_id
                , coalesce(ad.delivery_date, min(wo.date_created)) as delivery_date
            from analytics.PARTS_INVENTORY.asset_delivery_date ad
            left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
                on wo.asset_id = ad.asset_id
            group by ad.asset_id, ad.delivery_date ) ad
        ON eppa.asset_ID = ad.asset_ID
    JOIN (
            SELECT Warranty_ID
                , description
                , TIME_VALUE
            FROM ES_WAREHOUSE.PUBLIC.WARRANTY_ITEMS
            where description not ilike '%Structural%' and description not ilike '%EPA%'--use this for the overall warranty pull
            -- description ilike any ('%standard%','%comprehensive%','%general%','%limited%','%full%','%life%','%base%') --use this for standard warranties pull
                 and warranty_id not in
                    (4173, 1774, 1773, 1288, 1246, 1247,
                    1276, 1278, 1277, 1279, 1285,
                    1275, 2035, 1375,
                    900)
                AND DATE_DELETED is null
                AND (TIME_UNIT_ID is null or TIME_UNIT_ID = 20)) wd
        ON w.WARRANTY_ID = wd.WARRANTY_ID
    WHERE eppa.year >= 2018
        AND eppa.equipment_model_id not in (select equipment_model_id from ANALYTICS.WARRANTIES.UNWARRANTABLE_MODELS)
        AND eppa.service_branch_id != 1491 --"main branch"
        -- AND eppa.ASSET_TYPE_ID = 1         --equipment
        and ad.delivery_date is not null --sure to give us a warranty end date
)

, generated_dates as (
    SELECT dateadd(day, '-' || row_number() over (order by null), dateadd(day, +1, date_trunc(day, current_date()))
        ) as generated_date
    FROM table(generator(rowcount => 2920)) --8 years
)

, util_prep as (
    select date_trunc(quarter, gd.generated_date) as qtr
        , coalesce(rsp.rental_branch_id, msp.service_branch_id) as branch_id
        , count_if(ais.asset_inventory_status = 'Ready To Rent') as days_not_utilized
        , count(gd.generated_date) as days_in_qtr_asset_aggregate
        , days_in_qtr_asset_aggregate - days_not_utilized as days_utilized
        , days_utilized / days_in_qtr_asset_aggregate as perc_days_asset_warranty_rev
    from ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY_STATUS ais
    join generated_dates gd
        on ais.date_start < gd.generated_date
            and ais.date_end >= gd.generated_date
    left join ES_WAREHOUSE.SCD.SCD_ASSET_MSP msp
        on msp.asset_id = ais.asset_id
            and msp.date_start < date_trunc(quarter, gd.generated_date)
            and msp.date_end >= date_trunc(quarter, gd.generated_date)
    left join ES_WAREHOUSE.SCD.SCD_ASSET_RSP rsp
        on rsp.asset_id = ais.asset_id
            and rsp.date_start < date_trunc(quarter, gd.generated_date)
            and rsp.date_end >= date_trunc(quarter, gd.generated_date)
    group by qtr, branch_id
)

, asset_qtrs as (
    select gq.generated_date
        , coalesce(rsp.rental_branch_id, msp.service_branch_id) as branch_id
        -- , wf.asset_id
        , sum(zeroifnull(wf.oec)) as oec
    from generated_qtrs gq
    join warranty_final wf
        on wf.warranty_start_date <= gq.generated_date
            and wf.warranty_end_date >= gq.generated_date
    left join ES_WAREHOUSE.SCD.SCD_ASSET_MSP msp
        on msp.asset_id = wf.asset_id
            and msp.date_start < gq.generated_date
            and msp.date_end >= gq.generated_date
    left join ES_WAREHOUSE.SCD.SCD_ASSET_RSP rsp
        on rsp.asset_id = wf.asset_id
            and rsp.date_start < gq.generated_date
            and rsp.date_end >= gq.generated_date
    where coalesce(rsp.asset_id, msp.asset_id) is not null --Assuming that if it is at a branch then they can file warranty with it
    group by gq.generated_date, branch_id
)

-- claims every qtr
, qtr_claims as (
    select aq.generated_date
        , aq.branch_id
        , sum(zeroifnull(wi.total_amt)) claimed
        , claimed * 4 as annualized_claims
        , iff((aq.oec * up.perc_days_asset_warranty_rev) <> 0, annualized_claims / (aq.oec * up.perc_days_asset_warranty_rev), null) as ac_oec
        , aq.oec
        , up.perc_days_asset_warranty_rev
    from asset_qtrs aq
    left join ANALYTICS.WARRANTIES.WARRANTY_INVOICES wi
        on wi.branch_id = aq.branch_id
            and date_trunc(quarter, wi.date_created) = aq.generated_date
    left join util_prep up
        on up.branch_id = aq.branch_id
            and aq.generated_date = up.qtr
    group by aq.generated_date
        , aq.branch_id
        , aq.oec
        , up.perc_days_asset_warranty_rev
)

-- work orders completed at that branch
, work_orders_to_remove as (
    select wo.work_order_id
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS woct
        on wo.WORK_ORDER_ID = woct.WORK_ORDER_ID
    join ES_WAREHOUSE.WORK_ORDERS.COMPANY_TAGS ct
        on woct.COMPANY_TAG_ID = ct.COMPANY_TAG_ID
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on aa.asset_id = wo.asset_id
    where (woct.company_tag_id = 40 --Make Ready
            and (aa.make not ilike '%CASE%' and aa.make not ilike '%HOLLAND%')) --Case make readys are warrantable
        or woct.company_tag_id in (
            31 --ANSI
            , 23 --Customer Damage
            , 980 --EQ Transfer
            , 846 --DOT Inspection
            , 2836 --DOT Documents
            , 7624 --Telematics R&D Testing
            , 41 --Telematics Check
            )

    union

    select wo.work_order_id
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_ORIGINATORS woo
        on woo.work_order_id = wo.work_order_id
    where woo.originator_type_id = 3
        and wo.description ilike '%ANSI%'

    union

    select wo.work_order_id
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on aa.asset_id = wo.asset_id
    where (wo.description ilike '%Equipment Transfer%')
        or (wo.description ilike '%Transfer%')
        or (wo.description ilike '%Make Ready%' and ( aa.make not ilike '%CASE%' and aa.make not ilike '%HOLLAND%'))
        or (wo.description ilike '%DOT%'
        or (wo.description ilike '%Telematics%')
        or (wo.description ilike 'Tracker Install'))
)

, wo_branch as (
    select gq.generated_date
        , wo.branch_id
        , count(wo.work_order_id) as wo_completed
    from generated_qtrs gq
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        on date_trunc(quarter, wo.date_created) = gq.generated_date
    left join work_orders_to_remove wotr
        on wotr.work_order_id = wo.work_order_id
    where wo.archived_date is null
        and wo.date_completed is not null
        and wo.BRANCH_ID in (select market_id from analytics.PUBLIC.MARKET_REGION_XWALK)
        and wo.asset_id is not null
        and wotr.work_order_id is null
    group by gq.generated_date
        , wo.branch_id
)

-- work orders reviewed by warranty team
, admins as (
    select distinct user_id, warranty_admin
    from ANALYTICS.WARRANTIES.WARRANTY_ADMIN_ASSIGNMENTS
    where user_id <> 'Admin not in list'

    union

    select user_id::STRING, concat(first_name, ' ', last_name) as warranty_admin
    from ES_WAREHOUSE.PUBLIC.USERS u
    where user_id = 159621
)

, work_orders_w_admin_contact as (
    select m.market_id, wo.work_order_id, max(ca.date_created) as last_admin_interaction
    from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT ca
    join admins
        on admins.user_id = ca.user_id::STRING
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        on wo.work_order_id = ca.parameters:work_order_id
    join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
        on m.market_id = wo.branch_id
    where ca.command = 'UpdateWorkOrder' or ca.command  = 'DisassociateWorkOrderTag' or ca.command = 'CreateAndAssociateCompanyTag'
    group by m.market_id, wo.work_order_id
)

, admin_reviewed as (
    select wob.generated_date
        , wob.branch_id
        , wob.wo_completed
        , count(wowac.work_order_id) as admin_reviewed
        , admin_reviewed / wob.wo_completed percent_admin_reviewed
    from wo_branch wob
    left join work_orders_w_admin_contact wowac
        on wowac.market_id = wob.branch_id
            and wob.generated_date = date_trunc(quarter, wowac.last_admin_interaction)
    group by wob.generated_date
        , wob.branch_id
        , wob.wo_completed
)

-- work orders flipped to warranty by Henry's team
, ss_flipped_wos as (
    select m.market_id
        , ca.parameters:work_order_id work_order_id
        , max(ca.date_created::DATE) as date_flipped
    from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT ca
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        on wo.work_order_id = ca.parameters:work_order_id
    join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
        on m.market_id = wo.branch_id
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on aa.asset_id = wo.asset_id
    join (
            select distinct parameters:work_order_id work_order_id
            from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT
            where parameters:changes:description is not null --reviewed
                and user_id in (15641, 29401, 222408) --henry's team
            group by work_order_id
            ) lid
        on lid.work_order_id = ca.parameters:work_order_id
    where ca.user_id in (15641, 29401, 222408)
        and ca.parameters:changes:billing_type_id = 1
    group by m.market_id
        , ca.parameters:work_order_id
)

, reviews as (
    select ar.generated_date
        , ar.branch_id
        , ar.wo_completed
        , ar.admin_reviewed
        , ar.percent_admin_reviewed
        , count(ss.work_order_id) as ss_flipped_warranty
        , ss_flipped_warranty / ar.wo_completed as ss_percent_flipped
    from admin_reviewed ar
    left join ss_flipped_wos ss
        on date_trunc(quarter, ss.date_flipped) = ar.generated_date
            and ss.market_id = ar.branch_id
    group by ar.generated_date
        , ar.branch_id
        , ar.wo_completed
        , ar.admin_reviewed
        , ar.percent_admin_reviewed
)

, ss_billed_invoices as (
    select date_trunc(quarter, i.date_created) qtr
        , li.branch_id
        , count(distinct iff(i.created_by_user_id in (15641, 29401, 222408)
            , i.invoice_id
            , null)) as ss_created
        , count(distinct i.invoice_id) service_invoices
        , ss_created / service_invoices perc_invoice_ss_created
    from ES_WAREHOUSE.PUBLIC.INVOICES i
    join ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
        on i.invoice_id = li.invoice_id
    where li.line_item_type_id in (11, 13, 19, 20, 22, 23, 25, 26, 133, 134)
    group by qtr, li.branch_id
)

select concat('Q', quarter(r.generated_date), '-', year(r.generated_date)) as qtr
    , m.market_id
    , m.market_name
    , qc.oec
    , qc.perc_days_asset_warranty_rev
    , qc.ac_oec
    , r.wo_completed
    , r.percent_admin_reviewed
    , r.ss_percent_flipped
    , ss_billed.perc_invoice_ss_created
from reviews r
join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
    on m.market_id = r.branch_id
left join qtr_claims qc
    on qc.branch_id = r.branch_id
        and qc.generated_date = r.generated_date
left join ss_billed_invoices ss_billed
  on ss_billed.branch_id = m.market_id
    and ss_billed.qtr = r.generated_date
 ;;
  }
 dimension: quarter {
  type: string
  sql: ${TABLE}.qtr ;;
 }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }

  dimension: oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.oec ;;
  }

  dimension: asset_perc_days_warranty_rev {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.perc_days_asset_warranty_rev;;
  }

  dimension: annualized_claims_by_oec {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.ac_oec ;;
  }

  dimension: work_orders_completed {
    type: number
    sql: ${TABLE}.wo_completed ;;
  }

  dimension: percent_admin_reviewed {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.percent_admin_reviewed ;;
  }

  dimension: ss_percent_flipped {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.ss_percent_flipped ;;
  }

  dimension: perc_invoice_ss_created {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.perc_invoice_ss_created ;;
  }
}
