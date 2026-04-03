with
/* -------------------------- 1) Inputs -------------------------- */
commission_data as (
  select
      commission_id,
      line_item_id,
      salesperson_user_id,
      credit_note_line_item_id,
      manual_adjustment_id,
      transaction_type,          -- 1=commission, 2=clawback, 3=reimbursement
      commission_type,           -- 1=TAM, 2=NAM, 3=RC, etc
      transaction_date,
      commission_rate,
      split,
      reimbursement_factor,
      override_rate,
      exception,
      amount,
      false as is_finalized
  from {{ ref('int_commissions_combined_final') }}
),

/* Map region → RC go-live date; others default later */
rc_go_live as (
  select 4 as region, to_date('2025-06-18') as effective_date union all
  select 1, to_date('2025-07-10') union all
  select 2, to_date('2025-07-10') union all
  select 3, to_date('2025-07-10')
),
rc_default as (
  select to_date('2025-07-16') as effective_date
),

latest_termination as (
  select
      employee_id,
      date_terminated
  from {{ ref('stg_analytics_payroll__company_directory') }}
),


/* ----------------------- 2) Enrichment ------------------------ */
commission_data_enriched as (
  select
      cd.commission_id,
      cd.line_item_id,
      cd.salesperson_user_id,
      lid.invoice_id,
      lid.invoice_no,
      lid.order_id,
      lid.order_date,
      lid.market_id,
      lid.market_name,
      lid.parent_market_id,
      lid.parent_market_name,
      lid.region,
      lid.region_name,
      lid.district,
      lid.ship_to_state,
      lid.company_id,
      lid.company_name,
      lid.line_item_type_id,
      lid.line_item_type,
      lid.asset_id,
      lid.invoice_asset_make,
      lid.invoice_class_id,
      lid.invoice_class,
      lid.rental_class_id          as rental_class_id_from_rental,
      lid.rental_class             as rental_class_from_line_item,
      lid.amount                   as line_item_amount,
      cd.amount,
      lid.email_address,
      lid.employee_id,
      lid.full_name,
      lid.employee_title,

      /* derived helpers */
      case cd.transaction_type
        when 1 then iff(cd.credit_note_line_item_id is null, 'commission', 'credit')
        when 2 then 'clawback'
        when 3 then 'reimbursement'
      end                                           as transaction_type,

      lid.employee_manager_id,
      lid.employee_manager,
      case when cd.commission_type = 2 then 1 else lid.salesperson_type_id end as salesperson_type_id,
      case when cd.commission_type = 2 then 'Primary' else lid.sales_person_type end as salesperson_type,

      /* employee_type lookup (commission vs guarantee vs non-sales) */
      case
        when cd.transaction_type = 1
         and cd.transaction_date between eci.guarantee_start and eci.guarantee_end then 'guarantee'
        when cd.transaction_type = 1
         and cd.transaction_date between eci.commission_start and eci.commission_end then 'commission'

        when cd.transaction_type in (2,3)
         and cd.transaction_date between eci.guarantee_start and eci.guarantee_end then 'guarantee'
        when cd.transaction_type in (2,3)
         and cd.transaction_date between eci.commission_start and eci.commission_end
         and lid.billing_approved_date between eci.commission_start and eci.commission_end then 'commission'

        else 'non-salesperson'
      end                                           as employee_type,
      eci.guarantee_start,
      eci.commission_start,
      eci.guarantee_end,
      lid.secondary_rep_count,
      lid.rate_tier_id,
      lid.rate_tier_name,
      lid.book_rate,
      lid.benchmark_rate,
      lid.floor_rate,
      lid.business_segment_id,
      lid.rental_id,
      lid.rental_date_created,
      lid.rental_start_date,
      lid.rental_billed_days,
      lid.cheapest_period,
      lid.quoted_rates,
      cd.override_rate,
      coalesce(cd.exception, false)                 as is_exception,
      (cd.override_rate is not null)                as is_override,
      accc.full_name                                as allocation_cost_center,
      cd.commission_rate,                           -- ← unchanged
      cd.transaction_date,
      lid.billing_approved_date,
      cd.split,
      cd.transaction_type                           as transaction_type_id,
      cd.commission_type,
      eci.commission_type_id,
      lt.date_terminated,
      irscfd.is_payable                             as original_payable,
      cd.is_finalized,
      cd.reimbursement_factor,
      cd.credit_note_line_item_id,

      /* description helper */
      case
        when cd.transaction_type = 1 and cd.credit_note_line_item_id is not null then 'Credit Note Issued'
        when cd.transaction_type = 2 and cd.credit_note_line_item_id is not null then 'Credit Note Clawback'
        when cd.transaction_type = 3 and cd.credit_note_line_item_id is not null
             then concat('Credit Note ', round(coalesce(cd.reimbursement_factor,1)*100,0), '% Reimbursement')
        when cd.transaction_type = 1 then 'Commission Paid'
        when cd.transaction_type = 2 then 'Commission 120 Day Clawback'
        when cd.transaction_type = 3 then concat('Commission ', round(coalesce(cd.reimbursement_factor,1)*100,0), '% Reimbursement')
      end                                           as transaction_description,

      date_trunc(month, cd.transaction_date)        as commission_month,

      pp.paycheck_date,
      iff(not cd.is_finalized, true,
          current_timestamp() < dateadd(day,-1,pp.paycheck_date))  as hidden,

      cd.manual_adjustment_id
  from commission_data cd
  left join {{ ref('int_commissions_line_item_details') }}             lid
         on cd.line_item_id = lid.line_item_id
        and cd.salesperson_user_id = lid.salesperson_user_id
  left join {{ ref('stg_analytics_commission__employee_commission_info') }} eci
         on cd.salesperson_user_id = eci.user_id
        and lid.billing_approved_date
            between coalesce(eci.guarantee_start, eci.commission_start) and eci.commission_end
  left join {{ ref('stg_analytics_payroll__all_company_cost_centers') }} accc
         on lid.parent_market_id = accc.intaact
        and accc.name = 'Equipment Rental'
  left join {{ ref('stg_analytics_payroll__pay_periods') }} pp
         on comm_check_date
        and date_trunc(month,dateadd(month,-1,pp.paycheck_date)) = date_trunc(month,cd.transaction_date)
  left join latest_termination lt
    on lid.employee_id = lt.employee_id
  left join {{ ref('stg_analytics_commission__commission_details_final') }} irscfd
         on irscfd.commission_id =
              {{ generate_commission_id(
                     'cd.line_item_id',
                     'cd.salesperson_user_id',
                     '0',
                     'cd.manual_adjustment_id',
                     '1',
                     'cd.commission_type'
                 ) }}
),

