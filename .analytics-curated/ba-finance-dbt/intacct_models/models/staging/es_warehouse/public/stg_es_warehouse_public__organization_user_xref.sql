SELECT
    oux.organization_user_xref_id,
    oux.organization_id,
    oux.user_id,
    oux.sms_alerts,
    oux.email_alerts,
    oux._es_update_timestamp
FROM {{ source('es_warehouse_public', 'organization_user_xref') }} as oux
