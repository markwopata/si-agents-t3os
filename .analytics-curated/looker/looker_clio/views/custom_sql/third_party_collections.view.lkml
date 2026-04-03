view: third_party_collections {
    derived_table: {
      sql:
      WITH first_assignment AS (
        SELECT company_id, assignment_timestamp
        FROM analytics.bi_ops.collectors_inside_collections
        WHERE collector_id IN (3401, 3501, 3601, 3701)
        QUALIFY ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY assignment_timestamp) = 1
      ),


        snapshot_clean AS (
        SELECT
        company_id,
        snapshot_date,
        final_collector,
        CASE
        WHEN final_collector ILIKE '%DAL%' THEN 'DAL'
        WHEN final_collector ILIKE '%CCC%' THEN 'CCC'
        ELSE 'INTERNAL'
        END AS assignment_type
        FROM analytics.bi_ops.collector_customer_assignments_daily_snapshot
        ),

        snapshot_with_lag AS (
        SELECT
        company_id,
        snapshot_date,
        assignment_type,
        LAG(assignment_type) OVER (
        PARTITION BY company_id
        ORDER BY snapshot_date
        ) AS prev_assignment_type
        FROM snapshot_clean
        ),

        returned_accounts AS (
        SELECT
        company_id,
        MIN(snapshot_date) AS first_recall_date
        FROM snapshot_with_lag
        WHERE prev_assignment_type IN ('CCC','DAL')
        AND assignment_type = 'INTERNAL'
        GROUP BY company_id
        ),


        placement_starts AS (
        SELECT
        company_id,
        snapshot_date AS placement_start_date,
        assignment_type AS third_party_assigned
        FROM snapshot_with_lag
        WHERE assignment_type IN ('CCC','DAL')
        AND (prev_assignment_type IS NULL OR prev_assignment_type NOT IN ('CCC','DAL'))
        ),

        placement_ends AS (
        SELECT
        company_id,
        snapshot_date AS placement_end_date,
        prev_assignment_type AS third_party_assigned
        FROM snapshot_with_lag
        WHERE prev_assignment_type IN ('CCC','DAL')
        AND assignment_type NOT IN ('CCC','DAL')
        ),

        placement_windows AS (
        SELECT
        s.company_id,
        s.third_party_assigned,
        s.placement_start_date,
        MIN(e.placement_end_date) AS placement_end_date
        FROM placement_starts s
        LEFT JOIN placement_ends e
        ON  s.company_id = e.company_id
        AND s.third_party_assigned = e.third_party_assigned
        AND e.placement_end_date > s.placement_start_date
        GROUP BY
        s.company_id,
        s.third_party_assigned,
        s.placement_start_date
        ),

              vendor_companies AS (
        SELECT
          company_id,
          MAX_BY(third_party_assigned, placement_start_date) AS third_party_assigned
        FROM placement_windows
        GROUP BY company_id
      ),



        legal_customers AS (
        SELECT DISTINCT CAST(customer_number AS STRING) AS customer_number
        FROM financial_systems.clio_gold.matters
        ),


        invoices_core AS (
        SELECT
        i.invoice_id,
        i.company_id,
        i.invoice_no,
        i.date_created                        AS invoice_created_date,
        i.invoice_date,
        i.billed_amount                       AS invoice_amount,
        i.owed_amount                         AS current_balance,
        (i.extended_data:in_dispute)::boolean AS dispute_flag
        FROM es_warehouse.public.invoices i
        ),

                invoice_in_window AS (
        SELECT
        ic.invoice_id,
        MIN(pw.placement_start_date) AS window_start_for_invoice,
        MIN(pw.placement_end_date)   AS window_end_for_invoice
        FROM invoices_core ic
        JOIN placement_windows pw
        ON ic.company_id = pw.company_id
        AND ic.invoice_created_date >= pw.placement_start_date
        AND (pw.placement_end_date IS NULL
        OR ic.invoice_created_date < pw.placement_end_date)
        GROUP BY ic.invoice_id
        ),


        base_payments AS (
        SELECT
        pa.invoice_id,
        pa.amount                                AS applied_amount,
        pa.date                                  AS application_date,
        COALESCE(p.payment_date, p.date_created) AS payment_date,
        p.reference,
        ba.intacct_undepfundsacct,
        ic.company_id
        FROM es_warehouse.public.payment_applications pa
        JOIN es_warehouse.public.payments p
        ON pa.payment_id = p.payment_id
        LEFT JOIN es_warehouse.public.bank_account_erp_refs ba
        ON p.bank_account_id = ba.bank_account_id
        JOIN invoices_core ic
        ON pa.invoice_id = ic.invoice_id
        WHERE pa.reversed_date IS NULL
        ),

        payments_while_agency AS (
        SELECT
        pw.company_id,
        pw.third_party_assigned,
        pw.placement_start_date,
        pw.placement_end_date,
        bp.invoice_id,
        bp.applied_amount,
        bp.application_date,
        bp.payment_date,
        bp.reference,
        bp.intacct_undepfundsacct
        FROM placement_windows pw
        JOIN base_payments bp
        ON bp.company_id = pw.company_id
        AND bp.payment_date >= pw.placement_start_date
        AND (
        pw.placement_end_date IS NULL
        OR bp.payment_date < pw.placement_end_date
        )
        ),

        payments_agg AS (
        SELECT
        invoice_id,
        SUM(CASE
        WHEN intacct_undepfundsacct = '1205'
        THEN applied_amount ELSE 0
        END) AS adjustment_amount,
        SUM(CASE
        WHEN intacct_undepfundsacct <> '1205'
        OR intacct_undepfundsacct IS NULL
        THEN applied_amount ELSE 0
        END) AS payment_amount,
        MAX(payment_date)     AS latest_payment_date,
        MAX(application_date) AS latest_application_date,
        NULLIF(
        LISTAGG(DISTINCT reference, ' | ')
        WITHIN GROUP (ORDER BY reference),
        ''
        ) AS reference
        FROM payments_while_agency
        GROUP BY invoice_id
        ),


        credit_notes_joined AS (
        SELECT
        cn.originating_invoice_id AS invoice_id,
        cn.company_id,
        COALESCE(cn.credit_note_date, cn.date_created) AS credit_note_date,
        cn.memo,
        cn.total_credit_amount,
        cn.tax_amount,
        cn.line_item_amount
        FROM es_warehouse.public.credit_notes cn
        ),

        credit_notes_while_agency AS (
        SELECT
        pw.company_id,
        pw.third_party_assigned,
        pw.placement_start_date,
        pw.placement_end_date,
        cnj.invoice_id,
        cnj.credit_note_date,
        cnj.memo,
        cnj.total_credit_amount,
        cnj.tax_amount,
        cnj.line_item_amount
        FROM placement_windows pw
        JOIN credit_notes_joined cnj
        ON cnj.company_id = pw.company_id
        AND cnj.credit_note_date >= pw.placement_start_date
        AND (
        pw.placement_end_date IS NULL
        OR cnj.credit_note_date < pw.placement_end_date
        )
        ),

        credit_notes_agg AS (
        SELECT
        invoice_id,
        SUM(total_credit_amount) AS credit_note_total_amount,
        MAX(credit_note_date)    AS latest_credit_note_date,
        NULLIF(
        LISTAGG(DISTINCT memo, ' || '),
        ''
        ) AS credit_note_memo
        FROM credit_notes_while_agency
        GROUP BY invoice_id
        )


        SELECT
        ic.company_id                                        AS internal_account_id,
        c.name                                               AS customer_name,

        vc.third_party_assigned,
        pa.reference,

        /* Legal category from Clio matters */
        CASE
        WHEN lc.customer_number IS NOT NULL THEN 'Legal'
        ELSE 'Not Legal'
        END                                                 AS category,

        fa.assignment_timestamp                              AS placement_date,

        ra.first_recall_date                                 AS recall_date,
        CASE
        WHEN ra.company_id IS NOT NULL THEN TRUE
        ELSE FALSE
        END                                                 AS returned_flag,

        ic.invoice_id,
        ic.invoice_no,
        ic.invoice_created_date,
        ic.invoice_date,
        ic.invoice_amount,
        ic.current_balance,
        ic.dispute_flag,


        (ic.invoice_created_date >= fa.assignment_timestamp) AS alert_flag,
        CASE
        WHEN iw.invoice_id IS NOT NULL THEN TRUE
        ELSE FALSE
        END AS alert_flag_window,

        COALESCE(pa.payment_amount, 0)                       AS payment_amount,
        COALESCE(pa.adjustment_amount, 0)                    AS adjustment_amount,

        pa.latest_payment_date,
        pa.latest_application_date,

        COALESCE(ca.credit_note_total_amount, 0)             AS credit_note_total_amount,
        ca.latest_credit_note_date,
        ca.credit_note_memo

        FROM invoices_core ic
        JOIN first_assignment fa
        ON ic.company_id = fa.company_id
        JOIN vendor_companies vc
        ON ic.company_id = vc.company_id
        LEFT JOIN payments_agg pa
        ON ic.invoice_id = pa.invoice_id
        LEFT JOIN credit_notes_agg ca
        ON ic.invoice_id = ca.invoice_id
        LEFT JOIN es_warehouse.public.companies c
        ON ic.company_id = c.company_id
        LEFT JOIN legal_customers lc
        ON CAST(ic.company_id AS STRING) = lc.customer_number
        LEFT JOIN returned_accounts ra
        ON ic.company_id = ra.company_id
        LEFT JOIN invoice_in_window iw
        ON ic.invoice_id = iw.invoice_id
        WHERE vc.third_party_assigned IN ('DAL','CCC')
        ;;
    }



  dimension: internal_account_id {
    label: "Company ID"
    type: number
    sql: ${TABLE}.internal_account_id ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}.customer_name ;;
  }

  dimension: third_party_assigned {
    label: "Vendor (Assigned)"
    type: string
    sql: ${TABLE}.third_party_assigned ;;
  }

  dimension: reference {
    label: "Reference"
    type: string
    sql: ${TABLE}.reference ;;
  }

  dimension: category {
    label: "Category (Legal / Not Legal)"
    type: string
    sql: ${TABLE}.category ;;
    suggestions: ["Legal", "Not Legal"]
    suggestable: yes
  }

  dimension: placement_date {
    type: date
    sql: ${TABLE}.placement_date ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}.invoice_id ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}.invoice_no ;;
  }

  dimension: invoice_created_date {
    type: date
    sql: ${TABLE}.invoice_created_date ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}.invoice_date ;;
  }

  dimension: invoice_amount {
    type: number
    value_format_name: "usd"
    sql: ${TABLE}.invoice_amount ;;
  }

  dimension: current_balance {
    type: number
    value_format_name: "usd"
    sql: ${TABLE}.current_balance ;;
  }

  dimension: dispute_flag {
    type: yesno
    sql: ${TABLE}.dispute_flag ;;
  }

  dimension: alert_flag {
    label: "Post-Assignment Invoice Alert"
    type: yesno
    sql: ${TABLE}.alert_flag ;;
  }

  dimension: payment_amount {
    type: number
    value_format_name: "usd"
    sql: ${TABLE}.payment_amount ;;
  }

  dimension: adjustment_amount {
    type: number
    value_format_name: "usd"
    sql: ${TABLE}.adjustment_amount ;;
  }

  dimension: latest_payment_date {
    label: "Payment Date"
    type: date
    sql: ${TABLE}.latest_payment_date ;;
  }

  dimension: latest_application_date {
    type: date
    sql: ${TABLE}.latest_application_date ;;
  }

  dimension: credit_note_total_amount {
    label: "Credit Notes Amount"
    type: number
    value_format_name: "usd"
    sql: ${TABLE}.credit_note_total_amount ;;
  }

  dimension: latest_credit_note_date {
    label: "Credit Note Date"
    type: date
    sql: ${TABLE}.latest_credit_note_date ;;
  }

  dimension: credit_note_memo {
    label: "Credit Note Memo(s)"
    type: string
    sql: ${TABLE}.credit_note_memo ;;
  }

  measure: payments_total {
    type: sum
    sql: ${payment_amount} ;;
    value_format_name: "usd"
  }

  measure: adjustments_total {
    type: sum
    sql: ${adjustment_amount} ;;
    value_format_name: "usd"
  }

  measure: invoices_total {
    type: sum
    sql: ${invoice_amount} ;;
    value_format_name: "usd"
  }

  measure: credit_notes_total {
    type: sum
    sql: ${credit_note_total_amount} ;;
    value_format_name: "usd"
  }

  dimension: recall_date {
    label: "Date Moved Back (Recall Date)"
    type: date
    sql: ${TABLE}.recall_date ;;
  }

  dimension: returned_flag {
    label: "Returned From 3rd Party"
    type: yesno
    sql: ${TABLE}.returned_flag ;;
  }

  dimension: alert_flag_window {
    label: "Invoice Created While With Agency (Window-Based)"
    type: yesno
    sql: ${TABLE}.alert_flag_window ;;
  }

}
