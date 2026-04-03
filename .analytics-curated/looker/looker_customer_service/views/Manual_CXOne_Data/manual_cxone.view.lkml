view: manual_cxone {
    derived_table: {
      sql: with distinct_numbers as (
 select
  u.date_created
, u.user_id
, u.company_id
, u.username
, concat(u.first_name,' ',u.last_name) as full_name
, u.email_address
, regexp_replace(phone_number,'[^\\d]*') as trimed_phone_number
, RANK() OVER ( partition by regexp_replace(phone_number,'[^\\d]*') ORDER BY date_created DESC ) as most_recent_entry
from es_warehouse.public.users u
where phone_number != '555-555-5555'
and deleted = false
)
, pre_call_count as (
SELECT mcd.*
      , case when TRY_CAST(mcd."Contact_Name" as INTEGER)= 8336541665 then 'Branch Rollover' else 'Other' end as branch_rollover_status
      , timestamp_ntz_from_parts(mcd."Start_Date", mcd."start_time")::datetime as contact_start_date_time
      , hour(to_time(mcd."start_time")) as start_hour
      , concat(year(to_date(mcd."Start_Date")),'-',lpad(month(to_date(mcd."Start_Date")),2,'0')) as year_month

      , RANK() OVER ( partition by "Master_Contact_ID" ORDER BY timestamp_ntz_from_parts(mcd."Start_Date", mcd."start_time") ) as segment_order
      FROM ANALYTICS.CXONE_API.MANUAL_IMPORT_CALL_DETAILS mcd
      order by "Master_Contact_ID", "Start_Date" desc,"start_time"
      )
      select pre.*
      , coalesce(ui.user_id, uo.user_id) as user_id
      , coalesce(ui.company_id, uo.company_id) as customer_company_id
      , coalesce(ci.name, co.name) as customer_company_name
      , coalesce(ui.username, uo.username) as customer_username
      , coalesce(ui.full_name, uo.full_name) as customer_full_name
      , coalesce(ui.email_address, uo.email_address) as customer_email_address
      , coalesce(ui.trimed_phone_number,uo.trimed_phone_number) as customer_phone_number
      , case when segment_order = 1 then 'Primary Call' else 'Transfer' end as Segment_Type
      , case
        when right(trim("Skill_Name"),2) = 'OB' and segment_order = 1 then 'Outbound'
        when segment_order > 1 then 'Transfer'
        else 'Inbound' end as Call_Direction
      , case when segment_order = 1 then 1 else 0 end as Primary_Call
      , case when segment_order > 1 then 1 else 0 end as Transfer
      , 'Not Yet Available' as TAM
      , 'Not Yet Available' as DSM
      , case when ar.Reason is null then 'Not Refused' else ar.Reason end as agent_refusal_reason
      from pre_call_count pre
      left join distinct_numbers ui on ui.trimed_phone_number = pre.ani_dialnum and pre.ani_dialnum not in ('8888073687') and ui.most_recent_entry = 1 and right(trim("Skill_Name"),2) != 'OB'
      left join distinct_numbers uo on uo.trimed_phone_number = pre."Contact_Name" and pre."Contact_Name" not in ('8888073687') and uo.most_recent_entry = 1 and
      right(trim("Skill_Name"),2) = 'OB' and transfer != 1
      left join es_warehouse.public.companies ci on ui.company_id = ci.company_id
      left join es_warehouse.public.companies co on uo.company_id = co.company_id
      left join ANALYTICS.CXONE_API.MANUAL_IMPORT_AGENT_REFUSAL ar on ar.contact_id = pre."Contact_ID"
        ;;
    }

    measure: count {
       label: "Call Count"
       type: count
       drill_fields: [detail*]
    }

    measure: Primary_Call {
      type: sum
      sql:  ${TABLE}."PRIMARY_CALL" ;;
    }

    measure: Transfer {
      type: sum
      sql: ${TABLE}."TRANSFER" ;;
    }

    dimension: index {
      type: string
      sql: ${TABLE}."index" ;;
    }

    dimension: Segment_Type {
      type: string
      sql: ${TABLE}."SEGMENT_TYPE" ;;
    }

    dimension: Customer_TAM{
      type: string
      sql: ${TABLE}."TAM" ;;
    }

    dimension: Customer_DSM{
      type: string
      sql: ${TABLE}."DSM" ;;
    }

    dimension: agent_refusal_reason {
      type: string
      sql: ${TABLE}."AGENT_REFUSAL_REASON" ;;
    }

    dimension: year_month {
      type: string
      sql: ${TABLE}."YEAR_MONTH" ;;
    }

     dimension: user_id {
       type: string
      sql: ${TABLE}."USER_ID" ;;
    }

    dimension: call_direction {
      type: string
      sql: ${TABLE}."CALL_DIRECTION" ;;
    }

    dimension: customer_company_id {
      type: string
      sql: ${TABLE}."CUSTOMER_COMPANY_ID" ;;
    }

    dimension: customer_company_name {
      type: string
      sql: ${TABLE}."CUSTOMER_COMPANY_NAME" ;;
    }

    measure: company_count {
      type: count_distinct
      sql: ${customer_company_name} ;;
    }

    dimension: customer_username {
      type: string
      sql: ${TABLE}."CUSTOMER_USERNAME" ;;
    }

    dimension: customer_full_name {
      type: string
      sql: ${TABLE}."CUSTOMER_FULL_NAME" ;;
    }

    dimension: customer_email_address {
      type: string
      sql: ${TABLE}."CUSTOMER_EMAIL_ADDRESS" ;;
    }

    dimension: customer_phone_number {
      type: string
      sql: ${TABLE}."CUSTOMER_PHONE_NUMBER" ;;
    }

    dimension: contact_id {
      type: string
      sql: ${TABLE}."Contact_ID" ;;
    }

    dimension: master_contact_id {
      type: string
      sql: ${TABLE}."Master_Contact_ID" ;;
    }

    dimension: contact_code {
      type: string
      sql: ${TABLE}."Contact_Code" ;;
    }

    dimension: media_name {
      type: string
      sql: ${TABLE}."Media_Name" ;;
    }

    dimension: contact_name {
      type: string
      sql: ${TABLE}."Contact_Name" ;;
    }

    dimension: ani_dialnum {
      type: string
      sql: ${TABLE}."ANI_DIALNUM" ;;
    }

    dimension: skill_no {
      type: string
      sql: ${TABLE}."Skill_No" ;;
    }

    dimension: skill_name {
      type: string
      sql: ${TABLE}."Skill_Name" ;;
    }

    dimension: campaign_no {
      type: string
      sql: ${TABLE}."Campaign_No" ;;
    }

    dimension: campaign_name {
      type: string
      sql: ${TABLE}."Campaign_Name" ;;
    }

    dimension: agent_no {
      type: string
      sql: ${TABLE}."Agent_No" ;;
    }

    dimension: agent_name {
      type: string
      sql: ${TABLE}."Agent_Name" ;;
    }

    dimension: team_no {
      type: string
      sql: ${TABLE}."Team_No" ;;
    }

    dimension: team_name {
      type: string
      sql: ${TABLE}."Team_Name" ;;
    }

    dimension: sla {
      type: string
      sql: ${TABLE}."SLA" ;;
    }

    dimension: start_date {
      type: date
      sql: ${TABLE}."Start_Date" ;;
    }

    dimension: start_time {
      type: string
      sql: ${TABLE}."start_time" ;;
    }

    dimension: contact_start_date_time {
     type: date_time
     sql: ${TABLE}."CONTACT_START_DATE_TIME" ;;
    }

    dimension_group: contact_start {
      type: time
      sql: ${TABLE}."CONTACT_START_DATE_TIME";;
    }

   dimension: start_hour {
     type: number
     sql: ${TABLE}."START_HOUR" ;;
   }

    dimension: pre_queue {
      type: number
      sql: ${TABLE}."PreQueue" ;;
    }

   measure: pre_queue_sum {
     group_label: "time sums"
     type: sum
     sql:  ${pre_queue} ;;
    }

   measure: pre_queue_avg {
     group_label: "time averages"
     type: average
     sql:  ${pre_queue} ;;
   }

    dimension: in_queue {
      type: number
      sql: ${TABLE}."InQueue" ;;
    }

    measure: in_queue_sum {
      group_label: "time sums"
      type: sum
      sql:  ${in_queue} ;;
    }

    measure: in_queue_avg {
      group_label: "time averages"
      type: average
      sql:  ${in_queue} ;;
    }

    dimension: agent_time {
      type: number
      sql: ${TABLE}."Agent_Time" ;;
    }

    measure: agent_time_sum {
      group_label: "time sums"
      type: sum
      sql:  ${in_queue} ;;
    }

    measure: agent_time_avg {
      group_label: "time averages"
      type: average
      sql:  ${in_queue} ;;
    }

    dimension: post_queue {
      type: number
      sql: ${TABLE}."PostQueue" ;;
    }

    measure: post_queue_sum {
      group_label: "time sums"
      type: sum
      sql:  ${post_queue} ;;
    }

    measure: post_queue_avg {
      group_label: "time averages"
      type: average
      sql:  ${post_queue} ;;
    }

    dimension: acw_time {
      type: number
      sql: ${TABLE}."ACW_Time" ;;
    }

    measure: acw_time_sum {
      group_label: "time sums"
      type: sum
      sql:  ${acw_time} ;;
    }

    measure: acw_time_avg {
      group_label: "time averages"
      type: average
      sql:  ${acw_time} ;;
    }

    dimension: total_time_plus_disposition {
      type: number
      sql: ${TABLE}."Total_Time_Plus_Disposition" ;;
    }

    measure: total_time_plus_disposition_sum {
      group_label: "time sums"
      type: sum
      sql:  ${total_time_plus_disposition} ;;
    }

    measure: total_time_plus_disposition_avg {
      group_label: "time averages"
      type: average
      sql:  ${total_time_plus_disposition} ;;
    }

    dimension: abandon_time {
      type: number
      sql: ${TABLE}."Abandon_Time" ;;
    }

    measure: abandon_time_sum {
      group_label: "time sums"
      type: sum
      sql:  ${abandon_time} ;;
    }

    measure: abandon_time_avg {
      group_label: "time averages"
      type: average
      sql:  ${abandon_time} ;;
    }

    dimension: routing_time {
      type: number
      sql: ${TABLE}."Routing_Time" ;;
    }

    measure: routing_time_sum {
      group_label: "time sums"
      type: sum
      sql:  ${routing_time} ;;
    }

    measure: routing_time_avg {
      group_label: "time averages"
      type: average
      sql:  ${routing_time} ;;
    }

    dimension: abandon {
      type: string
      sql: ${TABLE}."Abandon" ;;
    }

    dimension: callback_time {
      type: number
      sql: ${TABLE}."Callback_Time" ;;
    }

    measure: callback_time_sum {
      group_label: "time sums"
      type: sum
      sql:  ${callback_time} ;;
    }

    measure: callback_time_avg {
      group_label: "time averages"
      type: average
      sql:  ${callback_time} ;;
    }

    dimension: logged {
      type: string
      sql: ${TABLE}."Logged" ;;
    }

    dimension: hold_time {
      type: number
      sql: ${TABLE}."Hold_Time" ;;
    }

    measure: hold_time_sum {
      group_label: "time sums"
      type: sum
      sql:  ${hold_time} ;;
    }

    measure: hold_time_avg {
      group_label: "time averages"
      type: average
      sql:  ${hold_time} ;;
    }

    dimension: disp_code {
      type: string
      sql: ${TABLE}."Disp_Code" ;;
    }

    dimension: disp_name {
      type: string
      sql: ${TABLE}."Disp_Name" ;;
    }

    dimension: disp_comments {
      type: string
      sql: ${TABLE}."Disp_Comments" ;;
    }

    dimension: tags {
      type: string
      sql: ${TABLE}."Tags" ;;
    }

    dimension: calculated_area_code {
      type: string
      sql: ${TABLE}."calculated_area_code" ;;
    }

    dimension: lat {
      type: string
      sql: ${TABLE}."Lat" ;;
    }

    dimension: long {
      type: string
      sql: ${TABLE}."Long" ;;
    }

    dimension: market_name {
      type: string
      sql: ${TABLE}."MARKET_NAME" ;;
    }

    dimension: state {
      type: string
      sql: ${TABLE}."STATE" ;;
    }

    dimension: region_name {
      type: string
      sql: ${TABLE}."REGION_NAME" ;;
    }

    dimension: area_code {
      type: string
      sql: ${TABLE}."AREA_CODE" ;;
    }

    dimension: phone_number {
      type: string
      sql: ${TABLE}."PHONE_NUMBER" ;;
    }

    dimension: latitude {
      type: string
      sql: ${TABLE}."LATITUDE" ;;
    }

    dimension: longitude {
      type: string
      sql: ${TABLE}."LONGITUDE" ;;
    }

    dimension: company_id {
      type: string
      sql: ${TABLE}."COMPANY_ID" ;;
    }

    dimension: zip_code {
      type: string
      sql: ${TABLE}."ZIP_CODE" ;;
    }

    dimension: market_id {
      type: string
      sql: ${TABLE}."MARKET_ID" ;;
    }

    dimension: location_id {
      type: string
      sql: ${TABLE}."LOCATION_ID" ;;
    }

    dimension: distance {
      type: string
      sql: ${TABLE}."distance" ;;
    }

    dimension: branch_rollover_status {
      type: string
      sql: ${TABLE}."BRANCH_ROLLOVER_STATUS" ;;
    }

    dimension: location {
      type: location
      sql_latitude: ${latitude} ;;
      sql_longitude: ${longitude} ;;
    }
    set: detail {
      fields: [
        index,
        contact_id,
        master_contact_id,
        contact_code,
        media_name,
        contact_name,
        ani_dialnum,
        skill_no,
        skill_name,
        campaign_no,
        campaign_name,
        agent_no,
        agent_name,
        team_no,
        team_name,
        sla,
        start_date,
        start_time,
        pre_queue,
        in_queue,
        agent_time,
        post_queue,
        acw_time,
        total_time_plus_disposition,
        abandon_time,
        routing_time,
        abandon,
        callback_time,
        logged,
        hold_time,
        disp_code,
        disp_name,
        disp_comments,
        tags,
        calculated_area_code,
        lat,
        long,
        market_name,
        state,
        region_name,
        area_code,
        phone_number,
        latitude,
        longitude,
        company_id,
        zip_code,
        market_id,
        location_id,
        distance,
        branch_rollover_status,
        location
      ]
    }
  }
