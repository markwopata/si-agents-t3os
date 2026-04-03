select
    b.id,
    b.items_count::int as items_count,
    b.owner_id,
    b.board_folder_id,
    b.name,
    b.workspace_id,
    b.updated_at,
    b.permission,
    b.top_group_id,
    b.type,
    b.state,
    b.board_kind,
    nullif(trim(b.description), '') as description,
    b._fivetran_deleted,
    b._fivetran_synced
from {{ source('analytics_monday', 'board') }} as b
