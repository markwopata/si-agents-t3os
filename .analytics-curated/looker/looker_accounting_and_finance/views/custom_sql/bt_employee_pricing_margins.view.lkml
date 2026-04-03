view: bt_employee_pricing_margins {
  derived_table: {
    sql:
      SELECT *
      FROM (
          SELECT DISTINCT
              CASE
                  WHEN SA3.DocumentType = 'Invoice' THEN OH.OrderNumber
                  ELSE NULL
              END AS SalesOrder,
              NULL AS CreditNote,
              INITCAP(C.Name) AS Customer,  -- Capitalize names properly
              IH.TotalAmount,
              IH.TotalMargin AS Margin,
              CAST(SA3.DocumentDate AS DATE) AS DateSoldorCredited,
              UO.Name AS CreatedBy
          FROM analytics.bt_dbo.SalesAnalysis3 SA3
          JOIN analytics.bt_dbo.InvoiceHeader IH
            ON SA3.DocumentID = IH.InvoiceID
           AND SA3.DocumentType = 'Invoice'
          LEFT JOIN analytics.bt_dbo.OrderHeader OH
            ON IH.InvoiceID = OH.InvoiceID
          LEFT JOIN analytics.bt_dbo.Customer C
            ON SA3.CustomerID = C.CustomerID
          LEFT JOIN analytics.bt_dbo.Users UO
            ON OH.CreatedByID = UO.UserID
          JOIN analytics.bt_dbo.SellPriceProfile
            ON SellPriceProfile.SellPriceProfileID = C.SellPriceProfileID
          WHERE
              (SellPriceProfile.Name ILIKE '%Employee Pricing%' OR C.udfEmployee = 1)
              AND C.Deleted = 0
              AND SA3.DocumentDate = DATEADD(DAY, -1, CURRENT_DATE)
              AND (IH.TotalMargin < 20 OR OH.CreatedByID = C.udfuserid)

      UNION

      SELECT DISTINCT
      NULL AS SalesOrder,
      CASE
      WHEN SA3.DocumentType = 'Credit' THEN CNH.CreditNoteNumber
      ELSE NULL
      END AS CreditNote,
      INITCAP(C.Name) AS Customer,
      -CNH.TotalAmount AS TotalAmount,
      CNH.TotalMargin AS Margin,
      CAST(SA3.DocumentDate AS DATE) AS DateSoldorCredited,
      UC.Name AS CreatedBy
      FROM analytics.bt_dbo.SalesAnalysis3 SA3
      JOIN analytics.bt_dbo.CreditNoteHeader CNH
      ON SA3.DocumentID = CNH.CreditNoteID
      AND SA3.DocumentType = 'Credit'
      LEFT JOIN analytics.bt_dbo.Customer C
      ON SA3.CustomerID = C.CustomerID
      LEFT JOIN analytics.bt_dbo.Users UC
      ON CNH.CreatedByID = UC.UserID
      JOIN analytics.bt_dbo.SellPriceProfile
      ON SellPriceProfile.SellPriceProfileID = C.SellPriceProfileID
      WHERE
      (SellPriceProfile.Name ILIKE '%Employee Pricing%' OR C.udfEmployee = 1)
      AND C.Deleted = 0
      AND SA3.DocumentDate = DATEADD(DAY, -1, CURRENT_DATE)
      AND (CNH.TotalMargin < 20 OR CNH.CreatedByID = C.udfuserid)
      ) t
      ORDER BY DateSoldorCredited DESC
      ;;
  }

  dimension: sales_order {
    type: string
    sql: ${TABLE}.SalesOrder ;;
  }

  dimension: credit_note {
    type: string
    sql: ${TABLE}.CreditNote ;;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}.Customer ;;
    label: "Customer Name"
  }

  measure: total_amount {
    type: sum
    value_format_name: usd  # $ prefix, 2 decimal places
    sql: ${TABLE}.TotalAmount ;;
    label: "Total Amount"
  }

  dimension: margin {
    type: number
    value_format: "0.00%"  # Format as percentage (e.g., 0.0956 → 9.56%)
    sql: ${TABLE}.Margin / 100 ;;
    label: "Margin"
  }

  dimension: date_sold_or_credited {
    type: date
    sql: ${TABLE}.DateSoldorCredited ;;
    label: "Date Sold or Credited"
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}.CreatedBy ;;
    label: "Created By"
  }
}
