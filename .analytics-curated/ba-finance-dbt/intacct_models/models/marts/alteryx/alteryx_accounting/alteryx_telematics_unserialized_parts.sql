with shipped as (
    select
        id.inventserialid                 as serial_num,
        ito.inventtransid                 as inv_log_id,
        it.itemid                          as part_id,
        cpst.name                           as part_description,
        it.costamountposted * -1          as std_cost,
        cpst.qty                            as inv_tran_qty_maybe,
        cast(cpst.deliverydate as date)    as date1,
        cast(it.datephysical as date)      as date2,
        ito.referenceid                    as so_number,
        it.qty                              as qty,
        it.qty * it.costamountposted      as cost_chg,
        cpst.packingslipid,
        cpst.priceunit,
        cpsj.invoiceaccount,
        tel_type.item_type,
        it.statusissue,
        it.invoiceid,
        it.packingslipid                  as pack_slip_id,
        it.inventdimid,
        id.inventlocationid,
        it.recid,
        sl.salesprice as sell_price,
        sl.costprice as sell_cost,
        st.custgroup as cust_group,
        gab.name as cust_name,
        st.deliveryname as delivery_name
    from {{ ref('stg_analytics_microsoft_dynamics__customer_packing_slip_transactions') }} cpst
    left join {{ ref('stg_analytics_microsoft_dynamics__inventory_transactions_origin') }} ito
              on cpst.inventtransid = ito.inventtransid
    left join {{ ref('stg_analytics_microsoft_dynamics__inventory_transactions') }} it
              on ito.recid = it.inventtransorigin and cpst.packingslipid = it.packingslipid
    left join {{ ref('stg_analytics_microsoft_dynamics__inventory_dimension') }} id
              on it.inventdimid = id.inventdimid
    left join {{ ref('stg_analytics_microsoft_dynamics__customer_packing_slip_journal') }} cpsj
              on cpst.packingslipid = cpsj.packingslipid
    left join {{ ref('stg_analytics_microsoft_dynamics__inventory_table') }}  tel_type
              on it.itemid = tel_type.item_id
    left join {{ ref('stg_analytics_microsoft_dynamics__sales_line') }} sl
        on sl.inventtransid = ito.inventtransid
    left join {{ ref('stg_analytics_microsoft_dynamics__sales_table') }} st
        on sl.salesid = st.salesid
    left join {{ ref('stg_analytics_microsoft_dynamics__customer_table') }} ct
        on ct.accountnum = st.custaccount
    left join {{ ref('stg_analytics_microsoft_dynamics__global_address_book') }} gab
        on gab.recid = ct.party
)

select
    distinct
    unser.inv_log_id,
    unser.part_id,
    unser.part_description,
    unser.std_cost,
    unser.date1         as create_date,
    unser.date2         as event_date,
    unser.pack_slip_id  as record_id,
    unser.so_number     as info,
    unser.so_number     as so_number,
    unser.qty           as qty_chg,
    unser.std_cost * -1 as cost_chg,
    unser.sell_price as sell_price,
    unser.sell_cost as sell_cost,
    unser.cust_group as cust_group,
    unser.cust_name as cust_name,
    unser.delivery_name as delivery_name,
    'FB2'               as worksheet
from
    shipped unser
left join(
    select 
        distinct unser2.pack_slip_id
    from shipped unser2
    ) excl_with_tracker
     on unser.packingslipid = excl_with_tracker.pack_slip_id
where
    unser.item_type = 'Other'
