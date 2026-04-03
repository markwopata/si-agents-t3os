with open_auto_insurance_claims as (
    select
        concat(
            replace(cast(date_of_loss as string), '-'),
            '-',
            coalesce(replace(driver_full_name, ' '), 'NoDriver'),
            '-',
            coalesce(asset_id, 'NoAsset')
        ) as claim_id,
        date_of_loss as date_of_claim,
        asset_id as asset_number,
        asset_year,
        asset_make,
        asset_model,
        serial,
        license_plate,
        market_id,
        market_name as location,
        general_manager,
        file_notes,
        last_action_taken_date,
        total_due_from_third_party,
        amount_collected_from_third_party,
        total_due_from_ES,
        amount_paid_by_ES,
        at_fault_payer,
        is_material_loss,
        repair_invoice as repair_invoice,
        repair_date,
        driver_full_name as driver_name,
        employee_id as driver_employee_id,
        'Open' as source,
        status_comments,
        google_drive_link
    from {{ ref('stg_analytics_claims__open_auto_insurance_claims') }}

), closed_auto_insurance_claims as (

    select
        concat(
            replace(cast(date_of_loss as string), '-'),
            '-',
            coalesce(replace(driver_full_name, ' '), 'NoDriver'),
            '-',
            coalesce(asset_id, 'NoAsset')
        ) as claim_id,
        date_of_loss as date_of_claim,
        asset_id as asset_number,
        asset_year,
        asset_make,
        asset_model,
        serial,
        license_plate,
        market_id,
        market_name as location,
        general_manager,
        file_notes,
        last_action_taken_date,
        total_due_from_third_party,
        amount_collected_from_third_party,
        total_due_from_ES,
        amount_paid_by_ES,
        at_fault_payer,
        is_material_loss,
        repair_invoice as repair_invoice,
        repair_date,
        driver_full_name as driver_name,
        employee_id as driver_employee_id,
        'Closed' as source,
        status_comments,
        google_drive_link
    from {{ ref('stg_analytics_claims__closed_auto_insurance_claims') }}

)

select * from open_auto_insurance_claims
union all
select * from closed_auto_insurance_claims
