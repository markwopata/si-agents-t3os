select
    glcodeid as gl_code_id,
    glcodetype as gl_code_type,
    description,
    glcode as gl_code,
    branchid as bt_branch_id,
    deleted,
    _fivetran_deleted,
    _fivetran_synced

from {{ source('analytics_bt_dbo', 'glcode') }}
