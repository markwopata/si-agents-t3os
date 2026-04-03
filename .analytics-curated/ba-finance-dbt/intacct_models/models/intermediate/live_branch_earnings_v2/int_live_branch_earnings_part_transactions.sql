with
part_transactions as (
    select * from {{ ref("part_inventory_transactions") }}
    where store_name not like '%TELE%'
    -- Assuming we don't want cancelled and processing transactions
    --and transaction_status not in ('Cancelled', 'Processing')
        and weighted_average_cost is not null
        and quantity is not null
        -- Below was taken from temp_live_parts_inventory
        and date_trunc('month', date_completed) >= '{{ live_be_start_date() }}'
        and transaction_type_id in (3, 4, 5, 7, 8, 9, 12, 13, 16, 22, /*added for manual part adjustment*/ 17, 18, 25)
        -- Excluding the conversion transaction - right now if they convert from a 55 gal unit to a 1 gal unit, cost is
        -- the same and units are the same, so they will have to increment the 1 gal units another way which won't show
        -- in P&L.
        and store_id not in (
            846, 879, 708, 652, 658, 546, 641, 722, 481, 886, 712, 670, 845,
            450, 698, 667, 688, 754, 772, 883, 651, 701, 776, 735, 882, 449
        )
        and (
            manual_adjustment_reason_id is null
            or manual_adjustment_reason_id in (1, 4, 5, 6, 7, 9)
        )
        -- Excluding transaction of large Found Items that materially skew live BE
        and transaction_id not in ('3404077')
),

work_orders as (
    select * from {{ ref('stg_es_warehouse_work_orders__work_orders') }}
),

line_items as (
    select
        invoice_id,
        extended_data,
        asset_id,
        line_item_type_id
    from {{ ref('stg_es_warehouse_public__line_items') }}
    where extended_data:part_id is not null
    -- Had to pick the first record as duplicates existed (with different line_item_types)
    qualify row_number() over (partition by invoice_id, extended_data:part_id order by line_item_id) = 1
),

clean_data as (
    select
        pit.market_id::int::varchar as market_id,
        case
            when
                pit.month_ >= '2022-01-01'
                and pit.transaction_type_id in (7, 9)
                and wo.billing_type_id = 2
                and li.line_item_type_id in (11, 25)
                then 'GDDAB'  -- Service Part Expense
            when pit.month_ >= '2022-01-01' and pit.transaction_type_id in (3, 4)
                then 'GDDAA'  -- Retail Part Expense (should we include 13)
            else 'GDDA'  -- Inventory/Bulk Part Expense
        end as acct_no,
        iff(acct_no = 'GDDAA', 9, 12) as sort_group,
        case
            when acct_no = 'GDDA'
                then 'Inventory/Bulk Part Expense'
            when acct_no = 'GDDAA'
                then 'COGS - Retail Parts'
            when acct_no = 'GDDAB'
                then 'COGS - Service Parts'
        end as gl_acct,

        coalesce(
            pit.market_name,
            concat('Unrecognized Market ID - ', market_id)
        ) as marketname,
        pit.transaction_type_id,
        iff(sort_group = 12, 'serv', 'reta') as dept,
        'EXP' as revexp,
        revexp || dept as code,
        case when sort_group = 12 then 'Cost of Service Revenues'
            when sort_group = 9 then 'Cost of Retail Revenues'
        end as type_,
        'Inventory Transaction ID | Inventory Transaction Item ID'
            as trans_no_format,
        pit.transaction_id || '|' || pit.transaction_item_id as trans_no,
        'Txn_Type:'
        || pit.transaction_type
        || ';Part:'
        || pit.part_number
        || ';Quantity:'
        || pit.quantity::text
        || ';Cost:'
        || pit.cost::text
        || ';Part_Descr:'
        || pit.description
        || ';User:'
        || pit.created_by_username
        || ';Store:'
        || pit.store_name as descr,
        pit.date_completed,
        'Inventory Transaction' as document_type,
        pit.transaction_id::varchar as document_number,
        null as url_sage,
        null as url_concur,
        case
            when pit.transaction_type_id in (3, 4)
                then
                    'https://admin.equipmentshare.com/#/home/transactions/invoices/'
                    || pit.to_id
        end as url_admin,
        case
            when pit.transaction_type_id = 7
                then 'https://app.estrack.com/#/service/work-orders/' || pit.to_id::string
        end as url_t3,
        pit.weighted_average_cost * pit.quantity as amount,
        li.asset_id
    from part_transactions as pit
        left join work_orders as wo
            on pit.work_order_id = wo.work_order_id
        left join line_items as li
            on wo.invoice_id = li.invoice_id
                and pit.part_id = li.extended_data:part_id
),

output as (
    select
        market_id,
        acct_no as account_number,
        trans_no_format as transaction_number_format,
        trans_no as transaction_number,
        descr as description,
        date_completed::date as gl_date,
        document_type,
        document_number,
        url_sage,
        url_concur,
        url_admin,
        url_t3,
        round(amount, 2) as amount,
        object_construct(
            'part_inventory_transaction_id', document_number
        ) as additional_data,
        'ES_WAREHOUSE' as source,
        iff(amount > 0, 'Parts Inventory Positive', 'Parts Inventory Negative') as load_section,
        '{{ this.name }}' as source_model
    from clean_data
)

---Part Transactions --
select
    market_id,
    account_number,
    transaction_number_format,
    transaction_number,
    description,
    gl_date,
    document_type,
    document_number,
    url_sage,
    url_concur,
    url_admin,
    url_t3,
    amount,
    additional_data,
    source,
    load_section,
    source_model
from output

union all

---Part Freight --
select
    market_id,
    '6301' as account_number,
    transaction_number_format,
    transaction_number,
    'Freight estimate from - ' || description as description,
    gl_date,
    document_type,
    document_number,
    url_sage,
    url_concur,
    url_admin,
    url_t3,
    amount * 0.06 as amount, -- Freight is 6% of the cost
    additional_data,
    source,
    'Parts Inventory Freight' as load_section,
    source_model
from output
where amount is not null
    and amount != 0
