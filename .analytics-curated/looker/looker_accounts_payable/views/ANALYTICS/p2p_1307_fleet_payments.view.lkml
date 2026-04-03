view: p2p_1307_fleet_payments {
    derived_table: {
      sql:


       SELECT

 apbpmt.paiditemkey,
    APRH.VENDORID,
    APRH.prbatch,
    VEND.NAME,
    VEND.VENDTYPE,
    VEND.VENDOR_CATEGORY,
    VEND.REPORTING_CATEGORY,
    VEND.TERMNAME,
    APBPMT.PAYMENTDATE,
    APRHPAY.STATE,
    APRD.ACCOUNTNO,
    COA.TITLE,
    --SUM(APBPMT.AMOUNT) AS summed_amount,
    APBPMT.AMOUNT,
    aprd.ITEMID, --add since account 2014 has so many that go to it
--, --aprhpay.description, aprhpay.description2, glbatch.batch_title,
--       TO_CHAR(DATE_TRUNC('MONTH', DATEADD(MONTH, -1, CURRENT_DATE())), 'YYYY-MM') AS prior_month_year,
--        TO_CHAR(LAST_DAY(DATE_TRUNC('MONTH', DATEADD(MONTH, -1, CURRENT_DATE()))), 'DD') AS last_day_of_prior_month,
--        CEIL(TO_NUMBER(TO_CHAR(LAST_DAY(DATE_TRUNC('MONTH', DATEADD(MONTH, -1, CURRENT_DATE()))), 'DD')) / 7) AS weeks_in_prior_month,
--        WEEK(CURRENT_DATE) AS current_week_of_year,
-- month(DATE_TRUNC('MONTH', CURRENT_DATE) - INTERVAL '1 MONTH') AS prior_month
FROM
    "ANALYTICS"."INTACCT"."APBILLPAYMENT" APBPMT
    LEFT JOIN "ANALYTICS"."INTACCT"."APRECORD" APRH ON APBPMT.RECORDKEY = APRH.RECORDNO AND APRH.RECORDTYPE IN ('apbill','apadjustment')
    LEFT JOIN "ANALYTICS"."INTACCT"."APDETAIL" APRD ON APBPMT.PAIDITEMKEY = APRD.RECORDNO AND APRH.RECORDNO = APRD.RECORDKEY
    LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VEND ON APRH.VENDORID = VEND.VENDORID
    LEFT JOIN "ANALYTICS"."INTACCT"."GLACCOUNT" COA ON APRD.ACCOUNTNO = COA.ACCOUNTNO
    LEFT JOIN "ANALYTICS"."INTACCT"."APRECORD" APRHPAY ON APBPMT.PAYMENTKEY = APRHPAY.RECORDNO
    --left join analytics.intacct.glbatch on aprhpay.prbatchkey = glbatch.prbatchkey
     --left join ANALYTICS.INTACCT.USERINFO userinfo ON APBPMT.createdby = userinfo.recordno
     --left join ANALYTICS.INTACCT.APRECORD aprecord on APBPMT.recordno = aprecord.recordno
WHERE
    --APBPMT.PAYMENTDATE >= {% date_start date_filter %}
    --AND APBPMT.PAYMENTDATE <= {% date_end date_filter %}
    --AND
    APBPMT.PAYMENTKEY = APBPMT.PARENTPYMT --WHEN THESE DON'T EQUAL IT IS A CREDIT MEMO APPLICATION I THINK
    AND APRHPAY.RECORDTYPE = 'appayment'
    and APRD.ACCOUNTNO = 1307
    --and APBPMT.PAYMENTDATE = '2024-03-04'
    --and year(APBPMT.PAYMENTDATE) = '2024'
    --and month(APBPMT.PAYMENTDATE) = '1'
    and
    --APRH.VENDORID = 'V11275'
    --APRH.prbatch like '%FLEET%'
    upper(APRH.prbatch) like '%FLEET%'


        ;;
    }

    measure: count {
      type: count

    }
    dimension:  item_id {
      type: string
      sql: ${TABLE}."ITEMID";;
    }
    dimension: related_parties {
      type: string
      sql: CASE WHEN ${TABLE}."VENDORID" in
        ('V28634',
'V34092',
'V28378',
'V34070',
'V32244',
'V12921',
'V32329',
'V12047',
'V34067',
'V12012',
'V30253',
'V12737',
'V12803',
'V29796',
'V11807',
'V27328',
'V11839',
'V11826',
'V27270'
        ) then 'related'


        else 'other' end;;
    }

    dimension: today_date {
      type: date
      sql: DATE(GETDATE()) ;;
    }

    dimension: weeks_in_prior_month {
      type: number
      sql: ${TABLE}."WEEKS_IN_PRIOR_MONTH";;
    }

    dimension: current_week_of_year {
      type: number
      sql: ${TABLE}."CURRENT_WEEK_OF_YEAR";;
    }
    # measure: weeks_in_prior_month2 {
    #   type: number
    #   sql: ${TABLE}."WEEKS_IN_PRIOR_MONTH";;
    # }
    dimension: vendor_id {
      type: string

      sql: ${TABLE}."VENDORID";;
    }

    dimension: vendor_name {
      type: string

      sql: ${TABLE}."NAME" ;;
    }

    dimension: vendor_type {
      type: string
      sql: ${TABLE}."VENDTYPE" ;;
    }

    dimension: vendor_category {
      type: string
      sql: ${TABLE}."VENDOR_CATEGORY" ;;
    }

    dimension: reporting_category {
      type: string
      sql: ${TABLE}."REPORTING_CATEGORY" ;;
    }

    dimension: terms {
      type: string
      sql: ${TABLE}."TERMNAME" ;;
    }

    dimension: payment_date {
      convert_tz: no
      type: date
      sql: ${TABLE}."PAYMENTDATE" ;;
    }

#   dimension_group: week {
#   type: time
#   timeframes: [
#     raw,
#     week
#   ]
#   sql: ${TABLE}."PAYMENTDATE";;

# }

    dimension_group: submit_date {
      type: time

      sql: ${TABLE}."PAYMENTDATE" ;;
    }



    dimension: state {
      type: string
      sql: ${TABLE}."STATE" ;;
    }

    dimension: account {
      type: string

      sql: ${TABLE}."ACCOUNTNO" ;;
    }

    dimension: account_name {
      type: string

      sql: ${TABLE}."TITLE" ;;
    }

    # measure: weeks_in_months {
    #   type: number
    #   sql: COUNT(DISTINCT DATE_TRUNC('week', ${TABLE}."PAYMENTDATE")) ;;
    #   # Replace ${date_field} with the appropriate field representing dates in your dataset
    #   # This dimension calculates the number of distinct weeks in the current month
    #   # It uses the DATE_TRUNC function to truncate dates to the week and counts the distinct weeks

    #   # sql_trigger_value: SELECT MAX(DATE_TRUNC('month', your_date_column)) FROM your_table_name ;;
    #   # # Replace your_date_column and your_table_name with the appropriate column and table names
    #   # # This SQL trigger ensures Looker reevaluates the calculation when the month changes
    # }
    # measure: weeks_in_prior_month {
    #   type: number
    #   sql: TIMESTAMP_DIFF(DATE_TRUNC('month', CURRENT_DATE), DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1' MONTH), WEEK) ;;
    #   # This measure calculates the number of weeks in the prior month
    #   # It uses TIMESTAMP_DIFF to calculate the difference in weeks between the current month and the previous month

    #   # sql_trigger_value: SELECT MAX(DATE_TRUNC('month', your_date_column)) FROM your_table_name ;;
    #   # # Replace your_date_column and your_table_name with the appropriate column and table names
    #   # # This SQL trigger ensures Looker reevaluates the calculation when the data changes
    # }

    measure: total_amount_prior_month {
      type: sum
      sql: CASE WHEN DATE_TRUNC('month', ${TABLE}."PAYMENTDATE") = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1' MONTH)
        THEN ${TABLE}."AMOUNT" ELSE NULL END ;;
    }
    # measure: amount {
    #   type: sum
    #   value_format: "#,##0.00"
    #   sql: ${TABLE}."Amount" ;;
    # }

    # measure: amount {
    #   type: number
    #   value_format: "#,##0.00"
    #   sql: ${TABLE}."AMOUNT" ;;
    # }

    # measure: amount {
    #   type: number
    #   sql: ${TABLE}."AMOUNT" ;;
    # }

    measure: amount {
      type: sum
      ##value_format: "$#,##0;($#,##0);-"
      drill_fields: [account,account_name,vendor_id,vendor_name,vendor_type, vendor_category, amount, payment_date]
      sql: ${TABLE}."AMOUNT"  ;;
    }


    measure: avg_spend_per_account_monthly {
      type: average
      sql: ${TABLE}."AMOUNT"
            sql_always_where: ${TABLE}."ACCOUNTNO" >= (current_date - INTERVAL '12' MONTH)
            timeframes: [month];;
    }


    set: drill_detail {
      fields: [
        vendor_id,
        vendor_name,
        vendor_type,
        vendor_category,
        reporting_category,
        terms,
        payment_date,
        state,
        account,
        account_name,
        amount, submit_date_time,total_amount_prior_month, today_date, weeks_in_prior_month, current_week_of_year,related_parties,item_id
      ]
    }

#   filter: date_filter {
#     convert_tz: no
#     type: date
#   }
  }
