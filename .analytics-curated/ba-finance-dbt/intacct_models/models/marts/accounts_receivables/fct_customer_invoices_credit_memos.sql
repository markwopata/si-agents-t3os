with fct_invoice_number_amount as (
    select
        invoice_id,
        customer_id,
        invoice_number,
        invoice_amount
    from {{ ref('fct_invoice_number_amount') }}
),

d_credit_notes as (

    select
        credit_note_id,
        originating_invoice_id,
        invoice_number
    from {{ ref('dim_credit_notes') }}

),

fct_credit_notes as (
    select
        credit_note_id,
        total_credit_amount,
        remaining_credit_amount
    from {{ ref('fct_credit_notes') }}
),

create_measures as (
    select
        inv.*,
        fcn.total_credit_amount,
        fcn.remaining_credit_amount,
        fcn.credit_note_id
    from fct_invoice_number_amount as inv
        inner join d_credit_notes as cr
            on inv.invoice_id = cr.originating_invoice_id
        inner join fct_credit_notes as fcn
            on cr.credit_note_id = fcn.credit_note_id

)

select * from create_measures
