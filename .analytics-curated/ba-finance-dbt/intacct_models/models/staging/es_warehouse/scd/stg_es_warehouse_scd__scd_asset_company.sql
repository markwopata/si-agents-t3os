with source as (

    select * from {{ source('es_warehouse_scd', 'scd_asset_company') }}

),

renamed as (

    select

        -- ids
        sac.asset_scd_company_id,
        sac.asset_id,
        sac.company_id,

        -- booleans
        sac.current_flag,

        -- timestamps
        sac.date_start,
        case
            when lead(sac.date_start)
                    over (
                        partition by sac.asset_id
                        order by
                            sac.date_start
                    )
                < date_end
                then lead(sac.date_start)
                        over (
                            partition by sac.asset_id
                            order by sac.date_start
                        )
            else sac.date_end
        end as date_end

    from source as sac

)

select * from renamed
