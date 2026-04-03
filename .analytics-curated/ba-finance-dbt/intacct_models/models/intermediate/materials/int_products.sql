select
    p.pk_product_id,
    p.product_code,
    p.product_group_id,
    pgh.level_1_id,
    pgh.level_1_name,
    pgh.level_2_id,
    pgh.level_2_name,
    p.short_description,
    p.description,
    p.datetime_created,
    p.datetime_last_modified
from {{ ref('stg_analytics_bt_dbo__product') }} as p
    left join {{ ref('int_product_group_hierarchy') }} as pgh
        on p.product_group_id = pgh.product_group_id
