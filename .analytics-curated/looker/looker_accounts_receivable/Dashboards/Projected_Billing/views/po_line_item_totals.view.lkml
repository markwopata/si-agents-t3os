view: po_line_item_totals {
  derived_table: {
    sql:
    with invoice_info as (
     SELECT
        i.billing_approved_date,
        i.invoice_no,
        i.invoice_id
     FROM ES_WAREHOUSE.PUBLIC.INVOICES i
     WHERE i.billing_approved = TRUE and i.paid = FALSE and
          {% condition company_id %} i.company_id {% endcondition %}
     GROUP BY
        i.billing_approved_date,
        i.invoice_no,
        i.invoice_id
    ),
    line_item_info as (
    SELECT
        i.*,
        v.line_item_id,
        v.rental_id,
        t.name,
        v.branch_id,
        v.asset_id,
        v.description,
        r.location_id,
        v.amount as amount,
        v.tax_amount as tax_amount,
        cn.total_credit_amount,
        ROW_NUMBER() OVER(PARTITION BY i.invoice_id, v.line_item_id
                                 ORDER BY v.amount DESC) AS rank
      FROM invoice_info i
        JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS v on v.invoice_id = i.invoice_id
        left join ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES t on v.line_item_type_id = t.line_item_type_id
        left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_ASSIGNMENTS e on v.rental_id = e.rental_id and v.asset_id = e.asset_id
        left join ES_WAREHOUSE.PUBLIC.RENTAL_LOCATION_ASSIGNMENTS r on e.rental_id = r.rental_id
        left join ES_WAREHOUSE.PUBLIC.CREDIT_NOTES cn on i.invoice_id = cn.originating_invoice_id
      WHERE v.amount > 0
      GROUP BY
        i.invoice_no,
        i.invoice_id,
        i.billing_approved_date,
        v.line_item_id,
        v.rental_id,
        t.name,
        v.branch_id,
        v.asset_id,
        v.description,
        r.location_id,
        v.amount,
        v.tax_amount,
        cn.total_credit_amount
        )
      SELECT *
      FROM line_item_info
      where rank = 1;;
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

      dimension: key {
        type: string
        primary_key: yes
        sql: CONCAT(TO_VARCHAR(${line_item_id}), '_', TO_VARCHAR(${invoice_no})) ;;
      }

      dimension: line_item_id {
        type: number
        sql: ${TABLE}."LINE_ITEM_ID" ;;
      }

      dimension: rental_id {
        type: number
        sql: ${TABLE}."RENTAL_ID" ;;
      }

      dimension: invoice_id {
        type: number
        sql: ${TABLE}."INVOICE_ID" ;;
      }

      dimension: invoice_no {
        type: string
        sql: ${TABLE}."INVOICE_NO" ;;
      }

      dimension: name {
        type: string
        sql: ${TABLE}."NAME" ;;
      }

      dimension: amount_raw {
        hidden: yes
        type: number
        sql: ${TABLE}."AMOUNT" ;;
        value_format_name: usd
      }

      dimension: tax_amount_raw {
        hidden: yes
        type: number
        sql: ${TABLE}."TAX_AMOUNT" ;;
        value_format_name: usd
      }

      dimension: total_credit_amount_raw {
        hidden: yes
        type: number
        sql: ${TABLE}."TOTAL_CREDIT_AMOUNT" ;;
        value_format_name: usd
      }

      dimension: discription {
        type: string
        sql: ${TABLE}."DESCRIPTION" ;;
      }

      dimension: branch_id {
        type: number
        sql: ${TABLE}."BRANCH_ID" ;;
      }

      dimension: asset_id {
        type: number
        sql: ${TABLE}."ASSET_ID" ;;
      }

      dimension: location_id {
        type: number
        sql: ${TABLE}."LOCATION_ID" ;;
      }

      dimension_group: billing_approved_date {
        label: "Billing Approved Date"
        description: "This field is the billing approved date for the invoice."
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
        sql: CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
      }

      measure: amount {
        type: sum_distinct
        sql: ${amount_raw} ;;
        value_format_name: usd
      }

      measure: tax_amount {
        type: sum_distinct
        sql: ${tax_amount_raw} ;;
        value_format_name: usd
      }

      measure: credit_amount {
        type: sum_distinct
        sql: ${total_credit_amount_raw} ;;
        value_format_name: usd
      }

      measure: amount_with_credits_applied {
        type: number
        sql: ${amount} - ${credit_amount} ;;
        value_format_name: usd
      }

  }
