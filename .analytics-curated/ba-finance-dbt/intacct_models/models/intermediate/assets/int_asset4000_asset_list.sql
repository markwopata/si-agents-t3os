with asset_list as (
    select
        gr.asset_code,
        gr.asset_account
    from {{ ref('stg_analytics_asset4000_dbo__gl_asset_grps') }} gr
    inner join {{ ref('int_asset4000_most_recent_code_groups')}} cg
        on gr.asset_code = cg.asset_code
        and gr.asset_gl_assignment_date = cg.max_date
    where coalesce(gr.asset_account, '') not in ('1508', '1518', '1619', '')
)

, add_admin_asset_list as (
    select
        l.asset_code
        , l.asset_account
        , d.admin_asset_id
    from asset_list l
    left join {{ ref('stg_analytics_asset4000_dbo__gl_asset_descs') }} d
        on l.asset_code = d.asset_code
        and not d._fivetran_deleted
)



select * from add_admin_asset_list
