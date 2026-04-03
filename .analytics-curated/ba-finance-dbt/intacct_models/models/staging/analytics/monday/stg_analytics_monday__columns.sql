select
    c.board_id,
    c.id,
    c.archived as is_archived,
    c.settings_str,
    iff(typeof(try_parse_json(c.settings_str)) = 'VARCHAR', null, try_parse_json(c.settings_str)) as settings_json,
    c.title as column_title,
    c.description,
    c.type,
    c.width,
    c._fivetran_deleted,
    c._fivetran_synced
from {{ source('analytics_monday', 'columns') }} as c
