view: work_order_to_invoice {
  derived_table: {
    sql:
with wo_note as (
    select work_order_id work_order_id
        , i.invoice_id
        , replace(upper(note), 'MANUAL INVOICE #', '') as invoice_number
        , lead(won.date_created) over (partition by work_order_id order by won.date_created asc) next_note_date
        , 'WO Note' as connected_by
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_NOTES won
    join ES_WAREHOUSE.PUBLIC.INVOICES i
        on replace(i.invoice_no,'-000','') = ltrim(replace(REGEXP_REPLACE(invoice_number,'[A-z]',''),'-000',''), ':#/-_,$.* ')
    where won.note ilike 'Manual Invoice #%'
    qualify next_note_date is null
)

, id as (
    select wo.work_order_id work_order_id
        , i.invoice_id
        , 'Invoice ID' as connected_by
    from (
            select wo.work_order_id, wo.invoice_id
            from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
            join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
                on m.market_id = wo.branch_id
            left join wo_note won
                on won.work_order_id = wo.work_order_id
            where won.work_order_id is null
                and wo.archived_date is null
                and wo.invoice_id is not null) wo
    join (
            select i.invoice_id
            from ES_WAREHOUSE.PUBLIC.INVOICES i
            left join wo_note won
                on won.invoice_id = i.invoice_id
            where won.invoice_id is null) i
        on i.invoice_id = wo.invoice_id
)

, no as (
    select wo.work_order_id as work_order_id
        , i.invoice_id
        , 'Invoice Number' as Connected_by
    from (
            select wo.work_order_id, wo.invoice_number, wo.asset_id
            from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
            join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
                on m.market_id = wo.branch_id
            left join wo_note won
                on won.work_order_id = wo.work_order_id
            left join id
                on id.work_order_id = wo.work_order_id
            where won.work_order_id is null
                and wo.archived_date is null
                and wo.invoice_number is not null
                and id.work_order_id is null) wo
    join (
            select i.invoice_id, i.invoice_no, a.asset_id
            from ES_WAREHOUSE.PUBLIC.INVOICES i
            left join (select invoice_id, max(asset_id) asset_id from ES_WAREHOUSE.PUBLIC.LINE_ITEMS group by invoice_id) a
                on a.invoice_id = i.invoice_id
            left join wo_note won
                on won.invoice_id = i.invoice_id
            left join id
                on id.invoice_id = i.invoice_id
            where won.invoice_id is null
                and id.invoice_id is null) i
        on ltrim(replace(REGEXP_REPLACE(wo.invoice_number,'[A-z]',''),'-000',''), ':#/-_,$.* ') = replace(i.invoice_no, '-000','')
            and i.asset_id = wo.asset_id
)


select work_order_id, invoice_id, connected_by from wo_note
union
select * from id
union
select * from no ;;
}

dimension: work_order_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.work_order_id ;;
 }

dimension: invoice_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.invoice_id ;;
}

dimension: connected_by {
  type: string
  sql: ${TABLE}.connected_by ;;
}
}

view: invoice_to_work_orders {
  derived_table: {
    sql:
      select listagg(work_order_id, ' / ') work_order_id
        , invoice_id
        , connected_by
      from ${work_order_to_invoice.SQL_TABLE_NAME}
      group by invoice_id, connected_by ;;
  }

  dimension: work_order_id { #Leave as string, contains a list on multiply linked invoices
    type: string
    sql: ${TABLE}.work_order_id ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }

  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.invoice_id ;;
  }

  dimension: connected_by {
    type: string
    sql: ${TABLE}.connected_by ;;
  }
}
