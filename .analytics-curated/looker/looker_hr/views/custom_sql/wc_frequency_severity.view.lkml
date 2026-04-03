view: wc_frequency_severity {
  derived_table: {
    sql:
    with dates_united as (
    SELECT ENTRY_DATE,
           sum(AMOUNT) as total_payroll,
           null        as total_incurred,
           null        as num_claims
    FROM ANALYTICS.INTACCT.GLENTRY gle
             JOIN ANALYTICS.INTACCT.GLACCOUNT gla on gla.ACCOUNTNO = gle.ACCOUNTNO
    WHERE gla.CATEGORYKEY = 781
    group by ENTRY_DATE

    union all

    select accident_date,
           null,
           sum(total_incurred),
           count(claim_number)
    from ANALYTICS.CLAIMS.WC_LOSS_RUN
    group by accident_date, null
),
     month_rollup as (
         select concat(year(ENTRY_DATE), '-', lpad(MONTH(ENTRY_DATE), 2, 0)) as year_month,
                sum(total_payroll)                                           as total_payroll,
                sum(total_incurred)                                          as total_incurred,
                count(num_claims)                                            as num_claims
         from dates_united
         group by year_month
     )
SELECT to_date(year_month, 'YYYY-MM') as year_month,
       (sum(total_incurred) over (order by year_month rows between 11 preceding and current row )) /
       (sum(num_claims) over (order by year_month rows between 11 preceding and current row ))               as severity_12,
       (sum(num_claims) over (order by year_month rows between 11 preceding and current row )) /
       ((sum(total_payroll) over (order by year_month rows between 11 preceding and current row )) /
        1000000)                                                                                              as frequency_12
from month_rollup;;
  }
  #dimension: year_month {
    #type: string
    #sql: ${TABLE}.YEAR_MONTH ;;
    #}

  dimension_group: year_month {
    type: time
    timeframes: [month]
    sql: ${TABLE}.YEAR_MONTH ;;
  }

    dimension:  severity_12{
      type: number
      value_format: "$#,##0.00"
      sql: ${TABLE}.SEVERITY_12 ;;
    }
  dimension:  frequency_12{
    type: number
    sql: ${TABLE}.FREQUENCY_12 ;;
  }
  }
