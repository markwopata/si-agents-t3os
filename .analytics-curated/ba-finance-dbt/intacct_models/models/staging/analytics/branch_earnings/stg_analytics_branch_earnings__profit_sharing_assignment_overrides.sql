with source as (

  select * from {{ source('analytics_branch_earnings', 'profit_sharing_assignment_overrides') }}

),

renamed as (

  select
    employee_id
    , employee_title_classification
    , region_name
    , district
    , market_id
    , override_percent_allocation
    , memo
    , quarter as profit_sharing_period
  from source
)

select * from renamed