with own_assets as (
    select
        ipp.asset_id,
        ia.asset_company_id,
        ia.owning_company_name,
        ipp.payout_program_name,
        ipp.date_start,
        ipp.date_end,
        ia.oec
    from {{ ref("int_payout_programs") }} as ipp
        inner join {{ ref("int_assets") }} as ia
            on ipp.asset_id = ia.asset_id
    where
        -- Hard code all EZ Equipment Zone LLC & Premiere Industrial Equipment LLC as OWN program
        ia.asset_company_id in (6954, 55524)
),

revenue as (
    select
        ild.asset_id,
        round(sum(ild.amount), 2) as amount,
        date_trunc(month, ild.gl_date)::date as month_,
        last_day(ild.gl_date) + 1 - interval '1 nanosecond' as month_end_timestamp,
        year(ild.gl_date) || 'Q' || quarter(ild.gl_date) as year_quarter,
        case
            when ild.line_item_type_id in (4, 11, 13, 19, 20, 25, 26) then 'Maintenance'
            when ild.line_item_type_id in (6, 8) then 'Rental'
        end as line_item
    from {{ ref("int_admin_invoice_and_credit_line_detail") }} as ild
    where ild.line_item_type_id in (/*Rental*/6, 8, /*Maintenance*/4, 11, 13, 19, 20, 25, 26)
        and ild.amount != 0
        and ild.gl_date is not null
    group by all
)

select
    md5(oa.asset_id || r.line_item || r.month_) as pk_own_asset_revenue_id,
    oa.asset_id,
    oa.payout_program_name,
    oa.asset_company_id as company_id,
    oa.owning_company_name,
    r.line_item,
    r.year_quarter,
    r.month_,
    oa.oec,
    round(sum(r.amount), 2) as amount,
from own_assets as oa
    inner join revenue as r
        on oa.asset_id = r.asset_id
            and r.month_end_timestamp between oa.date_start and oa.date_end
where r.month_ >= '2022-01-01'
group by all
