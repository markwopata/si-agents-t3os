view: commission_allocations {
  derived_table: {
    sql: SELECT c.user_id,
        cd.employee_id,
        c.full_name,
        case
        when c.line_item_type_id in (49,5,6,8,108,109,44,129,130,131,132) then 'rental'
        else 'retail' end                                         AS comm_type,
        coalesce(pm.parent_market_id, c.branch_id)::number        AS market_id,
        SUM(c.commission_amount)                                  AS branch_commission,
        SUM(SUM(commission_amount)) OVER (PARTITION BY c.user_id,comm_type) AS total_rep_commission,
        branch_commission / total_rep_commission                  AS percent_by_market,
        case
           when comm_type = 'retail' then acc2.FULL_NAME
            else acc1.full_name end                               as cost_center
   FROM analytics.commission.commission_details c
            JOIN es_warehouse.public.users u
            ON c.user_id = u.user_id
            LEFT JOIN analytics.payroll.company_directory cd
            ON TRY_TO_NUMBER(u.employee_id) = cd.employee_id
            LEFT JOIN analytics.BRANCH_EARNINGS.PARENT_MARKET pm
            ON c.BRANCH_ID = pm.MARKET_ID
            LEFT JOIN analytics.payroll.all_company_cost_centers acc1
            ON coalesce(parent_market_id, c.branch_id)::number = acc1.intaact
                           AND acc1.name IN ('Equipment Rental', 'Industrial Tooling')
            LEFT JOIN analytics.payroll.all_company_cost_centers acc2
            ON coalesce(parent_market_id, c.branch_id)::number = acc2.intaact
                           AND acc2.name IN ('Sales')
  WHERE c.commission_month = '2024-06-01' --the billing approved month (ex. for June commission payment, commission month would be May)
    AND c.employee_type = 'commission'
    AND c.is_finalized
  GROUP BY c.user_id, cd.employee_id, c.full_name, case
        when c.line_item_type_id in (49,5,6,8,108,109,44,129,130,131,132) then 'rental'
        else 'retail' end, coalesce(pm.parent_market_id,c.branch_id), case
           when comm_type = 'retail' then acc2.FULL_NAME
            else acc1.full_name end
QUALIFY total_rep_commission != 0
      ;;
   }

parameter: commission_month {
  type: date
}

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    value_format_name: id
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    value_format_name: id
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format_name: id
  }

  dimension: comm_type {
    type: string
    sql: ${TABLE}."COMM_TYPE" ;;
  }

  dimension: branch_commission {
    type: number
    sql: ${TABLE}."BRANCH_COMMISSION" ;;
    value_format_name: usd
  }

  dimension: total_rep_commission {
    type: number
    sql: ${TABLE}."TOTAL_REP_COMMISSION" ;;
    value_format_name: usd
  }

  dimension: percent_by_market {
    type: number
    sql: ${TABLE}."PERCENT_BY_MARKET" ;;
    value_format_name: percent_1
  }

  dimension: cost_center {
    type: string
    sql: ${TABLE}."COST_CENTER" ;;
  }

  measure: allocation {
    type: number
    sql: ${total_rep_commission}*${percent_by_market} ;;
    value_format_name: usd
  }
}
