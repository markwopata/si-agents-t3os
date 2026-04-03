with asset_historical_data as (
    select
        aho.pk_asset_daily_timestamp_id,
        aho.asset_id,
        case
            when aho.daily_timestamp::date = current_date then current_timestamp()
            else aho.daily_timestamp
        end as daily_timestamp,
        aho.month_end_date,

        /* asset's transfer details */
        aho.transfer_status,
        aho.is_in_transit,

        /* asset's market details */
        aho.rental_branch_id,
        aho.rental_branch_name,
        aho.service_branch_id,
        aho.service_branch_name,
        aho.inventory_branch_id,
        aho.inventory_branch_name,
        aho.market_id,
        aho.market_name,
        aho.market_company_id,
        aho.owning_company_name,
        aho.is_managed_by_es_owned_market,

        /* asset details and attributes */
        aho.asset_company_id,
        aho.asset_inventory_status,
        aho.asset_inventory_status in (
            'Make Ready',
            'Needs Inspection',
            'Soft Down',
            'Hard Down'
        ) as is_asset_unavailable,
        aho.is_rerent_asset,
        aho.days_in_status,
        /* Rental details */
        -- concatenate multiple rental_ids if asset is involved in more than one rental on the same day
        listagg(ea.rental_id::text, ', ') within group (order by ea.date_start) as rental_id,
        rental_id is not null as is_on_rent,
        boolor_agg(ea.is_last_assignment_on_day) as is_last_rental_in_day
    from {{ ref("int_asset_historical_ownership") }} as aho
        left join {{ ref("int_equipment_assignments") }} as ea
            on aho.asset_id = ea.asset_id
                and date_trunc('day', aho.daily_timestamp) between date_trunc('day', ea.date_start) and date_trunc(
                    'day', ea.date_end - interval '1 nanosecond'
                )
                and ea.rental_duration >= 30
    -- only consider assignments with a rental duration of more than half an hour
    -- include all days the asset was actively on rent;
    -- subtract 1 nanosecond to exclude rentals that end exactly at midnight from incorrectly counting the next day
    group by
        all
),

-- Did we purchase the asset through Fleet Track
is_asset_in_cpoli as (
    select asset_id
    from {{ ref("stg_es_warehouse_public__company_purchase_order_line_items") }}
    group by asset_id
),

rental_revenue as (
    select
        coalesce(ild.asset_id, -1) as asset_id,
        sum(ild.amount) as rental_revenue,
        case
            when ild.gl_date::date = current_date then current_timestamp()
            else date_trunc(day, ild.gl_date) + interval '1 day' - interval '1 nanosecond'
        end::timestamp_tz as daily_timestamp,
        case
            when last_day(ild.gl_date) = ild.gl_date::date
                or ild.gl_date::date = current_date
                then date_trunc(month, ild.gl_date)
        end::timestamp_tz as month_end_date
    from
        {{ ref('int_admin_invoice_and_credit_line_detail') }} as ild
    where ild.is_rental_revenue
        and ild.is_billing_approved
        and not ild.is_intercompany
        {% if is_incremental() %}
            and ild.gl_date >= dateadd(days, -15, current_date)::timestamp_tz
        {% endif %}
    group by all
)

