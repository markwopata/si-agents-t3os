view: p2p_auto_submits {

    derived_table: {
      sql: SELECT month as month_year,
  MAX(CASE WHEN source = 'Processed Invoices' THEN row_count END) AS processed_invoices_count,
  MAX(CASE WHEN source = 'Invoices Received' THEN row_count END) AS invoices_received_count,
MAX(CASE WHEN source = 'System Concur Processed Invoices' THEN row_count END) AS system_concur_processed_invoices_count,
MAX(CASE WHEN source = 'adjusted_invoices_received' THEN row_count END) AS adjusted_invoices_received_count
FROM (
  SELECT
    DATE_TRUNC('MONTH', submit_date) AS month,
    'Processed Invoices' AS source,
    COUNT(*) AS row_count
  FROM
    analytics.concur.processed_invoices_by_ap_user
  GROUP BY
    month

  UNION ALL

  SELECT
    DATE_TRUNC('MONTH', system_received_date) AS month,
    'Invoices Received' AS source,
    COUNT(*) AS row_count
  FROM
     (select request_id, invoice_name,

case when po_number = 'nan' then true else false
        end as po_is_blank,
-- case when po_number is not null and po_number::string regexp '^[0-9]{6}$' and cast(po_number as int) > 299999 then True else False
--         end as valid_t3_po,
--CASE
--  WHEN
--    (po_number IS NOT NULL AND po_number::string regexp '^[0-9]{6}$' AND cast(po_number AS int) > 299999) OR
--    (po_number IS NOT NULL AND po_number::string regexp '^[0-9]{6}-[0-9]{1,2}$' AND cast(replace(po_number, '-', '') AS int) > 299999)
--  THEN True
--  ELSE False
--END AS valid_t3_po,
CASE
  WHEN
    (po_number IS NOT NULL AND po_number::string regexp '^[0-9]{6}$' AND cast(po_number AS int) > 299999) OR
    (po_number IS NOT NULL AND po_number::string regexp '^[0-9]{6}-[0-9]{1,2}$' AND cast(replace(po_number, '-', '') AS int) > 299999)

    or --added latdr for when po went to next thousands
     (po_number IS NOT NULL AND po_number::string regexp '^[0-9]{7}$' AND cast(po_number AS int) > 299999) OR
    (po_number IS NOT NULL AND po_number::string regexp '^[0-9]{7}-[0-9]{1,2}$' AND cast(replace(po_number, '-', '') AS int) > 299999)

  THEN True
  ELSE False
END AS valid_t3_po,




-- case when regexp_like(po_number, '^E[0-9]{6}$') then true else false
--         end as valid_corporate_po,

CASE
  -- WHEN
  --   (regexp_like(po_number, '^E[0-9]{6}$') OR
  --    regexp_like(po_number, '^E[0-9]{6}-[0-9]+$')

    WHEN CAST(po_number AS STRING) REGEXP '^[1-2][0-9]{5}$' THEN true  -- six digits, starts with 1 or 2
    WHEN CAST(po_number AS STRING) REGEXP '^[1-2][0-9]{5}-[0-9]{1,2}$' THEN true  -- six digits, starts with 1 or 2, and - followed by up to two digits
    WHEN CAST(po_number AS STRING) REGEXP '^E[0-9]{6}$' THEN true  -- E followed by six digits
    WHEN CAST(po_number AS STRING) REGEXP '^E[0-9]{6}-[0-9]{2}$' THEN true  -- E followed by six digits and - followed by two digits
      -- None of the specified conditions matched



  ELSE false
END AS valid_corporate_po,



case
--when regexp_like(po_number, '^[0-9]{6}-[0-9]$') then true else false
when contains(po_number, '-') then true else false
        end as multiple_receipt_exclusion,
case when vendor_code in (select vendorid from analytics.intacct.vendor where vendor_category in ('Equipment/Attachment Purchase','OEM Parts/Equipment Parts/Batteries/Hoses & Fittings')) then 'inventory' else 'non_inventory'
        end as sage_vendor_category,
case when request_total <= 0 and sage_vendor_category = 'inventory' then true else false
        end as credit_or_zero_dollar_inventory_exclusion,
case when valid_t3_po = false and valid_corporate_po = false and vendor_code in (select vendorid from analytics.intacct.vendor where vendor_category in ('Transportation Services/Postage','Fuel/Propane/Welding Supplies & Gases')) then true else false        end as po_not_required,
case when count(*) over(partition by invoice_number, vendor_code, request_total, DATE_TRUNC('MONTH', system_received_date)) > 1 then true else false
        end as possible_duplicate,
case
--regexp_like(po_number, '^(VPO|SPO|BPO).*$', 'i') then true else false
when CONTAINS(upper(po_number), 'VP') then true
when CONTAINS(upper(po_number), 'SP') then true
when CONTAINS(upper(po_number), 'BP') then true
else false
        end as vpo_or_spo,

case --when regexp_like(upper(po_number), 'PAID|MC|VISA|CARD|EXPRESS|CREDIT|CC|CREDIT CARD PAY', 'i') then true else false

 when CONTAINS(upper(po_number), 'PAID') then true
  when CONTAINS(upper(po_number), 'MC') then true
 when CONTAINS(upper(po_number), 'VISA') then true
 when CONTAINS(upper(po_number), 'CARD') then true
 when CONTAINS(upper(po_number), 'EXPRESS') then true
 when CONTAINS(upper(po_number), 'MASTER') then true
 when CONTAINS(upper(po_number), 'CREDIT') then true
 when CONTAINS(upper(po_number), 'PAY') then true
 when CONTAINS(upper(po_number), 'REQUIRED') then true
 when CONTAINS(upper(po_number), 'CC') then true
else false
end as credit_card,


case when system_received_date < dateadd(month, -6, system_received_date) and system_received_date <= dateadd(month, 6, system_received_date) then true else false
        end as invalid_date,
case when invoice_date > system_received_date then true else false
        end as invoice_date_greater_than_system_received_date,
case when submitter = 'System, Concur' then true else false
        end as clean_submitted_by_concur,
 CASE WHEN invoice_date IS NOT NULL AND
                 invoice_date > LAST_DAY(DATE_TRUNC('MONTH', system_received_date)) THEN TRUE
            ELSE FALSE
       END AS is_invoice_date_after_last_day_of_month_system_received_date,
  CASE WHEN invoice_date IS NOT NULL AND
                 invoice_date >= DATEADD(DAY, -7, LAST_DAY(DATE_TRUNC('MONTH', system_received_date))) THEN TRUE
            ELSE FALSE end as within_5_business_days,
case when within_5_business_days = true and valid_t3_po = true and sage_vendor_category = 'inventory' then true else false
    end as branch_inventory_five_day_lead_time,
case when within_5_business_days = true and valid_t3_po = true and sage_vendor_category = 'non_inventory' then true else false
    end as branch_non_inventory_five_day_lead_time,
case
    when clean_submitted_by_concur = false and credit_or_zero_dollar_inventory_exclusion = true then true
    when clean_submitted_by_concur = false and po_not_required = true then true
    when clean_submitted_by_concur = false and possible_duplicate = true then true
    when clean_submitted_by_concur = false and vpo_or_spo = true then true
    when clean_submitted_by_concur = false and credit_card = true then true
    when clean_submitted_by_concur = false and multiple_receipt_exclusion = true then true
    when clean_submitted_by_concur = false and is_invoice_date_after_last_day_of_month_system_received_date = true then true
    when clean_submitted_by_concur = false and invalid_date = true then true
    when clean_submitted_by_concur = false and branch_inventory_five_day_lead_time = true then true
    when clean_submitted_by_concur = false and branch_non_inventory_five_day_lead_time = true then true

else false
end as adjusted_exclusions,

CASE
    WHEN adjusted_exclusions = TRUE THEN
        CASE
            WHEN multiple_receipt_exclusion = TRUE THEN 'multiple_receipt_exclusion'
            WHEN credit_or_zero_dollar_inventory_exclusion = TRUE THEN 'credit_or_zero_dollar_inventory_exclusion'
            WHEN po_not_required = TRUE THEN 'po_not_required'
            WHEN possible_duplicate = TRUE THEN 'possible_duplicate'
            WHEN vpo_or_spo = TRUE THEN 'vpo_or_spo'
            WHEN credit_card = TRUE THEN 'credit_card'
            WHEN is_invoice_date_after_last_day_of_month_system_received_date = TRUE THEN 'future_dated_invoice'
            WHEN branch_inventory_five_day_lead_time = TRUE THEN 'branch_inventory_five_day_lead_time'
            WHEN branch_non_inventory_five_day_lead_time = TRUE THEN 'branch_non_inventory_five_day_lead_time'
            WHEN invalid_date = TRUE THEN 'invalid_date'
            ELSE ''
        END
    ELSE NULL
END AS adjusted_exclusion_reasons,


po_number, invoice_number, approval_status, policy, vendor_code, vendor_name,  employee_last_name, submitter, request_total, system_received_date, invoice_date,  payment_due_date, latest_submit_date
from analytics.concur.invoices_received

) counts
  GROUP BY
    month

 UNION ALL

  SELECT
    DATE_TRUNC('MONTH', submit_date) AS month,
    'System Concur Processed Invoices' AS source,
    COUNT(*) AS row_count
  FROM
    analytics.concur.processed_invoices_by_ap_user where submitter = 'System, Concur'
  GROUP BY
    month

     UNION ALL

  SELECT
    DATE_TRUNC('MONTH', system_received_date) AS month,
    'adjusted_invoices_received' AS source,
    COUNT(*) AS row_count
  FROM
     (select request_id, invoice_name,

case when po_number = 'nan' then true else false
        end as po_is_blank,
-- case when po_number is not null and po_number::string regexp '^[0-9]{6}$' and cast(po_number as int) > 299999 then True else False
--         end as valid_t3_po,
-- CASE
--   WHEN
--    (po_number IS NOT NULL AND po_number::string regexp '^[0-9]{6}$' AND cast(po_number AS int) > 299999) OR
--    (po_number IS NOT NULL AND po_number::string regexp '^[0-9]{6}-[0-9]{1,2}$' AND cast(replace(po_number, '-', '') AS int) > 299999)
--  THEN True
--  ELSE False
-- END AS valid_t3_po,

CASE
  WHEN
    (po_number IS NOT NULL AND po_number::string regexp '^[0-9]{6}$' AND cast(po_number AS int) > 299999) OR
    (po_number IS NOT NULL AND po_number::string regexp '^[0-9]{6}-[0-9]{1,2}$' AND cast(replace(po_number, '-', '') AS int) > 299999)

    or --added latdr for when po went to next thousands
     (po_number IS NOT NULL AND po_number::string regexp '^[0-9]{7}$' AND cast(po_number AS int) > 299999) OR
    (po_number IS NOT NULL AND po_number::string regexp '^[0-9]{7}-[0-9]{1,2}$' AND cast(replace(po_number, '-', '') AS int) > 299999)

  THEN True
  ELSE False
END AS valid_t3_po,




-- case when regexp_like(po_number, '^E[0-9]{6}$') then true else false
--         end as valid_corporate_po,

CASE
  -- WHEN
  --   (regexp_like(po_number, '^E[0-9]{6}$') OR
  --    regexp_like(po_number, '^E[0-9]{6}-[0-9]+$')

    WHEN CAST(po_number AS STRING) REGEXP '^[1-2][0-9]{5}$' THEN true  -- six digits, starts with 1 or 2
    WHEN CAST(po_number AS STRING) REGEXP '^[1-2][0-9]{5}-[0-9]{1,2}$' THEN true  -- six digits, starts with 1 or 2, and - followed by up to two digits
    WHEN CAST(po_number AS STRING) REGEXP '^E[0-9]{6}$' THEN true  -- E followed by six digits
    WHEN CAST(po_number AS STRING) REGEXP '^E[0-9]{6}-[0-9]{2}$' THEN true  -- E followed by six digits and - followed by two digits
      -- None of the specified conditions matched



  ELSE false
END AS valid_corporate_po,



case
--when regexp_like(po_number, '^[0-9]{6}-[0-9]$') then true else false
when contains(po_number, '-') then true else false
        end as multiple_receipt_exclusion,
case when vendor_code in (select vendorid from analytics.intacct.vendor where vendor_category in ('Equipment/Attachment Purchase','OEM Parts/Equipment Parts/Batteries/Hoses & Fittings')) then 'inventory' else 'non_inventory'
        end as sage_vendor_category,
case when request_total <= 0 and sage_vendor_category = 'inventory' then true else false
        end as credit_or_zero_dollar_inventory_exclusion,
case when valid_t3_po = false and valid_corporate_po = false and vendor_code in (select vendorid from analytics.intacct.vendor where vendor_category in ('Transportation Services/Postage','Fuel/Propane/Welding Supplies & Gases')) then true else false        end as po_not_required,
case when count(*) over(partition by invoice_number, vendor_code, request_total, DATE_TRUNC('MONTH', system_received_date)) > 1 then true else false
        end as possible_duplicate,
case
--regexp_like(po_number, '^(VPO|SPO|BPO).*$', 'i') then true else false
when CONTAINS(upper(po_number), 'VP') then true
when CONTAINS(upper(po_number), 'SP') then true
when CONTAINS(upper(po_number), 'BP') then true
else false
        end as vpo_or_spo,

case --when regexp_like(upper(po_number), 'PAID|MC|VISA|CARD|EXPRESS|CREDIT|CC|CREDIT CARD PAY', 'i') then true else false

 when CONTAINS(upper(po_number), 'PAID') then true
  when CONTAINS(upper(po_number), 'MC') then true
 when CONTAINS(upper(po_number), 'VISA') then true
 when CONTAINS(upper(po_number), 'CARD') then true
 when CONTAINS(upper(po_number), 'EXPRESS') then true
 when CONTAINS(upper(po_number), 'MASTER') then true
 when CONTAINS(upper(po_number), 'CREDIT') then true
 when CONTAINS(upper(po_number), 'PAY') then true
 when CONTAINS(upper(po_number), 'REQUIRED') then true
 when CONTAINS(upper(po_number), 'CC') then true
else false
end as credit_card,


case when system_received_date < dateadd(month, -6, system_received_date) and system_received_date <= dateadd(month, 6, system_received_date) then true else false
        end as invalid_date,
case when invoice_date > system_received_date then true else false
        end as invoice_date_greater_than_system_received_date,
case when submitter = 'System, Concur' then true else false
        end as clean_submitted_by_concur,
 CASE WHEN invoice_date IS NOT NULL AND
                 invoice_date > LAST_DAY(DATE_TRUNC('MONTH', system_received_date)) THEN TRUE
            ELSE FALSE
       END AS is_invoice_date_after_last_day_of_month_system_received_date,
  CASE WHEN invoice_date IS NOT NULL AND
                 invoice_date >= DATEADD(DAY, -7, LAST_DAY(DATE_TRUNC('MONTH', system_received_date))) THEN TRUE
            ELSE FALSE end as within_5_business_days,
case when within_5_business_days = true and valid_t3_po = true and sage_vendor_category = 'inventory' then true else false
    end as branch_inventory_five_day_lead_time,
case when within_5_business_days = true and valid_t3_po = true and sage_vendor_category = 'non_inventory' then true else false
    end as branch_non_inventory_five_day_lead_time,
case
    when clean_submitted_by_concur = false and credit_or_zero_dollar_inventory_exclusion = true then true
    when clean_submitted_by_concur = false and po_not_required = true then true
    when clean_submitted_by_concur = false and possible_duplicate = true then true
    when clean_submitted_by_concur = false and vpo_or_spo = true then true
    when clean_submitted_by_concur = false and credit_card = true then true
    when clean_submitted_by_concur = false and multiple_receipt_exclusion = true then true
    when clean_submitted_by_concur = false and is_invoice_date_after_last_day_of_month_system_received_date = true then true
    when clean_submitted_by_concur = false and invalid_date = true then true
    when clean_submitted_by_concur = false and branch_inventory_five_day_lead_time = true then true
    when clean_submitted_by_concur = false and branch_non_inventory_five_day_lead_time = true then true

else false
end as adjusted_exclusions,

CASE
    WHEN adjusted_exclusions = TRUE THEN
        CASE
            WHEN multiple_receipt_exclusion = TRUE THEN 'multiple_receipt_exclusion'
            WHEN credit_or_zero_dollar_inventory_exclusion = TRUE THEN 'credit_or_zero_dollar_inventory_exclusion'
            WHEN po_not_required = TRUE THEN 'po_not_required'
            WHEN possible_duplicate = TRUE THEN 'possible_duplicate'
            WHEN vpo_or_spo = TRUE THEN 'vpo_or_spo'
            WHEN credit_card = TRUE THEN 'credit_card'
            WHEN is_invoice_date_after_last_day_of_month_system_received_date = TRUE THEN 'future_dated_invoice'
            WHEN branch_inventory_five_day_lead_time = TRUE THEN 'branch_inventory_five_day_lead_time'
            WHEN branch_non_inventory_five_day_lead_time = TRUE THEN 'branch_non_inventory_five_day_lead_time'
            WHEN invalid_date = TRUE THEN 'invalid_date'
            ELSE ''
        END
    ELSE NULL
END AS adjusted_exclusion_reasons,


po_number, invoice_number, approval_status, policy, vendor_code, vendor_name,  employee_last_name, submitter, request_total, system_received_date, invoice_date,  payment_due_date, latest_submit_date
from analytics.concur.invoices_received

) counts where adjusted_exclusion_reasons is null
  GROUP BY
    month

) AS subquery
GROUP BY
  month_year
ORDER BY
  month_year;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: processed_invoices_count {
      type: number
      sql: ${TABLE}."PROCESSED_INVOICES_COUNT" ;;
    }

    dimension: invoices_received_count {
      type: number
      sql: ${TABLE}."INVOICES_RECEIVED_COUNT" ;;
    }

    dimension: system_concur_processed_invoices_count {
      type: number
      sql: ${TABLE}."SYSTEM_CONCUR_PROCESSED_INVOICES_COUNT" ;;
    }

    dimension: adjusted_invoices_received_count {
      type: number
      sql: ${TABLE}."ADJUSTED_INVOICES_RECEIVED_COUNT" ;;
    }

    dimension: Date {
      type: date
      sql: ${TABLE}."MONTH_YEAR" ;;
    }
  dimension_group: srdate {
    convert_tz:  no
    type: time

    sql: ${TABLE}."MONTH_YEAR" ;;
  }

  dimension_group: monthyear {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MONTH_YEAR" ;;
  }
  measure: total_processed_invoices_count {
    type: number
    sql: ${TABLE}."PROCESSED_INVOICES_COUNT" ;;
  }

  measure: total_invoices_received_count {
    type: number
    sql: ${TABLE}."INVOICES_RECEIVED_COUNT" ;;
  }

  measure: total_system_concur_processed_invoices_count {
    type: number
    sql: ${TABLE}."SYSTEM_CONCUR_PROCESSED_INVOICES_COUNT" ;;
  }

  measure: total_adjusted_invoices_received_count {
    type: number
    sql: ${TABLE}."ADJUSTED_INVOICES_RECEIVED_COUNT" ;;
  }
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
        processed_invoices_count,
        invoices_received_count,
        system_concur_processed_invoices_count,
        adjusted_invoices_received_count

      ]
    }
  }
