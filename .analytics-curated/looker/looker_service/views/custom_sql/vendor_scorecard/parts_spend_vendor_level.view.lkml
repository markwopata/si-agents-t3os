view: parts_spend_vendor_level {
derived_table: {
  sql:
SELECT VEND.EXTERNAL_ERP_VENDOR_REF as vendorid,
        VENDINT.NAME as vendor_name,
        POH.PURCHASE_ORDER_NUMBER AS PO_Number,
        POH.PURCHASE_ORDER_ID AS PO_ID,
        POL.PURCHASE_ORDER_LINE_ITEM_ID,
        POH.DATE_CREATED AS PO_Date,
        POH.DATE_CREATED AS PO_Date_filter,
        CONCAT(BERP1.INTACCT_DEPARTMENT_ID,' - ',BRCH1.NAME) AS Requesting_Branch,
        CONCAT(BERP2.INTACCT_DEPARTMENT_ID,' - ',BRCH2.NAME) AS Deliver_To_Branch,
        CONCAT(POH.CREATED_BY_ID,' - ', USER1.FIRST_NAME,' ',USER1.LAST_NAME) AS Created_By,
        USER1.EMAIL_ADDRESS AS Email_Address,
        PA.PART_NUMBER AS Part_Number,
        POL.DESCRIPTION AS Description,
        pr.name as provider,
        POL.MEMO AS Memo,
        POL.QUANTITY AS Quantity_Ordered,
        sum(PORL.ACCEPTED_QUANTITY) AS Accepted_Quant,
        sum(PORL.REJECTED_QUANTITY) AS Rejected_Quantity,
        POL.PRICE_PER_UNIT AS Price_Per_Unit,
        POH.STATUS AS PO_Status,
        POL.PRICE_PER_UNIT * POL.QUANTITY as amount_approved, -- take the amount from line items table * the quantity. total value
        ACCEPTED_QUANT * POL.PRICE_PER_UNIT as amount_accepted, -- $ value of amount actually accepted / fulfilled
        CAST(
            CONCAT(listagg(porl.PURCHASE_ORDER_RECEIVER_ITEM_ID),
            pol.PURCHASE_ORDER_LINE_ITEM_ID)
            as VARCHAR) as primary_key,
        case
            when datediff(day,POH.date_created, min(POR.date_received)) < 8 --item received within 7 days
            then 1 else 0 end fulfilled_within_7_days,
   -- case when fulfilled_within_7_days = 1 then Accepted_Quantity else 0 end qty_fulfilled_within_7_days
FROM "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" POH
    LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" VEND
        ON POH.VENDOR_ID = VEND.ENTITY_ID
    LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VENDINT
        ON VEND.EXTERNAL_ERP_VENDOR_REF = VENDINT.VENDORID
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" USER1
        ON POH.CREATED_BY_ID = USER1.USER_ID
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."BRANCH_ERP_REFS" BERP1
        ON POH.REQUESTING_BRANCH_ID = BERP1.BRANCH_ID
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."BRANCH_ERP_REFS" BERP2
        ON POH.DELIVER_TO_ID = BERP2.BRANCH_ID
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" BRCH1
        ON POH.REQUESTING_BRANCH_ID = BRCH1.MARKET_ID
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" BRCH2
        ON POH.DELIVER_TO_ID = BRCH2.MARKET_ID
    LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" POL
        ON POH.PURCHASE_ORDER_ID = POL.PURCHASE_ORDER_ID
    join ES_WAREHOUSE.INVENTORY.PARTS p1
        on pol.item_id = p1.item_id
    join ANALYTICS.PARTS_INVENTORY.PARTS pa
        on p1.part_id = pa.part_id --inner join instead of left to get only parts
    left join ES_WAREHOUSE.INVENTORY.PROVIDERS pr
        on pr.provider_id = pa.provider_id
    LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" PORL
        ON POL.PURCHASE_ORDER_LINE_ITEM_ID = PORL.PURCHASE_ORDER_LINE_ITEM_ID
    left join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVERS POR
        on PORL.purchase_order_receiver_id = POR.purchase_order_receiver_id
WHERE vendorid is NOT NULL
    and poh.date_archived is null
    and pol.date_archived is null
GROUP BY VEND.EXTERNAL_ERP_VENDOR_REF,
        VENDINT.NAME,
        POH.PURCHASE_ORDER_NUMBER,
        POH.PURCHASE_ORDER_ID,
        POL.PURCHASE_ORDER_LINE_ITEM_ID,
        POH.DATE_CREATED,
        POH.DATE_CREATED,
        CONCAT(BERP1.INTACCT_DEPARTMENT_ID,' - ',BRCH1.NAME),
        CONCAT(BERP2.INTACCT_DEPARTMENT_ID,' - ',BRCH2.NAME),
        CONCAT(POH.CREATED_BY_ID,' - ', USER1.FIRST_NAME,' ',USER1.LAST_NAME),
        USER1.EMAIL_ADDRESS,
        PA.PART_NUMBER,
        pr.name,
        POL.DESCRIPTION,
        POL.MEMO,
        POL.QUANTITY,
        POL.PRICE_PER_UNIT,
        POH.STATUS
having amount_accepted is not null
    ;;
}

# parameter: start_date {
#   default_value: "2010-01-01"
#   type: date
# }

# parameter: end_date {
#   type: date
#   default_value: "2099-01-01"
# }

dimension: vendorid {
  type: string
  sql: ${TABLE}.vendorid ;;
}

dimension: vendor_name {
  type: string
  sql: ${TABLE}.vendor_name ;;
}

dimension: primary_key {
  type: string
  primary_key: yes
  sql: ${TABLE}.primary_key;;
}

dimension: po_number {
  type: string
  sql: ${TABLE}.po_number ;;
}

dimension: PO_ID {
  type: string
  sql: ${TABLE}.PO_ID ;;
}

dimension_group: PO_Date {
  type: time
  timeframes: [raw,date,time,week,month,quarter,year]
  sql: ${TABLE}.PO_Date ;;
}

dimension: Requesting_Branch {
  type: string
  sql: ${TABLE}.Requesting_Branch ;;
}

dimension: Deliver_To_Branch {
  type: string
  sql: ${TABLE}.Deliver_To_Branch ;;
}

dimension: Created_By {
  type: string
  sql: ${TABLE}.Created_By ;;
}

dimension: Email_Address {
  type: string
  sql: ${TABLE}.Email_Address ;;
}

dimension: Item_Type {
  type: number
  sql: ${TABLE}.Item_Type ;;
}

dimension: Item_Name {
  type: string
  sql: ${TABLE}.Item_Name ;;
}

dimension: Part_Number {
  type: string
  sql: ${TABLE}.Part_Number ;;
}

dimension: Description {
  type: string
  sql: ${TABLE}.Description ;;
}

dimension: provider {
  type: string
  sql: ${TABLE}.provider ;;
}

dimension: Memo {
  type: string
  sql: ${TABLE}.Memo ;;
}

dimension: Quantity_Ordered {
  type: number
  sql: ${TABLE}.Quantity_Ordered ;;
}

dimension: Accepted_Quantity {
  type: number
  sql: ${TABLE}.Accepted_Quant ;;
}

dimension: Rejected_Quantity {
  type: number
  sql: ${TABLE}.Rejected_Quantity ;;
}

dimension: Price_Per_Unit {
  type: number
  sql: ${TABLE}.Price_Per_Unit ;;
}

dimension: PO_Status {
  type: string
  sql: ${TABLE}.PO_Status ;;
}

dimension: amount_approved {
  type: number
  value_format_name:usd
  value_format: "$#,##0"
  sql: ${TABLE}.amount_approved ;;
}

dimension: amount_accepted {
  type: number
  value_format_name:usd
  value_format: "$#,##0"
  sql: ${TABLE}.amount_accepted ;;
}

dimension: fulfilled_within_7_days {
  type: number
  sql: ${TABLE}.fulfilled_within_7_days ;;
}

dimension:  last_30_days{
  type: yesno
  sql:  ${PO_Date_date} <= current_date AND ${PO_Date_date} >= (current_date - INTERVAL '30 days')
    ;;
}

measure: days_30_cost_parts {
  type: sum
  filters: [last_30_days: "No"]
  value_format_name:usd
  value_format: "$#,##0"
  sql: ${TABLE}.amount_approved ;;
  drill_fields: [
    vendorid,
    vendor_name,
    po_number,
    PO_ID,
    PO_Date_date,
    Requesting_Branch,
    Deliver_To_Branch,
    Created_By,
    Email_Address,
    Part_Number,
    Description,
    Memo,
    Quantity_Ordered,
    Accepted_Quantity,
    Rejected_Quantity,
    Price_Per_Unit,
    PO_Status
  ]
}

measure: days_30_count_parts {
  type: sum
  filters: [last_30_days: "No"]
  sql: ${TABLE}.Quantity_Ordered ;;
  drill_fields: [
    vendorid,
    vendor_name,
    po_number,
    PO_ID,
    PO_Date_date,
    Requesting_Branch,
    Deliver_To_Branch,
    Created_By,
    Email_Address,
    Part_Number,
    Description,
    Memo,
    Quantity_Ordered,
    Accepted_Quantity,
    Rejected_Quantity,
    Price_Per_Unit,
    PO_Status
  ]
}

measure: days_30_cost_parts_accepted {
  type: sum
  filters: [last_30_days: "No"]
  value_format_name:usd
  value_format: "$#,##0"
  sql: ${TABLE}.amount_accepted ;;
  drill_fields: [
    vendorid,
    vendor_name,
    po_number,
    PO_ID,
    PO_Date_date,
    Requesting_Branch,
    Deliver_To_Branch,
    Created_By,
    Email_Address,
    Part_Number,
    Description,
    Memo,
    Quantity_Ordered,
    Accepted_Quantity,
    Rejected_Quantity,
    Price_Per_Unit,
    PO_Status
  ]
}

measure: days_30_count_parts_accepted {
  type: sum
  filters: [last_30_days: "No"]
  sql: ${TABLE}.Accepted_Quant ;;
  drill_fields: [
    vendorid,
    vendor_name,
    po_number,
    PO_ID,
    PO_Date_date,
    Requesting_Branch,
    Deliver_To_Branch,
    Created_By,
    Email_Address,
    Part_Number,
    Description,
    Memo,
    Quantity_Ordered,
    Accepted_Quantity,
    Rejected_Quantity,
    Price_Per_Unit,
    PO_Status
  ]
}


measure: total_cost {
  type: sum
  value_format_name:usd
  value_format: "$#,##0"
  sql: ${TABLE}.amount_approved ;;
  drill_fields: [
    vendorid,
    vendor_name,
    po_number,
    PO_ID,
    PO_Date_date,
    Requesting_Branch,
    Deliver_To_Branch,
    Created_By,
    Email_Address,
    Part_Number,
    Description,
    Memo,
    Quantity_Ordered,
    Accepted_Quantity,
    Rejected_Quantity,
    Price_Per_Unit,
    PO_Status
  ]
}

measure: total_count {
  type: sum
  value_format_name:usd
  value_format: "$#,##0"
  sql: ${TABLE}.Quantity_Ordered ;;
  drill_fields: [
    vendorid,
    vendor_name,
    po_number,
    PO_ID,
    PO_Date_date,
    Requesting_Branch,
    Deliver_To_Branch,
    Created_By,
    Email_Address,
    Part_Number,
    Description,
    Memo,
    Quantity_Ordered,
    Accepted_Quantity,
    Rejected_Quantity,
    Price_Per_Unit,
    PO_Status
  ]
}

measure: total_cost_accepted {
  type: sum
  value_format_name:usd
  value_format: "$#,##0"
  sql: ${TABLE}.amount_accepted ;;
  drill_fields: [
    vendorid,
    vendor_name,
    po_number,
    PO_ID,
    PO_Date_date,
    Requesting_Branch,
    Deliver_To_Branch,
    Created_By,
    Email_Address,
    Part_Number,
    Description,
    Memo,
    Quantity_Ordered,
    Accepted_Quantity,
    Rejected_Quantity,
    Price_Per_Unit,
    PO_Status
  ]
}

measure: total_count_accepted {
  type: sum
  value_format_name:usd
  value_format: "$#,##0"
  sql: ${TABLE}.Accepted_Quant ;;
  drill_fields: [
    vendorid,
    vendor_name,
    po_number,
    PO_ID,
    PO_Date_date,
    Requesting_Branch,
    Deliver_To_Branch,
    Created_By,
    Email_Address,
    Part_Number,
    Description,
    Memo,
    Quantity_Ordered,
    Accepted_Quantity,
    Rejected_Quantity,
    Price_Per_Unit,
    PO_Status
  ]
}

measure: total_qty_accepted {
  type: sum
  sql: ${TABLE}.Accepted_Quant ;;
}

measure: total_qty_fulfilled_within_7_days {
  type: sum
  filters: [fulfilled_within_7_days: "1"]
  sql: ${TABLE}.Accepted_Quant ;;
}

measure: day_30_total_qty_fulfilled_within_7_days {
  type: sum
  filters: [fulfilled_within_7_days: "1", last_30_days: "No"]
  sql: ${TABLE}.Accepted_Quant ;;
}

measure: day_30_total_qty_ordered {
  type: sum
  filters: [last_30_days: "No"]
  sql: ${TABLE}.Quantity_Ordered ;;
}

measure: total_qty_ordered {
  type: sum
  sql: ${TABLE}.Quantity_Ordered ;;
}

measure: parts_fulfillment_cost {
  type: number
  value_format_name: percent_0
  sql: case when ${total_cost} = 0 or ${total_cost_accepted} = 0 then 0 else ${total_cost_accepted}/${total_cost} end;;
  html: {{parts_fulfillment_cost._rendered_value}} <br> {{total_qty_accepted._rendered_value}} Parts Accepted | {{total_qty_ordered._rendered_value}} Total Parts;;
}

measure: parts_fulfillment_count {
  type: number
  value_format_name: percent_0
  sql: case when ${total_qty_ordered} = 0 or ${total_qty_fulfilled_within_7_days} = 0 then 0
    else ${total_qty_fulfilled_within_7_days}/${total_qty_ordered} end;;
  html: {{parts_fulfillment_count._rendered_value}} <br> <p style="font-size:20px"> {{total_qty_fulfilled_within_7_days._rendered_value}} Fulfilled | {{total_qty_ordered._rendered_value}} Total </p>;;
}

measure: day_30_parts_fulfillment_count {
  type: number
  value_format_name: percent_0
  sql: case when ${day_30_total_qty_ordered} = 0 or ${day_30_total_qty_fulfilled_within_7_days} = 0 then 0
    else ${day_30_total_qty_fulfilled_within_7_days}/${day_30_total_qty_ordered} end;;
  html: {{day_30_parts_fulfillment_count._rendered_value}} <br> <p style="font-size:20px"> {{day_30_total_qty_fulfilled_within_7_days._rendered_value}} Parts Fulfilled <br> {{day_30_total_qty_ordered._rendered_value}} Total Parts </p>;;
}
}

