view: es_user_info {
  derived_table: {
    sql: with allocation_relationship as (
    select
        row_number() over (partition by relationship_entity_id order by created_date desc) as rn,
        allocation_id,
        relationship_entity_id
    from
        es_warehouse.time_tracking.allocations_relationships
    where
        allocation_relationship_type = 'USER')
select
        u.date_created,
        username,
        u.email_address,
        u.user_id,
        first_name,
        last_name,
        employee_id,
        branch_id,
        m.name as branch,
        listagg(distinct o.name) as groups,
        u.company_id as company_id,
        u.timezone as timezone,
        case
          when user_type_id = 1 then 'Non-Driver'
          when user_type_id = 2 then 'Driver'
          else 'Unspecified'
        end as user_type,
        case
          when security_level_id = 1 then 'Admin'
          when security_level_id = 2 then 'Owner'
          when security_level_id = 3 then 'Pending'
          when security_level_id = 4 then 'Salesperson'
          when security_level_id = 5 then 'User Manager'
          when security_level_id = 6 then 'Operations'
          when security_level_id = 7 then 'Driver'
        end as user_security_level,
        case
            when u.user_id in (17132,31851,21750,33123,28920,20770) then null
            else a.name
        end as overtime_rules,
        case when
             di.inactive_date is null AND user_type <> 'Driver' then 'Non-Driver'
             when di.inactive_date is null AND user_type = 'Driver' then 'Active'
             else 'Inactive'
             END as elog_driver_status
      from
          es_warehouse.public.users u
          join es_warehouse.public.companies c on c.company_id = 1854::numeric
          left join es_warehouse.public.organization_user_xref oux on oux.user_id = u.user_id
          left join es_warehouse.public.organizations o on o.organization_id = oux.organization_id
          left join es_warehouse.public.markets m on m.market_id = u.branch_id
          left join allocation_relationship ar on ar.relationship_entity_id = u.user_id and rn=1
          left join (select *
                     from es_warehouse.time_tracking.allocations
                     where not deleted) a on ar.allocation_id = a.allocation_id
          left join (select driver_id,
                            inactive_date
                     from es_warehouse.elogs.drivers d
                     left join es_warehouse.public.users u on d.driver_id = u.user_id
                     where u.company_id = 1854) di on u.user_id = di.driver_id
      where
          not u.deleted
          and u.company_id = 1854::numeric
          and u.username not like '%.suspended%'
      group by
          u.date_created,
          username,
          u.email_address,
          u.user_id,
          first_name,
          last_name,
          employee_id,
          branch_id,
          u.company_id,
          u.timezone,
          user_type,
          user_security_level,
          m.name,
          a.name,
          elog_driver_status
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: username {
    type: string
    sql: ${TABLE}."USERNAME" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    value_format_name: id
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    value_format_name: id
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format_name: id
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: groups {
    type: string
    sql: ${TABLE}."GROUPS" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: timezone {
    type: string
    sql: ${TABLE}."TIMEZONE" ;;
  }

  dimension: user_type {
    type: string
    sql: ${TABLE}."USER_TYPE" ;;
  }

  dimension: user_security_level {
    type: string
    sql: ${TABLE}."USER_SECURITY_LEVEL" ;;
  }

  dimension: overtime_rules {
    type: string
    sql: ${TABLE}."OVERTIME_RULES" ;;
  }

  dimension: elog_driver_status {
    type: string
    sql: ${TABLE}."ELOG_DRIVER_STATUS" ;;
  }


  set: detail {
    fields: [
      date_created_time,
      username,
      user_id,
      first_name,
      last_name,
      employee_id,
      branch_id,
      branch,
      groups,
      company_id,
      timezone,
      user_type,
      user_security_level,
      overtime_rules
    ]
  }
}
