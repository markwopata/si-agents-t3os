{% macro dropped_branch_earnings_journal_entries() %}

    SELECT JE_TRANS_NO FROM {{ ref('seed_be_dropped_je') }}
  
{% endmacro %}