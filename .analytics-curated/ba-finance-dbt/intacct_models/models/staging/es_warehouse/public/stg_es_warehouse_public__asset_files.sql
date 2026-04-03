SELECT
    af._es_load_timestamp,
    af.asset_file_id,
    af.original_filename,
    af.size_bytes,
    af.asset_id,
    af.url,
    af._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_files') }} as af
