# The dashboard that this view powers has been moved to the TBD folder: https://equipmentshare.looker.com/folders/13118
# This view can be deleted at the same time as that dashboard.

view: safety_meeting_union_with_tams {
  derived_table: {
    sql: with company_directory_mapping as (
      SELECT cdv.employee_id,
             CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0 then concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name, ' - ', cd.employee_id)
                  ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name)), ' - ', cd.employee_id) END as employee_name,
             cd.WORK_EMAIL as current_work_email,
             cd.EMPLOYEE_STATUS as employee_status,
             cdv.WORK_EMAIL as previous_work_email,
             cdv.EMPLOYEE_TITLE as employee_title,
             case when cd.DATE_HIRED > date_trunc('day', CONVERT_TIMEZONE('America/Chicago', cdv._ES_UPDATE_TIMESTAMP))::date then cd.DATE_HIRED
                  when cd.DATE_REHIRED > cd.DATE_HIRED and cd.DATE_REHIRED > date_trunc('day', CONVERT_TIMEZONE('America/Chicago', cdv._ES_UPDATE_TIMESTAMP))::date then cd.DATE_REHIRED
                  else date_trunc('day', CONVERT_TIMEZONE('America/Chicago', cdv._ES_UPDATE_TIMESTAMP))::date end as record_effective_date,
             cdv._ES_UPDATE_TIMESTAMP,
             cd.MARKET_ID as current_market_id,
             m.name as current_market_name,
             coalesce(mrx.MARKET_TYPE, 'Other') as market_type,
             IFF(REGEXP_LIKE(LEFT(split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 1), 2), 'R[0-9]+'),
                         2, 1) as DCCFP_type,
                     try_to_number(COALESCE(mrx.region::varchar,
                              CASE WHEN DCCFP_type = 1
                                      THEN IFF(REGEXP_LIKE(LEFT(split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 2), 2), 'R[0-9]+'),
                                               IFF(split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 2) NOT LIKE '% %',
                                                   RIGHT(split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 2),
                                                         len(split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 2)) - 1
                                                        ),
                                                   SUBSTR(split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 2), 2,
                                                          CHARINDEX(' ', split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 2)) - 1
                                                         )
                                                  ),
                                               split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 2)
                                              )
                                   WHEN DCCFP_type = 2
                                      THEN IFF(split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 1) NOT LIKE '% %',
                                               RIGHT(split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 1),
                                                     len(split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 1)) - 1
                                                    ),
                                               SUBSTR(split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 1), 2,
                                                      CHARINDEX(' ', split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 1)) - 1
                                                     )
                                              )
                              END
                             ) )    as region_abrv,
                     COALESCE(mrx.district,
                              CASE WHEN DCCFP_type = 1 THEN IFF(REGEXP_LIKE(split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 3), '[0-9]+-[0-9]+'),
                                                                split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 3), null
                                                               )
                                   WHEN DCCFP_type = 2 THEN IFF(REGEXP_LIKE(split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 2), '[0-9]+-[0-9]+'),
                                                                split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', 2), null
                                                               )
                              END
                             ) as district,
                     dr.REGION_NAME as current_region_name,
                     cd.DEFAULT_COST_CENTERS_FULL_PATH
      FROM analytics.payroll.company_directory_vault cdv
      left join analytics.payroll.company_directory cd on cdv.EMPLOYEE_ID = cd.EMPLOYEE_ID
      LEFT JOIN analytics.public.market_region_xwalk mrx ON cd.market_id = mrx.market_id
      LEFT JOIN es_warehouse.public.markets m ON cd.market_id = m.market_id
      left join (select distinct REGION,
                                 REGION_NAME
                 from analytics.public.market_region_xwalk) as dr on region_abrv = dr.REGION
      --WHERE cdv.EMPLOYEE_ID IN (9695
                                     --3712
                                    --, 8212
                                    --, 8131
                                    -- 5043
      --                              )
      where cd.EMPLOYEE_STATUS not in ('Terminated', 'Never Started', 'Not In Payroll', 'On Leave', 'Temporary Worker', 'Contractor', 'Inactive')
            and employee_name not like 'Test%'
            and {% condition market_name_filter_mapping %} m.name {% endcondition %}
            and {% condition district_filter_mapping %} district {% endcondition %}
            and {% condition region_name_filter_mapping %} dr.region_name {% endcondition %}
            and {% condition market_type_filter_mapping %} coalesce(mrx.market_type, 'Other') {% endcondition %}
      QUALIFY ROW_NUMBER() OVER (PARTITION BY cdv.employee_id, cdv.employee_title ORDER BY cdv._ES_UPDATE_TIMESTAMP) = 1
      ),
