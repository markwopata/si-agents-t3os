view: service_invoice_asset_credits {
    derived_table: {
      sql:
          select
          i.invoice_id,
          SUM(li.amount) as line_amount,
          SUM(cnli.credit_amount) as credit_amount

        FROM
        es_warehouse.public.invoices i
        left join es_warehouse.public.line_items li
        on i.invoice_id = li.invoice_id
        left join es_warehouse.public.credit_note_line_items cnli
        on li.line_item_id = cnli.line_item_id

        where cnli.line_item_type_id in (11, 13, 25, 26)

        GROUP BY i.invoice_id;;
    }

    dimension: invoice_id {
      primary_key: yes
      type: number
      sql: ${TABLE}."INVOICE_ID" ;;
    }

    measure: invoice_asset_amount {
      type: sum
      sql: ${TABLE}."LINE_AMOUNT" ;;
    }

    measure: invoice_asset_credit_amount {
      type: sum
      sql: ${TABLE}."CREDIT_AMOUNT" ;;
    }


  }
