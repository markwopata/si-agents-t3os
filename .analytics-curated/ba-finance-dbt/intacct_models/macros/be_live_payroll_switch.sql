{% macro be_live_payroll_switch() %}
  select distinct date_trunc(month, gl_date) as payroll_actual_months
    from {{ ref("int_live_branch_earnings_payroll_actuals")}}
    where gl_date between '{{ live_be_start_date() }}' and '{{ live_be_end_date() }}'
    and description not ilike '%reverse%'
    and description ilike '%wage accrual%'
{% endmacro %}