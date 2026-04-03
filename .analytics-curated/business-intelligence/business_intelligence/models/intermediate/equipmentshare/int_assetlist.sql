{{ config(materialized="table", cluster_by=["asset_id"]) }}

with
    selected_users as (
        select user_id, company_id, security_level_id
        from {{ ref("platform", "users") }}
    ),

    the_assets as (
        -- Assets directly linked by company
        select u.user_id, a.asset_id, 'o' as type, u.security_level_id
        from {{ ref("platform", "assets") }} a
        join selected_users u on a.company_id = u.company_id
        where not a.deleted

        union

        -- Telematics assets linked by company
        select u.user_id, t.asset_id, 't' as type, u.security_level_id
        from {{ ref("platform", "telematics_service_providers_assets") }} t
        join selected_users u on t.company_id = u.company_id

        union

        -- Assets linked by organization membership
        select x.user_id, oax.asset_id, 'x' as type, u.security_level_id
        from {{ ref("platform", "organization_user_xref") }} x
        join selected_users u on x.user_id = u.user_id
        join
            {{ ref("platform", "organization_asset_xref") }} oax
            on oax.organization_id = x.organization_id
    ),
    assetlist as (
        select distinct user_id, asset_id
        from the_assets
        where (security_level_id in (1, 2) or type = 'x')
    )
select distinct *
from assetlist {{ var("row_limit") }}
