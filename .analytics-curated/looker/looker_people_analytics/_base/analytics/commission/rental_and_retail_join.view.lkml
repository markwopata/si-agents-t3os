view: rental_and_retail_join {
  derived_table: {
    sql:
      (
        select
          'retail' as commission_type,
          employee_id,
          salesperson_user_id,
          full_name,
          paycheck_date,
          line_item_type_id,
          line_item_amount as revenue,
          commission_amount as commission,
          0 as commission_total,
          0 as credit_total,
          0 as clawback_total,
          0 as reimbursement_total,
          commission_amount as net_commission_total,
          1 as split,
          null as transaction_type_id,
          null as credit_note_line_item_id,
          null as is_payable
        from analytics.commission_dbt.retail_commission_final_all
        where line_item_type_id in (5, 6, 8, 24, 31, 33, 43, 44, 49, 80, 81, 108,
        109, 110, 111, 123, 129, 130, 131, 132, 140, 141, 152, 153)
          and employee_id is not null
      )

    union all

      (
        select
          'rental' as commission_type,
          employee_id,
          salesperson_user_id,
          full_name,
          paycheck_date,
          line_item_type_id,
          case
              when transaction_type_id = 1
              then line_item_amount * split
              else 0
              end as revenue,
          commission_amount as commission,
          case
              when transaction_type_id = 1 and credit_note_line_item_id is null
              then commission_amount
              else 0
              end as commission_total,
          case
              when transaction_type_id = 1 and credit_note_line_item_id is not null
              then commission_amount
              else 0
              end as credit_total,
          case
              when transaction_type_id = 2
              then commission_amount
              else 0
              end as clawback_total,
          case
              when transaction_type_id = 3
              then commission_amount
              else 0
              end as reimbursement_total,
          commission_total + credit_total + clawback_total + reimbursement_total as net_commission_total,
          split,
          transaction_type_id,
          credit_note_line_item_id,
          is_payable
        from analytics.commission_dbt.commission_final_all
        where is_payable = true
            and line_item_type_id not in (24, 80, 81, 110, 111, 123, 141)
            and employee_id is not null
      )
    ;;
  }

  dimension: commission_type {
    type: string
    sql: ${TABLE}.commission_type ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}.employee_id ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}.salesperson_user_id ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}.full_name ;;
  }

  dimension: paycheck_date {
    type: date
    sql: ${TABLE}.paycheck_date ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}.line_item_type_id ;;
  }

  dimension: revenue {
    type: number
    sql: ${TABLE}.revenue ;;
  }

  dimension: commission {
    type: number
    sql: ${TABLE}.commission ;;
  }

  dimension: commission_total {
    type: number
    sql: ${TABLE}.commission_total ;;
  }

  dimension: credit_total {
    type: number
    sql: ${TABLE}.credit_total ;;
  }

  dimension: clawback_total {
    type: number
    sql: ${TABLE}.clawback_total ;;
  }

  dimension: reimbursement_total {
    type: number
    sql: ${TABLE}.reimbursement_total ;;
  }

  dimension: net_commission_total {
    type: number
    sql: ${TABLE}.net_commission_total ;;
  }

  dimension: split {
    type: number
    sql: ${TABLE}.split ;;
  }

  dimension: transaction_type_id {
    type: number
    sql: ${TABLE}.transaction_type_id ;;
  }

  dimension: credit_note_line_item_id {
    type: number
    sql: ${TABLE}.line_item_type_id ;;
  }

  dimension: is_payable {
    type: yesno
    sql: ${TABLE}.is_payable ;;
  }
}
