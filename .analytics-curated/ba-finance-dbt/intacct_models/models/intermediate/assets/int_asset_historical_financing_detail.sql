with asset_dates as (
    select
        dc.asset_id,
        dc.daily_timestamp
    from {{ ref("int_asset_date_cross") }} as dc
    where 1 = 1
        {% if is_incremental() %}
            and dc.daily_timestamp >= dateadd(days, -15, current_date)::timestamp_tz
        {% endif %}
)

select
    md5(concat(adc.asset_id, adc.daily_timestamp)) as pk_asset_daily_timestamp_id,
    adc.asset_id,
    adc.daily_timestamp,
    case
        when last_day(adc.daily_timestamp) = adc.daily_timestamp::date
            or adc.daily_timestamp::date = current_date
            then date_trunc(month, adc.daily_timestamp)
    end as month_end_date, -- This will be not-null for EOM dates.
    iaph.finance_status,
    iaph.financial_schedule_id,
    iaph.po_number,
    iaph.oec,
    ifs.financing_facility_type,
    ifs.commencement_date as schedule_commencement_date,
    ifs.sage_account_number as schedule_account_number,
    ifs.schedule_number,
    ifs.debt_table_lender_name as lender_name,
    ifs.debt_table_loan_name as loan_name,
    ifs.sage_lender_vendor_id
from asset_dates as adc
    left join {{ ref("int_asset_purchase_history") }} as iaph
        on adc.asset_id = iaph.asset_id
            and adc.daily_timestamp >= iaph.date_start
            and adc.daily_timestamp < iaph.date_end
    left join {{ ref("int_financial_schedules") }} as ifs
        on iaph.financial_schedule_id = ifs.financial_schedule_id
