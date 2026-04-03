view: commission_guarantee_payments {
  derived_table: {
    sql:   WITH guarantee AS (SELECT csd.salesperson_user_id,
                          cd.employee_id,
                          csd.name,
                          cd.market_id,
                          csd.guarantee_amount,
                          csd.guarantee_start_date,
                          case
                              WHEN csd.GUARANTEE_END_DATE between DATEADD('month', 1, {% parameter commission_month_filter %}) and DATEADD('month', 2, {% parameter commission_month_filter %})
                                  then csd.GUARANTEE_END_DATE
                              else
                                  LAST_DAY(DATEADD('month', 1, csd.guarantee_end_date))::timestamp_ntz end AS guarantee_end_date,
                          ppp.paycheck_date                                                                AS prior_paycheck_date,
                          cpp.paycheck_date                                                                AS current_paycheck_date,
                          DATEDIFF(DAYS, DATE_TRUNC('month', prior_paycheck_date), LAST_DAY(prior_paycheck_date)) +
                          1                                                                                AS prior_month_days,
                          DATEDIFF(DAYS, DATE_TRUNC('month', current_paycheck_date), LAST_DAY(current_paycheck_date)) +
                          1                                                                                AS current_month_days,
                          CASE
                              WHEN MONTH(csd.guarantee_start_date) = MONTH(prior_paycheck_date)
                                  THEN DATEDIFF(DAYS, csd.guarantee_start_date, LAST_DAY(prior_paycheck_date)) + 1
                              WHEN MONTH(csd.guarantee_start_date) = MONTH(current_paycheck_date) AND
                                   DAY(csd.guarantee_start_date) != 1 AND
                                   csd.guarantee_start_date < DATEADD('days', -4, current_paycheck_date)
                                  THEN DATEDIFF(DAYS, csd.guarantee_start_date, LAST_DAY(current_paycheck_date) + 1)
                              ELSE NULL END                                                                AS prior_owed_days,
                          CASE
                              WHEN csd.guarantee_start_date < DATEADD('month', 1, {% parameter commission_month_filter %}) and
                                   DATE_TRUNC('month', csd.guarantee_end_date) =
                                   date_trunc('month', current_paycheck_date) and
                                   DAY(csd.guarantee_end_date) != day(LAST_DAY(current_paycheck_date))
                                  THEN day(csd.GUARANTEE_END_DATE)
                              ELSE current_month_days end                                                  as current_owed_days,
                          guarantee_amount / prior_month_days                                              AS prior_daily_rate,
                          guarantee_amount / current_month_days                                            AS current_daily_rate,
                          CASE
                              WHEN DATE_TRUNC('month', csd.guarantee_start_date) =
                                   DATE_TRUNC('month', prior_paycheck_date) AND
                                   csd.guarantee_start_date >= DATEADD('days', -4, prior_paycheck_date)
                                  THEN prior_owed_days * prior_daily_rate
                              ELSE NULL END                                                                AS prorated_guarantee,
                          CASE
                              WHEN current_owed_days != current_month_days then current_owed_days * current_daily_rate
                              ELSE GUARANTEE_AMOUNT end                                                    as current_guarantee,
                          coalesce(prorated_guarantee, 0) + coalesce(current_guarantee, 0)                 as total_commission
                   FROM analytics.public.commissions_salesperson_data csd
                            LEFT JOIN es_warehouse.public.users u
                                      ON csd.salesperson_user_id = u.user_id
                            LEFT JOIN analytics.payroll.company_directory cd
                                      ON TRY_TO_NUMBER(u.employee_id) = cd.employee_id
                            LEFT JOIN analytics.payroll.pay_periods ppp
                                      ON (MONTH({% parameter commission_month_filter %}) = MONTH(ppp.paycheck_date) AND
                                          YEAR({% parameter commission_month_filter %}) = YEAR(ppp.paycheck_date))
                            LEFT JOIN analytics.payroll.pay_periods cpp
                                      ON ((CASE
                                               WHEN MONTH({% parameter commission_month_filter %}) = 12 THEN MONTH(cpp.paycheck_date) = 1
                                               ELSE MONTH({% parameter commission_month_filter %}) + 1 = MONTH(cpp.paycheck_date) END) AND
                                          (CASE
                                               WHEN MONTH({% parameter commission_month_filter %}) = 12
                                                   THEN YEAR(cpp.paycheck_date) = YEAR({% parameter commission_month_filter %}) + 1
                                               ELSE YEAR({% parameter commission_month_filter %}) = YEAR(cpp.paycheck_date) END))
                   WHERE ((LAST_DAY(DATEADD('month', 1, {% parameter commission_month_filter %})) > csd.guarantee_start_date
                       AND LAST_DAY(DATEADD('month', 1, {% parameter commission_month_filter %})) <= guarantee_end_date)
                       OR
                          LAST_DAY({% parameter commission_month_filter %}) between csd.guarantee_start_date and guarantee_end_date)
                     AND csd.guarantee_start_date < DATEADD('days', -4, current_paycheck_date)
                     AND ppp.comm_check_date
                     AND cpp.comm_check_date)
SELECT g.salesperson_user_id,
       g.employee_id,
       g.name,
       coalesce(cdv.market_id,g.market_id) as market_id,
       g.guarantee_amount,
       g.guarantee_start_date,
       g.guarantee_end_date,
       g.prior_paycheck_date,
       g.current_paycheck_date,
       g.prorated_guarantee,
       g.current_guarantee,
       COALESCE(g.prorated_guarantee, 0) + COALESCE(g.current_guarantee, 0) AS total_guarantee_payment
FROM guarantee g
         asof
         join (SELECT *,
                      ROW_NUMBER() OVER (PARTITION BY EMPLOYEE_ID, DATE_TRUNC('day', _es_update_timestamp)
                          ORDER BY _es_update_timestamp DESC) AS row_num
               FROM ANALYTICS.PAYROLL.COMPANY_DIRECTORY_VAULT
               QUALIFY row_num = 1) cdv
    match_condition(g.guarantee_end_date >= cdv._es_update_timestamp) on g.EMPLOYEE_ID = cdv.EMPLOYEE_ID
      ;;
  }

  parameter: commission_month_filter {
    type: date
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
    value_format_name: id
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    value_format_name: id
  }

  dimension: name {
    description: "Salesperson Name"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: guarantee_amount {
    type: number
    sql: ${TABLE}."GUARANTEE_AMOUNT";;
    value_format_name: usd
  }

  dimension: guarantee_start_date {
    type: date
    sql: ${TABLE}."GUARANTEE_START_DATE" ;;
  }

  dimension: guarantee_end_date {
    type: date
    sql: ${TABLE}."GUARANTEE_END_DATE" ;;
  }

  dimension: prior_paycheck_date {
    type: date
    sql: ${TABLE}."PRIOR_PAYCHECK_DATE" ;;
  }

  dimension: current_paycheck_date {
    type: date
    sql: ${TABLE}."CURRENT_PAYCHECK_DATE" ;;
  }

  dimension: market_id {
    description: "Company directory default market_id."
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format_name: id
  }

  # dimension: commission_month {
  #   type: date
  #   sql: ${TABLE}."COMMISSION_MONTH" ;;
  # }

  dimension: prorated_guarantee {
    type: number
    sql: ${TABLE}."PRORATED_GUARANTEE" ;;
    value_format_name: usd
  }

  dimension: current_guarantee {
    type: number
    sql: ${TABLE}."CURRENT_GUARANTEE" ;;
    value_format_name: usd
  }

  dimension: total_guarantee_payment {
    type: number
    sql: ${TABLE}."TOTAL_GUARANTEE_PAYMENT" ;;
    value_format_name: usd
  }


}
