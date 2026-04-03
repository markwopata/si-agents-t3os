view: hiring_update_table_oe_oa_goals {
  derived_table: {sql:

--OFFERS ACCEPTED GOALS CURRENT MONTH
with open_reqs_as_of_fotm as (


--REQS THAT ARE CURRENTLY OPEN AND OPENED 15 DAYS BEFORE THE BEGINNING OF THE CURRENT MONTH
--AND DON'T HAVE AN OFFER ACCEPTED TIED TO THEM
with still_open_reqs_beginning_of_current_month as
(select
--TOP FOCUS
case when r.requisition_name like '%Territory Account Manager%' then 'Territory Account Managers'
      when r.requisition_name like '%District Sales Manager%' then 'District Sales Managers'
      when r.requisition_name = 'General Manager' OR r.requisition_name = 'General Manager - Advanced Solutions' then 'General Managers'
      when r.requisition_name like '%Service Manager%' then 'Service Managers'
      when r.requisition_name like '%Service Technician%' OR r.requisition_name like '%Field Technician%' OR r.requisition_name like '%Diesel Technician%' OR r.requisition_name like '%Shop Technician%' then 'Techs'
      when r.requisition_name like '%CDL%' then 'CDL Delivery Drivers'
      when r.requisition_name like '%District Operations%' and r.requisition_name not like '%Assistant%' then 'District Operations Managers'
      else null end as top_focus,
r.requisition_id,
r.requisition_name,
r.requisition_status,
f.application_requisition_offer_job_created_date,
f.application_requisition_offer_job_closed_date,
f.application_requisition_offer_offer_resolved_date,
f.application_requisition_offer_offer_sent_date,
f.application_requisition_offer_offer_key,
o.offer_status,
a.application_status,
case when (o.offer_status = 'accepted' and
f.application_requisition_offer_offer_resolved_date >= dateadd(day,-(day(current_date)-1),current_date)) or
o.offer_status <> 'accepted'
then 'Include'
else 'Exclude' end as include_
from PEOPLE_ANALYTICS.GREENHOUSE.V_FACT_APPLICATION_REQUISITION_OFFER f
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_REQUISITION r on f.application_requisition_offer_requisition_key = r.requisition_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_OFFER o on f.application_requisition_offer_offer_key = o.offer_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_APPLICATION a on f.application_requisition_offer_application_key = a.application_key
where
top_focus is not null and
r.requisition_custom_type = 'Active Requisition' and
r.requisition_status = 'open' and
f.application_requisition_offer_job_created_date <= dateadd(day,-(day(current_date)+15),current_date)
order by f.application_requisition_offer_offer_resolved_date desc
)

select
top_focus,
count(distinct case when include_ = 'Exclude' then requisition_id
else null end) as excluded_reqs,
count(distinct(requisition_id)) as total_reqs,
total_reqs - excluded_reqs as included_open_reqs
from still_open_reqs_beginning_of_current_month
group by top_focus),



--REQS THAT ARE CLOSED CURRENTLY BUT WERE OPEN AS OF THE FIRST DAY OF CURRENT MONTH
--AND WERE OPENED 15 DAYS OR MORE PRIOR TO THE FIRST DAY OF THE CURRENT MONTH
--AND DIDN"T HAVE AN OFFER ACCEPTED TIED TO THEM
closed_reqs_as_of_fotm as
(with all_closed_reqs_first_of_the_month_current_month as
(select
--TOP FOCUS
case when r.requisition_name like '%Territory Account Manager%' then 'Territory Account Managers'
      when r.requisition_name like '%District Sales Manager%' then 'District Sales Managers'
      when r.requisition_name = 'General Manager' OR r.requisition_name = 'General Manager - Advanced Solutions' then 'General Managers'
      when r.requisition_name like '%Service Manager%' then 'Service Managers'
      when r.requisition_name like '%Service Technician%' OR r.requisition_name like '%Field Technician%' OR r.requisition_name like '%Diesel Technician%' OR r.requisition_name like '%Shop Technician%' then 'Techs'
      when r.requisition_name like '%CDL%' then 'CDL Delivery Drivers'
      when r.requisition_name like '%District Operations%' and r.requisition_name not like '%Assistant%' then 'District Operations Managers'
      else null end as top_focus,
r.requisition_id,
r.requisition_name,
r.requisition_status,
f.application_requisition_offer_job_created_date,
f.application_requisition_offer_job_closed_date,
f.application_requisition_offer_offer_resolved_date,
f.application_requisition_offer_offer_key,
o.offer_status,
a.application_status,
case when a.application_status = 'hired' and
f.application_requisition_offer_offer_resolved_date >= dateadd(day,-(day(current_date)-2),current_date)
then 'Include'
when a.application_status <> 'hired' then 'Include'
else 'Exclude' end as include_
from PEOPLE_ANALYTICS.GREENHOUSE.V_FACT_APPLICATION_REQUISITION_OFFER f
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_REQUISITION r on f.application_requisition_offer_requisition_key = r.requisition_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_OFFER o on f.application_requisition_offer_offer_key = o.offer_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_APPLICATION a on f.application_requisition_offer_application_key = a.application_key
where
top_focus is not null and
r.requisition_status = 'closed' and
f.application_requisition_offer_job_created_date <= dateadd(day,-(day(current_date)+15),current_date) and
f.application_requisition_offer_job_closed_date >= dateadd(day,-(day(current_date)-2),current_date)
group by 1,2,3,4,5,6,7,8,9,10
order by requisition_id)

select
top_focus,
count(distinct case when include_ = 'Exclude' then requisition_id
else null end) as excluded_reqs,
count(distinct(requisition_id)) as total_reqs,
total_reqs - excluded_reqs as included_closed_reqs
from all_closed_reqs_first_of_the_month_current_month
group by top_focus),




--OFFERS ACCEPTED GOALS LAST MONTH
open_reqs_as_of_fotm_last_month as (


--REQS THAT ARE CURRENTLY OPEN AND OPENED 15 DAYS BEFORE THE BEGINNING OF LAST MONTH
--AND DON'T HAVE AN OFFER ACCEPTED TIED TO THEM
with still_open_reqs_beginning_of_last_month as
(select
--TOP FOCUS
case when r.requisition_name like '%Territory Account Manager%' then 'Territory Account Managers'
      when r.requisition_name like '%District Sales Manager%' then 'District Sales Managers'
      when r.requisition_name = 'General Manager' OR r.requisition_name = 'General Manager - Advanced Solutions' then 'General Managers'
      when r.requisition_name like '%Service Manager%' then 'Service Managers'
      when r.requisition_name like '%Service Technician%' OR r.requisition_name like '%Field Technician%' OR r.requisition_name like '%Diesel Technician%' OR r.requisition_name like '%Shop Technician%' then 'Techs'
      when r.requisition_name like '%CDL%' then 'CDL Delivery Drivers'
      when r.requisition_name like '%District Operations%' and r.requisition_name not like '%Assistant%' then 'District Operations Managers'
      else null end as top_focus,
r.requisition_id,
r.requisition_name,
r.requisition_status,
f.application_requisition_offer_job_created_date,
f.application_requisition_offer_job_closed_date,
f.application_requisition_offer_offer_resolved_date,
f.application_requisition_offer_offer_sent_date,
f.application_requisition_offer_offer_key,
o.offer_status,
a.application_status,
case when (o.offer_status = 'accepted' and
f.application_requisition_offer_offer_resolved_date >= dateadd(day,-(day(current_date)-2),dateadd(month,-1,current_date))) or
o.offer_status <> 'accepted'
then 'Include'
else 'Exclude' end as include_
from PEOPLE_ANALYTICS.GREENHOUSE.V_FACT_APPLICATION_REQUISITION_OFFER f
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_REQUISITION r on f.application_requisition_offer_requisition_key = r.requisition_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_OFFER o on f.application_requisition_offer_offer_key = o.offer_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_APPLICATION a on f.application_requisition_offer_application_key = a.application_key
where
top_focus is not null and
r.requisition_custom_type = 'Active Requisition' and
r.requisition_status = 'open' and
f.application_requisition_offer_job_created_date <= dateadd(day,-(day(current_date)+15),dateadd(month,-1,current_date))
order by f.application_requisition_offer_offer_resolved_date desc
)

select
top_focus,
count(distinct case when include_ = 'Exclude' then requisition_id
else null end) as excluded_reqs,
count(distinct(requisition_id)) as total_reqs,
total_reqs - excluded_reqs as included_open_reqs
from still_open_reqs_beginning_of_last_month
group by top_focus),



--REQS THAT ARE CLOSED CURRENTLY BUT WERE OPEN AS OF THE FIRST DAY OF LAST MONTH
--AND WERE OPENED 15 DAYS OR MORE PRIOR TO THE FIRST DAY OF THE CURRENT MONTH
--AND DIDN"T HAVE AN OFFER ACCEPTED TIED TO THEM
closed_reqs_as_of_fotm_last_month as
(with all_closed_reqs_first_of_the_month_last_month as
(select
--TOP FOCUS
case when r.requisition_name like '%Territory Account Manager%' then 'Territory Account Managers'
      when r.requisition_name like '%District Sales Manager%' then 'District Sales Managers'
      when r.requisition_name = 'General Manager' OR r.requisition_name = 'General Manager - Advanced Solutions' then 'General Managers'
      when r.requisition_name like '%Service Manager%' then 'Service Managers'
      when r.requisition_name like '%Service Technician%' OR r.requisition_name like '%Field Technician%' OR r.requisition_name like '%Diesel Technician%' OR r.requisition_name like '%Shop Technician%' then 'Techs'
      when r.requisition_name like '%CDL%' then 'CDL Delivery Drivers'
      when r.requisition_name like '%District Operations%' and r.requisition_name not like '%Assistant%' then 'District Operations Managers'
      else null end as top_focus,
r.requisition_id,
r.requisition_name,
r.requisition_status,
f.application_requisition_offer_job_created_date,
f.application_requisition_offer_job_closed_date,
f.application_requisition_offer_offer_resolved_date,
f.application_requisition_offer_offer_key,
o.offer_status,
a.application_status,
case when a.application_status = 'hired' and
f.application_requisition_offer_offer_resolved_date >= dateadd(day,-(day(current_date)-2),dateadd(month,-1,current_date))
then 'Include'
when a.application_status <> 'hired' then 'Include'
else 'Exclude' end as include_
from PEOPLE_ANALYTICS.GREENHOUSE.V_FACT_APPLICATION_REQUISITION_OFFER f
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_REQUISITION r on f.application_requisition_offer_requisition_key = r.requisition_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_OFFER o on f.application_requisition_offer_offer_key = o.offer_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_APPLICATION a on f.application_requisition_offer_application_key = a.application_key
where
top_focus is not null and
r.requisition_status = 'closed' and
f.application_requisition_offer_job_created_date <= dateadd(day,-(day(current_date)+15),dateadd(month,-1,current_date)) and
f.application_requisition_offer_job_closed_date >= dateadd(day,-(day(current_date)-2),dateadd(month,-1,current_date))
group by 1,2,3,4,5,6,7,8,9,10
order by requisition_id)

select
top_focus,
count(distinct case when include_ = 'Exclude' then requisition_id
else null end) as excluded_reqs,
count(distinct(requisition_id)) as total_reqs,
total_reqs - excluded_reqs as included_closed_reqs
from all_closed_reqs_first_of_the_month_last_month
group by top_focus),





--OFFERS ACCEPTED GOALS TWO MONTHS AGO
open_reqs_as_of_fotm_two_months_ago as (


--REQS THAT ARE CURRENTLY OPEN AND OPENED 15 DAYS BEFORE THE BEGINNING OF TWO MONTHS AGO
--AND DIDN'T HAVE AN OFFER ACCEPTED TIED TO THEM
with still_open_reqs_beginning_of_two_months_ago as
(select
--TOP FOCUS
case when r.requisition_name like '%Territory Account Manager%' then 'Territory Account Managers'
      when r.requisition_name like '%District Sales Manager%' then 'District Sales Managers'
      when r.requisition_name = 'General Manager' OR r.requisition_name = 'General Manager - Advanced Solutions' then 'General Managers'
      when r.requisition_name like '%Service Manager%' then 'Service Managers'
      when r.requisition_name like '%Service Technician%' OR r.requisition_name like '%Field Technician%' OR r.requisition_name like '%Diesel Technician%' OR r.requisition_name like '%Shop Technician%' then 'Techs'
      when r.requisition_name like '%CDL%' then 'CDL Delivery Drivers'
      when r.requisition_name like '%District Operations%' and r.requisition_name not like '%Assistant%' then 'District Operations Managers'
      else null end as top_focus,
r.requisition_id,
r.requisition_name,
r.requisition_status,
f.application_requisition_offer_job_created_date,
f.application_requisition_offer_job_closed_date,
f.application_requisition_offer_offer_resolved_date,
f.application_requisition_offer_offer_sent_date,
f.application_requisition_offer_offer_key,
o.offer_status,
a.application_status,
case when (o.offer_status = 'accepted' and
f.application_requisition_offer_offer_resolved_date >= dateadd(day,-(day(current_date)-2),dateadd(month,-2,current_date))) or
o.offer_status <> 'accepted'
then 'Include'
else 'Exclude' end as include_
from PEOPLE_ANALYTICS.GREENHOUSE.V_FACT_APPLICATION_REQUISITION_OFFER f
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_REQUISITION r on f.application_requisition_offer_requisition_key = r.requisition_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_OFFER o on f.application_requisition_offer_offer_key = o.offer_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_APPLICATION a on f.application_requisition_offer_application_key = a.application_key
where
top_focus is not null and
r.requisition_custom_type = 'Active Requisition' and
r.requisition_status = 'open' and
f.application_requisition_offer_job_created_date <= dateadd(day,-(day(current_date)+15),dateadd(month,-2,current_date))
order by f.application_requisition_offer_offer_resolved_date desc
)

select
top_focus,
count(distinct case when include_ = 'Exclude' then requisition_id
else null end) as excluded_reqs,
count(distinct(requisition_id)) as total_reqs,
total_reqs - excluded_reqs as included_open_reqs
from still_open_reqs_beginning_of_two_months_ago
group by top_focus),



--REQS THAT ARE CLOSED CURRENTLY BUT WERE OPEN AS OF THE FIRST DAY OF LAST MONTH
--AND WERE OPENED 15 DAYS OR MORE PRIOR TO THE FIRST DAY OF THE CURRENT MONTH
--AND DIDN"T HAVE AN OFFER ACCEPTED TIED TO THEM
closed_reqs_as_of_fotm_two_months_ago as
(with all_closed_reqs_first_of_the_month_two_months_ago as
(select
--TOP FOCUS
case when r.requisition_name like '%Territory Account Manager%' then 'Territory Account Managers'
      when r.requisition_name like '%District Sales Manager%' then 'District Sales Managers'
      when r.requisition_name = 'General Manager' OR r.requisition_name = 'General Manager - Advanced Solutions' then 'General Managers'
      when r.requisition_name like '%Service Manager%' then 'Service Managers'
      when r.requisition_name like '%Service Technician%' OR r.requisition_name like '%Field Technician%' OR r.requisition_name like '%Diesel Technician%' OR r.requisition_name like '%Shop Technician%' then 'Techs'
      when r.requisition_name like '%CDL%' then 'CDL Delivery Drivers'
      when r.requisition_name like '%District Operations%' and r.requisition_name not like '%Assistant%' then 'District Operations Managers'
      else null end as top_focus,
r.requisition_id,
r.requisition_name,
r.requisition_status,
f.application_requisition_offer_job_created_date,
f.application_requisition_offer_job_closed_date,
f.application_requisition_offer_offer_resolved_date,
f.application_requisition_offer_offer_key,
o.offer_status,
a.application_status,
case when a.application_status = 'hired' and
f.application_requisition_offer_offer_resolved_date >= dateadd(day,-(day(current_date)-2),dateadd(month,-2,current_date))
then 'Include'
when a.application_status <> 'hired' then 'Include'
else 'Exclude' end as include_
from PEOPLE_ANALYTICS.GREENHOUSE.V_FACT_APPLICATION_REQUISITION_OFFER f
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_REQUISITION r on f.application_requisition_offer_requisition_key = r.requisition_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_OFFER o on f.application_requisition_offer_offer_key = o.offer_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_APPLICATION a on f.application_requisition_offer_application_key = a.application_key
where
top_focus is not null and
r.requisition_status = 'closed' and
f.application_requisition_offer_job_created_date <= dateadd(day,-(day(current_date)+15),dateadd(month,-2,current_date)) and
f.application_requisition_offer_job_closed_date >= dateadd(day,-(day(current_date)-2),dateadd(month,-2,current_date))
group by 1,2,3,4,5,6,7,8,9,10
order by requisition_id)

select
top_focus,
count(distinct case when include_ = 'Exclude' then requisition_id
else null end) as excluded_reqs,
count(distinct(requisition_id)) as total_reqs,
total_reqs - excluded_reqs as included_closed_reqs
from all_closed_reqs_first_of_the_month_two_months_ago
group by top_focus),




oe_oa_ratio as (

select

--TOP FOCUS
case when r.requisition_name like '%Territory Account Manager%' then 'Territory Account Managers'
      when r.requisition_name like '%District Sales Manager%' then 'District Sales Managers'
      when r.requisition_name = 'General Manager' OR r.requisition_name = 'General Manager - Advanced Solutions' then 'General Managers'
      when r.requisition_name like '%Service Manager%' then 'Service Managers'
      when r.requisition_name like '%Service Technician%' OR r.requisition_name like '%Field Technician%' OR r.requisition_name like '%Diesel Technician%' OR r.requisition_name like '%Shop Technician%' then 'Techs'
      when r.requisition_name like '%CDL%' then 'CDL Delivery Drivers'
      when r.requisition_name like '%District Operations%' and r.requisition_name not like '%Assistant%' then 'District Operations Managers'
      else null end as top_focus,

--OFFERS ACCEPTED YTD
count(distinct
case when o.offer_status = 'accepted' and
r.requisition_custom_type = 'Active Requisition' and
year(date(f.application_requisition_offer_offer_resolved_date)) = year(current_date)
then o.offer_id
else null end) as offers_accepted_ytd,

--OFFERS EXTENDED YTD
count(distinct
case when o.offer_status <> 'deprecated' and
r.requisition_custom_type = 'Active Requisition' and
year(date(f.application_requisition_offer_offer_sent_date)) = year(current_date)
then o.offer_id
else null end) as offers_extended_ytd
from PEOPLE_ANALYTICS.GREENHOUSE.V_FACT_APPLICATION_REQUISITION_OFFER f
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_REQUISITION r on f.application_requisition_offer_requisition_key = r.requisition_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_OFFER o on f.application_requisition_offer_offer_key = o.offer_key
inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_APPLICATION a on f.application_requisition_offer_application_key = a.application_key
group by top_focus
),



top_focus as (SELECT TOP_FOCUS
FROM (
  VALUES
    ('Territory Account Managers'),
    ('District Sales Managers'),
    ('Techs'),
    ('General Managers'),
    ('CDL Delivery Drivers'),
    ('Service Managers'),
    ('District Operations Managers')
) v(TOP_FOCUS))



select
tf.top_focus,
case when ora.included_open_reqs is null then 0
else ora.included_open_reqs end as included_open_reqs_cm,
case when cr.included_closed_reqs is null then 0
else cr.included_closed_reqs end as included_closed_reqs_cm,
included_open_reqs_cm + included_closed_reqs_cm as OFFERS_ACCEPTED_GOAL_CURRENT_MONTH,
case when tf.top_focus = 'Territory Account Managers' then 0.28
when tf.top_focus = 'District Sales Managers' then 0.00
when tf.top_focus = 'Techs' then 0.41
when tf.top_focus = 'General Managers' then 0.34
when tf.top_focus = 'CDL Delivery Drivers' then 0.22
when tf.top_focus = 'Service Managers' then 0.23
when tf.top_focus = 'District Operations Managers' then 0.11
else null end
as fall_out_rate,


case when orlm.included_open_reqs is null then 0
else orlm.included_open_reqs end as included_open_reqs_lm,
case when crlm.included_closed_reqs is null then 0
else crlm.included_closed_reqs end as included_closed_reqs_lm,
included_open_reqs_lm + included_closed_reqs_lm as OFFERS_ACCEPTED_GOAL_LAST_MONTH,

case when ortma.included_open_reqs is null then 0
else ortma.included_open_reqs end as included_open_reqs_tma,
case when crtma.included_closed_reqs is null then 0
else crtma.included_closed_reqs end as included_closed_reqs_tma,
included_open_reqs_tma + included_closed_reqs_tma as OFFERS_ACCEPTED_GOAL_TWO_MONTHS_AGO,

from top_focus tf
left join open_reqs_as_of_fotm ora on tf.top_focus = ora.top_focus
left join closed_reqs_as_of_fotm cr on tf.top_focus = cr.top_focus
left join open_reqs_as_of_fotm_last_month orlm on tf.top_focus = orlm.top_focus
left join closed_reqs_as_of_fotm_last_month crlm on tf.top_focus = crlm.top_focus
left join open_reqs_as_of_fotm_two_months_ago ortma on tf.top_focus = ortma.top_focus
left join closed_reqs_as_of_fotm_two_months_ago crtma on tf.top_focus = crtma.top_focus
left join oe_oa_ratio oe_oa on tf.top_focus = oe_oa.top_focus;;
  }


  dimension: top_focus {
    type: string
    sql: ${TABLE}."TOP_FOCUS";;
  }

  dimension: fall_out_rate {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}."FALL_OUT_RATE" ;;
  }

  dimension: offers_accepted_goal_current_month {
    type: number
    sql: case when ${TABLE}."OFFERS_ACCEPTED_GOAL_CURRENT_MONTH" is null then 0
    else ${TABLE}."OFFERS_ACCEPTED_GOAL_CURRENT_MONTH" end;;
  }

  dimension: offers_extended_goal_current_month {
    type: number
    sql: case when round(${offers_accepted_goal_current_month}*(1+${fall_out_rate})) is null then 0
    else round(${offers_accepted_goal_current_month}*(1+${fall_out_rate})) end;;
  }

  dimension: offers_accepted_goal_last_month {
    type: number
    sql: case when ${TABLE}."OFFERS_ACCEPTED_GOAL_LAST_MONTH" is null then 0
    else ${TABLE}."OFFERS_ACCEPTED_GOAL_LAST_MONTH" end;;
  }

  dimension: offers_extended_goal_last_month {
    type: number
    sql: case when round(${offers_accepted_goal_last_month}*(1+${fall_out_rate})) is null then 0
    else round(${offers_accepted_goal_last_month}*(1+${fall_out_rate})) end;;
  }

  dimension: offers_accepted_goal_two_months_ago {
    type: number
    sql: case when ${TABLE}."OFFERS_ACCEPTED_GOAL_TWO_MONTHS_AGO" is null then 0
    else ${TABLE}."OFFERS_ACCEPTED_GOAL_TWO_MONTHS_AGO" end;;
  }

  dimension: offers_extended_goal_two_months_ago {
    type: number
    sql: case when round(${offers_accepted_goal_two_months_ago}*(1+${fall_out_rate})) is null then 0
    else round(${offers_accepted_goal_two_months_ago}*(1+${fall_out_rate})) end;;
  }

  dimension: percent_complete_with_current_month {
    type: number
    sql: round(day(current_date)/day(last_day(current_date)),4) ;;
  }


}
