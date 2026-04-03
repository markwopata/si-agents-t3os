view: budget_expense_lines {
 derived_table: {
  sql:
 SELECT
    BUDGET_YEAR
    ,EXPENSE_LINE_ID
    ,EXPENSE_LINE_NAME
    ,GL_MAPPING
    ,GL_ACCOUNT_TYPE
    ,COST_CAPTURE_ID
    ,concat(GL_MAPPING,' - ',EXPENSE_LINE_NAME) as GL_AND_EXPENSE_LINE

FROM
    analytics.corporate_budget.budget_expense_lines

ORDER BY
    BUDGET_YEAR
    ,EXPENSE_LINE_NAME
     ;;
}
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
   dimension: Budget_Year {
     type: string
     sql: ${TABLE}.BUDGET_YEAR ;;
   }

  dimension: Expense_Line_ID {
    type: string
    sql: ${TABLE}.EXPENSE_LINE_ID ;;
  }
  dimension: Expense_Line_Name{
    type: string
    sql: ${TABLE}.EXPENSE_LINE_NAME ;;
  }
  dimension: GL_Mapping{
    type: string
    sql: ${TABLE}.GL_MAPPING ;;
  }
  dimension: GL_Acccount_Type{
    type: string
    sql: ${TABLE}.GL_ACCOUNT_TYPE ;;
  }
  dimension: Cost_Capture_ID{
    type: string
    sql: ${TABLE}.COST_CAPTURE_ID ;;
  }
  dimension: GL_and_Expense_Line{
    type: string
    sql: ${TABLE}.GL_AND_EXPENSE_LINE ;;
  }

      measure: count {
        type: count
        drill_fields: [detail*]

      }
  set: detail {
    fields: [
      Budget_Year,
      Expense_Line_ID,
      Expense_Line_Name,
      GL_Mapping,
      GL_Acccount_Type,
      Cost_Capture_ID,
      GL_and_Expense_Line
    ]
  }
}
