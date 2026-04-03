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
    left join {{ ref('stg_analytics_microsoft_dynamics__inventory_table') }} tel_type
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
    kpd.serial_num,
    kpd.inv_log_id,
    kpd.part_id,
    kpd.part_description,
    kpd.std_cost,
    kpd.date1                               as create_date,
    kpd.date2                               as event_date,
    kpd.pack_slip_id                        as record_id,
    kpd.so_number,
    kpd.qty                                 as qty_chg,
    qty_tot_tracker.qty_chg                 as qty_chg_total,
    kpd.std_cost * -1                       as cost_chg,
    coalesce(nontrack_cost.nt_cost, 0) as cost_chg_nt,
    kpd.sell_price as sell_price,
    kpd.sell_cost as sell_cost,
    kpd.cust_group as cust_group,
    kpd.cust_name as cust_name,
    kpd.delivery_name as delivery_name,
    'FB1b'                                  as worksheet
from shipped kpd
left join (
    select
      kpd2.pack_slip_id,
      sum(kpd2.qty) as qty_chg
    from shipped kpd2
    where kpd2.item_type = 'Keypad'
    group by
      kpd2.pack_slip_id
) qty_tot_tracker 
  on kpd.pack_slip_id = qty_tot_tracker.pack_slip_id
left join(
    select
      kpd3.pack_slip_id,
      sum(kpd3.cost_chg / kpd3.qty) as nt_cost
    from shipped kpd3
    where kpd3.item_type = 'Other'
    group by 
      kpd3.pack_slip_id
) nontrack_cost on kpd.pack_slip_id = nontrack_cost.pack_slip_id
where
      kpd.item_type = 'Keypad'
