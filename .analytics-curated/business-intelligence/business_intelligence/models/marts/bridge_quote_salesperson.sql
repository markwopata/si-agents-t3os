-- when ANY salesperson is updated for a quote, you get ALL salespeople (both primary and secondary) for that quote
{{ config(
    materialized='incremental'
    , incremental_strategy = 'delete+insert'
    , unique_key = ['quote_key']
    , post_hook = [
        "
        delete from {{ this }} as t
        where exists (
            select 1
            from {{ ref('dim_quotes') }} q
            where q.quote_key = t.quote_key
                and q.quote_number = -1
        )
        "
    ]
) }}

WITH updated_primary as (
    select 
        quote_id
        , created_date
        , salesperson_user_id
        , 'Primary' as salesperson_type
    from {{ ref("stg_quotes__quotes")}}
    WHERE ( {{ filter_source_updates('_es_update_timestamp', buffer_amount=1, time_unit='day') }} )
)
    -- flag any quotes that changed secondary sales rep assignments
    , updated_secondary as (
        select quote_id 
        from {{ ref('stg_quotes__secondary_sales_rep') }}
        WHERE ( {{ filter_source_updates('_es_update_timestamp', buffer_amount=1, time_unit='day') }} )
    )

    , updated_quotes as (
        select quote_id from updated_primary
        UNION
        select quote_id from updated_secondary
    )

    , quotes_primary as (
        select
            quote_id
            , created_date
            , salesperson_user_id
            , 'Primary' as salesperson_type
        from {{ ref("stg_quotes__quotes")}}
        where quote_id in (select quote_id from updated_quotes)
    )

    , quotes_secondary AS (
        SELECT
            quote_id
            , salesperson_user_id
            , 'Secondary' as salesperson_type
        FROM {{ ref('stg_quotes__secondary_sales_rep') }} q
        where quote_id in (select quote_id from updated_quotes)
    )

    , primary_and_secondary as (
        SELECT 
            quote_id
            , salesperson_user_id
            , salesperson_type
        FROM quotes_primary
        UNION ALL
        SELECT 
            quote_id
            , salesperson_user_id
            , salesperson_type
        FROM quotes_secondary
    )

    , cte_users as (
        select user_key, user_id
        from {{ ref('platform', 'dim_users') }}
    )

    , cte_salesperson as (
        select salesperson_key, user_id, _valid_from, _valid_to
        from {{ ref('dim_salesperson_enhanced') }}
    )

    , cte_quotes as (
        select quote_source, quote_key, quote_id
        from {{ ref('dim_quotes') }}
    )

    , cte_full_list as (
        SELECT 
            qs.quote_source
            , ps.quote_id
            , q.quote_key
            , ps.salesperson_user_id
            , u.user_key as salesperson_user_key
            , s.salesperson_key
            , ps.salesperson_type
            , qp.created_date
            , s._valid_from
            , s._valid_to
        from primary_and_secondary ps
        JOIN {{ ref('int_quote_sources') }} qs
            ON ps.quote_id = qs.quote_id

        LEFT JOIN quotes_primary qp  -- just to get the quote creation date
            ON ps.quote_id = qp.quote_id
        LEFT JOIN cte_quotes q
            ON q.quote_id = ps.quote_id
            AND qs.quote_source = q.quote_source
        LEFT JOIN cte_users u
            ON u.user_id = ps.salesperson_user_id
        LEFT JOIN cte_salesperson s
            ON s.user_id = ps.salesperson_user_id AND qp.created_date BETWEEN s._valid_from and s._valid_to
    )

SELECT 
    {{ dbt_utils.generate_surrogate_key(
        ['quote_source', 'quote_id', 'salesperson_user_id']) 
    }} AS quote_salesperson_key
    , COALESCE(quote_key
        , {{ get_default_key_from_dim(model_name='dim_quotes') }}
    ) AS quote_key
    , COALESCE(salesperson_user_key
        , {{ get_default_key_from_dim(model_name='dim_users') }}
    ) AS salesperson_user_key
    , COALESCE(salesperson_key 
        , {{ get_default_key_from_dim(model_name='dim_salesperson_enhanced') }}
    ) AS salesperson_key

    , salesperson_type

    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

from cte_full_list