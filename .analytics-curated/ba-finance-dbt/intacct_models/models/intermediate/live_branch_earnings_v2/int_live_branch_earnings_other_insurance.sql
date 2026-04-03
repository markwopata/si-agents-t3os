-- depends_on: {{ ref('stg_analytics_public__branch_earnings_dds_snap') }}

-- zzz is a hack to get it to work with the in clause
{{ be_live_copy_from_last_month('Other Insurance',('7500', 'zzz')) }}
