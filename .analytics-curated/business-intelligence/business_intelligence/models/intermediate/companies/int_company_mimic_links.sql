{{ config(
    materialized='incremental'
    , unique_key=['company_id']
    , incremental_strategy='delete+insert'
) }}

-- prioritize support users with company owner access, then any user with company owner access, then any user from the company
with user_mimic_link as (
    select
        user_id
        , company_id
        , first_name
        , last_name
        , email_address
        , security_level_id
        , fleet_mimic_link
        , analytics_mimic_link
        , is_deleted
        ,_updated_recordtimestamp
    from {{ ref('int_user_mimic_links') }}
)

    -- companes that need to be recalculated if user was updated or new user entered in the company
    , company_updates as (
        select distinct company_id
        from user_mimic_link
        WHERE ({{ filter_transformation_updates('_updated_recordtimestamp') }})
    )

, ranked_users as (
    select 
        m.*
        , row_number() over (
            partition by m.company_id
            order by
                -- any null links ranked at the bottom
                (m.fleet_mimic_link IS NOT NULL OR m.analytics_mimic_link IS NOT NULL) DESC
                -- customer support users with company owner access (security level 2)
                , case when f.is_support_user and m.security_level_id = 2 then 1 else 0 end desc
                -- support user with non company owner access
                , f.is_support_user desc 
                 -- any user with company owner access (security level 2)
                , case when m.security_level_id = 2 then 1 else 0 end desc 
                -- random tiebreaker for any users from that company
                , random()
        ) as rn
    from user_mimic_link m 
    left join {{ ref('int_user_flags') }} f
        on m.user_id = f.user_id
    where m.company_id in (select company_id from company_updates) 
    -- do not include deleted users during ranking
    and (m.email_address not like '%deleted%') and m.is_deleted = false
)

select 
    user_id
    , company_id
    , first_name
    , last_name
    , email_address
    , security_level_id
    , fleet_mimic_link
    , analytics_mimic_link

    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

from ranked_users
where rn = 1