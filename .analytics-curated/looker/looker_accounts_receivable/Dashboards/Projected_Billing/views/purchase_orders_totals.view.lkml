view: purchase_orders_totals{
    derived_table: {
          sql:
      with po_info as (
      select
        purchase_order_id,
        name as po_name,
        coalesce(sum(budget_amount),0) as budget_amount
      from
        ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS
      where
        {% condition company_id %} COMPANY_ID {% endcondition %}
      group by
        purchase_order_id,
        name
      )
      ,budget_invoice_combine as (
      SELECT
        i.BILLING_APPROVED_DATE,
        pi.purchase_order_id,
        pi.po_name,
        i.invoice_id as invoice_id,
        i.invoice_no,
        i.billed_amount,
        pi.budget_amount,
        'ES' as rental_type
      FROM
        po_info pi
        JOIN ES_WAREHOUSE.PUBLIC.INVOICES i on i.purchase_order_id = pi.purchase_order_id
        JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON i.purchase_order_id = po.purchase_order_id
        left join ES_WAREHOUSE.PUBLIC.USERS u on i.ordered_by_user_id = u.user_id
      WHERE
          {% condition company_id %} u.COMPANY_ID {% endcondition %}
          and i.billing_approved_date >= po.start_date
      GROUP BY
          i.BILLING_APPROVED_DATE,
          pi.purchase_order_id,
          pi.po_name,
          i.billed_amount,
          pi.budget_amount,
          i.invoice_id,
          i.invoice_no )
      ,budget_by_po as (
      SELECT
        po_name,
        purchase_order_id,
        budget_amount,
        sum(billed_amount) as cumulative_amount,
        budget_amount - cumulative_amount as remaining_budget
      FROM
        budget_invoice_combine
      GROUP BY
        po_name,
        purchase_order_id,
        budget_amount
      )
      select
          po_name,
          purchase_order_id,
          coalesce(budget_amount,0) as budget_amount,
          coalesce(remaining_budget,0) as budget_remaining,
          coalesce(cumulative_amount,0) as cumulative_amount,
          case when budget_amount > 0 then ((coalesce(budget_amount,0) - coalesce(sum(cumulative_amount),0)) / coalesce(budget_amount,0)) else 0 end as pcnt_budget_remaining
      from
          budget_by_po
      group by
          po_name,
          purchase_order_id,
          budget_amount,
          remaining_budget,
          cumulative_amount ;;
    }

      filter: company_id {
        type: number
        sql: {% condition company_id %} ${main_company_id} {% endcondition %} ;;
      }

      dimension: main_company_id {
          type: number
          hidden: yes
          sql: ${companies.company_id} ;;
      }

      dimension: po_name {
        label: "PO No"
        type: string
        sql: COALESCE(${TABLE}."PO_NAME", 'Pending') ;;
      }

      dimension: purchase_order_id {
        type: number
        sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
      }

      dimension: total_spend {
        label: "PO Spend To Date"
        type: number
        sql: ${TABLE}."CUMULATIVE_AMOUNT" ;;
        value_format_name: usd
      }

      dimension: budget_amount {
        label: "Original PO Value"
        type: number
        sql: ${TABLE}."BUDGET_AMOUNT" ;;
        value_format_name: usd
      }


      dimension: budget_remaining {
        label: "PO Value Remaining"
        type: number
        sql: ${TABLE}."BUDGET_REMAINING" ;;
        value_format_name: usd
      }

 }
