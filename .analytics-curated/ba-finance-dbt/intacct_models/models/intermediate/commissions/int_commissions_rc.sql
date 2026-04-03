with
  /*** 0) Get the latest title per employee_id & effective date ***/
  vault as (
    select
      employee_id,
      employee_title,
      position_effective_date,
      date_terminated
    from (
      select
        employee_id,
        employee_title,
        position_effective_date,
        date_terminated,
        _es_update_timestamp,
        row_number() over (
          partition by employee_id, position_effective_date
          order by _es_update_timestamp desc
        ) as rn
      from {{ ref('stg_analytics_payroll__company_directory_vault') }}
    ) t
    where rn = 1
  ),

  /*** 0b) Annotate each title with the next change ***/
  vault_with_next as (
    select
      employee_id,
      employee_title,
      position_effective_date,
      date_terminated,
      lead(position_effective_date)
        over(partition by employee_id order by position_effective_date) as next_effective_date
    from vault
  ),

  /*** 1) Link employee → user and only keep dispatchers/RCs, with their effective window ***/
  creator_info as (
    select
      u.user_id,
      u.first_name || ' ' || u.last_name           as full_name,
      v.employee_title,
      v.position_effective_date,
      v.next_effective_date,
      v.date_terminated
    from {{ ref('stg_es_warehouse_public__users') }} as u
    join vault_with_next                             as v
      on try_to_number(u.employee_id) = v.employee_id
    where
      v.employee_title ILIKE 'dispatcher%'
      or v.employee_title ILIKE '%rental coordinator%'
  ),

  /*** 2) Only line-items that occur during their RC/dispatcher window ***/
  rc_line_items as (
    select
      lid.line_item_id,
      lid.invoice_id,
      lid.company_id,
      lid.salesperson_user_id,
      lid.line_item_type_id,
      lid.sales_person_type,
      lid.amount                            as line_item_amount,
      lid.book_rate,
      lid.benchmark_rate,
      lid.floor_rate,
      lid.billing_approved_date::timestamp_ntz as transaction_date,
      ci.date_terminated
    from {{ ref('int_commissions_line_item_details') }} as lid
    join creator_info as ci
      on lid.salesperson_user_id = ci.user_id
      -- in or after they became RC/dispatcher...
      and lid.billing_approved_date::date >= ci.position_effective_date
      -- ...but before any later title change (or forever if null)
      and (
        lid.billing_approved_date::date < ci.next_effective_date
        or ci.next_effective_date is null
      )
    where lid.amount != 0
    and lid.billing_approved_date::date >= '2025-06-18'
    -- clamping down rc line items to only include commishable items
    and lid.line_item_type_id in (6, 8, 108, 109)
  ),

  /*** 3) bring in the invoice cycle ranks ***/
  cycle_ranks as (
    select
      company_id,
      invoice_id,
      invoice_sequence,
      billed_amount
    from {{ ref('int_company_invoice_cycle_ranks') }}
    where invoice_id in (select invoice_id from rc_line_items)
  ),

  /*** 4) generate the RC commissions data ***/
  rc_commission_data as (
    select
      {{ generate_commission_id(
          'rli.line_item_id',
          'rli.salesperson_user_id',
          '0','0','1','3'
      ) }}                          as commission_id,
      rli.*,
      case
        when 
          rli.date_terminated is not null
          and rli.transaction_date::date > rli.date_terminated 
          and rli.line_item_amount >= 0 
        then 0.00
      else
        case
            when rli.line_item_type_id in (6, 8, 108, 109)
            and rli.sales_person_type = 'Primary Salesperson'
            then
              case
                when cr.invoice_sequence = 1 then
                  case
                    -- Only tier AFTER 2025-08-01 (strictly greater than)
                    when rli.transaction_date::date > to_date('2025-08-01') then
                      case
                        when 
                          rli.book_rate is not null 
                          and rli.line_item_amount >= rli.book_rate 
                          then 0.04
                        when 
                          rli.benchmark_rate is not null 
                          and rli.line_item_amount >= rli.benchmark_rate
                          then 0.03
                        when 
                          rli.book_rate is null and rli.benchmark_rate is null
                          then 0.03
                        else 0.02
                      end
                    else 0.04  -- legacy flat rate for seq-1 on/before 2025-08-01
                  end
                when cr.invoice_sequence = 2 then 0.02
                when cr.invoice_sequence = 3 then 0.01
                else 0.00
              end
            else 0.00
          end
                                    end as commission_rate,
      1                             as split,
      null                          as reimbursement_factor,
      null                          as override_rate,
      false                         as exception,
      rli.line_item_amount          as amount
    from rc_line_items rli
    join cycle_ranks cr
      on rli.company_id = cr.company_id
     and rli.invoice_id = cr.invoice_id
  ),

  /*** 5) Grab only the new RC commissions ***/
  new_rc_commissions as (
    select *
    from rc_commission_data

    {% if not var('ignore_finalized_filter', false) %}
    where commission_id not in (
        select commission_id
        from {{ ref('int_commissions_finalized_data') }}
    )
    {% endif %}
)



select
  commission_id,
  line_item_id,
  salesperson_user_id,
  null                as credit_note_line_item_id,
  null                as manual_adjustment_id,
  1                   as transaction_type,
  3                   as commission_type,
  transaction_date,
  commission_rate,
  split,
  reimbursement_factor,
  override_rate,
  exception,
  amount
from new_rc_commissions
