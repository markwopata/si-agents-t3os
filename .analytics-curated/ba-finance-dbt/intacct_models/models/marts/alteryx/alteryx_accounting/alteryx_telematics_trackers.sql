with shipped as (
  select
    id.inventserialid as serial_num,
    ito.inventtransid as inv_log_id,
    it.itemid as part_id,
    cpst.name as part_description,
    sl.costprice * it.qty * -1 as std_cost,
    cpst.qty as inv_tran_qty_maybe,
    cast(cpst.deliverydate as date) as date1,
    cast(it.datephysical as date) as date2,
    ito.referenceid as so_number,
    it.qty as qty,
    it.qty * (
      it.qty * sl.costprice
    ) as cost_chg,
    cpst.packingslipid,
    cpst.priceunit,
    cpsj.invoiceaccount,
    tel_type.item_type,
    it.statusissue,
    it.invoiceid,
    it.packingslipid as pack_slip_id,
    it.inventdimid,
    id.inventlocationid,
    it.recid,
    sl.salesprice as sell_price,
    sl.costprice as sell_cost,
    st.custgroup as cust_group,
    gab.name as cust_name,
    st.deliveryname as delivery_name
  from {{ ref('stg_analytics_microsoft_dynamics__customer_packing_slip_transactions') }} as cpst
  left join {{ ref('stg_analytics_microsoft_dynamics__inventory_transactions_origin') }} as ito
    on cpst.inventtransid = ito.inventtransid
  left join {{ ref('stg_analytics_microsoft_dynamics__inventory_transactions') }} as it
    on ito.recid = it.inventtransorigin and cpst.packingslipid = it.packingslipid
  left join {{ ref('stg_analytics_microsoft_dynamics__inventory_dimension') }} as id
    on it.inventdimid = id.inventdimid
  left join {{ ref('stg_analytics_microsoft_dynamics__customer_packing_slip_journal') }} as cpsj
    on cpst.packingslipid = cpsj.packingslipid
  left join {{ ref('stg_analytics_microsoft_dynamics__inventory_table') }}  as tel_type
    on it.itemid = tel_type.item_id
  left join {{ ref('stg_analytics_microsoft_dynamics__sales_line') }} as sl
    on ito.inventtransid = sl.inventtransid
  left join {{ ref('stg_analytics_microsoft_dynamics__sales_table') }} as st
    on sl.salesid = st.salesid
  left join {{ ref('stg_analytics_microsoft_dynamics__customer_table') }} as ct
    on st.custaccount = ct.accountnum
  left join {{ ref('stg_analytics_microsoft_dynamics__global_address_book') }} as gab
    on ct.party = gab.recid
)

, qty_tot_tracker as (
  select
    trk2.pack_slip_id,
    sum(trk2.qty) as qty_chg
  from shipped as trk2
  where
    trk2.item_type = 'Tracker'
  group by
    trk2.pack_slip_id 
)

, nontrack_cost as (
  select
    trk3.pack_slip_id,
    sum(trk3.cost_chg / trk3.qty) as nt_cost
  from shipped as trk3
  where
    trk3.item_type = 'Other'
  group by
    trk3.pack_slip_id
)

select
  distinct
  trk.serial_num,
  trk.inv_log_id,
  trk.part_id,
  trk.part_description,
  trk.std_cost,
  trk.date1 as create_date,
  trk.date2 as event_date,
  trk.pack_slip_id as record_id,
  trk.so_number,
  trk.qty as qty_chg,
  qty_tot_tracker.qty_chg as qty_chg_total,
  trk.std_cost * -1 as cost_chg,
  coalesce(nontrack_cost.nt_cost, 0) as cost_chg_nt,
  trk.sell_price as sell_price,
  trk.sell_cost as sell_cost,
  trk.cust_group as cust_group,
  trk.cust_name as cust_name,
  trk.delivery_name as delivery_name,
  'FB1' as worksheet
from shipped as trk
left join qty_tot_tracker
  on trk.pack_slip_id = qty_tot_tracker.pack_slip_id
left join nontrack_cost
  on trk.pack_slip_id = nontrack_cost.pack_slip_id
where
  trk.item_type = 'Tracker'