employee_termination as (
      select cdv2.EMPLOYEE_ID,
             cdv2.DATE_TERMINATED,
             cdv2.EMPLOYEE_TITLE
      from ANALYTICS.PAYROLL.COMPANY_DIRECTORY_VAULT cdv2
qualify rank() over (partition by cdv2.EMPLOYEE_ID, cdv2.EMPLOYEE_TITLE order by cdv2._ES_UPDATE_TIMESTAMP desc) = 1
),
      final_employee_cd_mapping as (
      select cdm.employee_id,
             employee_name,
             cdm.employee_status,
             previous_work_email,
             current_work_email,
             cdm.employee_title,
             cd.employee_title as current_employee_title, --- This is needed to remove employees who are currently in a title that doesn't need to attend the meetings
             IFF(cdm.record_effective_date < cd.date_hired, cd.date_hired, cdm.record_effective_date) as record_effective_date,
             coalesce(et.date_terminated, LEAD(cdm.record_effective_date, 1) OVER
                   (PARTITION BY cdm.employee_id ORDER BY cdm._es_update_timestamp),'12/31/2999') as record_ineffective_date,
             current_market_id as market_id, --- Current market/district/region is being used because we don't care about their previous markets
             current_market_name as market_name,
             market_type,
             cdm.district,
             region_abrv,
             current_region_name as region_name,
             cd.DEFAULT_COST_CENTERS_FULL_PATH
      from company_directory_mapping cdm
      left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd on cdm.EMPLOYEE_ID = cd.EMPLOYEE_ID
      left join employee_termination et on cdm.EMPLOYEE_ID = et.EMPLOYEE_ID and cdm.employee_title = et.employee_title
      ),
      weekly_eligibility as (
      select f.*,
             wtn.WEEKLY_TOPIC as eligible_topic_name,
             wtn.START_DATE::date as eligible_topic_start_date,
             'Weekly' as topic_type,
             1 as topic_type_flag,
             case when date_trunc(week,current_date) = date_trunc(week,eligible_topic_start_date)  then 1 else 0 end as current_eligible_topic_flag,
             case when eligible_topic_start_date <= date_trunc(week, current_date) then 'Previous Topics'
                              else 'Future Topic' end as topics_discussed,
             case when eligible_topic_start_date < date_trunc(week, current_date) then 'Previous Topics'
                              when eligible_topic_start_date = date_trunc(week, current_date) then 'Current Topic'
                              else 'Future Topic' end as topics_discussed_manager,
             case when concat(coalesce(market_name,'No Market'),' ', coalesce(district,'No District'),' ',region_name) is not null then 1 else 0 end as area_flag
      from final_employee_cd_mapping f
      left join ANALYTICS.BI_OPS.WEEKLY_TOPIC_NAMES wtn on wtn.START_DATE between record_effective_date and record_ineffective_date
      where SPLIT_PART(default_cost_centers_full_path,'/',1) not in ('T3', 'E-Commerce', 'Corp')
            AND current_employee_title not in ('Rental Territory Manager', 'Key Account Manager', 'Territory Manager', 'National Account Manager', 'Project Manager',
                                              'District Project Manager', 'Regional Project Manager', 'Executive Project Manger', 'Project Coordinator-Safety', 'Strategic Account Manager',
                                              'Regional Manager-Advanced Solutions', 'Regional Operations Director', 'Regional Operations Director-Southwest', 'Regional Operations Manager-Advanced Solutions',
                                              'Regional Vice President', 'Regional Product Specialist', 'Regional Director of Advanced Solutions', 'Regional Director of Operations', 'Market Consultant Manager',
                                              'Retail Account Manager')
            and (employee_title not like '%Sales%'
            AND employee_title not in ('Rental Territory Manager', 'Key Account Manager', 'Territory Manager', 'National Account Manager', 'Project Manager',
                                      'District Project Manager', 'Regional Project Manager', 'Executive Project Manger', 'Project Coordinator-Safety', 'Strategic Account Manager',
                                      'Regional Manager-Advanced Solutions', 'Regional Operations Director', 'Regional Operations Director-Southwest', 'Regional Operations Manager-Advanced Solutions',
                                      'Regional Vice President', 'Regional Product Specialist', 'Regional Director of Advanced Solutions', 'Regional Director of Operations', 'Market Consultant Manager',
                                      'Retail Account Manager'))
            and area_flag = 1
      ),
