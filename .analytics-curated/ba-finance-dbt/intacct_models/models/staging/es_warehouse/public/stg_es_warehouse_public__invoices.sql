with source as (
    select * from {{ source('es_warehouse_public', 'invoices') }}
),

renamed as (
    select
        -- ids
        i.invoice_id,
        i.order_id,
        i.billing_approved_by_user_id,
        i.ship_from:branch_id::int as market_id,
        i.created_by_user_id,
        i.billing_provider_id,
        i.xero_id,
        i.salesperson_user_id,
        i.avalara_transaction_id,
        i.purchase_order_id,
        i.ordered_by_user_id,
        i.company_id,

        -- strings
        'https://admin.equipmentshare.com/#/home/transactions/invoices/' || i.invoice_id as url_admin,
        i.reference,
        i.sent,
        i.public_note,
        i.public_note as invoice_memo,
        i.private_note,
        i.extended_data,
        i.ship_from,
        i.ship_to,
        i.paid as is_paid,

        -- numerics
        i.invoice_no,
        i.rental_amount,
        i.owed_amount,
        i.line_item_amount,
        i.billed_amount,
        i.rpp_amount,
        i.tax_amount,
        i.outstanding,

        -- booleans
        i.are_tax_calcs_missing,
        i.customer_tax_exempt_status,
        i.are_tax_cals_missing,
        i.extended_data:"deleted":"deleted_date" is not null as is_deleted,
        i.billing_approved,
        is_deleted = false and i.billing_approved = false as is_pending,

        -- timestamps
        i.billing_approved_date,
        i.due_date,
        i.end_date,
        i.paid_date,
        i.invoice_date,
        i._es_update_timestamp,
        i.start_date,
        i.date_created,
        i.avalara_transaction_id_update_dt_tm,
        i.taxes_invalidated_dt_tm,
        i.date_updated,
        i.due_date_outstanding,

        -- nested fields
        i.ship_from:"address":"state_abbreviation"::string as ship_from__address__state_abbreviation,
        i.ship_from:"branch_id"::int as ship_from__branch_id,
        i.ship_from:"address":"latitude" as ship_from__address__latitude,
        i.ship_from:"address":"zip_code" as ship_from__address__zip_code,
        i.ship_from:"address":"street_1"::string as ship_from__address__street_1,
        i.ship_from:"address":"longitude" as ship_from__address__longitude,
        i.ship_from:"address" as ship_from__address,
        i.ship_from:"address":"country"::string as ship_from__address__country,
        i.ship_from:"address":"city"::string as ship_from__address__city,
        i.ship_from:"location_id" as ship_from__location_id,
        i.ship_from:"nickname"::string as ship_from__nickname,
        i.ship_to:"address":"state_abbreviation"::varchar as ship_to__address__state_abbreviation,
        i.ship_to:"branch_id" as ship_to__branch_id,
        i.ship_to:"address":"latitude" as ship_to__address__latitude,
        i.ship_to:"address":"zip_code" as ship_to__address__zip_code,
        i.ship_to:"address":"street_1"::string as ship_to__address__street_1,
        i.ship_to:"address":"longitude" as ship_to__address__longitude,
        i.ship_to:"address" as ship_to__address,
        i.ship_to:"address":"country"::string as ship_to__address__country,
        i.ship_to:"address":"city"::string as ship_to__address__city,
        i.ship_to:"location_id" as ship_to__location_id,
        i.ship_to:"nickname"::string as ship_to__nickname,
        i.extended_data:"should_bill_dt" as extended_data__should_bill_dt,
        i.extended_data:"missing_special_charges" as extended_data__missing_special_charges,
        i.extended_data:"job":"job_name" as extended_data__job__job_name,
        i.extended_data:"job":"job_id" as extended_data__job__job_id,
        i.extended_data:"generation_request_id" as extended_data__generation_request_id,
        i.extended_data:"ignore_for_cycle" as extended_data__ignore_for_cycle,
        i.extended_data:"job":"phase_name" as extended_data__job__phase_name,
        i.extended_data:"in_dispute" as extended_data__in_dispute,
        i.extended_data:"job" as extended_data__job
    from source as i
)

select * from renamed
