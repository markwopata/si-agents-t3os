{% macro branch_earnings_accounts() %}
  select account_number 
  from {{ ref("stg_analytics_branch_earnings__account_mapping")}}
  where is_branch_earnings_account
{% endmacro %}