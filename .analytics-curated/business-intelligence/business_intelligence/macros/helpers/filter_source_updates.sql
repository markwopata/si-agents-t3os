{%- macro filter_source_updates(column_name, watermark_column=none, buffer_amount=1, time_unit='day', append_only=false) -%}

    {# Backfill mode: Override with specific date range if vars provided #}
    {%- if var('backfill_start_date', none) -%}
        {{ column_name }}::date >= '{{ var("backfill_start_date") }}'
        AND {{ column_name }}::date < '{{ var("backfill_end_date") }}'

    {# Default: watermark column name same as source. Override if different in target model #}
    {%- else -%}
        {%- set watermark_col = watermark_column or column_name -%}

        {# Non-incremental: Initial load logic #}
        {%- if not is_incremental() -%}
        {%- if append_only -%}
            1 = 1
        {%- else -%}
            {{ column_name }} < DATE_TRUNC('{{ time_unit }}', CURRENT_TIMESTAMP())
        {%- endif -%}

    {# Incremental: Time-window mode (for sources with late arrivals) #}
    {%- elif not append_only -%}
        {{ column_name }} >= DATE_TRUNC('{{ time_unit }}', DATEADD({{ time_unit }}, -{{ buffer_amount }}, CURRENT_TIMESTAMP()))
        AND {{ column_name }} < DATE_TRUNC('{{ time_unit }}', CURRENT_TIMESTAMP())

    {# Incremental: Watermark mode (for linear/append-only sources) #}
    {%- elif execute -%}
        {%- set threshold_query -%}
            select DATEADD({{ time_unit }}, -{{ buffer_amount }}, MAX({{ watermark_col }}))
            from {{ this }}
        {%- endset -%}
        {%- set threshold_result = run_query(threshold_query) -%}
        {%- if threshold_result and threshold_result.columns[0][0] is not none -%}
            {{ column_name }} >= '{{ threshold_result.columns[0][0] }}'
        {%- else -%}
            1 = 1  {# First run or empty table #}
        {%- endif -%}

        {# Parse phase fallback #}
        {%- else -%}
            1 = 1
        {%- endif -%}

    {%- endif -%}

{%- endmacro -%}