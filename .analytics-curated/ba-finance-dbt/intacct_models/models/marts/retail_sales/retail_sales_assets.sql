select
    rsad.*,
    a.equipment_class_id,
    a.equipment_class,
    a.category_id,
    a.category
from {{ ref("int_retail_sales_asset_detail") }} as rsad
    left join {{ ref("int_assets") }} as a
        on rsad.asset_id = a.asset_id
where rsad.is_current
