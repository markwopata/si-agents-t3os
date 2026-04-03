with source as (

    select * from {{ source('es_warehouse_public', 'credit_notes') }}

),

renamed as (

    select

        -- ids
        credit_note_id,
        created_by_user_id,
        erp_external_id,
        company_id,
        originating_invoice_id,
        credit_note_type_id,
        avalara_transaction_id,
        credit_note_status_id,

        -- strings
        memo,
        reference,
        ship_from,
        ship_to,
        ship_from:branch_id::int as market_id,
        'https://admin.equipmentshare.com/#/home/transactions/credit-notes/' || credit_note_id as url_credit_note_admin,

        -- numerics
        credit_note_number,
        total_credit_amount,
        tax_amount,
        remaining_credit_amount,
        line_item_amount,

        -- booleans
        are_tax_calcs_missing,
        sent,

        -- timestamps
        _es_update_timestamp,
        date_created,
        date_updated,
        avalara_transaction_id_update_dt_tm,
        taxes_invalidated_dt_tm,
        credit_note_date,

        -- nested fields
        ship_from:"address":"state_abbreviation"::string as ship_from_state,
        ship_from:"branch_id"::int as ship_from_branch_id,
        ship_from:"address":"latitude" as ship_from_latitude,
        ship_from:"address":"zip_code" as ship_from_zip_code,
        ship_from:"address":"street_1"::string as ship_from_street,
        ship_from:"address":"longitude" as ship_from_longitude,
        ship_from:"address" as ship_from_address,
        ship_from:"address":"country"::string as ship_from_country,
        ship_from:"address":"city"::string as ship_from_city,
        ship_from:"location_id" as ship_from_location_id,
        ship_from:"nickname"::string as ship_from_nickname,
        ship_to:"address":"state_abbreviation"::varchar as ship_to_state,
        ship_to:"branch_id" as ship_to_branch_id,
        ship_to:"address":"latitude" as ship_to_latitude,
        ship_to:"address":"zip_code" as ship_to_zip_code,
        ship_to:"address":"street_1"::string as ship_to_street,
        ship_to:"address":"longitude" as ship_to_longitude,
        ship_to:"address" as ship_to_address,
        ship_to:"address":"country"::string as ship_to_country,
        ship_to:"address":"city"::string as ship_to_city,
        ship_to:"location_id" as ship_to_location_id,
        ship_to:"nickname"::string as ship_to_nickname
    from source

)

select * from renamed
