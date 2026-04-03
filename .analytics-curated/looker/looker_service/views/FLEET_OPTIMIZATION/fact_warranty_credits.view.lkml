view: fact_warranty_credits {
  derived_table: {
    sql:
-- First part of this code is chatgpt made and annotated for flattening child and parent invoice relationships

-- Recursive CTE pattern:
-- 1) Identify "roots" (top-most parents)
-- 2) Anchor query: root -> immediate child
-- 3) Recursive query: keep following child -> next child until no more
-- 4) Optional cycle protection (path)

WITH RECURSIVE

/*-----------------------------------------------------------------------------
  roots:
  Find invoices that are "true parents" (i.e., they are NOT a child of any other
  invoice). These are the starting points / roll-up parents.
-----------------------------------------------------------------------------*/
roots AS (
    SELECT DISTINCT
        rc.invoice_no AS parent_invoice_no
    FROM ANALYTICS.WARRANTIES.RETOOL_CLAIMS rc

    -- If some other row points to rc.invoice_no as its child, then rc.invoice_no
    -- is NOT a root.
    LEFT JOIN ANALYTICS.WARRANTIES.RETOOL_CLAIMS p
        ON p.child_invoice_no = rc.invoice_no

    -- Keep only invoices that were never found as someone else's child
    -- (i.e., p didn't match anything).
    WHERE p.child_invoice_no IS NULL
),

/*-----------------------------------------------------------------------------
  invoice_hierarchy:
  This recursive CTE emits (parent_invoice_no, child_invoice_no) pairs for every
  descendant. It also builds a "path" string to prevent cycles.
-----------------------------------------------------------------------------*/
invoice_hierarchy AS (

    /*-------------------------------------------------------------------------
      Anchor member (base step):
      For each root parent, return its immediate child invoice(s).

      Output columns of the recursive CTE must match between anchor and recursive
      SELECTs (same count + compatible types):
        - parent_invoice_no (the root we’re rolling up to)
        - child_invoice_no  (current descendant)
        - path              (breadcrumb trail for cycle prevention)
    -------------------------------------------------------------------------*/
    SELECT
        r.parent_invoice_no,                      -- fixed root parent
        rc.child_invoice_no,                      -- first-level child
        rc.invoice_no || '>' || rc.child_invoice_no AS path  -- start path
    FROM roots r
    JOIN ANALYTICS.WARRANTIES.RETOOL_CLAIMS rc
        ON rc.invoice_no = r.parent_invoice_no    -- root row in the table
    WHERE rc.child_invoice_no IS NOT NULL         -- only continue where a child exists

    UNION ALL

    /*-------------------------------------------------------------------------
      Recursive member (step step):
      Take each row produced so far and try to find the *next* child.

      Logic:
        - ih.child_invoice_no is the "current node" we’re at
        - join table where invoice_no = that current node
        - emit the next child
        - carry the original root parent forward unchanged
        - extend the path
    -------------------------------------------------------------------------*/
    SELECT
        ih.parent_invoice_no,                     -- keep original root
        rc.child_invoice_no,                      -- next-level child
        ih.path || '>' || rc.child_invoice_no AS path   -- extend path trail
    FROM invoice_hierarchy ih
    JOIN ANALYTICS.WARRANTIES.RETOOL_CLAIMS rc
        ON rc.invoice_no = ih.child_invoice_no    -- walk down: current -> next
    WHERE rc.child_invoice_no IS NOT NULL         -- stop when no further child

      /*-----------------------------------------------------------------------
        Cycle protection:
        Prevent infinite recursion if bad data creates a loop like:
          A -> B -> C -> B (cycle)

        We check if the next child is already present in the accumulated path.
        If it is, we drop that row and do not recurse further down that branch.

        Wrapping both sides with '>' prevents partial matches:
          - avoids '12' matching inside '112' accidentally
      -----------------------------------------------------------------------*/
      AND POSITION(
            '>' || rc.child_invoice_no || '>'
            IN
            '>' || ih.path || '>'
          ) = 0
)

, parent_invoices as (
/*-----------------------------------------------------------------------------
  Final select:
  Return just the rollup pairs you care about (omit path).
-----------------------------------------------------------------------------*/
    SELECT
        parent_invoice_no,
        child_invoice_no
    FROM invoice_hierarchy
)

select w.*, listagg(p_inv.child_invoice_no, ' | ') as child_invoice_no, sum(zeroifnull(cw.warranty_credits_paid_amount)) as child_invoice_paid_amt
from "FLEET_OPTIMIZATION"."GOLD"."FACT_WARRANTY_CREDITS" w
left join FLEET_OPTIMIZATION.GOLD.DIM_INVOICES_FLEET_OPT i
    on i.invoice_key = w.warranty_credits_invoice_key
left join ANALYTICS.WARRANTIES.RETOOL_CLAIMS rc
    on trim(rc.invoice_no) = i.invoice_no
left join parent_invoices p_inv
    on p_inv.parent_invoice_no = rc.invoice_no
left join FLEET_OPTIMIZATION.GOLD.DIM_INVOICES_FLEET_OPT ci
    on ci.invoice_no = p_inv.child_invoice_no
left join FLEET_OPTIMIZATION.GOLD.FACT_WARRANTY_CREDITS cw
    on cw.warranty_credits_invoice_key = ci.invoice_key
group by all ;;
  }

  dimension: warranty_credits_ar_sum {
    type: number
    sql: ${TABLE}."WARRANTY_CREDITS_AR_SUM" ;;
  }
  dimension: warranty_credits_asset_key {
    type: string
    sql: ${TABLE}."WARRANTY_CREDITS_ASSET_KEY" ;;
  }
  dimension: warranty_credits_claim_closure_days {
    type: number
    sql: ${TABLE}."WARRANTY_CREDITS_CLAIM_CLOSURE_DAYS" ;;
  }
  dimension: warranty_credits_creator_user_key {
    type: string
    sql: ${TABLE}."WARRANTY_CREDITS_CREATOR_USER_KEY" ;;
  }
  dimension: warranty_credits_denied_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."WARRANTY_CREDITS_DENIED_AMOUNT" ;;
  }
  measure: denied_amt {
    type: sum
    value_format_name: usd_0
    filters: [warranty_credits_pending_amount: "=0"]
    sql: ${warranty_credits_denied_amount};;
    drill_fields: [
      warranty_work_orders_and_claims.market
      , warranty_work_orders_and_claims.reference_date
      , warranty_work_orders_and_claims.filter_admin
      , warranty_work_orders_and_claims.work_order_id
      , dim_invoices_fleet_opt.invoice_no
      , warranty_work_orders_and_claims.claim_number
      , warranty_work_orders_and_claims.billed_company
      , warranty_work_orders_and_claims.make
      , warranty_credits_paid_amount
      , warranty_credits_denied_amount
      , child_invoice_no
      , child_invoice_paid_amt
    ]
  }
  dimension: warranty_credits_invoice_credit_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."WARRANTY_CREDITS_INVOICE_CREDIT_AMOUNT" ;;
  }
  # dimension: warranty_credits_invoice_denied_sum { #Do not use, this is a stepping stone of just what was put into 5316
  #   type: number
  #   value_format_name: usd
  #   sql: ${TABLE}."WARRANTY_CREDITS_INVOICE_DENIED_SUM" ;;
  # }
  dimension: warranty_credits_invoice_key {
    type: string
    primary_key: yes
    sql: ${TABLE}."WARRANTY_CREDITS_INVOICE_KEY" ;;
  }
  dimension: warranty_credits_market_key {
    type: string
    sql: ${TABLE}."WARRANTY_CREDITS_MARKET_KEY" ;;
  }
  dimension: warranty_credits_most_recent_invoice_billing_date_key {
    type: string
    sql: ${TABLE}."WARRANTY_CREDITS_MOST_RECENT_INVOICE_BILLING_DATE_KEY" ;;
  }
  dimension: warranty_credits_paid_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."WARRANTY_CREDITS_PAID_AMOUNT" ;;
  }
  measure: paid_amt {
    type: sum
    value_format_name: usd_0
    filters: [warranty_credits_pending_amount: "=0"]
    html: {{paid_amt._rendered_value}} <br> <p style="font-size:12px"> {{count_closed ._rendered_value}} Closed Claims </p>;;
    sql: (${warranty_credits_paid_amount} + ${child_invoice_paid_amt}) ;;
    drill_fields: [
      warranty_work_orders_and_claims.market
      , warranty_work_orders_and_claims.reference_date
      , warranty_work_orders_and_claims.filter_admin
      , warranty_work_orders_and_claims.work_order_id
      , dim_invoices_fleet_opt.invoice_no
      , warranty_work_orders_and_claims.claim_number
      , warranty_work_orders_and_claims.billed_company
      , warranty_work_orders_and_claims.make
      , warranty_credits_paid_amount
      , warranty_credits_denied_amount
      , child_invoice_no
      , child_invoice_paid_amt
    ]
  }
  measure: count_closed {
    type: count
    filters: [warranty_credits_pending_amount: "=0"]
  }
  dimension: warranty_credits_paid_date_key {
    type: string
    sql: ${TABLE}."WARRANTY_CREDITS_PAID_DATE_KEY" ;;
  }
  dimension: warranty_credits_pending_amount {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."WARRANTY_CREDITS_PENDING_AMOUNT" ;;
  }
  measure: pending_amt {
    type: sum
    value_format_name: usd_0
    sql: ${warranty_credits_pending_amount} ;;
    filters: [warranty_credits_pending_amount: ">0"]
    html: {{pending_amt._rendered_value}} <br> <p style="font-size:12px"> {{count_pending._rendered_value}} Claims </p>;;
    drill_fields: [warranty_work_orders_and_claims.dynamic_axis
      , warranty_work_orders_and_claims.filter_admin
      , warranty_work_orders_and_claims.reference_date
      , warranty_work_orders_and_claims.make
      , dim_invoices_fleet_opt.invoice_no
      , warranty_work_orders_and_claims.claim_number
      , warranty_work_orders_and_claims.billed_company
      , warranty_credits_pending_amount
    ]
  }
  measure: pending_amt_overview_drill {
    type: sum
    value_format_name: usd_0
    sql: ${warranty_credits_pending_amount} ;;
    filters: [warranty_credits_pending_amount: ">0"]
    html: {{pending_amt._rendered_value}} <br> <p style="font-size:12px"> {{count_pending._rendered_value}} Claims </p>;;
    drill_fields: [
      warranty_work_orders_and_claims.market
      , warranty_work_orders_and_claims.reference_date
      , warranty_work_orders_and_claims.filter_admin
      , warranty_work_orders_and_claims.work_order_id
      , dim_invoices_fleet_opt.invoice_no
      , warranty_work_orders_and_claims.claim_number
      , warranty_work_orders_and_claims.billed_company
      , warranty_work_orders_and_claims.make
      , warranty_credits_pending_amount
    ]
  }
  dimension: warranty_credits_revenue_amount {
    type: number
    sql: ${TABLE}."WARRANTY_CREDITS_REVENUE_AMOUNT" ;;
  }
  dimension: warranty_credits_total_labor_requested {
    type: number
    sql: ${TABLE}."WARRANTY_CREDITS_TOTAL_LABOR_REQUESTED" ;;
  }
  dimension: warranty_credits_total_parts_requested {
    type: number
    sql: ${TABLE}."WARRANTY_CREDITS_TOTAL_PARTS_REQUESTED" ;;
  }
  dimension: warranty_credits_warranty_only_amount {
    type: number
    sql: ${TABLE}."WARRANTY_CREDITS_WARRANTY_ONLY_AMOUNT" ;;
  }
  dimension: perc_paid {
    type: number
    value_format_name: percent_1
    sql: ${warranty_credits_paid_amount} / nullifzero(${warranty_credits_pending_amount} + ${warranty_credits_paid_amount} + ${warranty_credits_denied_amount}) ;;
  }
  dimension: adj_perc_paid {
    type: number
    value_format_name: percent_1
    sql: (${child_invoice_paid_amt} + ${warranty_credits_paid_amount}) / (${warranty_credits_pending_amount} + ${warranty_credits_paid_amount} + ${warranty_credits_denied_amount}) ;;
  }
  measure: total_warranty_amt {
    type: sum
    value_format_name: usd_0
    sql: ${warranty_credits_warranty_only_amount} ;;
  }
  dimension: total_amt {
    type: number
    value_format_name: usd
    sql: (${warranty_credits_pending_amount} + ${warranty_credits_paid_amount} + ${warranty_credits_denied_amount})  ;;
  }
  measure: total_invoice_amt {
    type: sum
    value_format_name: usd_0
    html: {{total_invoice_amt._rendered_value}} <br> <p style="font-size:12px"> {{count._rendered_value}} Claims </p>;;
    sql: (${warranty_credits_pending_amount} + ${warranty_credits_paid_amount} + ${warranty_credits_denied_amount}) ;;
    drill_fields: [
      warranty_work_orders_and_claims.market
      , warranty_work_orders_and_claims.reference_date
      , warranty_work_orders_and_claims.filter_admin
      , warranty_work_orders_and_claims.work_order_id
      , dim_invoices_fleet_opt.invoice_no
      , warranty_work_orders_and_claims.claim_number
      , warranty_work_orders_and_claims.billed_company
      , warranty_work_orders_and_claims.make
      , warranty_work_orders_and_claims.claim_denial_reason
      , total_amt
      , warranty_credits_pending_amount
      , warranty_credits_paid_amount
      , warranty_credits_denied_amount
      , child_invoice_no
      , child_invoice_paid_amt
    ]
  }
  measure: total_invoice_amt_on_closed_claims {
    type: sum
    value_format_name: usd_0
    filters: [warranty_credits_pending_amount: "=0"]
    html: {{total_invoice_amt._rendered_value}} <br> <p style="font-size:12px"> {{count._rendered_value}} Claims </p>;;
    sql: (${warranty_credits_pending_amount} + ${warranty_credits_paid_amount} + ${warranty_credits_denied_amount}) ;;
    drill_fields: [
      warranty_work_orders_and_claims.market
      , warranty_work_orders_and_claims.reference_date
      , warranty_work_orders_and_claims.filter_admin
      , warranty_work_orders_and_claims.work_order_id
      , dim_invoices_fleet_opt.invoice_no
      , warranty_work_orders_and_claims.claim_number
      , warranty_work_orders_and_claims.billed_company
      , warranty_work_orders_and_claims.make
      , warranty_work_orders_and_claims.claim_denial_reason
      , total_amt
      , warranty_credits_pending_amount
      , warranty_credits_paid_amount
      , warranty_credits_denied_amount
      , child_invoice_no
      , child_invoice_paid_amt
    ]
  }
  dimension: child_invoice_no {
    type: string
    sql: ${TABLE}.child_invoice_no ;;
  }
  dimension: child_invoice_paid_amt {
    type: number
    value_format_name: usd
    sql: ${TABLE}.child_invoice_paid_amt ;;
  }
  measure: dispute_paid_amount {
    type: sum
    value_format_name: usd_0
    sql: ${child_invoice_paid_amt} ;;
  }
  measure: recovery_percentage {
    type: number
    value_format_name: percent_1
    sql: (${paid_amt} + ${dispute_paid_amount}) / iff(${total_invoice_amt} = 0, null, ${total_invoice_amt}) ;;
    html: {{recovery_percentage._rendered_value}} <br> <p style="font-size:12px"> {{total_dollars_till_80_perc._rendered_value}} Needed for 80% </p>;;
    drill_fields: [warranty_work_orders_and_claims.dynamic_axis
      , warranty_work_orders_and_claims.reference_date
      , warranty_work_orders_and_claims.filter_admin
      , warranty_work_orders_and_claims.work_order_id
      , dim_invoices_fleet_opt.invoice_no
      , warranty_work_orders_and_claims.claim_number
      , warranty_work_orders_and_claims.billed_company
      , warranty_work_orders_and_claims.make
      , warranty_work_orders_and_claims.claim_denial_reason
      , total_amt
      , warranty_credits_pending_amount
      , warranty_credits_paid_amount
      , warranty_credits_denied_amount
      , child_invoice_no
      , child_invoice_paid_amt
    ]
  }
  measure: recovery_percentage_for_overview {
    type: number
    value_format_name: percent_1
    sql: (${paid_amt} + ${dispute_paid_amount}) / iff(${total_invoice_amt} = 0, null, ${total_invoice_amt}) ;;
    html: {{recovery_percentage._rendered_value}} <br> <p style="font-size:12px"> {{total_dollars_till_80_perc._rendered_value}} Needed for 80% </p>;;
    drill_fields: [
      warranty_work_orders_and_claims.market
      , warranty_work_orders_and_claims.reference_date
      , warranty_work_orders_and_claims.filter_admin
      , warranty_work_orders_and_claims.work_order_id
      , dim_invoices_fleet_opt.invoice_no
      , warranty_work_orders_and_claims.claim_number
      , warranty_work_orders_and_claims.billed_company
      , warranty_work_orders_and_claims.make
      , warranty_work_orders_and_claims.claim_denial_reason
      , total_amt
      , warranty_credits_pending_amount
      , warranty_credits_paid_amount
      , warranty_credits_denied_amount
      , child_invoice_no
      , child_invoice_paid_amt
    ]
  }
  measure: denial_rate {
    type: number
    value_format_name: percent_1
    sql: ${denied_amt} / iff(${total_invoice_amt_on_closed_claims} = 0, null, ${total_invoice_amt_on_closed_claims}) ;;
    html: {{denial_rate._rendered_value}} <br> <p style="font-size:12px"> {{denied_amt._rendered_value}} Denied Total </p>;;
    drill_fields: [warranty_work_orders_and_claims.dynamic_axis
      , warranty_work_orders_and_claims.reference_date
      , warranty_work_orders_and_claims.filter_admin
      , warranty_work_orders_and_claims.work_order_id
      , dim_invoices_fleet_opt.invoice_no
      , warranty_work_orders_and_claims.claim_number
      , warranty_work_orders_and_claims.billed_company
      , warranty_work_orders_and_claims.make
      , warranty_work_orders_and_claims.claim_denial_reason
      , total_amt
      , warranty_credits_paid_amount
      , warranty_credits_denied_amount
    ]
  }
  measure: denial_rate_for_overview {
    type: number
    value_format_name: percent_1
    sql: ${denied_amt} / iff(${total_invoice_amt_on_closed_claims} = 0, null, ${total_invoice_amt_on_closed_claims}) ;;
    html: {{denial_rate._rendered_value}} <br> <p style="font-size:12px"> {{denied_amt._rendered_value}} Denied Total </p>;;
    drill_fields: [
      warranty_work_orders_and_claims.market
      , warranty_work_orders_and_claims.reference_date
      , warranty_work_orders_and_claims.filter_admin
      , warranty_work_orders_and_claims.work_order_id
      , dim_invoices_fleet_opt.invoice_no
      , warranty_work_orders_and_claims.claim_number
      , warranty_work_orders_and_claims.billed_company
      , warranty_work_orders_and_claims.make
      , warranty_work_orders_and_claims.claim_denial_reason
      , total_amt
      , warranty_credits_paid_amount
      , warranty_credits_denied_amount
    ]
  }
  measure: dispute_performance {
    type: number
    value_format_name: percent_1
    sql: ${dispute_paid_amount} / iff(${denied_amt} = 0, null, ${denied_amt}) ;;
    drill_fields: [warranty_work_orders_and_claims.dynamic_axis
      , warranty_work_orders_and_claims.reference_date
      , warranty_work_orders_and_claims.filter_admin
      , warranty_work_orders_and_claims.work_order_id
      , dim_invoices_fleet_opt.invoice_no
      , warranty_work_orders_and_claims.claim_number
      , warranty_work_orders_and_claims.billed_company
      , warranty_work_orders_and_claims.make
      , warranty_credits_paid_amount
      , warranty_credits_denied_amount
      , child_invoice_no
      , child_invoice_paid_amt
    ]
  }
  measure: dispute_performance_for_overview {
    type: number
    value_format_name: percent_1
    sql: ${dispute_paid_amount} / iff(${denied_amt} = 0, null, ${denied_amt}) ;;
    drill_fields: [
      warranty_work_orders_and_claims.market
      , warranty_work_orders_and_claims.reference_date
      , warranty_work_orders_and_claims.filter_admin
      , warranty_work_orders_and_claims.work_order_id
      , dim_invoices_fleet_opt.invoice_no
      , warranty_work_orders_and_claims.claim_number
      , warranty_work_orders_and_claims.billed_company
      , warranty_work_orders_and_claims.make
      , warranty_credits_paid_amount
      , warranty_credits_denied_amount
      , child_invoice_no
      , child_invoice_paid_amt
    ]
  }
  measure: count {
    type: count
  }
  measure: count_pending {
    type: count
    filters: [warranty_credits_pending_amount: ">0"]
  }
  measure: count_denied {
    type: count
    filters: [warranty_credits_denied_amount: ">0"]
    drill_fields: [
      warranty_work_orders_and_claims.market
      , warranty_work_orders_and_claims.reference_date
      , warranty_work_orders_and_claims.filter_admin
      , warranty_work_orders_and_claims.work_order_id
      , dim_invoices_fleet_opt.invoice_no
      , warranty_work_orders_and_claims.claim_number
      , warranty_work_orders_and_claims.billed_company
      , warranty_work_orders_and_claims.make
      , warranty_work_orders_and_claims.claim_denial_reason
      , total_amt
      , warranty_credits_paid_amount
      , warranty_credits_denied_amount
    ]
  }
  measure: ytd_claim_comparison {
    type: sum
    sql: (${warranty_credits_pending_amount} + ${warranty_credits_paid_amount} + ${warranty_credits_denied_amount}) ;;
    value_format_name: usd_0
    filters: [warranty_work_orders_and_claims.show_in_ytd_comparison: "Yes"]
  }
  dimension: days_into_year {
    type: number
    sql: datediff(day, date_trunc(year, current_date), current_date) ;;
  }
  dimension: days_left_in_year {
    type: number
    sql: datediff(day, current_date, date_trunc(year, dateadd(year, 1, current_date))) ;;
  }
  measure: remaining_year_claim_projection {
    type: number
    value_format_name: usd
    sql: (${total_invoice_amt} / ${days_into_year}) * ${days_left_in_year}  ;;
  }
  dimension: eighty_perc_of_claim {
    type: number
    value_format_name: usd
    sql: (${warranty_credits_pending_amount} + ${warranty_credits_paid_amount} + ${warranty_credits_denied_amount}) * 0.8 ;;
  }
  dimension: dollars_till_80_perc {
    type: number
    value_format_name: usd
    sql: ${eighty_perc_of_claim} - (${warranty_credits_paid_amount} + ${child_invoice_paid_amt}) ;;
  }
  measure: total_dollars_till_80_perc {
    type: sum
    value_format_name: usd_0
    sql: ${dollars_till_80_perc} ;;
  }

  dimension: is_appealed {
    type: yesno
    sql: iff(${child_invoice_no} <> '', TRUE, FALSE) ;;
  }

  dimension: warranty_state {
    type: string
    sql:
    case
      when ${total_amt} = ${warranty_credits_pending_amount} then 'Pending'
      when ${total_amt} = ${warranty_credits_denied_amount} and ${is_appealed} = false then 'Full Denial'
      when ${total_amt} = ${warranty_credits_denied_amount} and ${is_appealed} then 'Appealed Full Denial'
      when ${total_amt} = ${warranty_credits_paid_amount} then 'Paid'
      when ${warranty_credits_paid_amount} > 0 and ${warranty_credits_denied_amount} > 0 and ${is_appealed} = false then 'Short Pay'
      when ${warranty_credits_paid_amount} > 0 and ${warranty_credits_denied_amount} > 0 and ${is_appealed} then 'Appealed Short Pay'
      else 'Pre-File Denial' end ;;
  }
}
