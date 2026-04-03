with level1 as (
    select
        product_group_id,
        level_1_id,
        name as level_1_name
    from {{ ref('stg_analytics_bt_dbo__product_group') }}
    where tree_level = 1
),

level2 as (
    select
        product_group_id,
        level_2_id,
        name as level_2_name
    from {{ ref('stg_analytics_bt_dbo__product_group') }}
    where tree_level = 2
)

select
    pg.product_group_id,
    pg.level_1_id,
    level1.level_1_name,
    pg.level_2_id,
    level2.level_2_name
from {{ ref('stg_analytics_bt_dbo__product_group') }} as pg
    left join level1
        on pg.level_1_id = level1.level_1_id
    left join level2
        on pg.level_2_id = level2.level_2_id
