with source as (
      select * from {{ source('analytics_rate_achievement', 'high_pd_classes') }}
),
renamed as (
    select

    -- ids
        equipment_class_id,

    -- numerics
        tier3_per_hour,
        tier2_per_hour,
        tier1_per_hour,

    -- strings
        class,
        category


    from source
)
select * from renamed
  