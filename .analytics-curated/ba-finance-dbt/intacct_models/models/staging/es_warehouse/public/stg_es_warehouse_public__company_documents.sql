SELECT
    cd.company_id,
    cd.company_document_type_id,
    cd.created_by_user_id,
    cd.voided,
    cd.valid_from,
    cd.valid_until,
    cd.notes,
    cd.original_file_name,
    cd.file_name,
    cd.file_path,
    cd.extended_data,
    cd.company_document_id,
    cd.date_created,
    cd._es_update_timestamp,
    cd.extended_data:"tax_id" AS extended_data__tax_id,
    cd.extended_data:"total_coverage_amount" AS extended_data__total_coverage_amount
FROM {{ source('es_warehouse_public', 'company_documents') }} as cd
