with missing_receipts as (
    select * from {{ ref('int_missing_credit_card_receipts') }}
)

select
    full_name,
    user_full_name,
    employee_id,
    email_address,
    card_type,
    corporate_account_name,
    corporate_account_number,
    transaction_date,
    (transaction_date + interval '10 days')::date as shutoff_date,
    (transaction_date + interval '10 days')::date
    - convert_timezone('UTC', 'America/Chicago', current_timestamp())::date as days_until_shutoff,
    total_receipts_not_received
from missing_receipts
where row_number = 3
