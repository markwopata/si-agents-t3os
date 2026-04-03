view: p2p_purchase_order_entry_que {
    derived_table: {
      sql:
      with master as (

SELECT
-- pd.*,
--pd.createdfrom,
pd.docid,
pd.userid,
    PD.WHENCREATED,
     PD.DOCNO AS POE_NUMBER,
     PD.STATE AS STATUS,
    -- pd.createdby,
    PD.CUSTVENDID AS VENDOR_ID,
    VEND.NAME AS VENDOR_NAME,
    pde.docparid,
  pd.total,
  pd.whenmodified,
  pd.whendue,
    pd.blanket_po,
    pd.term_name,
pd._es_update_timestamp,
--pd.concur_image_id,
CURRENT_DATE() - pd.whencreated as days_since_creation,
case when current_date() - pd.whendue > 0 then (current_date() - pd.whendue) else 0 end as days_past_due,
--pd.totaldue,
case when pd.total > 49999 then true else false end as greater_than_49k,
-- case when pd.status = 'Submitted' then CURRENT_DATE() - pd.whencreated
--         ELSE NULL
--         end AS days_since_creation

FROM ANALYTICS.INTACCT.PODOCUMENT PD
    LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON PD.CUSTVENDID = VEND.VENDORID
 LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY PDE ON PD.DOCID = PDE.DOCHDRID
    LEFT JOIN ANALYTICS.CONCUR.PENDING_HQ_APPROVAL PHQA ON PD.DOCNO = PHQA.PO_NUMBER

)
, poe as (--need to get created by and when converted to see how long in que
select distinct * from master

where docparid = 'Purchase Order Entry' and
--WHENCREATED > '2024-01-01' and
status =
'Submitted'
order by poe_number)
-- select * from poe

, cte as(

select
ui.supplier_invoice_number,
ui.request_id,
ui.payment_due_date,
case when ui.purchase_order_number is not null then true else false end as invoice_found_in_concur_backlog, poe.*
from poe

left join analytics.concur.unsubmitted_invoices ui  on ui.purchase_order_number = poe.poe_number)



, cte_with_rank AS (
    SELECT
        cte.*,
        t2.departmentid,t2.departmentname,t2.itemid,t2.itemdesc,
        ROW_NUMBER() OVER (PARTITION BY t2.DOCHDRID ORDER BY t2.departmentid, t2.itemid) AS rn
    FROM
        cte
    JOIN
    --JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY PDE ON PD.DOCID = PDE.DOCHDRID
        ANALYTICS.INTACCT.PODOCUMENTENTRY t2 ON cte.docid = t2.DOCHDRID
)
SELECT
    *
FROM
    cte_with_rank
WHERE
    rn = 1
    order by whencreated








        ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }
  dimension: created_by {
    type: string
    sql: ${TABLE}."USERID" ;;
  }
  dimension: when_created {
    type: date
    sql: ${TABLE}."WHENCREATED" ;;
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEMID" ;;
  }


  dimension: item_id_description {
    type: string
    sql: ${TABLE}."ITEMDESC" ;;
  }


    dimension: department_name {
      type: string
      sql: ${TABLE}."DEPARTMENTNAME" ;;
    }
    dimension: po_entry_number {
      type: string
      sql: ${TABLE}."POE_NUMBER" ;;
    }

  dimension: department_id {
    type: string
    sql: ${TABLE}."DEPARTMENTID" ;;
  }


  dimension: invoice_number {
    type: string
    sql: ${TABLE}."SUPPLIER_INVOICE_NUMBER" ;;
  }
  dimension: request_id {
    type: string
    sql: ${TABLE}."REQUESTID" ;;
  }
  dimension: concur_due_date {
    type: string
    sql: ${TABLE}."PAYMENT_DUE_DATE" ;;
  }
    # dimension: timewhencreated {
    #   type: date_time_of_day
    #   sql: ${TABLE}."STATUS" ;;
    # }

    # dimension_group: date_created {
    #   type: time
    #   timeframes: [raw, date, week, month, quarter, year]
    #   convert_tz: no
    #   datatype: date
    #   sql: ${TABLE}."WHENCREATED" ;;
    # }


    dimension: vendor_id {
      type: string
      sql: ${TABLE}."VENDOR_ID" ;;
    }



    dimension: vendor_name {
      type: string
      sql: ${TABLE}."VENDOR_NAME" ;;
    }

    dimension: docparid {
      type: string
      sql: ${TABLE}."DOCPARID" ;;
    }

    dimension: total {
      type: number
      sql: ${TABLE}."TOTAL" ;;
    }

    dimension: last_modified {
      type: string
      sql: ${TABLE}."WHENMODIFIED" ;;
    }

    dimension: due_date {
      type: date
      sql: ${TABLE}."WHENDUE" ;;
    }
    dimension: blanket_po {
      type: string
      sql: ${TABLE}."BLANKET_PO" ;;
    }


    dimension: term_name {
      type: string
      sql: ${TABLE}."TERM_NAME" ;;
    }

    dimension: days_since_created {
      type: string
      sql: ${TABLE}."DAYS_SINCE_CREATION" ;;
    }
    dimension: days_past_due {
      type: string
      sql: ${TABLE}."DAYS_PAST_DUE" ;;
    }





  dimension: invoice_found_in_concur_backlog {
    type: string
    sql: ${TABLE}."INVOICE_FOUND_IN_CONCUR_BACKLOG" ;;
  }
  dimension: greater_than_49k {
    type: string
    sql: ${TABLE}."GREATER_THAN_49K" ;;
  }









    # dimension_group: monthyear {
    #   type: time
    #   timeframes: [raw, date, week, month, quarter, year]
    #   convert_tz: no
    #   datatype: date
    #   sql: ${TABLE}."MONTH_YEAR" ;;
    # }
    # measure: total_processed_invoices_count {
    #   type: number
    #   sql: ${TABLE}."PROCESSED_INVOICES_COUNT" ;;
    # }

    # measure: total_invoices_received_count {
    #   type: number
    #   sql: ${TABLE}."INVOICES_RECEIVED_COUNT" ;;
    # }

    # measure: total_system_concur_processed_invoices_count {
    #   type: number
    #   sql: ${TABLE}."SYSTEM_CONCUR_PROCESSED_INVOICES_COUNT" ;;
    # }

    # measure: total_adjusted_invoices_received_count {
    #   type: number
    #   sql: ${TABLE}."ADJUSTED_INVOICES_RECEIVED_COUNT" ;;
    # }
    # dimension: intacct_total {
    #   type: number
    #   sql: ${TABLE}."INT_TOTAL" ;;
    # }

    # dimension: intacct_state {
    #   type: string
    #   sql: ${TABLE}."INT_STATE" ;;
    # }

    # dimension: modified_by_id {
    #   type: string
    #   sql: ${TABLE}."MODIFIED_BY_ID" ;;
    # }

    # dimension: modified_by_login {
    #   type: string
    #   sql: ${TABLE}."MODIFIED_BY_LOGIN" ;;
    # }

    # dimension: po_number {
    #   type: string
    #   sql: ${TABLE}."PO_NUMBER" ;;
    # }

    # dimension: receipt_number {
    #   type: string
    #   sql: ${TABLE}."RECEIPT_NUMBER" ;;
    # }

    # dimension: date_received {
    #   type: date
    #   sql: ${TABLE}."DATE_RECEIVED" ;;
    # }

    # dimension: month {
    #   type: string
    #   label: "Month"
    #   sql: to_varchar(${TABLE}."PERIOD", 'MMMM YYYY');;
    # }

    # dimension: payed_amount {
    #   type: number
    #   sql: ${TABLE}."ACCEPT_QTY" ;;
    # }

    # dimension: payed_count_by_gl {
    #   type: number
    #   sql: ${TABLE}."REJECT_QTY" ;;
    # }

    # dimension: billed_amount {
    #   type: number
    #   sql: ${TABLE}."RECEIPT_QTY" ;;
    # }

    # dimension: billed_count_by_gl {
    #   type: number
    #   sql: ${TABLE}."UNIT_PRICE" ;;
    # }

    # dimension: billed_count_by_gl {
    #   type: number
    #   sql: ${TABLE}."EXT_COST" ;;
    # }

    # dimension: billed_count_by_gl {
    #   type: number
    #   sql: ${TABLE}."RECEIPT_CREATED" ;;
    # }


    # measure: paid {
    #   label: "Paid Amount"
    #   type: sum
    #   value_format: "#,##0;(#,##0);-"
    #   sql: ${payed_amount} ;;
    # }

    # measure: paid_count_by_gl {
    #   label: "Paid Count by GL"
    #   type: sum
    #   sql: ${payed_count_by_gl} ;;
    # }

    # measure: billed {
    #   label: "Billed Amount"
    #   type: sum
    #   value_format: "#,##0;(#,##0);-"
    #   sql: ${billed_amount} ;;
    # }

    # measure: billed_count {
    #   label: "Billed Count by GL"
    #   type: sum
    #   sql: ${billed_count_by_gl} ;;
    # }

    set: detail {
      fields: [
       detail*
      ]
    }
  }
