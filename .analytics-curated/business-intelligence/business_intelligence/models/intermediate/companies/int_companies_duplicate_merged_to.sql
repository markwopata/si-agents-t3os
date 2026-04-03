-- isolate the companies that have the automated naming 'duplicate-merged-to-%'
with duplicate_merged_to as (
    select 
        company_id as from_company_id
        , company_name as from_company_name
        , TRY_CAST(SPLIT_PART(company_name, '-', 5) AS number) as to_company_id
    from {{ ref('platform', 'dim_companies') }}
    where company_name ILIKE 'duplicate-company-merged-to%'
)
    select 
        m.from_company_id
        , m.from_company_name
        , m.to_company_id
        , c.company_name as to_company_name
    from duplicate_merged_to m 
    join {{ ref('platform', 'dim_companies') }} c 
    on m.to_company_id = c.company_id