select
    aho.pk_asset_daily_timestamp_id,
    aho.asset_id,
    aho.daily_timestamp,
    aho.month_end_date,
    aho.rental_branch_id,
    aho.rental_branch_name,
    aho.service_branch_id,
    aho.service_branch_name,
    aho.inventory_branch_id,
    aho.inventory_branch_name,
    aho.transfer_status,
    aho.is_in_transit,
    aho.market_id,
    aho.market_name,
    aho.market_company_id,
    aho.owning_company_name,
    aho.is_managed_by_es_owned_market,
    aho.asset_company_id,
    aho.asset_inventory_status,
    aho.is_asset_unavailable,
    aho.is_rerent_asset,
    aho.days_in_status,
    aho.rental_id,
    aho.is_on_rent,
    aho.is_last_rental_in_day,

    /* Asset details */
    round(ahfd.oec, 2) as oec,
    ia.asset_type_id,
    ia.asset_type,
    ia.purchase_date,
    ahfd.po_number,
    ia.first_rental_date,
    ia.make,
    ia.model,
    ia.year,
    ia.category_id,
    ia.category,
    ia.equipment_class_id,
    ia.equipment_class,

    /* Financing details */
    ahfd.finance_status,
    ahfd.financial_schedule_id,
    ahfd.financing_facility_type,
    ahfd.schedule_commencement_date,
    ahfd.schedule_account_number,
    ahfd.schedule_number,
    ahfd.lender_name,
    ahfd.sage_lender_vendor_id,
    ahfd.loan_name,

    /* Payout program details */
    pp.payout_program_id,
    pp.payout_program_name,
    pp.payout_program_type,
    pp.asset_payout_percentage,
    coalesce(pp.is_payout_program_unpaid, FALSE) as is_payout_program_unpaid, -- if the asset is not in a payout program, default to FALSE
    coalesce(pp.is_payout_program_enrolled, FALSE) as is_payout_program_enrolled,  -- if the asset is not in a payout program, default to FALSE
    pp.payout_program_id is not null as is_own_program_asset,

    /* For use in calculations */
    aho.is_managed_by_es_owned_market and not aho.is_rerent_asset as in_total_fleet,
    case
        when aho.is_rerent_asset then false -- Exclude re-rent assets from fleet (Rental and Total)
        when (
            cpoli.received_date is not null -- asset was received in fleet track
            or icpoli.asset_id is null -- count assets that were never in fleet track
        ) and ec.company_id is not null then true -- rental branch's company is ES-owned
        else false
    end as in_rental_fleet,

    round(case when in_total_fleet then ahfd.oec else 0 end, 2) as total_oec,
    case when in_total_fleet then 1 else 0 end as total_units,
    round(case when in_rental_fleet then ahfd.oec else 0 end, 2) as rental_fleet_oec,
    case when in_rental_fleet then 1 else 0 end as rental_fleet_units,
    round(case when in_rental_fleet and aho.is_asset_unavailable then ahfd.oec else 0 end, 2) as unavailable_oec,
    case when in_rental_fleet and aho.is_asset_unavailable then 1 else 0 end as unavailable_units,
    round(
        case when in_rental_fleet and aho.is_on_rent and aho.is_last_rental_in_day then ahfd.oec else 0 end, 2
    ) as oec_on_rent,
    case when in_rental_fleet and aho.is_on_rent and aho.is_last_rental_in_day then 1 else 0 end as units_on_rent,
    round(rr.rental_revenue, 2) as rental_revenue,
    round(case when in_rental_fleet and aho.asset_inventory_status = 'Pending Return' then ahfd.oec else 0 end, 2) as pending_return_oec,
    round(case when in_rental_fleet and aho.asset_inventory_status = 'Pending Return' then 1 else 0 end, 2) as pending_return_units,
    /* Internal metrics */
    round(case when not in_rental_fleet then rr.rental_revenue else 0 end, 2) as _non_rental_revenue,
    round(case when _non_rental_revenue > 0 and not in_rental_fleet then ahfd.oec else 0 end, 2)
        as _non_rental_oec_with_rental_revenue
from asset_historical_data as aho
    inner join {{ ref("int_asset_historical_financing_detail") }} as ahfd
        on aho.pk_asset_daily_timestamp_id = ahfd.pk_asset_daily_timestamp_id
    left join {{ ref("int_payout_programs") }} as pp
        on aho.asset_id = pp.asset_id
            and aho.daily_timestamp >= pp.date_start
            and aho.daily_timestamp < pp.date_end
    inner join {{ ref("int_assets") }} as ia
        on aho.asset_id = ia.asset_id
    left join {{ ref("int_asset_cpoli_received") }} as cpoli
        on aho.asset_id = cpoli.asset_id
            and aho.daily_timestamp >= cpoli.received_date
    left join is_asset_in_cpoli as icpoli
        on aho.asset_id = icpoli.asset_id
    left join {{ ref("int_markets") }} as m
        on aho.rental_branch_id = m.market_id
    left join {{ ref("stg_analytics_public__es_companies") }} as ec
        on m.company_id = ec.company_id
            and ec.owned
    left join rental_revenue as rr
        on aho.asset_id = rr.asset_id
            and aho.daily_timestamp = rr.daily_timestamp
where 1 = 1
    {% if is_incremental() %}
        and aho.daily_timestamp >= dateadd(days, -15, current_date)::timestamp_tz
    {% endif %}
