view: warranty_oec_summary_by_month {
 sql_table_name: "ANALYTICS"."WARRANTIES"."WARRANTY_OEC_SUMMARY_BY_MONTH_TMP" ;;

dimension: month {
  type: date_month
  sql: ${TABLE}.generated_date ;;
}

dimension: make {
  type: string
  sql: ${TABLE}.make ;;
}

dimension: warranty_oec_max_end_date {
  type: number
  value_format_name: usd_0
  sql: ${TABLE}.month_warranty_oec_max ;;
}

dimension: warranty_oec_min_end_date {
  type: number
  value_format_name: usd_0
  sql: ${TABLE}.month_warranty_oec_min ;;
}

dimension: scaled_oec_max_end_date {
  type: number
  value_format_name: usd_0
  sql: ${TABLE}.scaled_warranty_oec_max;;
}

dimension: scaled_oec_min_end_date {
  type: number
  value_format_name: usd_0
  sql: ${TABLE}.scaled_warranty_oec_min ;;
}

dimension: total_claimed {
  type: number
  value_format_name: usd_0
  sql: ${TABLE}.total_claimed ;;
  }

dimension: claimed_by_total_oec_max_end_date {
  type: number
  value_format_name: percent_2
  sql: ${TABLE}.claimed_oec_max ;;
}

  dimension: claimed_by_total_oec_min_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.claimed_oec_min ;;
  }

  dimension: claimed_scaled_oec_max_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.claimed_scaled_max;;
  }

  dimension: claimed_scaled_oec_min_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.claimed_scaled_min;;
  }

  #Paid
  dimension: total_paid {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_paid ;;
  }

  dimension: paid_total_oec_max_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.paid_oec_max ;;
  }

  dimension: paid_total_oec_min_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.paid_oec_min ;;
  }

  dimension: paid_scaled_oec_max_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.paid_scaled_max;;
  }

  dimension: paid_scaled_oec_min_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.paid_scaled_min;;
  }

  dimension: total_unpaid {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_unpaid ;;
  }

  dimension: recovery {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.recovery;;
  }
}

view: warranty_oec_year_summary {
  derived_table: {
    sql:
    select make
        , round(avg(month_warranty_oec_max), 2) as avg_monthly_oec_max
        , round(avg(month_warranty_oec_min), 2) as avg_monthly_oec_min
        , sum(scaled_warranty_oec_max) as scaled_oec_max
        , sum(scaled_warranty_oec_min) as scaled_oec_min
        --claimed
        , sum(total_claimed) as claimed
        , claimed / avg_monthly_oec_max as claimed_oec_max
        , iff(avg_monthly_oec_min > 0, claimed / avg_monthly_oec_min, null) as claimed_oec_min
        , claimed / scaled_oec_max as claimed_scaled_max
        , iff(scaled_oec_min > 0, claimed / scaled_oec_min, 0) as claimed_scaled_min
        --paid
        , sum(total_paid) as paid
        , paid / avg_monthly_oec_max as paid_oec_max
        , iff(avg_monthly_oec_min > 0, paid / avg_monthly_oec_min, 0) as paid_oec_min
        , paid / scaled_oec_max as paid_scaled_max
        , iff(scaled_oec_min > 0, paid / scaled_oec_min, 0) as paid_scaled_min
        , sum(total_unpaid) as unpaid
        , paid / claimed as recovery
    from ${warranty_oec_summary_by_month.SQL_TABLE_NAME}
    group by make ;;
}

dimension: make {
  type: string
  sql: ${TABLE}.make ;;
}

dimension: avg_monthly_oec_max_end_date {
  type: number
  value_format_name: usd_0
  sql: ${TABLE}.avg_monthly_oec_max ;;
}

  dimension: avg_monthly_oec_min_end_date {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.avg_monthly_oec_min ;;
  }

  dimension: scaled_oec_max_warranty_end {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.scaled_oec_max ;;
  }

  dimension: scaled_oec_min_warranty_end {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.scaled_oec_min ;;
  }

  dimension: claimed {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.claimed;;
  }

  dimension: claimed_total_oec_max_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.claimed_oec_max ;;
  }

  dimension: claimed_total_oec_min_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.claimed_oec_min ;;
  }

  dimension: claimed_scaled_oec_max_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.claimed_scaled_max;;
  }

  dimension: claimed_scaled_oec_min_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.claimed_scaled_min;;
  }

  #Paid
  dimension: total_paid {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.paid ;;
  }

  dimension: paid_total_oec_max_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.paid_oec_max ;;
  }

  dimension: paid_total_oec_min_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.paid_oec_min ;;
  }

  dimension: paid_scaled_oec_max_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.paid_scaled_max;;
  }

  dimension: paid_scaled_oec_min_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.paid_scaled_min;;
  }

  dimension: total_unpaid {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.unpaid ;;
  }

  dimension: recovery {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.recovery;;
  }
}

