with source as (

    select * from {{ source('analytics_corporate_budget', 'budget_sub_departments') }}

),

renamed as (

    select
        -- ids
        sub_department_id,
        _row,

        -- strings
        department,
        sub_department_name,
        department_id,
        cost_center_string,

        -- numerics
        budget_year,
        cost_capture_id,

        -- timestamp
        _fivetran_synced,

    from source

)

select * from renamed
