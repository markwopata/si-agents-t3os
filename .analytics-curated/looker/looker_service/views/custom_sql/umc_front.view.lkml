view: umc_front {
  derived_table: {
    sql: with uptime_center_tags as (
select
    tag_id,
    tag_name,
    parent_tag_id,
    case
        when parent_tag_id = 'tag_txawz' then 'Accepted'
        when parent_tag_id = 'tag_12aooz' then 'Case Status'
        when parent_tag_id = 'tag_11z7pf' then 'Megasites'
        when parent_tag_id = 'tag_10eqo3' then 'Priority'
        when parent_tag_id = 'tag_yc6ir' then 'Sentiment'
        when parent_tag_id = 'tag_11kuyr' then 'Problem Cluster'
        when parent_tag_id = 'tag_ydvwj' then 'Topic Categorization'
        when parent_tag_id = 'tag_12aohv' then 'Case Type'
        when tag_id in ('tag_10w05f','tag_10w077') then 'Case Status'
        when tag_id in ('tag_12moub') then 'Retool'
        else null
    end as parent_tag_name
from people_analytics.algorithms_inferences.front_uptime_center_tag
)

,tag_history as (
select
    th.tag_id,
    t.tag_name,
    t.parent_tag_id,
    t.parent_tag_name,
    th.conversation_id,
    th.updated_at as tagged_date,
    lead(updated_at) over (partition by tag_id,conversation_id order by updated_at) as untagged_date,
    lead(event_type) over (partition by tag_id,conversation_id order by updated_at) as untagged_checked,
    iff(untagged_checked is null,true,false) as active
from people_analytics.algorithms_inferences.front_uptime_center_conversation_tag_history th
join uptime_center_tags t
    using(tag_id)
qualify event_type = 'tag'
)

,case_type as(
select
    tag_name as case_type,
    conversation_id,
    tagged_date
from tag_history
where parent_tag_name = 'Case Type'
and active
qualify row_number() over (partition by conversation_id order by tagged_date desc) = 1
)

,case_status as(
select
    tag_name as case_status,
    conversation_id,
    tagged_date
from tag_history
where parent_tag_name = 'Case Status'
and active
qualify row_number() over (partition by conversation_id order by tagged_date desc) = 1
)
,retool_tagged as(
select
    tag_name as case_status,
    conversation_id,
    tagged_date
from tag_history
where parent_tag_name = 'Retool'
and active
qualify row_number() over (partition by conversation_id order by tagged_date desc) = 1
)
,branch_accepted as(
select
    tag_name,
    conversation_id,
    tagged_date
from tag_history
where parent_tag_name = 'Accepted'
and active
qualify row_number() over (partition by conversation_id order by tagged_date desc) = 1
)

,time_in_status as (
select
    conversation_id,
    sum(iff(tag_name = 'Under Investigation',datediff(hour,tagged_date,coalesce(untagged_date,current_timestamp)),null)) as under_investigation,
    sum(iff(tag_name = 'Follow-Up Required',datediff(hour,tagged_date,coalesce(untagged_date,current_timestamp)),null)) as follow_up_required,
    sum(iff(tag_name = 'Waiting for Response',datediff(hour,tagged_date,coalesce(untagged_date,current_timestamp)),null)) as waiting_for_response
    ,sum(iff(tag_name = 'Pending Repair',datediff(hour,tagged_date,coalesce(untagged_date,current_timestamp)),null)) as pending_repair
    ,sum(iff(tag_name = 'Dealer Repair',datediff(hour,tagged_date,coalesce(untagged_date,current_timestamp)),null)) as dealer_repair
    ,sum(iff(tag_name = 'Unresolved after Escalation',datediff(hour,tagged_date,coalesce(untagged_date,current_timestamp)),null)) as unresolved_after_escalation
from tag_history
where parent_tag_name = 'Case Status'
group by conversation_id
)
,notes as (
select
    conversation_id,
    listagg(body,'. \n\n') as notes
from people_analytics.algorithms_inferences.front_uptime_center_comment
group by conversation_id
)
,conversations as (
select
    date(dateadd(hour,-5,c.conversation_created_at)) as date_identified,
    try_to_number(nullif(split_part(split_part(coalesce(nullif(split_part(c.conversation_subject,': ',3),''),split_part(c.conversation_subject,': ',2)),' ',1),'.',1),'')) as asset,
    try_to_number(split_part(c.conversation_subject,' ',2)) as asset_t,
    iff(REGEXP_LIKE(asset, '[a-zA-Z]'),null,asset) as asset_tt,
    iff(REGEXP_LIKE(asset_t, '[a-zA-Z]'),null,asset_t) as asset_ttt,
    coalesce(asset_tt,asset_ttt)as asset_id,
    c.conversation_id,
    c.conversation_subject,
    iff(conversation_subject ilike '%test%',false,true) as test_flag
from people_analytics.algorithms_inferences.front_uptime_center_conversation c
where inbox_id = 'inb_27d4z'
and test_flag
and conversation_id not in ('cnv_jzqn64j','cnv_itkl1z7','cnv_ipj5jnn','cnv_ipjbglf','cnv_ipiz9j7','cnv_ipj0xab','cnv_ipj3rur','cnv_ipj85z7','cnv_iq7qdqb','cnv_iq7b1qb','cnv_iq7av5v','cnv_iqmzz2b','cnv_iw6a85f')
)

,conversations_mmy as (
select
    c.date_identified,
    c.asset_id,
    a.asset_equipment_make as make,
    a.asset_equipment_model_name as model,
    asset_year as year,
    c.conversation_id,
    c.conversation_subject,
    m.service_email as branch_email,
    m.name as branch_name
from conversations c
left join platform.gold.v_assets a
    using(asset_id)
left join es_warehouse.public.markets m
    on a.asset_service_market_id = m.market_id
)
,retool_convos as
(
SELECT DISTINCT
  t.conversation_id,
  f.value::STRING AS alert_key
FROM PEOPLE_ANALYTICS.ALGORITHMS_INFERENCES.front_uptime_center_message t,
LATERAL FLATTEN(
  INPUT => REGEXP_SUBSTR_ALL(
    COALESCE(SPLIT_PART(t.text, 'Alert Key(s):', 2), ''),
    '[0-9a-fA-F]{64}'
  )
) f
)
,retool_first_contacted as
(
SELECT rc.conversation_id, min(t.created_at) as first_contacted
FROM retool_convos rc
JOIN PEOPLE_ANALYTICS.ALGORITHMS_INFERENCES.front_uptime_center_message t
    USING(conversation_id)
GROUP BY rc.conversation_id
)
,retool_alerts as (
select
    date(dateadd(hour,-5,uas.ALERT_DATE)) as date_identified,
    uas.ASSET_ID,
    a.asset_equipment_make as make,
    a.asset_equipment_model_name as model,
    a.asset_year as year,
    ALERT_KEY,
    ALERT_KEY_LEGACY,
    ALERT_ID,
    CONCAT(ALERT_TYPE, ' Alert: ', uas.ASSET_ID) AS alert_subject,
    'Retool Alerts' as case_type,
    NULL as date_contacted,
    NULL as response_acknowledged,
    NULL as date_of_response,
    null as branch_response_summary,
    ALERT_STATUS,
    iff(uas.ALERT_STATUS IN ('Resolved','Internal Missed Opportunity','External Missed Opportunity'), uas.START_DATE::date,null) as date_of_resolution,
    m.service_email as branch_email,
    m.name as branch_name
from ANALYTICS.SERVICE.UPTIME_ALERT_STATUS uas
left join platform.gold.v_assets a
    using(asset_id)
left join es_warehouse.public.markets m
    on a.asset_service_market_id = m.market_id
WHERE IS_CURRENT = True
)
,retool_time_in_status as
(
select
    uas.ALERT_ID,
    sum(iff(ALERT_STATUS = 'Under Investigation',datediff(hour,uas.START_DATE,IFF(END_DATE = '2999-01-01 00:00:00.000000000 +00:00', current_timestamp, END_DATE)),null)) as under_investigation,
    sum(iff(ALERT_STATUS = 'Follow-up Required',datediff(hour,uas.START_DATE,IFF(END_DATE = '2999-01-01 00:00:00.000000000 +00:00', current_timestamp, END_DATE)),null)) as follow_up_required,
    sum(iff(ALERT_STATUS = 'Waiting for Response',datediff(hour,uas.START_DATE,IFF(END_DATE = '2999-01-01 00:00:00.000000000 +00:00', current_timestamp, END_DATE)),null)) as waiting_for_response
    ,sum(iff(ALERT_STATUS = 'Pending Repair',datediff(hour,uas.START_DATE,IFF(END_DATE = '2999-01-01 00:00:00.000000000 +00:00', current_timestamp, END_DATE)),null)) as pending_repair
    ,sum(iff(ALERT_STATUS = 'Dealer Repair',datediff(hour,uas.START_DATE,IFF(END_DATE = '2999-01-01 00:00:00.000000000 +00:00', current_timestamp, END_DATE)),null)) as dealer_repair
    ,sum(iff(ALERT_STATUS = 'Unresolved after Escalation',datediff(hour,uas.START_DATE,IFF(END_DATE = '2999-01-01 00:00:00.000000000 +00:00', current_timestamp, END_DATE)),null)) as unresolved_after_escalation
    --,sum(iff(ALERT_STATUS = 'No Action Required',datediff(hour,uas.START_DATE,IFF(END_DATE = '2999-01-01 00:00:00.000000000 +00:00', current_timestamp, END_DATE)),null)) as no_action_required
from ANALYTICS.SERVICE.UPTIME_ALERT_STATUS uas
GROUP BY  uas.ALERT_ID
)
,
retool_notes as
(
select
    ALERT_KEY,
    listagg(NOTE,'. \n\n') as notes
from ANALYTICS.SERVICE.UPTIME_ALERT_NOTES uan
group by ALERT_KEY
)
select
    c.date_identified,
    c.asset_id,
    c.make,
    c.model,
    c.year,
    c.conversation_id,
    c.conversation_subject,
    c.conversation_id as alert_identifier,
    c.conversation_subject as alert_subject,
    ct.case_type,
    iff(ct.case_type = 'Branch Escalation',ct.tagged_date,null) as date_contacted,
    iff(ba.conversation_id is not null,true,false)as response_acknowledged,
    ba.tagged_date::date as date_of_response,
    ba.tag_name as branch_response_summery,
    cs.case_status,
    iff(cs.case_status IN ('Resolved','Internal Missed Opportunity','External Missed Opportunity'),cs.tagged_date::date,null) as date_of_resolution,
    c.branch_email,
    n.notes,
    tis.under_investigation,
    tis.follow_up_required,
    tis.waiting_for_response,
    tis.pending_repair,
    tis.dealer_repair,
    tis.unresolved_after_escalation,
    c.branch_name
from conversations_mmy c
left join case_type ct
    using(conversation_id)
left join case_status cs
    using(conversation_id)
left join branch_accepted ba
    using(conversation_id)
left join notes n
    using(conversation_id)
left join time_in_status tis
    using(conversation_id)
left join retool_tagged rt
    using (conversation_id)
where rt.conversation_id is null
--AND date_identified >= dateadd(day, -1, current_timestamp)
-- and case_status <> 'No Action Required'
UNION
SELECT  ra.date_identified,
    ra.ASSET_ID,
    ra.make,
    ra.model,
    ra.year,
    c.conversation_id,
    c.conversation_subject,
    COALESCE(c.conversation_id, ra.alert_id::string) as alert_identifier,
    COALESCE(c.conversation_subject, ra.alert_subject) as alert_subject,
    COALESCE(ct.case_type,IFF(rc.conversation_id is not null, 'Branch Escalation', 'Internal Investigation')) as case_type,
    rfc.first_contacted::date as date_contacted,
    iff(ba.conversation_id is not null,true,false)as response_acknowledged,
    ba.tagged_date::date as date_of_response,
    ba.tag_name as branch_response_summery,
    ra.alert_status as case_status,
    ra.date_of_resolution,
    ra.branch_email,
    notes,
    rtis.under_investigation,
    rtis.follow_up_required,
    rtis.waiting_for_response,
    rtis.pending_repair,
    rtis.dealer_repair,
    rtis.unresolved_after_escalation,
    ra.branch_name
FROM retool_alerts ra
left join retool_time_in_status rtis
    using(alert_id)
left join retool_notes rn
    on rn.ALERT_KEY = ra.ALERT_KEY
left join retool_convos rc
    on rc.alert_key = COALESCE(ra.alert_key_legacy, ra.alert_key)
left join conversations_mmy c
    USING (conversation_id)
left join case_type ct
    using(conversation_id)
left join case_status cs
    using(conversation_id)
left join branch_accepted ba
    using(conversation_id)
left join retool_first_contacted rfc
    using(conversation_id)
;;
  }
  dimension_group: date_identified {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${TABLE}."DATE_IDENTIFIED" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }
  dimension: conversation_id {
    type: string
    sql: ${TABLE}."CONVERSATION_ID" ;;
  }
  dimension: subject {
    type: string
    sql: ${TABLE}."ALERT_SUBJECT";;
  }
  dimension: alert_identifier {
    type: string
    sql: ${TABLE}."ALERT_IDENTIFIER" ;;
  }
  dimension: case_type {
    type: string
    sql: ${TABLE}."CASE_TYPE" ;;
  }
  dimension_group: date_contaced {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${TABLE}."DATE_CONTACTED" ;;
  }
  dimension: response_acknowledge {
    type: yesno
    sql: ${TABLE}."RESPONSE_ACKNOWLEDGED" ;;
  }
  dimension_group: date_of_response {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${TABLE}."DATE_OF_RESPONSE" ;;
  }
  dimension: branch_response_summary {
    type: string
    sql: ${TABLE}."BRANCH_RESPONSE_SUMMERY" ;;
  }
  dimension: case_status {
    type: string
    sql: ${TABLE}."CASE_STATUS" ;;
  }
  dimension: case_status_order {
    type: number
    sql: case
          when ${case_status} = 'Under Investigation' then 1
          when ${case_status} = 'Waiting for Response' then 2
          when ${case_status} = 'Follow-up Required' then 3
          when ${case_status} = 'Follow-Up Required' then 3
          when ${case_status} = 'Pending Repair' then 4
          when ${case_status} = 'Dealer Repair' then 5
          when ${case_status} = 'Unresolved after Escalation' then 6
          when ${case_status} = 'Internal Missed Opportunity' then 7
          when ${case_status} = 'External Missed Opportunity' then 8
          when ${case_status} = 'Resolved' then 9
          else null
          end;;
  }
  dimension_group: date_of_resolution {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${TABLE}."DATE_OF_RESOLUTION" ;;
  }
  dimension: branch_email {
    type: string
    sql: ${TABLE}."BRANCH_EMAIL" ;;
  }
  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }
  dimension: under_investigation_tis {
    type: number
    sql: ${TABLE}."UNDER_INVESTIGATION" ;;
  }
  dimension: waiting_for_response_tis {
    type: number
    sql: ${TABLE}."WAITING_FOR_RESPONSE" ;;
  }
  dimension: follow_up_required_tis {
    type: number
    sql: ${TABLE}."FOLLOW_UP_REQUIRED" ;;
  }
  dimension: pending_repair_tis {
    type: number
    sql: ${TABLE}."PENDING_REPAIR" ;;
  }
  dimension: dealer_repair_tis {
    type: number
    sql: ${TABLE}."DEALER_REPAIR" ;;
  }
  dimension: unresolved_after_escalation_tis {
    type: number
    sql: ${TABLE}."UNRESOLVED_AFTER_ESCALATION" ;;
  }
  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }
  measure: count_conversations {
    type: count_distinct
    sql: ${alert_identifier} ;;
    drill_fields: [drill*]
  }
  measure: avg_tis_waiting_for_response {
    type: average
    sql: ${waiting_for_response_tis} ;;
    value_format_name: decimal_2
  }
  measure: avg_tis_under_investigation {
    type: average
    sql: ${under_investigation_tis} ;;
    value_format_name: decimal_2
  }
  measure: avg_tis_follow_up_required {
    type: average
    sql: ${follow_up_required_tis} ;;
    value_format_name: decimal_2
  }
  measure: avg_tis_pending_repair {
    type: average
    sql: ${pending_repair_tis} ;;
    value_format_name: decimal_2
  }
  measure: avg_tis_dealer_repair {
    type: average
    sql: ${dealer_repair_tis} ;;
    value_format_name: decimal_2
  }
  measure: avg_tis_unresolved_after_escalation {
    type: average
    sql: ${unresolved_after_escalation_tis} ;;
    value_format_name: decimal_2
  }
  set: drill {
    fields: [date_identified_date,
            asset_id,
            make,
            model,
            year,
            conversation_id,
            subject,
            alert_identifier,
            case_type,
            date_contaced_date,
            response_acknowledge,
            date_of_response_date,
            branch_response_summary,
            case_status,
            date_of_resolution_date,
            branch_email,
            notes]
  }
}