two_email_check as (
select cdv.EMPLOYEE_ID,
       concat(cdv.FIRST_NAME, ' ', cdv.LAST_NAME) as full_name,
       cdv.WORK_EMAIL,
       cd.WORK_EMAIL as email_for_looker_permissions
--        cdv.EMPLOYEE_TITLE,
--        cdv._ES_UPDATE_TIMESTAMP --- This is the date right before the email switched over
from ANALYTICS.PAYROLL.COMPANY_DIRECTORY_VAULT cdv
join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd on cdv.EMPLOYEE_ID = cd.EMPLOYEE_ID
where cd.EMPLOYEE_STATUS not in ('Terminated', 'Never Started', 'Not In Payroll', 'On Leave', 'Temporary Worker', 'Contractor', 'Inactive')
qualify row_number() over (partition by cd.EMPLOYEE_ID, CASE WHEN
        cdv.WORK_EMAIL <> cd.WORK_EMAIL then 1 END order by _ES_UPDATE_TIMESTAMP desc) = 1
),
completed_topics as (
select tec.EMPLOYEE_ID,
       tec.email_for_looker_permissions as email_address,
       smr.WEEKLY_TOPIC,
       smr.MONTHLY_TOPIC,
       DATE_SUBMITTED
from two_email_check tec
left join ANALYTICS.BI_OPS.SAFETY_MEETING_RESPONSES smr on lower(tec.WORK_EMAIL) = lower(smr.EMAIL_ADDRESS)
),
      weekly_info as (
      select we.*,
             smr.WEEKLY_TOPIC as completed_topic_name,
             smr.DATE_SUBMITTED::date as date_submitted,
             case when completed_topic_name is not null then 1 else 0 end as attended_topic
      from weekly_eligibility we
      left join completed_topics smr on lower(we.current_work_email) = lower(smr.EMAIL_ADDRESS)
                                     and we.eligible_topic_name ILIKE '%' || smr.WEEKLY_TOPIC || '%'
                                     and date_trunc(year, we.eligible_topic_start_date) = date_trunc(year, smr.date_submitted::date)
      ),
      monthly_eligibility as (
      select f.*,
             mtn.MONTHLY_TOPICS as eligible_topic_name,
             mtn.START_DATE::date as eligible_topic_start_date,
             'Monthly' as topic_type,
             2 as topic_type_flag,
             case when date_trunc(month,current_date) = date_trunc(month,eligible_topic_start_date) then 1 else 0 end as current_eligible_topic_flag,
             case when eligible_topic_start_date <= date_trunc(month, current_date) then 'Previous Topics'
                              else 'Future Topic' end as topics_discussed,
             case when eligible_topic_start_date < date_trunc(month, current_date) then 'Previous Topics'
                              when eligible_topic_start_date = date_trunc(month, current_date) then 'Current Topic'
                              else 'Future Topic' end as topics_discussed_manager,
             case when concat(coalesce(market_name,'No Market'),' ', coalesce(district,'No District'),' ',region_name) is not null then 1 else 0 end as area_flag
      from final_employee_cd_mapping f
      left join ANALYTICS.BI_OPS.MONTHLY_TOPIC_NAMES mtn on mtn.START_DATE between record_effective_date and record_ineffective_date
      where (employee_title like '%Driver%'
                        or employee_title like '%Tractor Trailer A%'
                        or employee_title like '%Delivery%'
                        or employee_title like '%Field%'
                        or employee_title like '%(NJ Union)%'
                        or employee_title like '%Service Technician%'
                        or employee_title like 'Traveling Technician'
                        or employee_title like 'Mobile Technician')
            AND
                        (current_employee_title like '%Driver%'
                        or current_employee_title like '%Tractor Trailer A%'
                        or current_employee_title like '%Delivery%'
                        or current_employee_title like '%Field%'
                        or current_employee_title like '%(NJ Union)%'
                        or current_employee_title like '%Service Technician%'
                        or current_employee_title like 'Traveling Technician'
                        or current_employee_title like 'Mobile Technician')
            AND (employee_title not like 'Service Technician - Shop')
            AND (current_employee_title not like 'Service Technician - Shop')
      ),
      monthly_info as (
      select me.*,
             smr.MONTHLY_TOPIC as completed_topic_name,
             smr.DATE_SUBMITTED::date as date_submitted,
             case when completed_topic_name is not null then 1 else 0 end as attended_topic
      from monthly_eligibility me
      left join completed_topics smr on lower(me.current_work_email) = lower(smr.EMAIL_ADDRESS)
                                     and me.eligible_topic_name ILIKE '%' || smr.MONTHLY_TOPIC || '%'
                                     and date_trunc(year, me.eligible_topic_start_date) = date_trunc(year, smr.date_submitted::date)
      ),
      final_table as (
      select *
      from weekly_info

      UNION

      select *
      from monthly_info
      )
      select *
      from final_table
      where
      {% condition topic_type_filter_mapping %} topic_type {% endcondition %}

      AND (

      (
      'developer' = {{ _user_attributes['department'] }}
      OR 'god view' = {{ _user_attributes['department'] }}
      OR 'telematics' = {{ _user_attributes['department'] }}
      )

      OR
      (
      'managers' = {{ _user_attributes['department'] }}
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      ----- This is for anyone who is appointed to manage the safety meetings other than the GMs or Rental Coordinators
      ----- They will need to be given the Workplace Safety Group as well

      OR
      (
      'safety' = {{ _user_attributes['department'] }}
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      ----- This is for individual user access for the 'Individual Safety Meeting Dashboard'. Add the different 'departments' from user attributes here if need be.

      OR
      (
      'users' = {{ _user_attributes['department'] }}
      AND
      (
      current_work_email ILIKE '{{ _user_attributes['email'] }}'
      )
      )

      OR
      (
      'rental coordinators' = {{ _user_attributes['department'] }}
      AND
      (
      current_work_email ILIKE '{{ _user_attributes['email'] }}'
      )
      )

      --OR
      --(
      --'telematics' = {{ _user_attributes['department'] }}
      --AND
      --(
      --current_work_email ILIKE '{{ _user_attributes['email'] }}'
      --)
      --)

      OR
      (
      'fleet' = {{ _user_attributes['department'] }}
      AND
      (
      current_work_email ILIKE '{{ _user_attributes['email'] }}'
      )
      )

      ----- This is for individual hard coded access. This is needed when someone who isn't a GM ask for manager permission for the dashboard.

      OR
      (
      'aryn.rodenbaugh@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'jerad.webster@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'james.donnelly@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'cody.brown@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'marques.baldwin@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'mashanda.blaise@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'susan.lauretti@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'zach.douthitt@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'erik.munoz@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'brian.shimko@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'blake.comeaux@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'max.belyeu@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'tara.vossekuil@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'lucas.lopez@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'louie.johnson@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'morgan.panos@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'chris.sondergaard@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'wyatt.slavens@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'ben.paullus@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'brent.hutchison@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'derick.dunne@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'hector.rodriguez@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'clay.crow@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'jeremy.brownmiller@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'matthew.etherington@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'devin.hamilton@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'jr.curayag@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'ashlie.ward@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ('10550','97880') --- Change this to be ({{_user_attributes['market_id']}}) once Mariam isn't managiing the attendance for the Advanced branch anymore
      )
      )

      OR
      (
      'mariam.behashti@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ('10550','97880') --- Change this to be ({{_user_attributes['market_id']}}) once Mariam isn't managiing the attendance for the Advanced branch anymore
      )
      )

      OR
      (
      'joe.maccall@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'ben.acio@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'matt.tanner@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'halley.moore@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      OR
      (
      'anthony.young@equipmentshare.com' = '{{ _user_attributes['email'] }}'
      AND
      (
      region_name in ({{_user_attributes['region']}})
      OR district in ({{_user_attributes['district']}})
      OR market_id in ({{_user_attributes['market_id']}})
      )
      )

      );;
  }


  ## For everything to work, the start dates MUST be correct on the weekly and monthly topic names Google Sheet. Here is the link to the
  # Sheet: https://docs.google.com/spreadsheets/d/1hGh680aUcGsc5m9hPbkmOJwggG9i7tKUaC-N0ACDakA/edit#gid=1964261246
  # Kyle Croucher and Michael Brown are the only ones with permission to edit those protected sheets


  # This view is used on two different dashboards. Safety Meeting Attendance and Individual Safety Meeting Attendance


  ## There are a few things happening within the joins and where clauses

  # First for an employee to be eligible in the weekly topics, the topic start date must be between the employees record effective date and the record ineffective date. This helps capture issues where employees have switched job titles. Please see the where clause in the final_employee_cd_mapping CTE for those employee examples.
  # For an employee to be eligible in the monthly topics, the topic month must be after the employees record effective date.

  # As for the other requirements; the topic submitted date must be within the year of the topics. Everything else is just filtering out different titles.

  measure: count {
    type: count
  }

  dimension: employee_name {
    label: "Employee Name With ID"
    type: string
    #   suggest_persist_for: "1 minute"
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
  }

  dimension: employee_name_with_link {
    type: string
    #  suggest_persist_for: "1 minute"
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
    link: {
      label: "Link to Individual Employee Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/1158?Topic+Type={{ _filters['safety_meeting_union_with_tams.topic_type'] | url_encode }}&Employee+Name={{ value }}"
    }
  }

  dimension: email_address {
    type: string
    primary_key: yes
    sql: ${TABLE}."CURRENT_WORK_EMAIL" ;;
  }

  # dimension_group: hired {
  #   type: time
  #   sql: ${TABLE}."DATE_HIRED" ;;
  #   html: {{ rendered_value | date: "%b %d, %Y" }};;
  # }

  dimension_group: record_effective {
    label: "Position Effective"
    type: time
    sql: ${TABLE}."RECORD_EFFECTIVE_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: record_ineffective {
    type: time
    sql: ${TABLE}."RECORD_INEFFECTIVE_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

  # dimension_group: rehired {
  #   type: time
  #   sql: ${TABLE}."DATE_REHIRED" ;;
  #   html: {{ rendered_value | date: "%b %d, %Y" }};;
  # }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: topic {
    type: string
    sql: ${TABLE}."ELIGIBLE_TOPIC_NAME" ;;
    order_by_field: topic_start_date
  }

  dimension_group: topic_start {
    type: time
    sql: ${TABLE}."ELIGIBLE_TOPIC_START_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: response_topic_attended {
    type: string
    sql: ${TABLE}."COMPLETED_TOPIC_NAME" ;;
  }

  dimension_group: topic_completed {
    type: time
    sql: ${TABLE}."DATE_SUBMITTED" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: attended_topic {
    type: string
    sql: case when ${TABLE}."ATTENDED_TOPIC" = 1 then 'Yes' else 'No' end ;;
  }

  dimension: topic_type_flag {
    type: string
    sql: ${TABLE}."TOPIC_TYPE_FLAG" ;;
  }

  dimension: topic_type {
    type: string
    sql: ${TABLE}."TOPIC_TYPE" ;;
  }

  dimension: current_eligible_topic_flag {
    type: string
    sql: ${TABLE}."CURRENT_ELIGIBLE_TOPIC_FLAG" ;;
  }

  dimension: topics_discussed {
    type: string
    sql: ${TABLE}."TOPICS_DISCUSSED" ;;
  }

  dimension: topics_discussed_manager {
    type: string
    sql: ${TABLE}."TOPICS_DISCUSSED_MANAGER" ;;
  }

  dimension: attended_topic_formatted {
    type: string
    sql: case when ${TABLE}."CURRENT_ELIGIBLE_TOPIC_FLAG" = 1 and ${TABLE}."ATTENDED_TOPIC" = 0 then 'In Progress' else ${attended_topic} end ;;
    html:
    {% if value == "Yes" %}
    <p><img src="https://findicons.com/files/icons/573/must_have/48/check.png" alt="" height="13" width="13">‎ ‎ ‎ {{ rendered_value }}</p>
    {% elsif value == "No" %}
    <p><img src="https://findicons.com/files/icons/719/crystal_clear_actions/64/cancel.png" alt="" height="13" width="13">‎ ‎ ‎ {{ rendered_value }}</p>
    {% elsif value == "In Progress" %}
    <p><img src="https://findicons.com/files/icons/1681/siena/128/clock_blue.png" alt="" height="13" width="13">‎ ‎ ‎ {{ rendered_value }}</p>
    {% else %}
    {% endif %};;
  }

  measure: count_of_attended_employees {
    type: count_distinct
    sql: ${email_address} ;;
    filters: [attended_topic: "Yes"]
    drill_fields: [employee_info*]
    ##html: <font color="#26D701">{{ value }}</font>;;
  }

  measure: count_of_not_attended_employees {
    type: count_distinct
    sql: ${email_address} ;;
    filters: [attended_topic: "No"]
    drill_fields: [employee_info*]
    ##html: <font color="#FF4949">{{ value }}</font>;;
  }

  measure: total_count_of_employees {
    type: count_distinct
    sql: ${TABLE}."CURRENT_WORK_EMAIL" ;;
    drill_fields: [employee_info*]
  }

  measure: total_count_of_eligible_topics {
    type: count_distinct
    sql: ${topic} ;;
  }

  measure: total_count_of_topics_attended_by_employee {
    type: count_distinct
    sql: ${topic} ;;
    filters: [attended_topic: "Yes"]
  }

  measure: total_count_of_weekly_topics_attended_by_employee {
    type: count_distinct
    sql: ${topic} ;;
    filters: [attended_topic: "Yes", topic_type: "Weekly"]
  }

  measure: total_count_of_weekly_topics_not_attended_by_employee {
    type: count_distinct
    sql: ${topic} ;;
    filters: [attended_topic: "No", topic_type: "Weekly"]
    drill_fields: [topic,topic_start_date]
  }

  measure: topic_completion_percentage_individual {
    type: number
    sql: ${total_count_of_topics_attended_by_employee}/case when ${total_count_of_eligible_topics} = 0 then null else ${total_count_of_eligible_topics} end ;;
    value_format_name: percent_1
  }

  measure: percentage_complete {
    type: number
    sql: ${count_of_attended_employees}/case when ${total_count_of_employees} = 0 then null else ${total_count_of_employees} end ;;
    value_format_name: percent_1
  }

  filter: region_name_filter_mapping {
    type: string
  }

  filter: district_filter_mapping {
    type: string
  }

  filter: market_name_filter_mapping {
    type: string
  }

  filter: market_type_filter_mapping {
    type: string
  }

  filter: topic_type_filter_mapping {
    type: string
  }


  set: employee_info {
    fields: [
      employee_name,
      email_address,
      market_name,
      district,
      region_name,
      record_effective_date,
      employee_title,
      employee_status,
      topic,
      topic_completed_date
    ]
  }


}
