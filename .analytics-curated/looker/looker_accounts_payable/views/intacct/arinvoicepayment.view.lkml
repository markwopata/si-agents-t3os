view: arinvoicepayment {
    # sql_table_name: "INTACCT"."ARINVOICEPAYMENT" ;;
    derived_table: {
      sql:
      with main as (SELECT recordkey, amount, paymentdate, concat(recordkey, amount, paymentdate) as dis_key
      FROM ANALYTICS.INTACCT.ARINVOICEPAYMENT
      where parentpymt <> recordkey

        UNION ALL

        SELECT recordno as recordkey, trx_totalentered as amount, null, concat(amount, whencreated,recordkey )
        FROM ANALYTICS.INTACCT.ARRECORD
        where arrecord.trx_totalentered < 0 and arrecord.trx_totalentered is not null
        and arrecord.recordtype = 'arinvoice'
        --and upper(arrecord.docnumber) not like '%CREDIT%'

        ),
        r_numbers as (
        select
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS unique_id, main.*
        from main
        )

        select r_numbers.*, arrecord.recordid
        from r_numbers
        left join analytics.intacct.arrecord on r_numbers.recordkey = arrecord.recordno
        where recordkey not in ('8565520','9193091')

        ;;


    }

    # measure: amount_paid {
    #   type: sum
    #   drill_fields: [detail*]
    #   sql: ${TABLE}."AMOUNT" ;;
    # }

    measure: amount_paid {
      type:  sum
      sql:
      --CASE
      --WHEN ${ardetail.amount} < 0 and ${ardetail.amount} is not null then 0

                                  -- when ${arrecord.recordid} LIKE '%REV%' THEN null

                                 -- else ${TABLE}."AMOUNT"
                               -- END

                              ${TABLE}."AMOUNT"  ;;

      ##this is the same as the credits_filtered_sum_amount_paid but had to leave for reasons
      drill_fields: [detail*]

    }

    measure: credits_filtered_sum_amount_paid {
      type:  sum
      sql:
      --CASE
      --WHEN ${ardetail.amount} < 0 and ${ardetail.amount} is not null then 0

                                  -- when ${arrecord.recordid} LIKE '%REV%' THEN null

                                  --else ${TABLE}."AMOUNT"
                                --END

                             ${TABLE}."AMOUNT"  ;;
      label: "Filtered of Invoices Paid"
      drill_fields: [detail*]

    }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."RECORDID" ;;
  }
    dimension: unique_id {
       primary_key: yes
      type: string
      sql: ${TABLE}."UNIQUE_ID" ;;
    }

  dimension: recordkey {
    type: string
    sql: ${TABLE}."RECORDKEY" ;;
  }
    # dimension_group: _es_update_timestamp {
    #   type: time
    #   timeframes: [raw, time, date, week, month, quarter, year]
    #   sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
    # }

    dimension: amount {
      type: number
      sql: ${TABLE}."AMOUNT" ;;
    }

    # dimension: createdby {
    #   type: number
    #   sql: ${TABLE}."CREATEDBY" ;;
    # }
    # dimension: currency {
    #   type: string
    #   sql: ${TABLE}."CURRENCY" ;;
    # }
    # dimension_group: ddsreadtime {
    #   type: time
    #   timeframes: [raw, time, date, week, month, quarter, year]
    #   sql: CAST(${TABLE}."DDSREADTIME" AS TIMESTAMP_NTZ) ;;
    # }
    # dimension: invbaseamt {
    #   type: number
    #   sql: ${TABLE}."INVBASEAMT" ;;
    # }
    # dimension: invtrxamt {
    #   type: number
    #   sql: ${TABLE}."INVTRXAMT" ;;
    # }
    # dimension: modifiedby {
    #   type: number
    #   sql: ${TABLE}."MODIFIEDBY" ;;
    # }
    # dimension: paiditemkey {
    #   type: number
    #   sql: ${TABLE}."PAIDITEMKEY" ;;
    # }
    # dimension: parentpymt {
    #   type: number
    #   sql: ${TABLE}."PARENTPYMT" ;;
    # }
    # dimension: payitemkey {
    #   type: number
    #   sql: ${TABLE}."PAYITEMKEY" ;;

    # dimension_group: paymentdate {
    #   type: time
    #   timeframes: [raw, date, week, month, quarter, year]
    #   convert_tz: no
    #   datatype: date
    #   sql: ${TABLE}."PAYMENTDATE" ;;
    # }

    # dimension: paymentkey {
    #   type: number
    #   sql: ${TABLE}."PAYMENTKEY" ;;
    # }
    # dimension: recordkey {
    #   type: number
    #   sql: ${TABLE}."RECORDKEY" ;;
    # }
    # dimension: recordno {
    #   type: number
    #   primary_key: yes
    #   sql: ${TABLE}."RECORDNO" ;;
    # }
    # dimension: state {
    #   type: string
    #   sql: ${TABLE}."STATE" ;;
    # }
    # dimension: trx_amount {
    #   type: number
    #   sql: ${TABLE}."TRX_AMOUNT" ;;
    # }
    # dimension_group: whencreated {
    #   type: time
    #   timeframes: [raw, time, date, week, month, quarter, year]
    #   sql: CAST(${TABLE}."WHENCREATED" AS TIMESTAMP_NTZ) ;;
    # }
    # dimension_group: whenmodified {
    #   type: time
    #   timeframes: [raw, time, date, week, month, quarter, year]
    #   sql: CAST(${TABLE}."WHENMODIFIED" AS TIMESTAMP_NTZ) ;;
    # }
    # measure: count {
    #   type: count
    #}
    # ----- Sets of fields for drilling ------
    set: detail {
      fields: [
        recordkey,invoice_number

        ,credits_filtered_sum_amount_paid

      ]
    }

  }

#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
