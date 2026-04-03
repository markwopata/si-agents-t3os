with rental_revenue as (
-- Grab rental revenue at a market level. An asset can be owned by a different market than the market on the invoice
-- because of timing.
    select
        ild.market_id,
        sum(ild.amount) as rental_revenue,
        case
            when ild.gl_date::date = current_date then current_timestamp()
            else date_trunc(day, ild.gl_date) + interval '1 day' - interval '1 nanosecond'
        end::timestamp_tz as daily_timestamp
    from {{ ref("int_admin_invoice_and_credit_line_detail") }} as ild
    where ild.is_rental_revenue
        and ild.is_billing_approved
        and not ild.is_intercompany
    {% if is_incremental() %}
        and ild.gl_date >= dateadd(days, -15, current_date)::timestamp_tz
    {% endif %}
    group by all
),

-- Grab all the asset level metrics minus rental revenue
asset_metrics_daily as (
    select
        iah.daily_timestamp,
        iah.month_end_date,
        iah.market_id,
        sum(iah.total_oec) as total_oec,
        sum(iah.total_units) as total_units,
        sum(iah.rental_fleet_oec) as rental_fleet_oec,
        sum(iah.rental_fleet_units) as rental_fleet_units,
        sum(iah.unavailable_oec) as unavailable_oec,
        sum(iah.unavailable_units) as unavailable_units,
        sum(iah.oec_on_rent) as oec_on_rent,
        sum(iah.units_on_rent) as units_on_rent,
        sum(iah.pending_return_oec) as pending_return_oec,
        sum(iah.pending_return_units) as pending_return_units
    from {{ ref("int_asset_historical") }} as iah
    where 1 = 1
    {% if is_incremental() %}
        and iah.daily_timestamp >= dateadd(days, -15, current_date)::timestamp_tz
    {% endif %}
    group by all
),

out as (
    select
        amd.daily_timestamp,
        amd.month_end_date,
        amd.market_id,
        sum(amd.total_oec) as total_oec,
        sum(amd.total_units) as total_units,
        sum(amd.rental_fleet_oec) as rental_fleet_oec,
        sum(amd.rental_fleet_units) as rental_fleet_units,
        sum(amd.unavailable_oec) as unavailable_oec,
        sum(amd.unavailable_units) as unavailable_units,
        sum(amd.oec_on_rent) as oec_on_rent,
        sum(amd.units_on_rent) as units_on_rent,
        sum(amd.pending_return_oec) as pending_return_oec,
        sum(amd.pending_return_units) as pending_return_units,
        sum(rr.rental_revenue) as rental_revenue
    from asset_metrics_daily as amd
        left join rental_revenue as rr
            on date_trunc('day', amd.daily_timestamp) = date_trunc('day',rr.daily_timestamp)
                and amd.market_id = rr.market_id
    where 1 = 1
    {% if is_incremental() %}
        and amd.daily_timestamp >= dateadd(days, -15, current_date)::timestamp_tz
    {% endif %}
    group by all
)

select * from out
