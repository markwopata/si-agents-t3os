select
    g.board_id,
    g.id as group_id,
    g.archived as is_archived,
    g.color,
    g.deleted as is_deleted,
    g.position,
    g.title as group_title,
    g._fivetran_deleted,
    g._fivetran_synced
from {{ source('analytics_monday', 'groups') }} as g
