with eligible_line_items as (
    select
        concat(
            cor.commission_override_request_id,
            '-',
            li.line_item_id,
            '-',
            cor.request_user_id
        ) as override_key,
        cor.commission_override_request_id,
        cor.request_user_id as salesperson_user_id,
        o.order_id,
        r.rental_id,
        cor.date_created as request_start_date,
        dateadd('days', 30, cor.date_created) as request_end_date,
        o.date_created as order_date_created,
        dateadd('days', 100, cor.date_created) as invoice_end_date,
        i.invoice_id,
        li.line_item_id,
        current_timestamp as _es_update_timestamp
    from {{ ref("stg_es_warehouse_public__orders") }} as o
        inner join {{ ref("stg_es_warehouse_public__users") }} as u on o.user_id = u.user_id
        inner join
            {{ ref("stg_es_warehouse_public__order_salespersons") }} as os
            on o.order_id = os.order_id
        inner join {{ ref("stg_es_warehouse_public__rentals") }} as r on o.order_id = r.order_id
        inner join
            {{ ref("stg_sworks_commissions__commission_override_requests") }} as cor
            on r.equipment_class_id = cor.equipment_class_id
                and os.user_id = cor.request_user_id
                and o.market_id = cor.market_id
        left join
            {{ ref("stg_es_warehouse_public__invoices") }} as i
            on o.order_id = i.order_id
                and cor.company_id = i.company_id
        left join
            {{ ref("stg_es_warehouse_public__line_items") }} as li
            on i.invoice_id = li.invoice_id
                and r.rental_id = li.rental_id
                and (
                    cor.date_created <= i.billing_approved_date
                    and i.billing_approved_date <= dateadd('days', 100, cor.date_created)
                )
                and li.line_item_type_id = 8
    where
        (
            (
                cor.date_created < '2024-05-01'
                and o.date_created between request_start_date and request_end_date
            )
            or (
                cor.date_created >= '2024-05-01'
                and o.date_created between dateadd(
                    'days', -14, request_start_date
                ) and request_end_date
            )
        )
        and (
            cor.review_status = 'approved'
            or cor.review_status = 'APPROVED'
        )
)

select *
from eligible_line_items
where line_item_id is not null
qualify row_number() over (partition by line_item_id, salesperson_user_id order by _es_update_timestamp desc) = 1
