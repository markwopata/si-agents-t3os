view: 5300_5301_revenue_intaact {
  derived_table: {
    sql: with work_orders as (
    select wo.work_order_id, wo.date_completed::date as date_completed, wo.asset_id, i.invoice_id
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    left join ES_WAREHOUSE.PUBLIC.INVOICES i1
        on i1.invoice_id = wo.invoice_id
    left join ES_WAREHOUSE.PUBLIC.INVOICES i2
        on replace(i2.invoice_no, '-000','') = ltrim(replace(REGEXP_REPLACE(wo.invoice_number,'[A-z]',''),'-000',''), ':#/-_,$.* ')
    join ES_WAREHOUSE.PUBLIC.INVOICES i
        on i.invoice_id = coalesce(i1.invoice_id, i2.invoice_id)
)

    select c.name as customer
        , wo.work_order_id
        , wo.date_completed as work_order_completed_date
        , max(coalesce(coalesce(li.asset_id, wo.asset_id), ar.fk_admin_asset_id)) as asset_id
        , owner.name as asset_owner_at_billing
        , case
            when vpp.payout_program_name is not null then vpp.payout_program_name
            when esc.company_name is not null then 'ES Owned'
            when coalesce(coalesce(li.asset_id, wo.asset_id), ar.fk_admin_asset_id) is null then null
            else 'External' end as ownership_at_billing
        , i.invoice_id
        , i.invoice_no
        , i.billing_approved_date::DATE as approved_date
        , sum(li.amount) as admin_amount
        , i.public_note as memo
        , iff(lli.invoice_id is not null, false, true) as part_only
        , iff(ar.invoice_number is null, false, true) as sage_connected
        , sum(ar.amount) as sage_amount
        , ar.gl_date as whenposted
    from ES_WAREHOUSE.PUBLIC.INVOICES i
    join ANALYTICS.PUBLIC.V_LINE_ITEMS li
        on li.invoice_id = i.invoice_id
    join ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES lit
        on lit.line_item_type_id = li.line_item_type_id
    left join work_orders wo
        on wo.invoice_id = i.invoice_id
    left join (
            select *
            from ANALYTICS.INTACCT_MODELS.AR_DETAIL
            where account_number in (5301,5300)) ar
        on ar.fk_admin_line_item_id = li.line_item_id
    left join ES_WAREHOUSE.PUBLIC.COMPANIES c
        on c.company_id = i.company_id
    left join ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY scd --Who Owns it
        on scd.asset_id = coalesce(coalesce(li.asset_id, wo.asset_id), ar.fk_admin_asset_id)
            and scd.date_start <= approved_date
            and scd.date_end >= approved_date
    left join ANALYTICS.PUBLIC.ES_COMPANIES esc --is that owner an es company?
        on esc.company_id = scd.company_id
    left join ES_WAREHOUSE.PUBLIC.COMPANIES owner --all companies
        on owner.company_id = scd.company_id
    left join ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS vpp --in payout program?
        on vpp.asset_id = coalesce(coalesce(li.asset_id, wo.asset_id), ar.fk_admin_asset_id)
            and vpp.start_date <= approved_date
            and coalesce(vpp.end_date, '2099-12-31') >= approved_date
    left join (
            select distinct li.invoice_id
            from ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
            join ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES lit
                on lit.line_item_type_id = li.line_item_type_id
            where lit.name ilike '%labor%') lli
        on lli.invoice_id = i.invoice_id
    where li.line_item_type_id in (11, 13, 121, 49, 26, 25)
        and i.company_id not in (select company_id from ANALYTICS.PUBLIC.ES_COMPANIES)
        and approved_date is not null
    group by c.name
        , wo.work_order_id
        , work_order_completed_date
        , asset_owner_at_billing
        , ownership_at_billing
        , i.invoice_id
        , i.invoice_no
        , lli.invoice_id
        , approved_date
        , i.public_note
        , ar.invoice_number
        , whenposted
    having sum(li.amount) > 0
    order by approved_date desc;;
  }
  dimension: customer {
    type: string
    sql: ${TABLE}.customer ;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
  }

  dimension: work_order_completed_date {
    type: date
    sql: ${TABLE}.work_order_completed_date ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: asset_owner {
    type: string
    sql: ${TABLE}.asset_owner_at_billing ;;
  }

  dimension: ownership {
    type: string
    sql: ${TABLE}.ownership_at_billing ;;
  }

  dimension: invoice_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.invoice_id ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}.invoice_no ;;
  }

  dimension: approved_date {
    type: date
    sql: ${TABLE}.approved_date ;;
  }

  dimension: amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}.admin_amount ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}.memo ;;
  }

  dimension: part_only {
    type: yesno
    sql: ${TABLE}.part_only ;;
  }

  dimension: sage_connected {
    type: yesno
    sql: ${TABLE}.sage_connected ;;
  }

  dimension: sage_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}.sage_amount ;;
  }

  dimension: whenposted {
    type: date
    sql: ${TABLE}.whenposted ;;
  }
}
