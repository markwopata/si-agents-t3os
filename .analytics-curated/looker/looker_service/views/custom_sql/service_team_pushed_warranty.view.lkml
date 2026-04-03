view: service_team_pushed_warranty {
  derived_table: {
    sql:
    select distinct ca.user_id
        , m.market_name
        , wo.work_order_id
        , wi.invoice_id
        , wi.total_amt
        , wi.paid_amt
        , wi.pending_amt
        , wi.total_denied_amt as denied_amt
    from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT ca
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        on parameters:work_order_id = wo.work_order_id
    left join ES_WAREHOUSE.PUBLIC.INVOICES i1
        on i1.invoice_id = wo.invoice_id
    left join ES_WAREHOUSE.PUBLIC.INVOICES i2
        on replace(i2.invoice_no,'-000','') = ltrim(replace(REGEXP_REPLACE(wo.invoice_number,'[A-z]',''),'-000',''), ':#/-_,$.* ')
    left join ANALYTICS.WARRANTIES.WARRANTY_INVOICES wi
        on wi.invoice_id = coalesce(i1.invoice_id, i2.invoice_id)
    join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
        on m.market_id = wo.branch_id
    where command = 'UpdateWorkOrder'
        and user_id in (29401, 222408, 15641)
        and parameters:changes:billing_type_id = 1
        and wo.archived_date is null ;;
  }

  dimension: user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.user_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
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

  dimension: total_amt {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_amt ;;
  }

  dimension: pending_amt {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.pending_amt ;;
  }

  dimension: denied_amt {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.denied_amt ;;
  }

  dimension: paid_amt {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.paid_amt ;;
  }

  measure: count {
    type: count
    drill_fields: [ billing_approval_user.full_name
      , work_orders.work_order_id_with_link_to_work_order
      , billing_types.name
      , work_orders.branch_id
      , work_orders.date_completed_date
      , work_orders.asset_id
      , assets_aggregate.make
      , current_own_program_assets.payout_program_name
      , invoices.invoice_id_with_link_to_invoice
      , invoices.date_created_date
      , total_amt
      , pending_amt
      , paid_amt
      , denied_amt
    ]
  }
}
