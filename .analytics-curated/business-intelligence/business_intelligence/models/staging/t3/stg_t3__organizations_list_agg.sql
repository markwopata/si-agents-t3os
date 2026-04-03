{{ config(
    materialized='table'
    , cluster_by=['company_id', 'asset_id']
) }}

select
    a.asset_id,
    a.company_id,
    listagg(coalesce(o.name,'No Group'), ', ') as name
    from es_warehouse.public.assets a
    left join es_warehouse.public.organization_asset_xref oax on a.asset_id = oax.asset_id
    left join es_warehouse.public.organizations o on oax.organization_id = o.organization_id
    group by
    a.asset_id,
    a.company_id
    order by 
    a.company_id, a.asset_id