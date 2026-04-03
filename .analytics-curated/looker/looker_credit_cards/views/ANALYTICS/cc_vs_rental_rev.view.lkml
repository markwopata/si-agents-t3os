view: cc_vs_rental_rev {
  derived_table: {
    sql:WITH month_series AS (
              SELECT
                  DATE_TRUNC('month', DATEADD(month, -ROW_NUMBER() OVER (ORDER BY seq4()) + 1, CURRENT_DATE)) AS month
              FROM TABLE(GENERATOR(ROWCOUNT => 12))
          ),
          cc_transactions AS (
              SELECT
                  DATE_TRUNC('month', transaction_date) AS month,
                  employee_id,
                  SUM(CASE WHEN verified_status_desc = 'Verified' THEN transaction_amount ELSE 0 END) AS verified_transactions,
                  SUM(CASE WHEN verified_status_desc = 'Unverified' THEN transaction_amount ELSE 0 END) AS unverified_transactions--,
                  --SUM(CASE WHEN verified_status_desc = 'Reallocated' THEN transaction_amount ELSE 0 END) AS reallocated_transactions,
                  --SUM(CASE WHEN verified_status_desc = 'Travel Platform' THEN transaction_amount ELSE 0 END) AS travel_platform_transactions
              FROM analytics.credit_card.transaction_verification
              WHERE transaction_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 YEAR')
                AND employee_id IN (SELECT employee_id FROM analytics.bi_ops.salesperson_info)
              GROUP BY DATE_TRUNC('month', transaction_date), employee_id
          ),
          rental_revenues AS (
              SELECT
                  DATE_TRUNC('month', CONVERT_TIMEZONE('UTC', rental_approved_date)::date) AS month,
                  cd.employee_id,
                  slh.sp_user_id,
                  SUM(RENTAL_REVENUE) AS rental_revenue
              FROM analytics.bi_ops.salesperson_line_items_historic slh
              LEFT JOIN analytics.payroll.company_directory cd ON lower(slh.sp_email) = lower(cd.work_email)
              WHERE rental_approved_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 YEAR')
              GROUP BY DATE_TRUNC('month', CONVERT_TIMEZONE('UTC', rental_approved_date)::date), cd.employee_id, slh.sp_user_id
              UNION
              SELECT
                  DATE_TRUNC('month', CONVERT_TIMEZONE('UTC', rental_approved_date)::date) AS month,
                  cd.employee_id,
                  slc.sp_user_id,
                  SUM(RENTAL_REVENUE) AS rental_revenue
              FROM analytics.bi_ops.salesperson_line_items_current slc
              LEFT JOIN analytics.payroll.company_directory cd ON lower(slc.sp_email) = lower(cd.work_email)
              GROUP BY DATE_TRUNC('month', CONVERT_TIMEZONE('UTC', rental_approved_date)::date), cd.employee_id, slc.sp_user_id
          ),
          transactions_revenue_combined AS (
              SELECT
                  rr.month,
                  rr.employee_id,
                  rr.sp_user_id,
                  rr.rental_revenue,
                  cc.verified_transactions,
                  cc.unverified_transactions--,
                  --cc.reallocated_transactions,
                  --cc.travel_platform_transactions
              FROM rental_revenues rr
              FULL OUTER JOIN cc_transactions cc
              ON rr.employee_id = cc.employee_id AND rr.month = cc.month
          )
          , new_account_totals AS (
              select sp_user_id,
              date_trunc(month, na_date) as month,
              COUNT(distinct company_id) as total_new_accounts
              FROM analytics.bi_ops.new_account_by_type_log
              group by sp_user_id, date_trunc(month, na_date)
          )

          , last_day_oec AS (
          select date, salesperson_user_id, SUM(OEC_on_rent) as oec from analytics.bi_ops.rep_market_oec_aor_historical where date = LAST_DAY(date) group by date, salesperson_user_id
          union
          select date, salesperson_user_id, SUM(OEC_on_rent) as oec from analytics.bi_ops.rep_market_oec_aor_current where date = LAST_DAY(date) OR date = current_timestamp::date group by date, salesperson_user_id
          )
          SELECT
              ms.month,
              CASE
                  WHEN POSITION(' ', COALESCE(cd.nickname, cd.first_name)) = 0
                      THEN CONCAT(COALESCE(cd.nickname, cd.first_name), ' ', cd.last_name, ' - ', cd.employee_id::varchar)
                  ELSE CONCAT(COALESCE(cd.nickname, CONCAT(cd.first_name, ' ', cd.last_name)), ' - ', cd.employee_id::varchar)
              END AS sp_name,
              trc.sp_user_id,
              cd.date_hired,
              cd.date_terminated,
              COALESCE(nat.total_new_accounts,0) as total_new_accounts,
              COALESCE(ldo.oec,0) as last_day_oec_on_rent,

              ZEROIFNULL(trc.rental_revenue) AS rental_revenue,

              LAG(ZEROIFNULL(trc.rental_revenue), 1) OVER (PARTITION BY trc.employee_id ORDER BY ms.month) AS prev_month_rental_revenue,
              ZEROIFNULL(trc.verified_transactions) AS verified_transactions,
              ZEROIFNULL(trc.unverified_transactions) AS unverified_transactions,
              ZEROIFNULL(trc.verified_transactions) + ZEROIFNULL(trc.unverified_transactions) as total_card_spend
              --ZEROIFNULL(trc.reallocated_transactions) AS reallocated_transactions,
              --ZEROIFNULL(trc.travel_platform_transactions) AS travel_platform_transactions
          FROM month_series ms
          LEFT JOIN transactions_revenue_combined trc
              ON ms.month = trc.month
          LEFT JOIN analytics.payroll.company_directory cd
              ON trc.employee_id = cd.employee_id
          LEFT JOIN last_day_oec ldo ON ldo.salesperson_user_id = trc.sp_user_id AND DATE_TRUNC(month, ldo.date) = ms.month
          LEFT JOIN new_account_totals nat ON nat.month = ms.month and nat.sp_user_id = trc.sp_user_id;;
  }

  dimension: month {
    type: date
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SP_NAME" ;;
  }

  dimension: date_hired {
    type: date
    sql: ${TABLE}."DATE_HIRED" ;;
  }

  dimension: date_terminated {
    type: date
    sql: ${TABLE}."DATE_TERMINATED" ;;
  }

  dimension: total_new_accounts {
    type: number
    sql: ${TABLE}."TOTAL_NEW_ACCOUNTS" ;;
  }

  dimension: last_day_oec_on_rent {
    type: number
    sql: ${TABLE}."LAST_DAY_OEC_ON_RENT" ;;
    description: "Oec on rent for sales person on the last day of the month or the current date"
    value_format_name: usd_0
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
    value_format_name: usd_0
  }

  dimension: prev_month_rental_revenue {
    type: number
    sql: ${TABLE}."PREV_MONTH_RENTAL_REVENUE" ;;
    value_format_name: usd_0
  }

  dimension: verified_transactions {
    type: number
    sql: ${TABLE}."VERIFIED_TRANSACTIONS" ;;
    value_format_name: usd_0
  }

  dimension: unverified_transactions {
    type: number
    sql: ${TABLE}."UNVERIFIED_TRANSACTIONS" ;;
    value_format_name: usd_0
  }

  dimension: total_card_spend {
    type: number
    sql: ${TABLE}."TOTAL_CARD_SPEND" ;;
    value_format_name: usd_0
  }

  # dimension: reallocated_transactions {
  #   type: number
  #   sql: ${TABLE}."REALLOCATED_TRANSACTIONS" ;;
  #   value_format_name: usd_0
  # }

  # dimension: travel_platform_transactions {
  #   type: number
  #   sql: ${TABLE}."TRAVEL_PLATFORM_TRANSACTIONS" ;;
  #   value_format_name: usd_0
  # }
}
