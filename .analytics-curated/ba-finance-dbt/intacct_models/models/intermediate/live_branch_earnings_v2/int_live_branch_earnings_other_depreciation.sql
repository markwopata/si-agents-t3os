-- depends_on: {{ ref('stg_analytics_public__branch_earnings_dds_snap') }}

{{ be_live_copy_from_last_month('Other Depreciation',('IBAA', '8104', '8102')) }}
