with abs_lsd_board as (
    {{ generate_monday_table_from_column_map('7183462981') }}
)

select
    -- board/item metadata
    board_id,
    item_id,
    group_id,
    group_title,
    item_name,
    ownership_changed as is_ownership_changed
from abs_lsd_board
