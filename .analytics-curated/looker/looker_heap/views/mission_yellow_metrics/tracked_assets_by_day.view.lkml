view: tracked_assets_by_day {
  derived_table: {
    sql:
with generate_series as (
          select * from table(generate_series(
          '2022-12-01'::timestamp_tz,
          current_date::timestamp_tz,
          'day'))
    )
    , sub_info as (
    select
        t3.month::date as invoiced_month,
        t3.company_id,
        row_number() over (partition by t3.company_id order by t3.month::date asc) as rnk
    from
        analytics.analytics.t_3_invoice_company_ids t3
    )
    , tracker_installs as (
    select
        ao.asset_company_id,
        a.date_created::date as asset_create_date,
        ata.date_installed::date as date_tracker_installed,
        ao.asset_id,
        a.asset_type_id,
        aca.date_installed::date as date_camera_installed
    from
        analytics.bi_ops.asset_ownership ao
    left join
        ES_WAREHOUSE.PUBLIC.ASSETS a on a.asset_id = ao.asset_id
    left join
        ES_WAREHOUSE.PUBLIC.asset_tracker_assignments ata on ata.asset_id = ao.asset_id and ata.date_uninstalled is null
    left join
        ES_WAREHOUSE.PUBLIC.asset_camera_assignments aca on aca.asset_id = ao.asset_id and aca.date_uninstalled is null
    where
        asset_type_id in (1,2, 3)
    and
        ao.ownership in ('CUSTOMER')
    and
        a.company_id not in (1854,10859,16184,420,155,23515,11606,77198,5383,4110,88180,37906,36810,42268,84297,58589)
    and
        a.deleted = false
    )
    select
        gs.series as date,
        si.company_id,
        c.name as company_name,
        case
            when rnk = 1 then 'Y'
            else 'N'
        end as new_company,
        ti.asset_id,
        case
          when ti.asset_type_id = 1 then 'Equipment'
          when ti.asset_type_id = 2 then 'Vehicle'
          when ti.asset_type_id = 3 then 'Trailer'
        end as asset_type,
        ti.asset_create_date,
        case
            when ti.date_tracker_installed <= gs.series then 'Y'
            else 'N'
        end as tracker_installed,
                case
            when ti.date_camera_installed <= gs.series then 'Y'
            else 'N'
        end as camera_installed
    from
        generate_series gs
    left join
        sub_info si on si.invoiced_month = date_trunc('month', gs.series)
    left join
        tracker_installs ti on si.company_id = ti.asset_company_id and ti.asset_create_date <= gs.series::date
    join
        ES_WAREHOUSE.PUBLIC.companies c on c.company_id = si.company_id
      ;;
}

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
    convert_tz: no
  }

  dimension_group: grouped_date {
    type: time
    label: "Assets Connected"
    sql: ${TABLE}."DATE" ;;
    convert_tz: no
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: new_company {
    label: "New Customer"
    type: string
    sql: ${TABLE}."NEW_COMPANY" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_create_date {
    type: date
    sql: ${TABLE}."ASSET_CREATE_DATE" ;;
    convert_tz: no
  }

  dimension: tracker_installed {
    type: string
    sql: ${TABLE}."TRACKER_INSTALLED" ;;
  }

  dimension: camera_installed {
    type: string
    sql: ${TABLE}."CAMERA_INSTALLED" ;;
  }

  measure: total_tracked_assets {
    label: "Tracked Assets"
    type: count_distinct
    sql: case when ${tracker_installed} = 'Y' or ${camera_installed} = 'Y' then ${asset_id} else null end;;
  }

  measure: total_untracked_assets {
    label: "Untracked Assets"
    type: count_distinct
    sql: case when ${tracker_installed} = 'N' then ${asset_id} else null end;;
  }

  measure: total_dash_cams {
    label: "Total Installed Dash Cams"
    type: count_distinct
    sql: case when ${camera_installed} = 'Y' then ${asset_id} else null end;;
  }

  measure: combined_total_assets {
    label: "Total Assets"
    type: count_distinct
    sql: ${asset_id} ;;
  }

  measure: company_count {
    label: "Total T3 Companies"
    type: count_distinct
    sql: ${company_name} ;;
    # drill_fields: [subscription_companies*]
  }

  measure: percent_of_tracked_assets {
    label: "% Tracked Assets"
    type: number
    sql: coalesce(${total_tracked_assets} / case when ${combined_total_assets} = 0 then null else ${combined_total_assets} end,0) ;;
    value_format_name: percent_1
  }

  measure: total_new_companies {
    label: "Total New Companies"
    type: count_distinct
    sql: case when ${new_company} = 'Y' then ${company_id} else null end;;
  }

  set: detail {
    fields: [
      date,
      company_id,
      company_name,
      new_company,
      asset_id,
      asset_create_date,
      tracker_installed
    ]
  }

  set: subscription_companies {
    fields: [
      date,
      company_name
    ]
  }

}
