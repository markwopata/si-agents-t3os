view: equipment_sales_finalized_post_jake_finalized {
  sql_table_name:"ANALYTICS"."COMMISSION_DBT"."RETAIL_COMMISSION_FINAL_ALL" ;;

  dimension: commission_id{
    type: string
    sql: ${TABLE}.commission_id;;
  }

  dimension: line_item_id{
    type: number
    sql: ${TABLE}.line_item_id;;
  }

  dimension: salesperson_user_id{
    type: number
    sql: ${TABLE}.salesperson_user_id;;
  }

  dimension: invoice_id{
    type: number
    sql: ${TABLE}.invoice_id;;
  }

  dimension: invoice_no{
    type: string
    sql: ${TABLE}.invoice_no;;
  }

  dimension: order_id{
    type: number
    sql: ${TABLE}.order_id;;
  }

  dimension: invoice_created_date{
    type: date
    sql: ${TABLE}.invoice_created_date;;
  }

  dimension: order_date{
    type: date
    sql: ${TABLE}.order_date;;
  }

  dimension: market_id{
    type: number
    sql: ${TABLE}.market_id;;
  }

  dimension: market_name{
    type: string
    sql: ${TABLE}.market_name;;
  }

  dimension: parent_market_id{
    type: number
    sql: ${TABLE}.parent_market_id;;
  }

  dimension: parent_market_name{
    type: string
    sql: ${TABLE}.parent_market_name;;
  }

  dimension: region{
    type: number
    sql: ${TABLE}.region;;
  }

  dimension: region_name{
    type: string
    sql: ${TABLE}.region_name;;
  }

  dimension: district{
    type: string
    sql: ${TABLE}.district;;
  }

  dimension: ship_to_state{
    type: string
    sql: ${TABLE}.ship_to_state;;
  }

  dimension: company_id{
    type: number
    sql: ${TABLE}.company_id;;
  }

  dimension: company_name{
    type: string
    sql: ${TABLE}.company_name;;
  }

  dimension: line_item_type_id{
    type: number
    sql: ${TABLE}.line_item_type_id;;
  }

  dimension: line_item_type{
    type: string
    sql: ${TABLE}.line_item_type;;
  }

  dimension: asset_id{
    type: number
    sql: ${TABLE}.asset_id;;
  }

  dimension: invoice_asset_make{
    type: string
    sql: ${TABLE}.invoice_asset_make;;
  }

  dimension: invoice_class_id{
    type: number
    sql: ${TABLE}.invoice_class_id;;
  }

  dimension: invoice_class{
    type: string
    sql: ${TABLE}.invoice_class;;
  }

  dimension: line_item_amount{
    type: number
    sql: ${TABLE}.line_item_amount;;
  }

  dimension: amount{
    type: number
    sql: ${TABLE}.amount;;
  }

  dimension: email_address{
    type: string
    sql: ${TABLE}.email_address;;
  }

  dimension: employee_id{
    type: number
    sql: ${TABLE}.employee_id;;
  }

  dimension: full_name{
    type: string
    sql: ${TABLE}.full_name;;
  }

  dimension: employee_title{
    type: string
    sql: ${TABLE}.employee_title;;
  }

  dimension: transaction_type{
    type: string
    sql: ${TABLE}.transaction_type;;
  }

  dimension: employee_manager_id{
    type: number
    sql: ${TABLE}.employee_manager_id;;
  }

  dimension: employee_manager{
    type: string
    sql: ${TABLE}.employee_manager;;
  }

  dimension: salesperson_type_id{
    type: number
    sql: ${TABLE}.salesperson_type_id;;
  }

  dimension: salesperson_type{
    type: string
    sql: ${TABLE}.salesperson_type;;
  }

  dimension: employee_type{
    type: string
    sql: ${TABLE}.employee_type;;
  }

  dimension: secondary_rep_count{
    type: number
    sql: ${TABLE}.secondary_rep_count;;
  }

  dimension: profit_margin{
    type: number
    sql: ${TABLE}.profit_margin;;
  }

  dimension: nbv{
    type: number
    sql: ${TABLE}.nbv;;
  }

  dimension: floor_rate{
    type: number
    sql: ${TABLE}.floor_rate;;
  }

  dimension: benchmark_rate{
    type: number
    sql: ${TABLE}.benchmark_rate;;
  }

  dimension: online_rate{
    type: number
    sql: ${TABLE}.online_rate;;
  }

  dimension: rate_tier_id{
    type: string
    sql: ${TABLE}.rate_tier_id;;
  }

  dimension: rate_achievement{
    type: string
    sql: ${TABLE}.rate_achievement;;
  }

  dimension: is_exception{
    type: yesno
    sql: ${TABLE}.is_exception;;
  }

  dimension: allocation_cost_center{
    type: string
    sql: ${TABLE}.allocation_cost_center;;
  }

  dimension: commission_rate{
    type: number
    sql: ${TABLE}.commission_rate;;
  }

  dimension: transaction_date{
    type: date
    sql: ${TABLE}.transaction_date;;
  }

  dimension: billing_approved_date{
    type: date
    sql: ${TABLE}.billing_approved_date;;
  }

  dimension: split{
    type: number
    sql: ${TABLE}.split;;
  }

  dimension: transaction_type_id{
    type: number
    sql: ${TABLE}.transaction_type_id;;
  }

  dimension: is_payable{
    type: yesno
    sql: ${TABLE}.is_payable;;
  }

  dimension: is_finalized{
    type: yesno
    sql: ${TABLE}.is_finalized;;
  }

  dimension: reimbursement_factor{
    type: number
    sql: ${TABLE}.reimbursement_factor;;
  }

  dimension: credit_note_line_item_id{
    type: number
    sql: ${TABLE}.credit_note_line_item_id;;
  }

  dimension: transaction_description{
    type: string
    sql: ${TABLE}.transaction_description;;
  }

  dimension: commission_month{
    type: date
    sql: ${TABLE}.commission_month;;
  }

  dimension: commission_amount{
    type: number
    sql: ${TABLE}.commission_amount;;
  }

  dimension: paycheck_date{
    type: date
    sql: ${TABLE}.paycheck_date;;
  }

  dimension: hidden{
    type: yesno
    sql: ${TABLE}.hidden;;
  }

  dimension: manual_adjustment_id{
    type: number
    sql: ${TABLE}.manual_adjustment_id;;
  }

  dimension: requester_id{
    type: number
    sql: ${TABLE}.requester_id;;
  }

  dimension: requester_full_name{
    type: string
    sql: ${TABLE}.requester_full_name;;
  }

  dimension: description{
    type: string
    sql: ${TABLE}.description;;
  }

  dimension: comments{
    type: string
    sql: ${TABLE}.comments;;
  }

  dimension: submitted_by{
    type: string
    sql: ${TABLE}.submitted_by;;
  }

  dimension: submitted_date{
    type: date
    sql: ${TABLE}.submitted_date;;
  }

  dimension: commission_type_id{
    type: number
    sql: ${TABLE}.commission_type_id;;
  }





}
