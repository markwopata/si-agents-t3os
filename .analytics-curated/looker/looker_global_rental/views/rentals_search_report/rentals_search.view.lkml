view: rentals_search {
  derived_table: {
    sql: select
          o.order_id,
          r.rental_id,
          --r.equipment_class_id,
          coalesce(ec.name, p.name, '') as asset_class,
          --m.market_id as branch_id,
          m.name as branch,
          rst.name as rental_status,
          --o.purchase_order_reference as purchase_order,
          po.name as purchase_order,
          --u.company_id as customer_id,
          c.name as customer,
          nt.name as account_net_terms,
          coalesce(a.custom_name, '') as asset,
          coalesce(ea.asset_id, r.asset_id) as asset_id,
          --initcap(aty.name) as asset_type,
          --was owner.name as asset_owner,
          l.nickname as jobsite,
          concat(l.nickname, ' - ', l.street_1, ', ', l.city, ', ', st.abbreviation,', ', l.zip_code) as jobsite_location,
          CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', r.start_date) as rental_start,
          CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', r.end_date) as rental_end,
          coalesce(r.price_per_day,0) as price_per_day,
          coalesce(r.price_per_week,0) as price_per_week,
          coalesce(r.price_per_month,0) as price_per_month,
          coalesce(r.price_per_hour,0) as price_per_hour,
          --coalesce(r.one_time_charge, 0) as one_time_charge,
          --rpo.name as rpo_options,
          --r.has_re_rent as subrent,
          --r.drop_off_delivery_id,
          --r.return_delivery_id,
          --m.company_id as renter_company_id,
          coalesce(concat(salesperson.last_name, ', ', salesperson.first_name), 'No Assigned Salesperson') as salesperson,
          coalesce(d.charge,0) as transport_price,
          coalesce(edr.effective_daily_rate,0) as effective_daily_rate,
          (coalesce(edr.effective_daily_rate,0) * coalesce(edr.total_days_on_rent,0)) + coalesce(d.charge,0) as estimated_rental_total,
          j.name as job_code,
          pc.name as phase_code,
          u.email_address,
          -- cr.daily_class_avg,
          -- cr.weekly_class_avg,
          -- cr.monthly_class_avg,
          -- cr.hourly_class_avg
          case
            when r.asset_id is not null then 1
            when r.asset_id is null then coalesce(r.quantity, rpa.quantity, iia.inventory_item_quantity)
            else 1
          end as quantity,
          case
            when rst.name in ('Off Rent','Completed') then CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', coalesce(r.off_rent_date_requested, r.end_date))
            else null
          end as off_rent_date,
          coalesce(qr.quantity_returned, rpa.quantity_returned, iia.inventory_item_quantity_returned, 0) as quantity_returned
      from
          ES_WAREHOUSE.public.orders o
          join ES_WAREHOUSE.public.rentals r on o.order_id = r.order_id
          join ES_WAREHOUSE.public.markets m on m.market_id = o.market_id
          left join ES_WAREHOUSE.public.rental_statuses rst on rst.rental_status_id = r.rental_status_id
          left join ES_WAREHOUSE.public.equipment_classes ec on ec.equipment_class_id = r.equipment_class_id
          left join ES_WAREHOUSE.public.order_salespersons os on o.order_id = os.order_id
          left join ES_WAREHOUSE.public.users u on o.user_id = u.user_id
          left join ES_WAREHOUSE.public.users salesperson on o.salesperson_user_id = salesperson.user_id or os.user_id = salesperson.user_id
          left join ES_WAREHOUSE.public.companies c on u.company_id = c.company_id
          left join ES_WAREHOUSE.public.rental_location_assignments rla on r.rental_id = rla.rental_id
          left join ES_WAREHOUSE.public.locations l on l.location_id = rla.location_id
          left join ES_WAREHOUSE.public.states st on l.state_id = st.state_id
          left join ES_WAREHOUSE.public.rental_purchase_options rpo on r.rental_purchase_option_id = rpo.rental_purchase_option_id
          left join ES_WAREHOUSE.PUBLIC.purchase_orders po on o.purchase_order_id = po.purchase_order_id
          left join ES_WAREHOUSE.public.equipment_assignments ea on r.rental_id = ea.rental_id and coalesce(ea.end_date, current_timestamp) >= r.end_date
          left join ES_WAREHOUSE.PUBLIC.assets a on coalesce(ea.asset_id, r.asset_id) = a.asset_id
          left join ES_WAREHOUSE.PUBLIC.asset_types aty on a.asset_type_id = aty.asset_type_id
          --left join ES_WAREHOUSE.PUBLIC.companies owner ON a.company_id = owner.company_id
          left join ES_WAREHOUSE.PUBLIC.net_terms nt on c.net_terms_id = nt.net_terms_id
          left join ES_WAREHOUSE.public.jobs j on j.job_id = o.job_id
          left join ES_WAREHOUSE.public.jobs pc on j.job_id = pc.parent_job_id
      --left join avg_class_rates cr on cr.equipment_class_id = r.equipment_class_id
          left join es_warehouse_stage.public.effective_daily_rate edr on edr.rental_id = r.rental_id and edr.company_id = {{ _user_attributes['company_id'] }}
          left join
          (select rental_id, sum(charge) as charge from ES_WAREHOUSE.public.deliveries group by rental_id) d on d.rental_id = r.rental_id
          left join
            (select rental_id,
                    sum(case when asset_id is not null then 1 else quantity end) as quantity_returned
            from ES_WAREHOUSE.PUBLIC.deliveries
            where delivery_status_id = 3 and delivery_type_id in (5,6)
            group by 1) qr on qr.rental_id = r.rental_id
          left join ES_WAREHOUSE.INVENTORY.parts p on p.part_id = r.inventory_product_id
          left join es_warehouse.public.rental_part_assignments rpa on r.rental_id = rpa.rental_id
          left join es_warehouse.public.inventory_item_assignments iia on r.rental_id = iia.rental_id
          --ES_WAREHOUSE.public.deliveries d on d.rental_id = r.rental_id
          --left join (
          --    select
          --        rentalid as rental_id,
          --        sum(price) as transport_price
          --    from
          --        GLOBAL_BILLING.GLOBAL_BILLING.lineitems
          --    where
          --        chargeid in (1,7)
          --        and isarchived = false
          --    group by
          --        rentalid
          --) tp on tp.rental_id = r.rental_id
      where
          m.company_id = {{ _user_attributes['company_id'] }}::numeric
          AND CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}',r.start_date)::timestamp_ntz BETWEEN coalesce({% date_start start_date_filter %},'2000-01-01') AND coalesce({% date_end start_date_filter %},'2999-12-31')
          AND CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}',r.end_date)::timestamp_ntz BETWEEN coalesce({% date_start end_date_filter %},'2000-01-01')  AND coalesce({% date_end end_date_filter %},'2999-12-31')
          AND {% condition order_id_filter %} o.order_id {% endcondition %}
          AND {% condition rental_id_filter %} r.rental_id {% endcondition %}
          AND {% condition rental_status_filter %} rst.name {% endcondition %}
          AND {% condition customer_filter %} c.name {% endcondition %}
          AND {% condition customer_filter %} a.custom_name {% endcondition %}
          AND {% condition asset_class_filter %} coalesce(a.asset_class, p.name, '') {% endcondition %}
          AND {% condition job_code_filter %} j.name {% endcondition %}
          AND {% condition phase_code_filter %} pc.name {% endcondition %}
          AND {% condition branch_filter %} m.name {% endcondition %}
       ;;
  }

          #   --{% if filter_on_date._parameter_value == "'Rental Start Date'" %}
          # --r.start_date BETWEEN {% date_start date_filter %}::timestamp_ntz AND {% date_end date_filter %}::timestamp_ntz
          # --{% elsif filter_on_date._parameter_value == "'Rental End Date'" %}
          # --r.end_date BETWEEN {% date_start date_filter %}::timestamp_ntz AND {% date_end date_filter %}::timestamp_ntz
          # --{% else %}
          # --overlaps(r.start_date,r.end_date,{% date_start date_filter %}::timestamp_ntz,{% date_end date_filter %}::timestamp_ntz)
          # --{% endif %}

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
    value_format_name: id
    html: <font color="#0063f3"><u><a href="https://manage.estrack.io/rentops/orders/{{ order_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
    html: <font color="#0063f3"><u><a href="https://manage.estrack.io/rentops/rentals/{{ rental_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_class {
    label: "Product"
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

  dimension: purchase_order {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER" ;;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER" ;;
  }

  dimension: account_net_terms {
    type: string
    sql: ${TABLE}."ACCOUNT_NET_TERMS" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
  }

  dimension: jobsite_location {
    type: string
    sql: ${TABLE}."JOBSITE_LOCATION" ;;
  }

  dimension_group: rental_start {
    type: time
    sql: ${TABLE}."RENTAL_START" ;;
  }

  dimension_group: rental_end {
    type: time
    sql: ${TABLE}."RENTAL_END" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd
  }

  dimension: price_per_hour {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
    value_format_name: usd
  }

  dimension: one_time_charge {
    type: number
    sql: ${TABLE}."ONE_TIME_CHARGE" ;;
    value_format_name: usd
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: transport_price {
    label: "Total Transport Charge"
    type: number
    sql: ${TABLE}."TRANSPORT_PRICE" ;;
    value_format_name: usd
  }

  dimension: effective_daily_rate {
    type: number
    sql: ${TABLE}."EFFECTIVE_DAILY_RATE" ;;
    value_format_name: usd
  }

  dimension: estimated_rental_total {
    type: number
    sql: ${TABLE}."ESTIMATED_RENTAL_TOTAL" ;;
    value_format_name: usd
  }

  dimension: job_code {
    type: string
    sql: ${TABLE}."JOB_CODE" ;;
  }

  dimension: phase_code {
    type: string
    sql: ${TABLE}."PHASE_CODE" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: quantity_returned {
    type: number
    sql: ${TABLE}."QUANTITY_RETURNED" ;;
  }

  dimension: off_rent_date {
    type: date
    sql: ${TABLE}."OFF_RENT_DATE" ;;
  }

  dimension: rental_start_formatted {
    group_label: "HTML Passed Date Format"
    label: "Rental Start Date"
    type: date_time
    sql: ${rental_start_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: rental_end_formatted {
    group_label: "HTML Passed Date Format"
    label: "Rental End Date"
    type: date_time
    sql: ${rental_end_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: asset_custom_name_to_asset_info {
    group_label: "Link to T3"
    label: "Asset"
    type: string
    sql: ${asset};;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
  }

  filter: start_date_filter {
    type: date_time
  }

  filter: end_date_filter {
    type: date_time
  }

  filter: order_id_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: rental_id_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: rental_status_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: customer_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: asset_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: asset_class_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: job_code_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: phase_code_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  filter: branch_filter {
    # suggest_explore: cost_center
    # suggest_dimension: cost_center.district_name
  }

  parameter: filter_on_date {
    type: string
    allowed_value: { value: "Rental Start Date" }
    allowed_value: { value: "Rental End Date"}
    allowed_value: { value: "Rental Start & End Date"}
  }

  set: detail {
    fields: [
      order_id,
      rental_id,
      asset_class,
      branch,
      rental_status,
      purchase_order,
      customer,
      account_net_terms,
      asset,
      jobsite,
      jobsite_location,
      rental_start_time,
      rental_end_time,
      price_per_day,
      price_per_week,
      price_per_month,
      price_per_hour,
      one_time_charge,
      salesperson,
      transport_price,
      effective_daily_rate,
      estimated_rental_total
    ]
  }
}
