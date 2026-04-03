# MB created this view for test purposes on the visual side for population purposes
# View can be deleted once this concept is copied from for new leaderboard work
view: new_accounts_leaderboard {
  derived_table: {
    sql: with testing as (
      SELECT
          DATE_TRUNC('month', na_date) as na_month,
          sp_user_id,
          SUM(CASE WHEN app_type = 'Credit' THEN 1 ELSE 0 END) as total_monthly_credit,
          SUM(CASE WHEN app_type = 'COD' THEN 1 ELSE 0 END) as total_monthly_cod,
          COUNT(DISTINCT company_id) as total_monthly_new_accounts
      FROM
          analytics.bi_ops.new_account_testing nat
      WHERE
          na_month >= date_trunc('month', current_date())
      GROUP BY
          DATE_TRUNC('month', na_date), sp_user_id
      )
      , user_bucket as (
      select
          case
              when total_monthly_new_accounts = 0 then '0'
              when total_monthly_new_accounts = 1 then '1'
              when total_monthly_new_accounts = 2 then '2'
              when total_monthly_new_accounts = 3 then '3'
              when total_monthly_new_accounts = 4 then '4'
              when total_monthly_new_accounts = 5 then '5'
              when total_monthly_new_accounts = 6 then '6'
              when total_monthly_new_accounts = 7 then '7'
              when total_monthly_new_accounts = 8 then '8'
              when total_monthly_new_accounts = 9 then '9'
              when total_monthly_new_accounts >= 10 then '10+'
          else 'Undefined'
          end as buckets
      from
          testing
      where
          sp_user_id = 11581 --swap to email to pull logged in user flag for correct bucket
      )
      , population_buckets as (
      select
          case
              when total_monthly_new_accounts = 0 then '0'
              when total_monthly_new_accounts = 1 then '1'
              when total_monthly_new_accounts = 2 then '2'
              when total_monthly_new_accounts = 3 then '3'
              when total_monthly_new_accounts = 4 then '4'
              when total_monthly_new_accounts = 5 then '5'
              when total_monthly_new_accounts = 6 then '6'
              when total_monthly_new_accounts = 7 then '7'
              when total_monthly_new_accounts = 8 then '8'
              when total_monthly_new_accounts = 9 then '9'
              when total_monthly_new_accounts >= 10 then '10+'
          else 'Undefined'
          end as buckets,
          sum(total_monthly_new_accounts) as total_monthly_new_accounts
      from
          testing
      group by
          buckets
      )
      select
          pb.buckets,
          iff(pb.buckets = ub.buckets,TRUE,FALSE) as user_selected_bucket,
          iff(pb.buckets = ub.buckets, pb.total_monthly_new_accounts,0) as user_selected_population_bucket,
          iff(pb.buckets = ub.buckets, 0, pb.total_monthly_new_accounts) as population_bucket,
          pb.total_monthly_new_accounts
      from
          population_buckets pb
          left join user_bucket ub on ub.buckets = pb.buckets ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: buckets {
    type: string
    sql: ${TABLE}."BUCKETS" ;;
  }

  dimension: user_selected_bucket {
    type: yesno
    sql: ${TABLE}."USER_SELECTED_BUCKET" ;;
  }

  dimension: user_selected_population_bucket {
    type: number
    sql: ${TABLE}."USER_SELECTED_POPULATION_BUCKET" ;;
  }

  dimension: population_bucket {
    type: number
    sql: ${TABLE}."POPULATION_BUCKET" ;;
  }

  dimension: total_monthly_new_accounts {
    type: number
    sql: ${TABLE}."TOTAL_MONTHLY_NEW_ACCOUNTS" ;;
  }

  measure: total_population_user_bucket {
    type: sum
    sql: ${user_selected_population_bucket} ;;
  }

  measure: total_population_bucket {
    type: sum
    sql: ${population_bucket} ;;
  }

  set: detail {
    fields: [
      buckets,
      user_selected_bucket,
      user_selected_population_bucket,
      population_bucket,
      total_monthly_new_accounts
    ]
  }
}