view: warranty_oec_company_wide_summary {
  derived_table: {
    sql:
    select generated_date
        , round(sum(month_warranty_oec_max), 2) as company_oec_max
        , round(sum(month_warranty_oec_min), 2) as company_oec_min
        , sum(scaled_warranty_oec_max) as scaled_oec_max
        , sum(scaled_warranty_oec_min) as scaled_oec_min
        --claimed
        , sum(total_claimed) as claimed
        , claimed / company_oec_max as claimed_oec_max
        , claimed / company_oec_min as claimed_oec_min
        , claimed / scaled_oec_max as claimed_scaled_max
        , claimed / scaled_oec_min as claimed_scaled_min
        , sum(total_paid) as paid
        --paid
        , paid / company_oec_max as paid_oec_max
        , paid / company_oec_min as paid_oec_min
        , paid / scaled_oec_max as paid_scaled_max
        , paid / scaled_oec_min as paid_scaled_min
        , sum(total_unpaid) as unpaid
        , paid / claimed as recovery
    from ${warranty_oec_summary_by_month.SQL_TABLE_NAME}
    group by generated_date ;;
  }
  dimension: month {
    type: date_month
    sql: ${TABLE}.generated_date ;;
  }

  dimension: company_warranty_oec_max_end_date {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.company_oec_max ;;
  }

  dimension: company_warranty_oec_min_end_date {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.company_oec_min ;;
  }

  dimension: scaled_oec_max_warranty_end {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.scaled_oec_max ;;
  }

  dimension: scaled_oec_min_warranty_end {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.scaled_oec_min ;;
  }

  dimension: claimed {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.claimed;;
  }

  dimension: claimed_total_oec_max_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.claimed_oec_max ;;
  }

  dimension: claimed_total_oec_min_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.claimed_oec_min ;;
  }

  dimension: claimed_scaled_oec_max_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.claimed_scaled_max;;
  }

  dimension: claimed_scaled_oec_min_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.claimed_scaled_min;;
  }

  #Paid
  dimension: total_paid {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.paid ;;
  }

  dimension: paid_total_oec_max_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.paid_oec_max ;;
  }

  dimension: paid_total_oec_min_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.paid_oec_min ;;
  }

  dimension: paid_scaled_oec_max_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.paid_scaled_max;;
  }

  dimension: paid_scaled_oec_min_end_date {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.paid_scaled_min;;
  }

  dimension: total_unpaid {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.unpaid ;;
  }

  dimension: recovery {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.recovery;;
  }
  }

view: warranty_oec_summary_by_quarter {
  derived_table: {
    sql:
      select date_trunc(quarter, generated_date) as quarter
        , make
        , round(avg(month_warranty_oec_max), 2) as avg_warranty_oec
        , sum(scaled_warranty_oec_max) as scaled_oec_max
        --claimed
        , sum(total_claimed) as claimed
        , claimed / avg_warranty_oec as claimed_oec_max
        , claimed / scaled_oec_max as claimed_scaled_max
        -- , sum(total_paid) as paid
        -- --paid
        -- , paid / avg_warranty_oec as paid_oec_max
        -- , paid / scaled_oec_max as paid_scaled_max
        -- , sum(total_unpaid) as unpaid
        -- , paid / claimed as recovery
    from ${warranty_oec_summary_by_month.SQL_TABLE_NAME}
    group by quarter, make ;;
    }

    dimension: quarter {
      type: date
      sql: ${TABLE}.quarter ;;
    }

    dimension: make {
      type: string
      sql: ${TABLE}.make ;;
    }

    dimension: avg_warranty_oec {
      type: number
      value_format_name: usd_0
      sql: ${TABLE}.avg_warranty_oec ;;
    }

  dimension: scaled_oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.scaled_oec_max ;;
  }

  dimension: claimed {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.claimed;;
  }

  dimension: claimed_total_oec{
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.claimed_oec_max ;;
  }

  dimension: claimed_scaled_oec {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.claimed_scaled_max;;
  }
}
