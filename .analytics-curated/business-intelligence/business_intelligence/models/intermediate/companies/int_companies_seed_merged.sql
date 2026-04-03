with merge_seed_files as (
    select 
        from_company_id
        , to_company_id
        , 'manual merge mapping' as flag
    from {{ ref('stg_seed_companies__manual_merge_mapping') }}
    where _is_deleted = false
    union all
    select 
        from_company_id
        , to_company_id
        , 'use account merge mapping' as flag
    from {{ ref('stg_seed_companies__use_account_merge_mapping') }}
    where _is_deleted = false
    union all
    select 
        company_id as from_company_id
        , 1000 as to_company_id
        ,'use counter account' as flag
    from {{ ref('stg_seed_companies__use_counter_account') }}
    where _is_deleted = false
),

    all_merges as (
        select 
            from_company_id
            , from_company_name
            , to_company_id
            , to_company_name
            , 'company merged to' as flag
        from {{ ref('int_companies_duplicate_merged_to')}}

        UNION ALL

        select 
            m.from_company_id
            , from_c.company_name as from_company_name
            , m.to_company_id
            , to_c.company_name as to_company_name
            , m.flag
        from merge_seed_files m
        join {{ ref('platform', 'dim_companies') }} from_c
        on m.from_company_id = from_c.company_id
        join {{ref('platform', 'dim_companies') }} to_c
        on m.to_company_id = to_c.company_id
    )

select *
from all_merges