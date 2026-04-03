with source as (
    select * from {{ source('analytics_public', 'amex_cc_transactions') }}
),

renamed as (
    select
        act.control_acct_no as corporate_account_number,
        act.cardmember_acct_no as cardmember_account_number,
        act.full_name,
        act.first_name,
        act.last_name,
        act.transaction_id,
        act.transaction_description,
        act.transaction_type,
        act.supplier_no as supplier_number,
        act.supplier_name as merchant_name,
        act.sic_no as sic_number,
        act.sic,
        act.sic_division,
        act.mcc_code,
        act.mcc,
        act.mcc_group,
        act.charge_date::date as transaction_date,
        act.postal_code,
        act.supplier_postal_code,
        act.transaction_reference_id,
        act.email,
        act.cardmember_status,
        act.cardmember_status as status, -- Future state get rid of this because the other one is more clear.
        act.account_status,
        act.net_billed_amt as transaction_amount,
        act.charge_amt as charge_amount,
        act.credit_amt as credit_amount,
        act.credit_amt != 0 as is_credit,
        'amex' as card_type,
        false as is_bypass_verification -- This shouldn't be here
    from source as act
)

select * from renamed