/* ------------------- 3) Human-friendly flags ------------------ */
flags as (
  select
    cde.*,
    /* classify people + workflows */
    (commission_type = 3)                                    as is_rc,
    (commission_type = 1)                                    as is_tam,
    (commission_type_id in (6,7) and commission_type = 2)    as is_nam,
    (commission_type_id > 7)                                 as is_ram,
    (employee_title = 'Rental Coordinator')                  as is_title_rc,

    /* transaction kinds */
    (transaction_type_id = 1 and credit_note_line_item_id is     null) as is_commission_txn,
    (transaction_type_id = 1 and credit_note_line_item_id is not null) as is_credit_txn,
    (transaction_type_id = 2)                                           as is_clawback_txn,
    (transaction_type_id = 3)                                           as is_reimb_txn,

    /* RC rollout window by region (with default) */
    iff(transaction_date >= coalesce(rg.effective_date, rd.effective_date), true, false) as is_rc_rollout_active
  from commission_data_enriched cde
  left join rc_go_live  rg on cde.region = rg.region
  cross join rc_default rd
),

/* --------------- 4) Payability (pre-dedupe) ------------------- */
payability_init as (
  select
    f.*,
    case
      /* RC workflow */
      when f.is_rc then
        case
          -- Base RC commissions
          when f.commission_rate > 0
            and f.is_rc_rollout_active
              and (
                    f.date_terminated is null
                    or f.transaction_date::date <= f.date_terminated
                  )
              and not (
                    f.guarantee_start is not null
                    and f.transaction_date::date between f.guarantee_start::date and f.guarantee_end::date

                  )
          then true
          -- RC credits / clawbacks / reimbursements
          when (
                (f.is_credit_txn or f.is_clawback_txn or f.is_reimb_txn)
                and (f.original_payable = true or f.original_payable is null)
                and (
                      f.date_terminated is null
                      or f.transaction_date::date <= f.date_terminated
                    )
                and not (
                  f.guarantee_start is not null
                  and f.transaction_date::date between f.guarantee_start::date and f.guarantee_end::date
                )
              )
              then true

          else false
        end
      /* TAMs */
      when f.commission_type_id < 6 then
        case
          when f.is_commission_txn and f.employee_type = 'commission' then true
          when ( (f.is_credit_txn or f.is_clawback_txn or f.is_reimb_txn)
                 and (f.original_payable = true or f.original_payable is null)
                 and f.employee_type = 'commission' )
               then true
          else false
        end

      /* NAMs */
      when f.is_nam then
        case
          when f.is_commission_txn and f.employee_type = 'commission' then true
          when ( (f.is_credit_txn or f.is_clawback_txn or f.is_reimb_txn)
                 and (f.original_payable = true or f.original_payable is null)
                 and f.employee_type = 'commission' )
               then true
          else false
        end

      /* RAMs */
      when f.is_ram then
        case
          when f.is_commission_txn
               and f.employee_type = 'commission'
               and (f.line_item_type_id in (8,6,43,108,109)
                    and right(f.company_name,5) = '(RPO)')
               then true
          when ( (f.is_credit_txn or f.is_clawback_txn or f.is_reimb_txn)
                 and (f.original_payable = true or f.original_payable is null)
                 and f.employee_type = 'commission' )
               then true
          else false
        end

      /* Title-based RC (legacy TAM workflow) */
      when f.is_title_rc then
        case
          when f.is_commission_txn
            and f.line_item_type_id = 49
                    and (
                          f.date_terminated is null
                          or f.transaction_date::date <= f.date_terminated
                        )
                then true

          when ( (f.is_credit_txn or f.is_clawback_txn or f.is_reimb_txn)
                 and (f.original_payable = true or f.original_payable is null)
                 and (
              f.date_terminated is null
              or f.transaction_date::date <= f.date_terminated
            ))
               then true
          else false
        end

      else false
    end as is_payable_init
  from flags f
),

