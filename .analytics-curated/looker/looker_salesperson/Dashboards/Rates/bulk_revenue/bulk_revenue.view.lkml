view: bulk_revenue {

  derived_table: {

    sql: WITH blkr as
(SELECT mrx.MARKET_ID
       , mrx.MARKET_NAME
       , mrx.REGION_NAME
       , i.COMPANY_ID
       , c.NAME as RENTING_COMPANY_NAME
       , vli.gl_billing_approved_date
       , vli.rental_id
       , SUM(vli.amount) as amount
FROM ES_WAREHOUSE.PUBLIC.INVOICES i
JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS vli
    ON i. INVOICE_ID = vli.INVOICE_ID
JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx
    ON vli.BRANCH_ID = mrx.MARKET_ID
JOIN ES_WAREHOUSE.PUBLIC.COMPANIES c
    ON i.COMPANY_ID = c.COMPANY_ID
WHERE vli.GL_BILLING_APPROVED_DATE < CURRENT_DATE()      ----- Change to desired date
    AND vli.LINE_ITEM_TYPE_ID = '44'
GROUP BY mrx.MARKET_ID
       , mrx.MARKET_NAME
       , mrx.REGION_NAME
       , rental_ID
       , renting_company_name
       , i.company_id
       , vli.gl_billing_approved_date
)

    SELECT blkr.Rental_ID
   , blkr.Market_ID
   , blkr.Market_name
   , blkr.Region_Name
   , blkr.Company_ID
   , blkr.Renting_Company_Name
   , sp.store_id
   , coalesce(p2.part_id
   , p1.part_id) as PART_ID
   , coalesce(p2.part_number
   , p1.part_number) as PART_NUMBER
   , CURRENT_ON_RENT_QTY
   , pt.Description
   , pt.Part_Type_ID
   , pr.Name
   , blkr.Amount
   , blkr.GL_BILLING_APPROVED_DATE::DATE AS Billing_Approved_Date
   , MONTH(blkr.GL_BILLING_APPROVED_DATE::DATE) AS MONTH_REV
   , on_r.On_rent
    FROM blkr
    join (SELECT DISTINCT rental_ID
   , part_ID
   , sum(QUANTITY) as QUANTITY
    FROM ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS
    GROUP BY rental_ID
   , part_ID) rpa
    on rpa.rental_ID = blkr.rental_ID
    join ES_WAREHOUSE.INVENTORY.PARTS p1
    on rpa.part_id = p1.part_id
    left join es_warehouse.INVENTORY.parts p2 -- In case the p1 part refers to a part that was MergePart'ed
    on p1.DUPLICATE_OF_ID = p2.part_id
    join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
    on pt.PART_TYPE_ID = coalesce(p2.PART_TYPE_ID
   , p1.PART_TYPE_ID)
    join ES_WAREHOUSE.INVENTORY.PROVIDERS pr
    on p1.provider_id = pr.provider_id
    join ES_WAREHOUSE.INVENTORY.STORES s
    on blkr.MARKET_ID = s.BRANCH_ID
    join ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
    on s.store_id = sp.STORE_ID
    and sp.PART_ID = coalesce(p2.part_id
   , p1.part_id)
    left join (SELECT DISTINCT Rental_ID
   , Part_ID
   , Quantity as CURRENT_ON_RENT_QTY
   , 'Y' as On_Rent
    FROM ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS rpa
    where CURRENT_DATE() between rpa.START_DATE and coalesce(rpa.END_DATE
   , '2099-12-31'::DATE)) on_r
    on on_r.rental_ID = blkr.rental_ID AND coalesce(p2.part_id
   , p1.part_id) = on_r.part_id ;;


  }

  dimension: rental_id {

    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format: "##############0"
  }
  dimension: market_id {

    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format: "#############0"
  }
  dimension: market_name {

    type: string
    sql: ${TABLE}."MARKET_NAME" ;;


  }
  dimension: region_name {

    type: string
    sql: ${TABLE}."REGION_NAME" ;;


  }
  dimension: company_id {

    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format: "###########0"
  }

  dimension: renting_company_name {

    type: string
    sql: ${TABLE}."RENTING_COMPANY_NAME" ;;


  }
  dimension: store_id {

    type: number
    sql: ${TABLE}."STORE_ID" ;;
    value_format: "###########0"
  }

  dimension: part_id {

    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format: "###########0"


  }

  dimension: part_number {

   type: string
   sql: ${TABLE}."PART_NUMBER" ;;

  }

  dimension: current_on_rent_qty {

    type: number
    sql: ${TABLE}."CURRENT_ON_RENT_QTY" ;;
  }
  dimension: description {

    type: string
    sql: ${TABLE}."DESCRIPTION" ;;

  }

  dimension: part_type_id {

    type: number
    sql: ${TABLE}."PART_TYPE_ID" ;;
    value_format: "############0"


}
  dimension: category_name {

    type: string
    sql: ${TABLE}."NAME" ;;


  }
  dimension: amount {

    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd
  }

  dimension: billing_approved_date {

    type: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;


  }
  dimension: month_rev {

    type: number
    sql: ${TABLE}."MONTH_REV" ;;

  }

  dimension: on_rent {

    type: string
    sql: ${TABLE}."ON_RENT" ;;
  }


  dimension_group: quarter {
    type: time
    timeframes: [
      quarter,
      year
    ]
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }
  }
