select 
    tt.id,
    tt.order_id,
    tt.user_id,
    tt.amount,
    tt.currency,
    tt.test,
    tt.processed_at,
    tt.remote_reference,
    tt.payment_details_credit_card_number,
    tt.payment_details_credit_card_company,
    tt.payment_method,
    tt._fivetran_synced
from {{ source('analytics_shopify_swag', 'tender_transaction') }} as tt