view: vendor_fulfillment_score {
  derived_table: {
    sql:
with agg as (
    select coalesce(pv.vendorid, v.vendorid) as vendorid
        , coalesce(pv.vendor_type, tvm.vendor_type) as vendor_type
        , coalesce(pv.mapped_vendor_name, tvm.mapped_vendor_name) as mapped_vendor_name
        , count_if(fulfilled_within_7_days = 1) as fulfilled
        , count(PURCHASE_ORDER_LINE_ITEM_ID) as total_lines
    from ${parts_spend_vendor_level.SQL_TABLE_NAME} v
    left join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm
        on tvm.vendorid = v.vendorid
    left join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING pv --Switching to Primary Vendor if possible
        on pv.mapped_vendor_name = tvm.mapped_vendor_name
          and pv.primary_vendor = 'YES'
    where PO_Date >= dateadd(month, -12, date_trunc(month, current_date))
    group by 1, 2, 3
)

select a.vendorid
    , a.vendor_type --hidden
    , a.fulfilled vendor_fulfilled
    , a.total_lines vendor_lines
    , sum(pa.fulfilled) as peers_fulfilled
    , sum(pa.total_lines) as peers_lines
--    , peers_fulfilled / peers_total_lines as peers_fulfillment
--    , greatest(coalesce(peers_fulfillment, 0), 0.9) as target
--    , round(iff(((vendor_fulfillment / target) * 1.25) > 1.25, 1.25, ((vendor_fulfillment / target) * 1.25)), 2) as parts_fulfillment_score
--    , round(iff(((vendor_fulfillment / target) * 10) > 10, 10, ((vendor_fulfillment / target) * 10)), 1) as parts_fulfillment_score10
from agg a
left join agg pa
    on pa.vendorid <> a.vendorid
        and pa.mapped_vendor_name <> a.mapped_vendor_name
        and pa.vendor_type = a.vendor_type
group by 1,2,3,4;;
  }
  dimension: vendorid {
    type: string
    primary_key: yes
    sql: ${TABLE}.vendorid ;;
  }
  dimension: vendor_fulfilled {
    type:number
    sql: ${TABLE}.vendor_fulfilled ;;
  }
  measure: total_vendor_fulfilled {
    type: sum
    sql: ${vendor_fulfilled} ;;
  }
  dimension: vendor_lines {
    type:number
    sql: ${TABLE}.vendor_lines ;;
  }
  measure: total_vendor_lines {
    type: sum
    sql: ${vendor_lines} ;;
  }
  measure: vendor_fulfillment {
    type: number
    value_format_name: percent_0
    sql: ${total_vendor_fulfilled} / nullifzero(${total_vendor_lines}) ;;
  }
  dimension: peers_fulfilled {
    type: number
    sql: ${TABLE}.peers_fulfilled ;;
  }
  measure: total_peers_fulfilled {
    type: sum
    sql: ${peers_fulfilled} ;;
  }
  dimension: peers_lines {
    type: number
    sql: ${TABLE}.peers_lines ;;
  }
  measure: total_peers_lines {
    type: sum
    sql: ${peers_lines} ;;
  }
  measure: peers_fulfillment {
    type: number
    value_format_name: percent_0
    sql: ${total_peers_fulfilled} / nullifzero(${total_peers_lines}) ;;
  }
  measure: graded_target {
    type: number
    value_format_name: percent_0
    sql: greatest(coalesce(${peers_fulfillment}, 0), 0.95);;
  }
  measure: parts_fulfillment_score {
    type:number
    value_format_name: decimal_2
    sql: coalesce(iff(((${vendor_fulfillment} / ${graded_target}) * (1/14)) > (1/14), (1/14), ((${vendor_fulfillment} / ${graded_target}) * (1/14))), 0);;
  }
  measure: parts_fulfillment_score10 {
    type:number
    value_format_name: decimal_1
    sql: coalesce(iff(((${vendor_fulfillment} / ${graded_target}) * 10) > 10, 10, ((${vendor_fulfillment} / ${graded_target}) * 10)), 0) ;;
  }
}
