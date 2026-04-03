SELECT
    ppma.master_agreement_id,
    ppma._es_update_timestamp
FROM {{ source('es_warehouse_public', 'payout_program_master_agreements') }} as ppma
