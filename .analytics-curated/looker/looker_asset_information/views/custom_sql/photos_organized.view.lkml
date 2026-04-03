view: photos_organized {
    derived_table: {
      # datagroup_trigger: 6AM_update
      sql:

with admin_pic as(
select
a.asset_id
,p1.filename
,to_timestamp(current_timestamp()) as date_

from ES_WAREHOUSE.PUBLIC.assets a
left join ES_WAREHOUSE.PUBLIC.photos p1
on a.photo_id =p1.photo_id
)

,delivery_pics as(
select
a2.asset_id
,p2.filename
,to_timestamp(d.completed_date) as date_

from ES_WAREHOUSE.PUBLIC.assets a2
left join ES_WAREHOUSE.PUBLIC.deliveries d
on a2.asset_id =d.asset_id
left join ES_WAREHOUSE.PUBLIC.delivery_photos dp
on d.delivery_id =dp.delivery_id
left join ES_WAREHOUSE.PUBLIC.photos p2
on dp.photo_id =p2.photo_id

where p2.filename is not null --some deliveries are missing data. Was making some of the first row_number results null. Jack G 8/20/21

order by d.completed_date desc
)

,final_table as(
select
*
from admin_pic
union all
select
*
from delivery_pics
)

select
*
,row_number() over(partition by asset_id order by date_ desc) as rn
from final_table

          ;;
    }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: filename {
    type: string
    sql: ${TABLE}.filename ;;
  }

  dimension: photo_link {
    type: string
    sql: concat('https://appcdn.equipmentshare.com/uploads/',${filename}) ;;
  }

  dimension: asset_photos {
    type: string
    sql: ${photo_link} ;;
    html: <p><img src={{photo_link._value}} height =50 width =50> </p> ;;
  }

  dimension: sort {
    type: number
    sql: ${TABLE}.rn ;;
  }

  dimension_group: photo_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_id_link_to_photos {
    type: string
    sql: ${photo_link} ;;
    html: <font color="blue "><u><a href="{{ photo_link._value }}" target="_blank">{{ photo_link._value }}</a></font></u> ;;
  }

   }
