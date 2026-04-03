SELECT
    cc._es_load_timestamp,
    cc.company_contract_id,
    cc.date_signed,
    cc.updated_date,
    cc.envelope_id,
    cc.created_date,
    cc.docusign_template_update_id,
    cc.company_id,
    cc.signer_name,
    cc.signer_email,
    cc.signer_id,
    cc.status_id,
    cc._es_update_timestamp
FROM {{ source('es_warehouse_public', 'company_contracts') }} as cc
