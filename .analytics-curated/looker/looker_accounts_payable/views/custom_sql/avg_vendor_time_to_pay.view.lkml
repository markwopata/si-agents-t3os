view: avg_vendor_time_to_pay {
    derived_table: {
      sql: SELECT
vendorid,
    vendorname,
    AVG(DATEDIFF(day, whendue, whenpaid)) AS avg_payment_time_days,
    termname
FROM
    analytics.intacct.aprecord
WHERE
    whendue IS NOT NULL
    AND whenpaid IS NOT NULL
    and recordtype = 'apbill'
GROUP BY
    vendorid, vendorname, termname


      ;;
    }

    dimension: terms {
      type: string
      sql: ${TABLE}."TERMNAME" ;;
    }

    dimension: vendor_id {
      type: string
      sql: ${TABLE}."VENDORID" ;;
    }

    dimension: vendor_name {
      type: string
      sql: ${TABLE}."VENDORNAME" ;;
    }

    dimension: avg_days {
      type: number
      sql: ${TABLE}."AVG_PAYMENT_TIME_DAYS" ;;
    }


  }
