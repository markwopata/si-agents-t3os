{% macro be_live_copy_from_last_month(load_section, account_numbers) %}

    {% set gl_dates = be_live_date_list() %}
    {% set last_known_date = last_branch_earnings_published_date() %}

    WITH dds_snap AS (
        {% for gl_date in gl_dates %}
        SELECT
            market_id,
            account_number,
            SUM(amount) AS amount,
            '{{ gl_date }}'::date AS gl_date
        FROM {{ ref('stg_analytics_public__branch_earnings_dds_snap') }}
        WHERE DATE_TRUNC(month, gl_date) = 
            (SELECT MIN(date)
             FROM (
                 SELECT '{{ last_known_date }}'::date AS date
                 UNION ALL
                 SELECT DATEADD(month, -1, '{{ gl_date }}'::date) AS date
             ) AS known_dates
             WHERE date < '{{ gl_date }}'::date
            )
        AND account_number IN {{ account_numbers }}
        GROUP BY market_id, account_number
        {% if not loop.last %}UNION ALL{% endif %}
        {% endfor %}
    )

    SELECT 
            dds_snap.market_id as market_id,
            dds_snap.account_number as account_number,
            '' as transaction_number_format,
            '' as transaction_number,
            'Estimate from Previous Month' as description,
            dds_snap.gl_date,
            'DDS' as document_type,
            '' as document_number,
            null as url_sage,
            null as url_concur,
            null as url_admin,
            null as url_t3,
            dds_snap.amount,
            object_construct() as additional_data,
            'DDS SNAP' as source,
            '{{load_section}}' as load_section,
            '{{ this.name }}' as source_model
    FROM dds_snap

{% endmacro %}