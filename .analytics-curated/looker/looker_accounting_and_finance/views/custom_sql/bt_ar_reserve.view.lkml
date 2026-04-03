view: bt_ar_reserve {
  derived_table: {
    sql:
SELECT DISTINCT
  B.BranchCode,
  B.Name AS BranchName,
  C.name AS CustomerName,
  A.DocumentNumber AS Invoice_Credit_Number,
  A.TaxAmount,
  (A.OriginalAmount - A.TaxAmount) AS GoodsTotal,
  A.OriginalAmount,
  A.AmountOutstanding,
  A.TransactionDate AS Invoice_Credit_Date,
COALESCE(IH.DueDate, CNH.DueDate, LAST_DAY(DATEADD(MONTH, 1, A.TransactionDate), 'MONTH')) AS Invoice_Credit_Due_Date,
  A.FullyPaidActualDate Paid_in_Full_Date,
  CASE
    WHEN COALESCE(A.CashTransaction, C.CashAccount) = 1 THEN 'Cash'
    WHEN COALESCE(A.CashTransaction, C.CashAccount) = 0 THEN 'Credit'
  END AS Cash_Credit_Sale,
  R.Name As DirectPosting
FROM ANALYTICS.BT_DBO.AccountsTransaction AS A
LEFT JOIN ANALYTICS.BT_DBO.Customer AS C ON C.CustomerID = A.CustomerID
LEFT JOIN ANALYTICS.BT_DBO.InvoiceHeader AS IH ON CAST(IH.InvoiceNumber AS VARCHAR(50)) = A.DocumentNumber
  AND A.TransactionType = 1
LEFT JOIN ANALYTICS.BT_DBO.CreditNoteHeader AS CNH ON A.DocumentNumber = CAST(CNH.CreditNoteNumber AS VARCHAR(50))
  AND A.TransactionType = 2
LEFT JOIN ANALYTICS.BT_DBO.SalesAnalysis3 AS SA ON A.CustomerID = SA.CustomerID
  AND A.DocumentID = SA.DocumentID
LEFT JOIN ANALYTICS.BT_DBO.Branch AS B ON B.BranchID = A.BranchID
LEFT JOIN ANALYTICS.BT_DBO.Reason AS R ON A.ReasonID = R.ReasonID
WHERE (A.TransactionType IN (1, 2) OR (A.TransactionType = 8 AND A.ReasonID = 17))
ORDER BY C.name, A.TransactionDate
    ;;
  }

  dimension: BranchCode {
    label: "Branch Code"
    type: string
    sql: ${TABLE}.BranchCode ;;
  }

  dimension: BranchName {
    label: "Branch Name"
    type: string
    sql: ${TABLE}.BranchName ;;
  }

  dimension: CustomerName {
    label: "Customer Name"
    type: string
    sql: ${TABLE}.CustomerName ;;
  }

  dimension: DocumentNumber {
    label: "Document Number"
    type: string
    sql: ${TABLE}.Invoice_Credit_Number ;;
  }

  dimension: TaxAmount {
    label: "Tax Amount"
    type: number
    value_format_name: usd
    sql: ${TABLE}.TaxAmount ;;
  }

  dimension: GoodsTotal {
    label: "Goods Total"
    type: number
    value_format_name: usd
    sql: ${TABLE}.GoodsTotal ;;
  }

  dimension: OriginalAmount{
    label: "Original Amount"
    type: number
    value_format_name: usd
    sql: ${TABLE}.OriginalAmount ;;
  }

  dimension: AmountOutstanding {
    label: "Amount Outstanding"
    type: number
    value_format_name: usd
    sql: ${TABLE}.AmountOutstanding ;;
  }

  dimension: TransactionDate {
    label: "Transaction Date"
    type: date
    sql: ${TABLE}.Invoice_Credit_Date ;;
  }

  dimension: DueDate {
    label: "Due Date"
    type: date
    sql: ${TABLE}.Invoice_Credit_Due_Date ;;
  }

  dimension: PaidInFullDate {
    label: "Paid in Full Date"
    type: date
    sql: ${TABLE}.Paid_in_Full_Date ;;
  }

  dimension: sale_type {
    label: "Sale Type"
    type: string
    sql: ${TABLE}.Cash_Credit_Sale ;;
  }

  dimension: DirectPosting {
    label: "Direct Posting"
    type: string
    sql: ${TABLE}.DirectPosting ;;
  }

}
