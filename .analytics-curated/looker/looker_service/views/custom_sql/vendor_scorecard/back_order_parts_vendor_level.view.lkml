view: back_order_parts_vendor_level {
    derived_table: {
      sql:with
              back_order_parts_detail AS (
            select coalesce(xw.MARKET_ID, ma.market_id)               as the_market_id
                , coalesce(xw.MARKET_NAME, ma.NAME)                   as the_market_name
                , coalesce(xw._id_dist, ma.district_id)               as the_district_id
                , coalesce(xw.DISTRICT, d.name)                       as the_district_name
                , coalesce(xw.REGION, d.REGION_ID)                    as the_region_id
                , coalesce(xw.REGION_NAME, reg.name)                  as the_region_name
                , po.purchase_order_number
                , po.date_created
                , datediff(days, po.date_created, current_date) days_since_order
                , li.purchase_order_line_item_id
                , sum(li.quantity - li.total_accepted - li.total_rejected) as total_on_order
                , li.price_per_unit
                , total_on_order * li.price_per_unit as value_on_order
                , coalesce(p2.part_id, p.part_id) as the_part_id
                , coalesce(p2.part_number, p.part_number) as the_part_number
                , pr.name as provider_name
                , pt.description
                , r.date_received
                , po.purchase_order_id
                , ent.name as vendor_name
                , evs.EXTERNAL_ERP_VENDOR_REF as vendorid
                , CASE WHEN po.date_created <= GETDATE() AND po.date_created > (DATEADD(DAY, -30, GETDATE())) THEN 30
                    ELSE 0
                    END AS days_30_60
            from "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" po
            join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" li
                on po.PURCHASE_ORDER_ID = li.PURCHASE_ORDER_ID
            left join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" ri
                on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
            left join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS" r
                on ri.purchase_order_receiver_id = r.purchase_order_receiver_id
            join "ES_WAREHOUSE"."INVENTORY"."PARTS" p
                on li.item_id = p.item_id
            left join ES_WAREHOUSE.INVENTORY.PARTS p2
                on p.DUPLICATE_OF_ID = p2.PART_ID
            join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
                on coalesce(p2.part_type_id, p.part_type_id) = pt.PART_TYPE_ID
            left join "ES_WAREHOUSE"."INVENTORY"."PROVIDERS" pr
                on coalesce(p2.provider_id, p.provider_id) = pr.provider_id
            left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
                on po.REQUESTING_BRANCH_ID = xw.MARKET_ID
            left join ES_WAREHOUSE.PUBLIC.MARKETS ma
                on po.REQUESTING_BRANCH_ID = ma.MARKET_ID
            left join ES_WAREHOUSE.PUBLIC.DISTRICTS d
                on ma.DISTRICT_ID = d.DISTRICT_ID
            left join ES_WAREHOUSE.PUBLIC.REGIONS reg
                on d.REGION_ID = reg.REGION_ID
            left join "ES_WAREHOUSE"."PURCHASES"."ENTITIES" ent
                on po.VENDOR_ID = ent.ENTITY_ID
          --join for Vxxx vendorid and vendor name
          left join "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" evs --to get vendor id formatted like Vxxx
                on ent.entity_ID = evs.entity_ID
          LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VENDINT ON evs.EXTERNAL_ERP_VENDOR_REF = VENDINT.VENDORID --get vendor name
            where days_since_order >= 10
                and po.status = 'OPEN'
                and po.date_archived is null
                and li.date_archived is null
                AND DATE_RECEIVED IS NULL
                and the_region_id is not null
                and ma.company_id = 1854

                and po.date_archived is null
                and li.date_archived is null

            group by the_market_id
                , the_market_name
                , the_district_id
                , the_district_name
                , the_region_id
                , the_region_name
                , po.purchase_order_number
                , po.date_created
                , r.date_received
                , the_part_id
                , the_part_number
                , pt.description
                , provider_name
                , li.purchase_order_line_item_id
                , r.date_received
                , po.purchase_order_number
                , li.price_per_unit
                , po.purchase_order_id
                , ent.name
                , evs.EXTERNAL_ERP_VENDOR_REF
            order by days_since_order desc
            )

        SELECT
        *
        FROM back_order_parts_detail
        ;;
    }

    dimension: vendorid {
      type: string
      primary_key: yes
      sql: ${TABLE}.vendorid ;;
    }

    dimension: vendor_name {
      type: string
      sql: ${TABLE}.vendor_name ;;
    }

  dimension: the_market_id {
    type: number
    sql: ${TABLE}.the_market_id ;;
  }

  dimension: the_market_name {
    type: string
    sql: ${TABLE}.the_market_name ;;
  }

  dimension: the_district_id {
    type: number
    sql: ${TABLE}.the_district_id ;;
  }

  dimension: the_district_name {
    type: string
    sql: ${TABLE}.the_district_name ;;
  }

  dimension: the_region_id {
    type: number
    sql: ${TABLE}.the_region_id ;;
  }

  dimension: the_region_name {
    type: string
    sql: ${TABLE}.the_region_name ;;
  }

  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}.purchase_order_number ;;
  }

  dimension: date_created {
    type: date
    sql: ${TABLE}.date_created ;;
  }

  dimension: days_since_order {
    type: number
    sql: ${TABLE}.days_since_order ;;
  }

  dimension: purchase_order_line_item_id {
    type: number
    sql: ${TABLE}.purchase_order_line_item_id ;;
  }

  dimension: total_on_order {
    type: number
    sql: ${TABLE}.total_on_order ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}.price_per_unit ;;
  }

  dimension: value_on_order {
    type: number
    sql: ${TABLE}.value_on_order ;;
  }

  dimension: the_part_id {
    type: number
    sql: ${TABLE}.the_part_id ;;
  }

  dimension: the_part_number {
    type: number
    sql: ${TABLE}.the_part_number ;;
  }

  dimension: provider_name {
    type: string
    sql: ${TABLE}.provider_name ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: date_received {
    type: date
    sql: ${TABLE}.date_received ;;
  }

  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}.purchase_order_id ;;
  }

  dimension: days_30_60 {
    type: number
    sql: ${TABLE}.days_30_60 ;;
  }

  measure: days_30_cost_bo {
    type: sum
    filters: [days_30_60: "0"]
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${TABLE}.value_on_order ;;
    drill_fields: [
    the_market_id,
    the_market_name,
    the_district_id,
    the_district_name,
    the_region_id,
    the_region_name,
    purchase_order_number,
    date_created,
    days_since_order,
    purchase_order_line_item_id,
    total_on_order,
    price_per_unit,
    value_on_order,
    the_part_id,
    the_part_number,
    provider_name,
    description,
    date_received,
    purchase_order_id,
    vendor_name,
    vendorid,
    days_30_60
    ]
  }

  measure: days_30_avg_bo {
    type: average
    filters: [days_30_60: "0"]
    value_format: "0"
    sql: ${TABLE}.days_since_order ;;
    drill_fields: [
    the_market_id,
    the_market_name,
    the_district_id,
    the_district_name,
    the_region_id,
    the_region_name,
    purchase_order_number,
    date_created,
    days_since_order,
    purchase_order_line_item_id,
    total_on_order,
    price_per_unit,
    value_on_order,
    the_part_id,
    the_part_number,
    provider_name,
    description,
    date_received,
    purchase_order_id,
    vendor_name,
    vendorid,
    days_30_60
    ]
  }

  measure: total_cost_bo {
    type: sum
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${TABLE}.value_on_order ;;
    drill_fields: [
    the_market_id,
    the_market_name,
    the_district_id,
    the_district_name,
    the_region_id,
    the_region_name,
    purchase_order_number,
    date_created,
    days_since_order,
    purchase_order_line_item_id,
    total_on_order,
    price_per_unit,
    value_on_order,
    the_part_id,
    the_part_number,
    provider_name,
    description,
    date_received,
    purchase_order_id,
    vendor_name,
    vendorid,
    days_30_60
    ]
  }

  measure: total_avg_bo {
    type: average
    value_format: "0"
    sql: ${TABLE}.days_since_order ;;
    drill_fields: [
    the_market_id,
    the_market_name,
    the_district_id,
    the_district_name,
    the_region_id,
    the_region_name,
    purchase_order_number,
    date_created,
    days_since_order,
    purchase_order_line_item_id,
    total_on_order,
    price_per_unit,
    value_on_order,
    the_part_id,
    the_part_number,
    provider_name,
    description,
    date_received,
    purchase_order_id,
    vendor_name,
    vendorid,
    days_30_60
    ]
  }

  }
