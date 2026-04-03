select
    b.name as board_name,
    cv.board_id,
    cv.item_id,
    i.item_name,
    i.group_id,
    g.group_title,
    cv.id as column_id,
    cv.column_title,
    cv.column_description,
    c.type,
    cv.settings_str,
    cv.settings_json,
    cv.visualization_type,
    cv.width,
    cv.value_raw,
    cv.value_json,
    cv.value_str,
    cv.text,
    cv.display_value,
    cv.date,
    cv.symbol,
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
    cv.label,
    cv.time,
    cv.hour,
    cv.minute,
    cv.label_style_color,
    cv.label_style_border,
    cv.is_archived,
    cv.started_at,
    cv.update_id,
    cv.updated_at,
    cv._fivetran_deleted,
    cv._fivetran_synced
from {{ ref('stg_analytics_monday__board') }} as b
    inner join {{ ref('stg_analytics_monday__item') }} as i
        on b.id = i.board_id
    inner join {{ ref('stg_analytics_monday__column_value') }} as cv
        on b.id = cv.board_id
            and i.id = cv.item_id
    inner join {{ ref('stg_analytics_monday__columns') }} as c
        on cv.board_id = c.board_id
            and cv.id = c.id
    left join {{ ref('stg_analytics_monday__groups') }} as g
        on b.id = g.board_id
            and i.group_id = g.group_id
where not i._fivetran_deleted
    and not cv._fivetran_deleted
    and not g._fivetran_deleted
