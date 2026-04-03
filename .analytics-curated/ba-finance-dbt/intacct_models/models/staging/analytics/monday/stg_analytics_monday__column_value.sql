select
    -- Identifiers
    cv.board_id,
    cv.item_id,
    cv.id,

    -- Column detail
    cv.title as column_title,
    nullif(trim(cv.description), '') as column_description,
    cv.settings_str,
    iff(typeof(try_parse_json(cv.settings_str)) = 'VARCHAR', null, try_parse_json(cv.settings_str)) as settings_json,
    cv.visualization_type,
    cv.width,

    -- Values are populated depending on type
    cv.value as value_raw,
    iff(typeof(try_parse_json(cv.value)) = 'VARCHAR', null, try_parse_json(cv.value)) as value_json,
    trim(case when position('{', cv.value) = 0 then substr(cv.value, 2, length(cv.value) - 2) end) as value_str,

    nullif(trim(cv.text), '') as text,
    nullif(trim(cv.display_value), '') as display_value,
    cv.date,
    nullif(trim(cv.symbol), '') as symbol,
    cv.rating,
    cv.running,
    cv.duration,
    cv.number,
    cv.from_date,
    cv.to_date,
    cv.checked,
    cv.direction,
    cv.is_done,
    cv.index,
    nullif(trim(cv.label), '') as label,
    nullif(trim(cv.time), '') as time,
    cv.hour,
    cv.minute,
    cv.label_style_color,
    cv.label_style_border,

    cv.archived as is_archived,
    cv.started_at,
    cv.update_id,
    cv.updated_at,
    cv._fivetran_deleted,
    cv._fivetran_synced
from {{ source('analytics_monday', 'column_value') }} as cv
