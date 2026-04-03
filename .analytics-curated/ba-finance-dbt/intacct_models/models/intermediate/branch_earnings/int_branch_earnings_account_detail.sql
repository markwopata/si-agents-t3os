with plexi_bucket_mapping as (

    select * from {{ ref('stg_analytics_gs__plexi_bucket_mapping') }}

)

, gl_account as (

    select * from {{ ref('stg_analytics_intacct__gl_account') }}

)

select

    -- ids
    pbm.sage_gl as account_number
    , coalesce(pbm.sage_name,gla.account_name) as gl_account_name

    -- strings
    , pbm."GROUP" as code
    , pbm.display_name as type
    , left(pbm."GROUP", 3) as revexp
    , substr(pbm."GROUP", 4, 20) as dept

    -- numerics
    -- booleans
    -- dates
    -- timestamps

from plexi_bucket_mapping as pbm
left join gl_account as gla
    on pbm.sage_gl = gla.account_number
