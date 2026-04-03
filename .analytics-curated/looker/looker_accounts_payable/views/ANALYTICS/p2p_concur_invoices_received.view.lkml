view: p2p_concur_invoices_received {
    derived_table: {
      sql: with main as (
select request_id, invoice_name,

case when po_number = 'nan' then true else false
        end as po_is_blank,
-- case when po_number is not null and po_number::string regexp '^[0-9]{6}$' and cast(po_number as int) > 299999 then True else False
--         end as valid_t3_po,
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

)
select * from main where request_id not in (select request_id from analytics.concur.deleted_invoices)


;;


    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: request_id {
      primary_key: yes
      type: string
      sql: ${TABLE}."REQUEST_ID" ;;
    }
  dimension: adjusted_exclusion_reasons {
    type: string
    sql: ${TABLE}."ADJUSTED_EXCLUSION_REASONS" ;;
  }
    dimension: invoice_name {
      type: string
      sql: ${TABLE}."INVOICE_NAME" ;;
    }

    dimension: po_is_blank {
      type: yesno
      sql: ${TABLE}."PO_IS_BLANK" ;;
    }

    dimension: valid_t3_po {
      type: yesno
      sql: ${TABLE}."VALID_T3_PO" ;;
    }

    dimension: valid_corporate_po {
      type: yesno
      sql: ${TABLE}."VALID_CORPORATE_PO" ;;
    }
  dimension: future_dated_invoice {
    type: yesno
    sql: ${TABLE}."IS_INVOICE_DATE_AFTER_LAST_DAY_OF_MONTH_SYSTEM_RECEIVED_DATE" ;;
  }

  dimension: branch_inventory_five_day_lead_time {
    type: yesno
    sql: ${TABLE}."BRANCH_INVENTORY_FIVE_DAY_LEAD_TIME" ;;
  }
  dimension: branch_non_inventory_five_day_lead_time {
    type: yesno
    sql: ${TABLE}."BRANCH_NON_INVENTORY_FIVE_DAY_LEAD_TIME" ;;
  }
    dimension: multiple_receipt_exclusion {
      type: yesno
      sql: ${TABLE}."MULTIPLE_RECEIPT_EXCLUSION" ;;
    }

    dimension: sage_vendor_category {
      type: string
      sql: ${TABLE}."SAGE_VENDOR_CATEGORY" ;;
    }

    dimension: credit_or_zero_dollar_inventory_exclusion {
       type: yesno
      sql: ${TABLE}."CREDIT_OR_ZERO_DOLLAR_INVENTORY_EXCLUSION" ;;
    }

    dimension: po_not_required {
      type: yesno
      sql: ${TABLE}."PO_NOT_REQUIRED" ;;
    }

    dimension: possible_duplicate {
      type: yesno
      sql: ${TABLE}."POSSIBLE_DUPLICATE" ;;
    }

    dimension: vpo_or_spo {
      type: yesno
      sql: ${TABLE}."VPO_OR_SPO" ;;
    }

    dimension: credit_card {
      type: yesno
      sql: ${TABLE}."CREDIT_CARD" ;;
    }

    dimension: invalid_date {
      type: yesno
      sql: ${TABLE}."INVALID_DATE" ;;
    }

    # dimension: invoice_date_greater_than_system_received_date {
    #   type: yesno
    #   sql: ${TABLE}."INVOICE_DATE_GREATER_THAN_SYSTEM_RECEIVED_DATE" ;;
    # }

    dimension: submitted_by_system_concur {
      type: yesno
      sql: ${TABLE}."CLEAN_SUBMITTED_BY_CONCUR" ;;
    }

    dimension: po_number {
      type: string
      sql: ${TABLE}."PO_NUMBER" ;;
    }

    dimension: invoice_number {
      type: string
      sql: ${TABLE}."INVOICE_NUMBER" ;;
    }

    dimension: approval_status {
      type: string
      sql: ${TABLE}."APPROVAL_STATUS" ;;
    }

    dimension: policy {
      type: string
      sql: ${TABLE}."POLICY" ;;
    }

    dimension: vendor_code {
      type: string
      sql: ${TABLE}."VENDOR_CODE" ;;
    }

    dimension: vendor_name {
      type: string
      sql: ${TABLE}."VENDOR_NAME" ;;
    }

  dimension: employee_last_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_LAST_NAME" ;;
  }

  dimension: submitter {
    type: string
    sql: ${TABLE}."SUBMITTER" ;;
  }

  dimension: request_total {
    type: number
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }

  dimension: system_received_date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."SYSTEM_RECEIVED_DATE" ;;
  }
  dimension_group: srdate {
    convert_tz:  no
    type: time

    sql: ${TABLE}."SYSTEM_RECEIVED_DATE" ;;
  }

  dimension: invoice_date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: payment_due_date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."PAYMENT_DUE_DATE" ;;
  }




    set: detail {
      fields: [
        request_id,
        invoice_name,
        po_is_blank,
        valid_t3_po,
        valid_corporate_po,

        multiple_receipt_exclusion,
        sage_vendor_category,
        credit_or_zero_dollar_inventory_exclusion,
        po_not_required,
        possible_duplicate,
        vpo_or_spo,
        credit_card,
        invalid_date,

        submitted_by_system_concur,
        po_number,
        invoice_number,
        approval_status,
        policy,
        vendor_code,
        vendor_name,
        employee_last_name,
        submitter,
        request_total,
        system_received_date,
        invoice_date,
        payment_due_date
      ]
    }
  }
