view: customer_segments_by_T3_usage {
  derived_table: {
    sql: with selected_period_users as (
      select
          distinct(user_id) as user_id
      from
          heap_t3_platform_production.heap.all_events
      where
          time >= dateadd(day,-14,current_date)
      )
      , heap_user_info as (
      select
          user_id as heap_user_id,
          identity,
          user_name,
          company_name,
          _user_id as es_user_id,
          company_id
      from
          heap_t3_platform_production.heap.users
      where
          mimic_user = 'No'
      )
      , active_users as (
      select
          heap_user_id,
          identity,
          user_name,
          company_name,
          es_user_id,
          company_id
      from
          heap_user_info hui
          join selected_period_users pu on hui.heap_user_id = pu.user_id
      )
      , active_users_per_company as (
      select
          company_id,
          count(distinct es_user_id) as active_users_per_company
      from active_users au
      group by company_id
      )
      ,events_in_selected_period as (
      select
          heap_user_id,
          es_user_id,
          ae.event_id,
          ae.time,
          ae.session_id
      from
          heap_user_info au
          join heap_t3_platform_production.heap.all_events ae on au.heap_user_id = ae.user_id
      where
          time >= dateadd(day,-14,current_date)
       )
      , events_per_user as (
      select
          aue.heap_user_id,
          aue.es_user_id,
          'analytics_app' as heap_event,
          coalesce(count(ANALYTICS_APP.event_id),0) as total_events
      from
          events_in_selected_period aue
          left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.ANALYTICS_BROWSER_LOAD_APP ANALYTICS_APP on aue.heap_user_id = ANALYTICS_APP.user_id AND aue.event_id = ANALYTICS_APP.event_id AND ANALYTICS_APP._app_name = 'Analytics'
       group by
          aue.heap_user_id,
          aue.es_user_id
      UNION
      select
          aue.heap_user_id,
          aue.es_user_id,
          'costcapture_app' as heap_event,
          coalesce(count(COSTCAPTURE.event_id),0) as total_events
      from
          events_in_selected_period aue
          left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.COSTCAPTURE_BROWSER_LOAD_APP COSTCAPTURE on aue.heap_user_id = COSTCAPTURE.user_id AND aue.event_id = COSTCAPTURE.event_id
       group by
          aue.heap_user_id,
          aue.es_user_id
      UNION
      select
          aue.heap_user_id,
          aue.es_user_id,
          'elogs_browser' as heap_event,
          coalesce(count(ELOGSB.event_id),0) as total_events
      from
          events_in_selected_period aue
          left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.E_LOGS_BROWSER_LOAD_APP ELOGSB on aue.heap_user_id = ELOGSB.user_id AND aue.event_id = ELOGSB.event_id
       group by
          aue.heap_user_id,
          aue.es_user_id
      UNION
      select
          aue.heap_user_id,
          aue.es_user_id,
          'elogs_mobile' as heap_event,
          coalesce(count(ELOGSM.event_id),0) as total_events
      from
          events_in_selected_period aue
          left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.E_LOGS_MOBILE_APP_LOAD_APP ELOGSM on aue.heap_user_id = ELOGSM.user_id AND aue.event_id = ELOGSM.event_id
       group by
          aue.heap_user_id,
          aue.es_user_id
      UNION
      select
          aue.heap_user_id,
          aue.es_user_id,
          'inventory_browser' as heap_event,
          coalesce(count(INVENTORYB.event_id),0) as total_events
      from
          events_in_selected_period aue
          left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.INVENTORY_BROWSER_LOAD_APP INVENTORYB on aue.heap_user_id = INVENTORYB.user_id AND aue.event_id = INVENTORYB.event_id
       group by
          aue.heap_user_id,
          aue.es_user_id


      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'link_mobile_assets' as heap_event,
      coalesce(count(LINKMA.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.LINKAPP_DASHBOARD_MENU_TOUCH_ASSETS LINKMA on aue.heap_user_id = LINKMA.user_id AND aue.event_id = LINKMA.event_id

      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'link_mobile_inspections' as heap_event,
      coalesce(count(LINKMI.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.LINKAPP_DASHBOARD_MENU_TOUCH_INSPECTIONS LINKMI on aue.heap_user_id = LINKMI.user_id AND aue.event_id = LINKMI.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'link_mobile_rentals' as heap_event,
      coalesce(count(LINKMR.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.LINKAPP_DASHBOARD_MENU_TOUCH_RENTALS LINKMR on aue.heap_user_id = LINKMR.user_id AND aue.event_id = LINKMR.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'link_mobile_timecards' as heap_event,
      coalesce(count(LINKMTC.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.LINKAPP_DASHBOARD_MENU_TOUCH_TIME_CARDS LINKMTC on aue.heap_user_id = LINKMTC.user_id AND aue.event_id = LINKMTC.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'link_mobile_work_orders' as heap_event,
      coalesce(count(LINKMWO.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.LINKAPP_DASHBOARD_MENU_TOUCH_WORK_ORDERS LINKMWO on aue.heap_user_id = LINKMWO.user_id AND aue.event_id = LINKMWO.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'rent_mobile' as heap_event,
      coalesce(count(RENTM.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.RENTAPP_MOBILE_APP_LOAD_APP RENTM on aue.heap_user_id = RENTM.user_id AND aue.event_id = RENTM.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'rent_browser' as heap_event,
      coalesce(count(RENTB.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.RENTAPP_PAGE_LOAD_HOME RENTB on aue.heap_user_id = RENTB.user_id AND aue.event_id = RENTB.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'timetracking_browser' as heap_event,
      coalesce(count(TIMETRACKINGB.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.TIME_TRACKING_BROWSER_LOAD_APP TIMETRACKINGB on aue.heap_user_id = TIMETRACKINGB.user_id AND aue.event_id = TIMETRACKINGB.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'fleet_alerts' as heap_event,
      coalesce(count(FLEET_ALERTS.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.USER_SEGMENTS_FLEET__FLEET_NAVIGATION_MENU_CLICK_ALERTS FLEET_ALERTS on aue.heap_user_id = FLEET_ALERTS.user_id AND aue.event_id = FLEET_ALERTS.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'fleet_assets' as heap_event,
      coalesce(count(FLEET_ASSETS.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.USER_SEGMENTS_FLEET__FLEET_NAVIGATION_MENU_CLICK_ASSETS FLEET_ASSETS on aue.heap_user_id = FLEET_ASSETS.user_id AND aue.event_id = FLEET_ASSETS.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'fleet_billing' as heap_event,
      coalesce(count(FLEET_BILLING.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.USER_SEGMENTS_FLEET__FLEET_NAVIGATION_MENU_CLICK_BILLING FLEET_BILLING on aue.heap_user_id = FLEET_BILLING.user_id AND aue.event_id = FLEET_BILLING.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'fleet_camera' as heap_event,
      coalesce(count(FLEET_CAMERA.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.USER_SEGMENTS_FLEET__FLEET_NAVIGATION_MENU_CLICK_CAMERA FLEET_CAMERA on aue.heap_user_id = FLEET_CAMERA.user_id AND aue.event_id = FLEET_CAMERA.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'fleet_company_admin' as heap_event,
      coalesce(count(FLEET_COMPANY_ADMIN.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.USER_SEGMENTS_FLEET__FLEET_NAVIGATION_MENU_CLICK_COMPANY_ADMIN FLEET_COMPANY_ADMIN on aue.heap_user_id = FLEET_COMPANY_ADMIN.user_id AND aue.event_id = FLEET_COMPANY_ADMIN.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'fleet_dashboard' as heap_event,
      coalesce(count(FLEET_DASHBOARD.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.USER_SEGMENTS_FLEET__FLEET_NAVIGATION_MENU_CLICK_DASHBOARD FLEET_DASHBOARD on aue.heap_user_id = FLEET_DASHBOARD.user_id AND aue.event_id = FLEET_DASHBOARD.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'fleet_geofences' as heap_event,
      coalesce(count(FLEET_GEOFENCES.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.USER_SEGMENTS_FLEET__FLEET_NAVIGATION_MENU_CLICK_GEOFENCES FLEET_GEOFENCES on aue.heap_user_id = FLEET_GEOFENCES.user_id AND aue.event_id = FLEET_GEOFENCES.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'fleet_inventory' as heap_event,
      coalesce(count(FLEET_INVENTORY.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.USER_SEGMENTS_FLEET__FLEET_NAVIGATION_MENU_CLICK_INVENTORY FLEET_INVENTORY on aue.heap_user_id = FLEET_INVENTORY.user_id AND aue.event_id = FLEET_INVENTORY.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'fleet_map' as heap_event,
      coalesce(count(FLEET_MAP.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.FLEET_NAVIGATION_MENU_CLICK_MAP FLEET_MAP on aue.heap_user_id = FLEET_MAP.user_id AND aue.event_id = FLEET_MAP.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'fleet_rentals' as heap_event,
      coalesce(count(FLEET_RENTALS.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.USER_SEGMENTS_FLEET__FLEET_NAVIGATION_MENU_CLICK_RENTALS FLEET_RENTALS on aue.heap_user_id = FLEET_RENTALS.user_id AND aue.event_id = FLEET_RENTALS.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'fleet_service' as heap_event,
      coalesce(count(FLEET_SERVICE.event_id),0) as total_events
      from
      events_in_selected_period aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.USER_SEGMENTS_FLEET__FLEET_NAVIGATION_MENU_CLICK_SERVICE FLEET_SERVICE on aue.heap_user_id = FLEET_SERVICE.user_id AND aue.event_id = FLEET_SERVICE.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      )
      , active_users_per_company as (
      select
      company_id,
      count(distinct es_user_id) as active_users_per_company
      from active_users au
      group by company_id
      )
      , sessions_per_company as (
      select
      au.company_id,
      sum(esp.total_events) as sessions_per_company
      from
      events_per_user esp
      join active_users au on au.es_user_id = esp.es_user_id
      group by
      au.company_id
      )
      , total_assets as (
      select
      company_id,
      count(a.tracker_id) as total_trackers,
      count(a.asset_id) as total_assets
      from
      assets a
      where
      deleted = FALSE
      group by
      company_id
      )
      , total_telematics_assets as (
      select
      ts.company_id,
      count(ts.asset_id) as tracked_assets
      from
      telematics_service_providers_assets ts
      join assets a on a.asset_id = ts.asset_id
      where
      a.deleted = FALSE
      group by
      ts.company_id
      )
      , company_revenue as(
      select
      c.company_id,
      sum(li.amount) as total_rental_revenue,
      case when sum(li.amount) >= 1500000 then '1.5M+'
      when sum(li.amount) >= 1000000 AND sum(li.amount) < 1500000 then '1-1.5M'
      when sum(li.amount) >= 750000 AND sum(li.amount) < 1000000 then '750K-1M'
      when sum(li.amount) >= 500000 AND sum(li.amount) < 750000 then '500K-750K'
      when sum(li.amount) >= 250000 AND sum(li.amount) < 500000 then '250K-500K'
      else '0-250K'
      end as revenue_bucket
      from
      ES_WAREHOUSE.PUBLIC.orders o
      join ES_WAREHOUSE.PUBLIC.invoices i on i.order_id = o.order_id
      join ANALYTICS.PUBLIC.v_line_items li on li.invoice_id = i.invoice_id
      join ES_WAREHOUSE.PUBLIC.users u on u.user_id = o.user_id
      join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
      where
      li.line_item_type_id in (6,8,108,109)
      and li.gl_date_created::DATE >= (current_date - INTERVAL '2 months')
      group by
      c.company_id,
      c.name
      )
      , total_events_per_type as (
      select company_id,
      heap_event,
      sum(total_events) as total_events_per_type
      FROM events_per_user evp
      join heap_user_info hui on evp.es_user_id = hui.es_user_id
      group by
      company_id,
      heap_event
      )
      , total_events_per_company as (
      select company_id,
      sum(total_events) as total_events_per_company
      FROM events_per_user evp
      join heap_user_info hui on evp.es_user_id = hui.es_user_id
      group by
      company_id
      )
      select
      hui.company_name,
      hui.company_id,
      hui.es_user_id,
      evp.heap_event,
      evp.total_events as total_events_per_user,
      cr.total_rental_revenue,
      cr.revenue_bucket,
      auc.active_users_per_company,
      spc.sessions_per_company,
      --tvt.total_events_per_type,
      tvc.total_events_per_company,
      CAST((tvc.total_events_per_company/auc.active_users_per_company) AS DECIMAL(15,2)) as avg_events_per_user_per_company,
      COALESCE(ta.total_assets,0) as total_assets,
      COALESCE(ta.total_trackers,0) as total_trackers,
      COALESCE(tta.tracked_assets,0) as total_tracked_assets
      FROM events_per_user evp
      join heap_user_info hui on evp.es_user_id = hui.es_user_id
      join company_revenue cr on hui.company_id = cr.company_id
      join active_users_per_company auc on hui.company_id = auc.company_id
      join sessions_per_company spc on hui.company_id = spc.company_id
      --join total_events_per_type tvt on hui.company_id = tvt.company_id and evp.heap_event = tvt.heap_event
      join total_events_per_company tvc on hui.company_id = tvc.company_id
      left join total_assets ta on ta.company_id = hui.company_id
      left join total_telematics_assets tta on tta.company_id = hui.company_id
      where total_events > 0
      and hui.company_id <> 420
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: es_user_id {
    type: string
    sql: ${TABLE}."ES_USER_ID" ;;
  }

  dimension: heap_event {
    type: string
    sql: ${TABLE}."HEAP_EVENT" ;;
  }

  dimension: total_events_per_user {
    type: number
    sql: ${TABLE}."TOTAL_EVENTS_PER_USER" ;;
  }

  dimension: total_rental_revenue {
    type: number
    sql: ${TABLE}."TOTAL_RENTAL_REVENUE" ;;
  }

  dimension: revenue_bucket {
    type: string
    sql: ${TABLE}."REVENUE_BUCKET" ;;
  }

  dimension: active_users_per_company {
    type: number
    sql: ${TABLE}."ACTIVE_USERS_PER_COMPANY" ;;
  }

  dimension: sessions_per_company {
    type: number
    sql: ${TABLE}."SESSIONS_PER_COMPANY" ;;
  }

  dimension: total_events_per_company {
    type: number
    sql: ${TABLE}."TOTAL_EVENTS_PER_COMPANY" ;;
  }

  dimension: avg_events_per_user_per_company {
    type: number
    sql: ${TABLE}."AVG_EVENTS_PER_USER_PER_COMPANY" ;;
  }

  dimension: total_assets {
    type: number
    sql: ${TABLE}."TOTAL_ASSETS" ;;
  }

  dimension: total_trackers {
    type: number
    sql: ${TABLE}."TOTAL_TRACKERS" ;;
  }

  dimension: total_tracked_assets {
    type: number
    sql: ${TABLE}."TOTAL_TRACKED_ASSETS" ;;
  }

  set: detail {
    fields: [
      company_name,
      company_id,
      es_user_id,
      heap_event,
      total_events_per_user,
      total_rental_revenue,
      revenue_bucket,
      active_users_per_company,
      sessions_per_company,
      total_events_per_company,
      avg_events_per_user_per_company,
      total_assets,
      total_trackers,
      total_tracked_assets
    ]
  }
}
