select
    i.board_id,
    i.id,
    i.parent_item_id,
    i.group_id,
    i.email,
    i.name as item_name,
    i.updated_at,
    i.state,
    i.created_at,
    i.creator_id,
    i._fivetran_deleted,
    i._fivetran_synced
from {{ source('analytics_monday', 'item') }} as i
