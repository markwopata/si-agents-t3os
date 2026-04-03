
view: bulk_parts_on_rent {
  derived_table: {
    sql:--Transaction Log for Bulk Part Rentals. initital drop offs, final returns and partial returns pulled at seperate times due to difference in calculation.
      with ido as ( --Initial Drop offs. Quantity of rental is take from the delivery data not the rental.
          select r.rental_id
              , ido.*
          from ES_WAREHOUSE.PUBLIC.RENTALS r
          join (select distinct rpa.rental_id as id
                      , rpa.part_id
                      , d.quantity
                      , d.completed_date
                  from ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS rpa
                  join ES_WAREHOUSE.PUBLIC.DELIVERIES d
                      on iff(rpa.drop_off_delivery_id is not null, d.delivery_id = rpa.drop_off_delivery_id, d.rental_id = rpa.rental_id)
                          and d.PART_ID = rpa.PART_ID
                  where delivery_type_id = 1 and delivery_status_id <> 4) ido
              on ido.id = r.rental_id
          where r.deleted = false
          order by r.rental_id
      )

      , fr as ( --Final Returns to end the rental. Quantity purchased and returned captured. Pulled from Rental Part Assignment corrsponding to the final return delivery (type 6).
          select distinct r.rental_id
              , fr.purchased_amount as final_purchase_amount
              , fr.true_quantity_returned as final_quantity
              , fr.completed_date
          from ES_WAREHOUSE.PUBLIC.RENTALS r
          join (select rpa.rental_id as id
                      , iff(rpa.quantity_purchased is null, 0, rpa.quantity_purchased) as purchased_amount
                      , iff(rpa.quantity_returned is null, 0, rpa.quantity_returned) as true_quantity_returned
                      , d.completed_date
                      , d.delivery_id
                  from ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS rpa
                  join ES_WAREHOUSE.PUBLIC.DELIVERIES d
                      on iff(rpa.return_delivery_id is not null, d.delivery_id = rpa.return_delivery_id, d.rental_id = rpa.rental_id)
                          and d.PART_ID = rpa.PART_ID
                  where delivery_type_id = 6 and delivery_status_id <> 4) fr
              on fr.id = r.rental_id
          where r.deleted  = false
              order by rental_id
      )

      , pr  as ( --Partial Returns. Can have multiple lines in rental parts assignment (meaning multiple partial returns for each rental). Similar to final returns, but quantities are aggregated.
          select r.rental_id
              , sum(pr.true_quantity_returned) as partial_return_total
              , sum(pr.purchased_amount) as partial_purchase_total
          from ES_WAREHOUSE.PUBLIC.RENTALS r
          join (select distinct rpa.rental_id as id
                      , iff(rpa.quantity_purchased is null, 0, rpa.quantity_purchased) as purchased_amount
                      , iff(rpa.quantity_returned is null, 0, rpa.quantity_returned) as true_quantity_returned
                      , d.completed_date
                      , rpa.rental_id
                      , rpa.part_id
                      , rpa.drop_off_delivery_id
                      , d.delivery_id
                      , d.delivery_type_id
                  from ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS rpa
                  join ES_WAREHOUSE.PUBLIC.DELIVERIES d
                      on iff(rpa.return_delivery_id is not null, d.delivery_id = rpa.return_delivery_id, d.rental_id = rpa.rental_id)
                          and d.PART_ID = rpa.PART_ID
                  where delivery_type_id = 5 and delivery_status_id <> 4) pr
              on pr.id = r.rental_id
          where r.deleted  = false
          group by r.rental_id
          order by rental_id
      )

      , events as ( --Combining and summing all rental events and preparing the data for the final join CTE. Pulling in part information associated.
          select ido.rental_id
              , ido.completed_date::DATE as initial_drop_off
              , fr.completed_date::DATE as final_return
              , ido.part_id
              , ido.quantity

              , iff(fr.final_quantity is NULL, 0, fr.final_quantity ) as final_return_quantity
              , iff(pr.partial_return_total is NULL, 0, pr.partial_return_total) as partial_return_final
              , (final_return_quantity + partial_return_final) as quantity_returned

              , iff(fr.final_purchase_amount is NULL, 0, fr.final_purchase_amount) as final_return_purchase
              , iff(pr.partial_purchase_total is NULL, 0, pr.partial_purchase_total) as partial_return_purchase
              , (final_return_purchase + partial_return_purchase) as quantity_purchased
              , (ido.quantity - quantity_returned - quantity_purchased) as quantity_still_on_rent

              , p.part_number
              , p.search as description
              , prov.name as provider_name
          from ido
          left join pr
              on pr.rental_id = ido.rental_id
          left join fr
              on fr.rental_id = ido.rental_id
          left join ES_WAREHOUSE.INVENTORY.PARTS p
              on p.part_id = ido.part_id
          left join ES_WAREHOUSE.INVENTORY.PROVIDERS prov
              on prov.provider_id = p.provider_id
          group by ido.rental_id
              , ido.part_id
              , initial_drop_off
              , final_return
              , ido.quantity
              , final_return_quantity
              , partial_return_final
              , quantity_returned
              , final_return_purchase
              , partial_return_purchase
              , quantity_purchased
              , quantity_still_on_rent
              , p.part_number
              , description
              , provider_name
      )
      --select count(rental_id) /*44278*/, count(distinct rental_id) /*44277*/ from events                        ;

      -- , parts_join as ( --Initially part data was pulled in here and combined with rental events data
      --     select e.*
      --         , p.part_number
      --         , p.search as description
      --         , pr.name as provider_name
      --     from events e
      --     left join ES_WAREHOUSE.INVENTORY.PARTS p
      --         on p.part_id = e.part_id
      --     left join ES_WAREHOUSE.INVENTORY.PROVIDERS pr
      --         on pr.provider_id = p.provider_id
      -- )

      , rental_details as ( --Pulling in information on the rental limited to just bulk part rentals. This is seperate from events because there can be future rentals that don't have full informtation worked out yet in rental parts assignment and delivery tables
          select distinct r.rental_id
              , 'https://admin.equipmentshare.com/#/home/rentals/'||r.rental_id||'' as rental_link
              , r.start_date::DATE as start_date
              , r.end_date::DATE as end_date
              , iff(r.start_date <= current_timestamp and r.end_date >= current_timestamp, 'YES', 'NO') as on_rent
              , iff(r.start_date > current_timestamp, 'YES','NO') as future_rent
              , o.market_id
              , m.market_name
              , po.company_id as customer_id
              , c.name as customer_name
              , rs.name rental_status
          from ES_WAREHOUSE.PUBLIC.RENTALS r
          join ES_WAREHOUSE.PUBLIC.RENTAL_STATUSES rs
          on r.rental_status_id=rs.rental_status_id
          join ES_WAREHOUSE.PUBLIC.ORDERS o
              on o.order_id = r.order_id
          join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
              on m.market_id = o.market_id
          left join ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po
              on po.purchase_order_id = o.purchase_order_id
          left join ES_WAREHOUSE.PUBLIC.COMPANIES c
              on c.company_id = po.company_id
          join ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS rpa
              on rpa.rental_id = r.rental_id
          where r.deleted = FALSE
              and rpa.part_id is not null
      )

      , pre_final as ( --Joining details and events
          select rd.rental_id
              , rd.rental_link
              , rd.start_date
              , rd.end_date
              , rd.on_rent
              , rd.future_rent
              , rd.market_id
              , rd.market_name
              , rd.customer_id
              , rd.customer_name
              ,rd.rental_status
              , e.part_id
              , e.part_number
              , e.description
              , e.provider_name
              , e.initial_drop_off
              , e.final_return
              , e.quantity as rental_quantity
              , e.quantity_purchased
              , e.quantity_returned
              , e.quantity_still_on_rent
          from rental_details rd
          left join events e
              on e.rental_id = rd.rental_id
          order by rd.start_date desc
      )

      , unreturned_bulk_items as ( --pulling info for rows with line_item_type_id = 121
               select li.extended_data:part_id as part_id,
                        li.line_item_type_id,
                        i.billing_approved,
                        li.rental_id
               from ES_WAREHOUSE.PUBLIC.line_items li
                        LEFT JOIN ES_WAREHOUSE.PUBLIC.invoices i ON li.invoice_id = i.invoice_id
               WHERE line_item_type_id = 121
        )

      , final as (
          select f.rental_id
              , f.rental_link
              , f.start_date
              , f.end_date
              , f.on_rent
              , f.future_rent
              , f.market_id
              , f.market_name
              , f.customer_id
              , f.customer_name
              , f.rental_status
              , f.part_id
              , f.part_number
              , f.description
              , f.provider_name
              , f.initial_drop_off
              , f.final_return
              , f.rental_quantity
              , f.quantity_purchased
              , f.quantity_returned
              , f.quantity_still_on_rent
                ,CASE
                 WHEN f.QUANTITY_STILL_ON_RENT > 0 THEN 'N/A' --rental not over
                 WHEN f.quantity_purchased = 0 THEN 'N/A' --rental over and all parts returned
                 WHEN f.quantity_purchased > 0 AND ubi.line_item_type_id is null THEN 'Unbilled'
                 WHEN f.quantity_purchased > 0 AND ubi.line_item_type_id is not null AND ubi.billing_approved = False THEN 'Billing Pending'
                 WHEN f.quantity_purchased > 0 AND ubi.line_item_type_id is not null AND ubi.billing_approved = True THEN 'Billed'
                 ELSE 'Unclassified'
                 END AS billing_flag
        from pre_final f
        LEFT JOIN unreturned_bulk_items ubi ON f.rental_id = ubi.rental_id AND f.part_id = ubi.part_id
      )


  select * from final
      --Below are the QC statements
      --select count(rental_id), rental_id from final group by rental_id having count(rental_id) > 1 --Tracking down duplicates. We know of one duplicate that seems to be a data entry error.
      --where quantity_still_on_rent < 0 --Find data entry errors or join errors.  When more parts were returned than delivered
      --where part_id is null --Find join errors
      --where future_rent = 'NO'
      --and on_rent = 'NO'
      --and quantity_still_on_rent > 0 --Past rentals with quanitites still out. Data entry errors, missing parts, or join errors.
      order by start_date desc ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_ID" ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/rentals/{{ rental_id }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  dimension: rental_link {
    type: string
    sql: ${TABLE}."RENTAL_LINK" ;;
  }
  dimension: rental_status {
    type:  string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: end_date {
    type: date
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: on_rent {
    type: string
    sql: ${TABLE}."ON_RENT" ;;
  }

  dimension: future_rent {
    type: string
    sql: ${TABLE}."FUTURE_RENT" ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: customer_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: provider_name {
    type: string
    sql: ${TABLE}."PROVIDER_NAME" ;;
  }

  dimension: initial_drop_off {
    type: date
    sql: ${TABLE}."INITIAL_DROP_OFF" ;;
  }

  dimension: final_return {
    type: date
    sql: ${TABLE}."FINAL_RETURN" ;;
  }

  dimension: rental_quantity {
    type: number
    sql: ${TABLE}."RENTAL_QUANTITY" ;;
  }

  dimension: quantity_purchased {
    type: number
    sql: ${TABLE}."QUANTITY_PURCHASED" ;;
  }

  dimension: quantity_returned {
    type: number
    sql: ${TABLE}."QUANTITY_RETURNED" ;;
  }

  dimension: quantity_still_on_rent {
    type: number
    sql: ${TABLE}."QUANTITY_STILL_ON_RENT" ;;
  }

  dimension: billing_flag {
    type: string
    sql: ${TABLE}."BILLING_FLAG" ;;
  }

  set: detail {
    fields: [
            rental_id,
            rental_link,
            start_date,
            end_date,
            on_rent,
            future_rent,
            market_id,
            market_name,
            customer_id,
            customer_name,
            part_id,
            part_number,
            description,
            provider_name,
            initial_drop_off,
            final_return,
            rental_quantity,
            quantity_purchased,
            quantity_returned,
            quantity_still_on_rent,
            billing_flag
            ]
  }
}
