view: rental_fleet_assets {
  derived_table: {
    sql: with wo_pic_ranking as (
           select
              wo.asset_id,
              ROW_NUMBER() OVER(partition by wo.asset_id ORDER BY wof.date_created) wo_picture_ranking,
              url as filename
          from
             work_orders.work_order_files wof
             join work_orders.work_orders wo on wo.work_order_id = wof.work_order_id
          where
            date_deleted is null
            qualify wo_picture_ranking <= 10
           )
, first_10_pictures_pivot as (
select * from wo_pic_ranking
pivot(max(filename) for wo_picture_ranking in (1,2,3,4,5,6,7,8,9,10))
)
, first_10_pictures_final as (
select
asset_id
, "1" as image_01
, "2" as image_02
, "3" as image_03
, "4" as image_04
, "5" as image_05
, "6" as image_06
, "7" as image_07
, "8" as image_08
, "9" as image_09
, "10" as image_10
from first_10_pictures_pivot
)
, cateogry_table as (
select
    a.asset_id,
    c.name as category
from
    assets a
    left join equipment_models em on em.equipment_model_id = a.equipment_model_id
    left join equipment_classes_models_xref ecx on ecx.equipment_model_id = em.equipment_model_id
    left join equipment_classes ec on ec.equipment_class_id = ecx.equipment_class_id
    left join categories c on c.category_id = ec.category_id and c.parent_category_id is not null and c.active = TRUE
)
, min_mmr as (
select
asset_id
, min(date_completed) as date_of_first_completed_MMR
from
work_orders.work_orders
group by asset_id
)
select
  a.asset_id
, a.serial_number
, ct.category
, aa.class
, a.make
, a.model
, a.date_created as asset_date_created
, aa.purchase_date
, mm.date_of_first_completed_MMR
, aa.first_rental
, round(aa.oec,2) as oec
, concat('https://appcdn.equipmentshare.com/uploads/',po.filename) as es_admin_file_name
, pf.image_01 as work_order_image_01
, pf.image_02 as work_order_image_02
, pf.image_03 as work_order_image_03
, pf.image_04 as work_order_image_04
, pf.image_05 as work_order_image_05
, pf.image_06 as work_order_image_06
, pf.image_07 as work_order_image_07
, pf.image_08 as work_order_image_08
, pf.image_09 as work_order_image_09
, pf.image_10 as work_order_image_10
from assets a
join analytics.bi_ops.asset_ownership ao on ao.asset_id = a.asset_id and ao.rentable = true
left join es_warehouse.public.assets_aggregate aa on aa.asset_id = a.asset_id
left join ES_WAREHOUSE.PUBLIC.photos po on a.photo_id =po.photo_id
left join first_10_pictures_final pf on pf.asset_id = a.asset_id
left join min_mmr mm on mm.asset_id = a.asset_id
left join cateogry_table ct on ct.asset_id = a.asset_id
order by asset_id desc;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension_group: asset_date_created {
    type: time
    sql: ${TABLE}."ASSET_DATE_CREATED" ;;
  }

  dimension_group: purchase_date {
    type: time
    sql: ${TABLE}."PURCHASE_DATE" ;;
  }

  dimension_group: date_of_first_completed_mmr {
    type: time
    sql: ${TABLE}."DATE_OF_FIRST_COMPLETED_MMR" ;;
  }

  dimension_group: first_rental {
    type: time
    sql: ${TABLE}."FIRST_RENTAL" ;;
  }

  dimension: oec {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}."OEC" ;;
  }

  dimension: es_admin_file_name {
    type: string
    sql: ${TABLE}."ES_ADMIN_FILE_NAME" ;;
    html: <a href="{{rendered_value}}">ES Admin Photo </a> ;;
  }

  dimension: work_order_image_01 {
    type: string
    sql: ${TABLE}."WORK_ORDER_IMAGE_01" ;;
    html: <a href="{{rendered_value}}">WO Image 1 </a> ;;
  }

  dimension: work_order_image_02 {
    type: string
    sql: ${TABLE}."WORK_ORDER_IMAGE_02" ;;
    html: <a href="{{rendered_value}}">WO Image 2 </a> ;;
  }

  dimension: work_order_image_03 {
    type: string
    sql: ${TABLE}."WORK_ORDER_IMAGE_03" ;;
    html: <a href="{{rendered_value}}">WO Image 3 </a> ;;
  }

  dimension: work_order_image_04 {
    type: string
    sql: ${TABLE}."WORK_ORDER_IMAGE_04" ;;
    html: <a href="{{rendered_value}}">WO Image 4 </a> ;;
  }

  dimension: work_order_image_05 {
    type: string
    sql: ${TABLE}."WORK_ORDER_IMAGE_05" ;;
    html: <a href="{{rendered_value}}">WO Image 5 </a> ;;
  }

  dimension: work_order_image_06 {
    type: string
    sql: ${TABLE}."WORK_ORDER_IMAGE_06" ;;
    html: <a href="{{rendered_value}}">WO Image 6 </a> ;;
  }

  dimension: work_order_image_07 {
    type: string
    sql: ${TABLE}."WORK_ORDER_IMAGE_07" ;;
    html: <a href="{{rendered_value}}">WO Image 7 </a> ;;
  }

  dimension: work_order_image_08 {
    type: string
    sql: ${TABLE}."WORK_ORDER_IMAGE_08" ;;
    html: <a href="{{rendered_value}}">WO Image 8 </a> ;;
  }

  dimension: work_order_image_09 {
    type: string
    sql: ${TABLE}."WORK_ORDER_IMAGE_09" ;;
    html: <a href="{{rendered_value}}">WO Image 9 </a> ;;
  }

  dimension: work_order_image_10 {
    type: string
    sql: ${TABLE}."WORK_ORDER_IMAGE_10" ;;
    html: <a href="{{rendered_value}}">WO Image 10 </a> ;;
  }

  set: detail {
    fields: [
      asset_id,
      serial_number,
      category,
      class,
      make,
      model,
      asset_date_created_time,
      purchase_date_time,
      date_of_first_completed_mmr_time,
      first_rental_time,
      oec,
      es_admin_file_name,
      work_order_image_01,
      work_order_image_02,
      work_order_image_03,
      work_order_image_04,
      work_order_image_05,
      work_order_image_06,
      work_order_image_07,
      work_order_image_08,
      work_order_image_09,
      work_order_image_10
    ]
  }
}
