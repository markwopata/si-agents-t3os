view: ap_avg_days_dy {
    derived_table: {
      sql:
      --with main as (

        SELECT

        vend.vendorid,
        VEND.NAME,
        -- VEND.VENDTYPE,
         VEND.VENDOR_CATEGORY,
        -- VEND.REPORTING_CATEGORY,
        VEND.TERMNAME,
        APRH.RECORDID                                           AS BILL_NUMBER,
        aprh.whencreated as bill_date,
        -- APRD.whencreated as detail_created,
        -- apbpmt.whencreated as bill_payment_created,
        APBPMT.PAYMENTDATE,
        APRHPAY.STATE,
        --APRD.ACCOUNTNO,
        --COA.TITLE,
        --SUM(APBPMT.AMOUNT) AS "Amount"
        APBPMT.AMOUNT,
        --aprd.ITEMID
        --add since account 2014 has so many that go to it
        DATEDIFF(day, aprh.whencreated, apbpmt.paymentdate) AS payment_time_days,
        YEAR(apbpmt.paymentdate) AS payment_year
        FROM
        "ANALYTICS"."INTACCT"."APBILLPAYMENT" APBPMT
        LEFT JOIN "ANALYTICS"."INTACCT"."APRECORD" APRH ON APBPMT.RECORDKEY = APRH.RECORDNO AND APRH.RECORDTYPE IN ('apbill')
        LEFT JOIN "ANALYTICS"."INTACCT"."APDETAIL" APRD ON APBPMT.PAIDITEMKEY = APRD.RECORDNO AND APRH.RECORDNO = APRD.RECORDKEY
        LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VEND ON APRH.VENDORID = VEND.VENDORID
        LEFT JOIN "ANALYTICS"."INTACCT"."GLACCOUNT" COA ON APRD.ACCOUNTNO = COA.ACCOUNTNO
        LEFT JOIN "ANALYTICS"."INTACCT"."APRECORD" APRHPAY ON APBPMT.PAYMENTKEY = APRHPAY.RECORDNO
        WHERE

        APBPMT.PAYMENTKEY = APBPMT.PARENTPYMT --WHEN THESE DON'T EQUAL IT IS A CREDIT MEMO APPLICATION I THINK
        AND
        APRHPAY.RECORDTYPE = 'appayment'
        --and aprh.recordid ='326436'


        --)

        --select

        --vendorid as id, name, termname as terms,

        --SUM(CASE WHEN YEAR(paymentdate) = YEAR(CURRENT_DATE()) THEN amount ELSE 0 END) AS current_year_paid,
        --AVG(CASE WHEN payment_year = YEAR(CURRENT_DATE()) THEN payment_time_days ELSE NULL END) AS current_year_avg_days_to_pay,

        --SUM(CASE WHEN YEAR(paymentdate) = YEAR(CURRENT_DATE()) - 1 THEN amount ELSE 0 END) AS prior_year_paid,
        --AVG(CASE WHEN payment_year = YEAR(CURRENT_DATE()) - 1 THEN payment_time_days ELSE NULL END) AS prior_year_avg_days_to_pay,

        --SUM(CASE WHEN YEAR(paymentdate) = YEAR(CURRENT_DATE()) - 2 THEN amount ELSE 0 END) AS two_years_ago_paid,
        --AVG(CASE WHEN payment_year = YEAR(CURRENT_DATE()) - 2 THEN payment_time_days ELSE NULL END) AS two_years_ago_avg_days_to_pay,
        --sum(amount) as Sum_Total_Paid

        --from main
        --
        --group by vendorid, name, termname

        ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }
    measure: amount {
      type: sum
      drill_fields: [detail*]
    }

    # dimension: sum_total_paid {
    #   type: string
    #   sql: ${TABLE}."SUM_TOTAL_PAID" ;;
    # }
    dimension: id {
      type: string
      sql: ${TABLE}."VENDORID" ;;
    }
  dimension: vendor_category {
    type: string
    sql: ${TABLE}.vendor_category ;;
  }
    dimension: name {
      type: string
      sql: ${TABLE}."NAME" ;;
    }

    dimension: terms {
      type: string
      sql: ${TABLE}."TERMNAME" ;;
    }

    dimension: payment_year {
      type: number
      sql: ${TABLE}."PAYMENT_YEAR" ;;
    }

    dimension: payment_time_days {
      type: number
      sql: ${TABLE}."PAYMENT_TIME_DAYS" ;;
    }

    dimension: bill_number {
      type: string
      sql: ${TABLE}."BILL_NUMBER" ;;
    }

  dimension: bill_date {
    type: date
    sql: ${TABLE}."BILL_DATE" ;;
  }

  dimension: payment_date {
    type: date
    sql: ${TABLE}."PAYMENTDATE" ;;

  }# dimension: prior_year_avg_days_to_pay {
    #   type: number
    #   sql: ${TABLE}."PRIOR_YEAR_AVG_DAYS_TO_PAY" ;;
    # }
    # dimension: two_years_ago_paid {
    #   type: number
    #   sql: ${TABLE}."TWO_YEARS_AGO_PAID" ;;
    # }

    # dimension: two_years_ago_avg_days_to_pay {
    #   type: number
    #   sql: ${TABLE}."TWO_YEARS_AGO_AVG_DAYS_TO_PAY" ;;
    # }

    set: detail {
      fields: [
        id,
        name,
        terms,
        payment_year,
        payment_time_days,
        bill_number
      ]
    }
  }
