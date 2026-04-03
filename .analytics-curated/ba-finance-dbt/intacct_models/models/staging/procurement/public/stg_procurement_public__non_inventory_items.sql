SELECT
    nii.non_inventory_item_id,
    nii.name,
    nii.item_id,
    nii._es_update_timestamp
FROM {{ source('procurement_public', 'non_inventory_items') }} as nii
