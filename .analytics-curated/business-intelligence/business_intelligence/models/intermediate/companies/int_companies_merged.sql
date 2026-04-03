{{ config(
    materialized='table',
    unique_key=['from_company_id'],
) }} 


with all_merges as (
    select from_company_id
            , from_company_name
            , to_company_id
            , to_company_name
            , flag as source
    from {{ ref('int_companies_seed_merged') }}
    UNION ALL
    select from_company_id
            , from_company_name
            , to_company_id
            , to_company_name
            , 'email mapping' as source
    from {{ ref('int_user_company_email_merge_mapping') }}
)

    -- Step 1: Limit number of records we run recursions on
        -- by finding to_company_id that also exist in from_company_id
        -- These are potential roots of recursive paths
    , filtered_merges AS (
        SELECT *
        FROM all_merges
        WHERE from_company_id IN (
            SELECT to_company_id
            FROM all_merges
        )
    )

    -- Step 2: Run recursion on just the records that may need additional mapping
    , recursive_mapping as (
        SELECT 
            from_company_id
            , from_company_name
            , to_company_id
            , to_company_name
        FROM all_merges

        UNION ALL

        -- Recursive step: join back to follow the chain
        SELECT 
            rm.from_company_id
            , rm.from_company_name
            , m.to_company_id
            , m.to_company_name
        FROM recursive_mapping rm
        JOIN all_merges m
        ON rm.to_company_id = m.from_company_id
        WHERE rm.to_company_id <> m.to_company_id  -- stop infinite loops
    )

    , recursive_company_mapping as (
        SELECT 
            from_company_id
            , from_company_name
            , to_company_id
            , to_company_name
        FROM recursive_mapping
        QUALIFY ROW_NUMBER() OVER (PARTITION BY from_company_id ORDER BY to_company_id) = 1
    )

    -- Step 3: for the ones with recursion, remap the to_company_id
    select 
        m.from_company_id
        , m.from_company_name
        , COALESCE(rm.to_company_id, m.to_company_id) as to_company_id
        , COALESCE(rm.to_company_name, m.to_company_name) as to_company_name
        , m.source
    from all_merges m
    left join recursive_company_mapping rm 
    on m.to_company_name = rm.from_company_name