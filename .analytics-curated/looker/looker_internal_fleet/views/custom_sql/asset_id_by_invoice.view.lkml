view: asset_id_by_invoice {
  derived_table: {
    sql:
      with assets_by_invoice as (select asset_id, asset_invoice_url
                    from es_warehouse.public.asset_purchase_history as aph)
      SELECT
          ai.asset_id,
          TRIM(s.value) AS invoice_number -- TRIM to remove any leading/trailing spaces
      FROM
          assets_by_invoice AS ai,
          LATERAL SPLIT_TO_TABLE(ai.asset_invoice_url, ' / ') AS s;;
  }

    dimension: asset_id {
      type: string
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension: invoice_number {
      type: string
      sql: ${TABLE}."INVOICE_NUMBER" ;;
    }
  }
