SELECT
    pp.payout_program_id,
    pp.name,
    pp.payout_program_type_id,
    pp.asset_payout_percentage,
    pp._es_update_timestamp
FROM {{ source('es_warehouse_public', 'payout_programs') }} as pp
