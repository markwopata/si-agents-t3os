with
    source as (select * from {{ source('es_warehouse_public', 'rentals') }}),
    renamed as (
        select

            rental_id,
            job_description,
            equipment_class_id,
            lien_notice_sent,
            delivery_instructions,
            delivery_required,
            drop_off_delivery_required,
            return_delivery_required,
            return_delivery_id,
            borrower_user_id,
            start_date_estimated,
            rental_protection_plan_id,
            asset_id,
            order_id,
            taxable,
            end_date_estimated,
            rental_status_id,
            deleted,
            drop_off_delivery_id,
            rental_type_id,
            _es_update_timestamp,
            price,
            delivery_charge,
            amount_received,
            return_charge,
            off_rent_date_requested,
            date_created,
            end_date,
            start_date,
            rental_purchase_option_id,
            part_type_id,
            has_re_rent,
            is_below_floor_rate,
            quantity,
            external_id,
            purchase_price,
            rate_type_id,
            price_per_day,
            price_per_week,
            price_per_month,
            price_per_hour,
            is_flat_monthly_rate,
            is_flexible_rate,
            inventory_product_id,
            inventory_product_name,
            inventory_product_name_historical,
            one_time_charge,
            rental_pricing_structure_id,
            shift_type_id,
            'https://admin.equipmentshare.com/#/home/rentals/'|| rental_id as url_admin

        from source

    )

select *
from renamed
