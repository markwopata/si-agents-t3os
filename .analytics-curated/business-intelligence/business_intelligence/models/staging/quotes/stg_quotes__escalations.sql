with 

source as (

    select * from {{ source('quotes', 'escalations') }}

),

renamed as (

    select
        escalation_id as quote_escalation_id,
        created_at as created_date,
        updated_at as updated_date,
        user_id as escalation_user_id,
        user_name as escalation_user_name,
        email as escalation_user_email,
        attachment_filepath,
        message as escalation_reason,
        _es_update_timestamp

    from source

)

select * from renamed