/* ----------- 5) RC keys that are actually payable -------------- */
rc_payable as (
  select distinct line_item_id, salesperson_user_id
  from payability_init
  where is_rc and is_payable_init
),

/* ---------------- 6) Final dedupe (easy to read) --------------- */
deduped as (
  select
    p.*,
    case
      when p.is_tam and rp.line_item_id is not null then false
      else p.is_payable_init
    end as is_payable
  from payability_init p
  left join rc_payable rp
    on rp.line_item_id        = p.line_item_id
   and rp.salesperson_user_id = p.salesperson_user_id
)

/* ------------------------- 7) Output --------------------------- */
select
  commission_id,
  line_item_id,
  salesperson_user_id,
  invoice_id,
  invoice_no,
  order_id,
  order_date,
  market_id,
  market_name,
  parent_market_id,
  parent_market_name,
  region,
  region_name,
  district,
  ship_to_state,
  company_id,
  company_name,
  line_item_type_id,
  line_item_type,
  asset_id,
  invoice_asset_make,
  invoice_class_id,
  invoice_class,
  rental_class_id_from_rental,
  rental_class_from_line_item,
  line_item_amount,
  amount,
  email_address,
  employee_id,
  full_name,
  employee_title,
  transaction_type,
  employee_manager_id,
  employee_manager,
  salesperson_type_id,
  salesperson_type,
  employee_type,
  secondary_rep_count,
  rate_tier_id,
  rate_tier_name,
  book_rate,
  benchmark_rate,
  floor_rate,
  business_segment_id,
  rental_id,
  rental_date_created,
  rental_start_date,
  rental_billed_days,
  cheapest_period,
  quoted_rates,
  override_rate,
  is_exception,
  is_override,
  allocation_cost_center,
  commission_rate, 
  commission_type,
  transaction_date,
  billing_approved_date,
  split,
  transaction_type_id,
  is_payable,
  original_payable,
  is_finalized,
  reimbursement_factor,
  credit_note_line_item_id,
  transaction_description,
  commission_month,

  iff(commission_rate != 0, coalesce(override_rate, commission_rate), commission_rate)
    * split
    * coalesce(reimbursement_factor, 1)
    * (case when is_exception and transaction_type_id = 1 then 1
            when is_exception then 0 else 1 end)
    * amount                                       as commission_amount,

  paycheck_date,
  hidden,
  manual_adjustment_id
from deduped
