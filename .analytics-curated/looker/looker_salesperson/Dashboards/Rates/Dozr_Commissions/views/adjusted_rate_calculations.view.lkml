view: adjusted_rate_calculations {
derived_table: {

  sql: with quotes as (

select q.id, q.quote_number, q.created_date, q.expiry_date, e.day_rate, e.week_rate, e.four_week_rate, e.equipment_class_id, q.branch_id, rr.market_name as branch_name, ec.name from quotes.quotes.quote as q
left join quotes.quotes.quote_pricing as qp

on q.id = qp.quote_id
left join quotes.quotes.equipment_type as e
on e.quote_id = q.id
left join analytics.rate_achievement.rate_regions as rr
on rr.market_id = q.branch_id
left join es_warehouse.public.equipment_classes ec
on ec.equipment_class_id = e.equipment_class_id
where company_name ilike '%Dozr%'



),

region_rates as (

select
rr.region,
br.branch_id,
br.equipment_class_id,
br.rate_type_id,
max(br.price_per_hour) over(partition by rr.region, br.equipment_class_id, br.rate_type_id) as region_price_per_hour,
max(br.price_per_day) over(partition by rr.region, br.equipment_class_id, br.rate_type_id) as region_price_per_day,
max(br.price_per_week) over(partition by rr.region, br.equipment_class_id, br.rate_type_id) as region_price_per_week,
max(br.price_per_month) over(partition by rr.region, br.equipment_class_id, br.rate_type_id) as region_price_per_month,
mode(br.call_for_pricing) over(partition by rr.region, br.equipment_class_id, br.rate_type_id) as call_for_pricing
from analytics.rate_achievement.rate_regions rr
left join es_warehouse.public.branch_rental_rates as br
on br.branch_id = rr.market_id
where br.rate_type_id = 1 and ACTIVE = TRUE

),

branch_rates as (

select
branch_id,
equipment_class_id,
rate_type_id,
price_per_hour,
price_per_day,
price_per_week,
price_per_month,
call_for_pricing
from es_warehouse.public.branch_rental_rates
where rate_type_id = 1 and active = TRUE

),

commission as (select q.*, r.region_price_per_month, r.region_price_per_hour, r.region_price_per_day, r.region_price_per_week,
CASE WHEN q.four_week_rate >= region_price_per_month THEN .08
     WHEN q.four_week_rate >= region_price_per_month * .93 THEN .06
     WHEN q.four_week_rate >= region_price_per_month * .86 THEN .04
     WHEN q.four_week_rate >= region_price_per_month * .79 THEN .02 ELSE 0 END as four_week_commission_pct_achieved,
CASE WHEN q.week_rate >= region_price_per_week THEN .08
     WHEN q.week_rate >= region_price_per_week * .93 THEN .06
     WHEN q.week_rate >= region_price_per_week * .86 THEN .04
     WHEN q.week_rate >= region_price_per_week * .79 THEN .02 ELSE 0 END as week_commission_pct_achieved,
CASE WHEN q.day_rate >= region_price_per_day THEN .08
     WHEN q.day_rate >= region_price_per_day * .93 THEN .06
     WHEN q.day_rate >= region_price_per_day * .86 THEN .04
     WHEN q.day_rate >= region_price_per_day * .79 THEN .02 ELSE 0 END as day_commission_pct_achieved




from quotes as q
left join region_rates as r
on r.branch_id = q.branch_id and r.equipment_class_id = q.equipment_class_id
)

select c.quote_number,
c.equipment_class_id,
c.name,
xw.region_name,
xw.district,
c.branch_name,
c.branch_id,
c.region_price_per_hour,
c.region_price_per_day,
c.region_price_per_week,
c.region_price_per_month,
c.four_week_rate as quoted_monthly_rate,
c.week_rate as quoted_weekly_rate,
c.day_rate as quoted_daily_rate,
c.four_week_commission_pct_achieved,
c.week_commission_pct_achieved,
c.day_commission_pct_achieved,
c.four_week_rate/region_price_per_month as four_week_achieved_rate,
c.week_rate/region_price_per_week as week_achieved_rate,
c.day_rate/region_price_per_day as day_achieved_rate,
c.created_date,
c.expiry_date,
c.four_week_rate - (c.four_week_commission_pct_achieved * c.four_week_rate) as adjusted_monthly_rental_rate,
c.week_rate - (c.week_rate * c.week_commission_pct_achieved) as adjusted_weekly_rental_rate,
c.day_rate - (c.day_rate * c.day_commission_pct_achieved) as adjusted_daily_rental_rate,
c.four_week_commission_pct_achieved * c.four_week_rate as four_week_commission_achieved,
c.week_commission_pct_achieved * c.week_rate as week_commission_achieved,
c.day_commission_pct_achieved * c.day_rate as day_commission_achieved

from commission as c
left join analytics.public.market_region_xwalk as xw
on xw.market_id = c.branch_id


 ;;

}
dimension: district {

  type: string
  sql: ${TABLE}."DISTRICT" ;;

}

dimension: region_name {

  type: string
  sql: ${TABLE}."REGION_NAME" ;;

}

dimension: four_week_achieved_rate {

  type: number
  sql: ${TABLE}."FOUR_WEEK_ACHIEVED_RATE" ;;
  value_format_name: percent_0

}

dimension: week_achieved_rate {

  type: number
  sql: ${TABLE}."WEEK_ACHIEVED_RATE" ;;
  value_format_name: percent_0
}

dimension: day_achieved_rate {

  type: number
  sql: ${TABLE}."DAY_ACHIEVED_RATE" ;;
  value_format_name: percent_0
}

dimension: achieved_rate {

  type: string
  sql: FLOOR(${day_achieved_rate}*100)||'%'||'/'||FLOOR(${week_achieved_rate}*100)||'%'||'/'||FLOOR(${four_week_achieved_rate}*100)||'%';;


}

dimension: equipment_class_name {

  type: string
  sql: ${TABLE}."NAME" ;;

}

dimension: branch_name {

  type: string
  sql: ${TABLE}."BRANCH_NAME" ;;

}

dimension: quote_number {

  type: number
  sql: ${TABLE}."QUOTE_NUMBER" ;;
  value_format: "###########0"

}

dimension: equipment_class_id {

  type: number
  sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  value_format: "###########0"

}

dimension: branch_id  {

  type: number
  sql: ${TABLE}."BRANCH_ID" ;;
  value_format: "###########0"
}

dimension: online_region_price_per_hour {

  type: number
  value_format_name: usd_0
  sql: ${TABLE}."REGION_PRICE_PER_HOUR" ;;

}

dimension: online_region_price_per_day {

  type: number
  value_format_name: usd_0
  sql: ${TABLE}."REGION_PRICE_PER_DAY" ;;

}

dimension: online_region_price_per_week {

  type: number
  value_format_name: usd_0
  sql: ${TABLE}."REGION_PRICE_PER_WEEK" ;;

}

dimension: online_region_price_per_month {

  type: number
  sql: ${TABLE}."REGION_PRICE_PER_MONTH" ;;
  value_format_name: usd_0
}

dimension: region_rates {

  type: string
  sql:  '$'||FLOOR(${online_region_price_per_day})||'/'||' $'||FLOOR(${online_region_price_per_week})||'/'||'$'||FLOOR(${online_region_price_per_month});;

}

dimension: quoted_monthly_rate {

  type: number
  sql: ${TABLE}."QUOTED_MONTHLY_RATE" ;;
  value_format_name: usd_0

}

dimension: quoted_weekly_rate {

  type: number
  sql: ${TABLE}."QUOTED_WEEKLY_RATE" ;;
  value_format_name: usd_0
}
  dimension: quoted_daily_rate {

    type: number
    sql: ${TABLE}."QUOTED_DAILY_RATE" ;;
    value_format_name: usd_0
  }

dimension: quoted_rates {

  type: string
  sql: '$'||${quoted_daily_rate}||'/'||'$'||${quoted_weekly_rate}||'/'||'$'||${quoted_monthly_rate} ;;


}

dimension: adjusted_daily_rental_rate {

  type: number
  sql: ${TABLE}."ADJUSTED_DAILY_RENTAL_RATE" ;;
  value_format_name: usd_0
}

dimension: adjusted_weekly_rental_rate {

  type: number
  sql: ${TABLE}."ADJUSTED_WEEKLY_RENTAL_RATE" ;;
  value_format_name: usd_0
}

dimension: adjusted_monthly_rental_rate {

  type: number
  sql: ${TABLE}."ADJUSTED_MONTHLY_RENTAL_RATE" ;;
  value_format_name: usd

}

dimension: adjusted_rates {

  type: string
  sql: '$'||${adjusted_daily_rental_rate}||'/'||'$'||${adjusted_weekly_rental_rate}||'/'||'$'||${adjusted_monthly_rental_rate} ;;


}
dimension: four_week_commission_pct_achieved {

  type: number
  sql: ${TABLE}."FOUR_WEEK_COMMISSION_PCT_ACHIEVED" ;;
  value_format_name: percent_0

}

dimension: week_commission_pct_achieved {

  type: number
  sql: ${TABLE}."WEEK_COMMISSION_PCT_ACHIEVED" ;;
  value_format_name: percent_0

}

dimension: day_commission_pct_achieved {

  type: number
  sql: ${TABLE}."DAY_COMMISSION_PCT_ACHIEVED" ;;
  value_format_name: percent_0
}

dimension: commission_pct_achieved {

  type: string
  sql:  FLOOR(${day_commission_pct_achieved}*100)||'%'||'/'||FLOOR(${week_commission_pct_achieved}*100)||'%'||'/'||FLOOR(${four_week_commission_pct_achieved}*100)||'%' ;;

}

dimension: four_week_commission_achieved {

  type: number
  sql: ${TABLE}."FOUR_WEEK_COMMISSION_ACHIEVED" ;;
  value_format_name: usd
}

dimension: week_commission_achieved {

  type: number
  sql: ${TABLE}."WEEK_COMMISSION_ACHIEVED" ;;
  value_format_name: usd
}

dimension: day_commission_achieved {

  type: number
  sql: ${TABLE}."DAY_COMMISSION_ACHIEVED" ;;
  value_format_name: usd
}

dimension: commission_achieved {

  type: string
  sql:  '$'||${day_commission_achieved}||'/'||'$'||${week_commission_achieved}||'/'||'$'||${four_week_commission_achieved} ;;

}

dimension: created_date {

  type: date
  sql: ${TABLE}."CREATED_DATE" ;;
}
dimension: expiry_date {

  type: date
  sql: ${TABLE}."EXPIRY_DATE" ;;

}
 }
