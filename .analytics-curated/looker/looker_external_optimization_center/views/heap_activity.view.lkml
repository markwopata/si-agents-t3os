view: heap_activity {
  derived_table: {
    sql: with previous_90_day_users as (
      select
          distinct(user_id) as user_id
      from
          heap_t3_platform_production.heap.all_events
      where
          time >= dateadd(day,-180,current_date)
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
      --     and user_id in
      --     (6963518929631460,6551117199636535,6551117199636535,3770172573704642,5878611466536383,6391878732081974,
      -- 2990537645748898,4353580851249931,622618406828387,6963518929631460,
      -- 3223145324511890,8137130372262148,8233139334785183,2205416556728188,5392754847463266,6486179903093643,
      -- 5347215259921387,1786597174100824,6821171531451121,710148809260048,8768274214880626,5878611466536383,6088050822619715,8828911543242233,6953693027479776,6198372953323763,7748280057152809,5389277761711610,
      -- 6198372953323763,6953693027479776,8651180931611638,5217450373909453,8828911543242233,6365403627671317,7693047617491924,434913377614141,
      -- 7748280057152809,5389277761711610,1904211878787028,1629492153964239,5822211321144092,8889147489505515,
      -- 8847929030745090,3476865871149269,2376892165903115,3430433836604913,5850125552500782,3551455236138021,
      -- 7180093877220246,6396539745012007,2173891279318159,8580317734986232,4028981520377266,2461525251302231,1912913226424870,4270532652252836,8721145330583965,8184444750426970,2464963706095940,2419707940313040,
      -- 5665562126295538,4120660754348859,3839250428949293,8283800329194182,7088923188125015,5774671131848836,4417780657114883,1553911033798874,1384620706018444,8671588833697337,
      -- 4888447252530807,5477208567825461,4834349447539562,2077115515950633,3319173343961805,3367078229705552,
      -- 6009235878416527,6547130814660803,4387301345134413,800406424323508,8407723697478993,4546601285608613,
      -- 5094621309995748,5950315045512354,2975331400796791,7442705392003979,8284369629637989,4091562246737720,
      -- 6024076609065121,2017290806157649,7321905099447803,2812503114287007,7879024756620878,2368670199418802,
      -- 6129545519097080,8838015357176331,3144970084386499,8014176419447404,7503115202862042,5286713555295882,
      -- 6230821253174301,4270532652252836,8620695119719395,4998447336748294,8721145330583965,8442828773619952,
      -- 5192287176005480,4936767299416160,1322117921687259,8289263492892578,8302045411355921,3222454268823909,
      -- 6101367662980419,3391992685779058,1883435629175529,439370659948282,2676064349857487,1736135669780430,
      -- 6726822857075987,2419707940313040,8893990724261632,198439690762702,1481042189679854,8283287053728190,2740784430534952,
      -- 6502662950301774,1783121096091229,2325879773494169,6233587515167639,1350168988898538,8184444750426970,3404506503777423,3852811505943975,522470454363515,6881161914665961,7075802167871856,5388043629378901,
      -- 7075802167871856,522470454363515,5388043629378901,6881161914665961,855645871169433,5498293970557942,6922149481761627,6077904676390419,1736191130148804,8619045898346985,
      -- 6286440613011009,3309827838740222,6077904676390419,8619045898346985,248397838120127,5498293970557942,855645871169433,4898853415658640,
      -- 7049897492203481,793595530702242,6162105762773480,7738712585263209,6157523874676805,5578031496757878,
      -- 8634702644275299,3847466668026714,975812912430005,1736191130148804,8100622535995545,6922149481761627, 2500270620573616,7549680092220063,8661748149033571,6595204382112637,1536647461678167,5082436784462771,7549680092220063,
      -- 2994886975497743,5822441828306297,5494200311572616,6841669419363632,6736241789689227,7110673022882066,
      -- 4934428980196919,4861594635500407,5082436784462771,8661748149033571,2722175949597802,2500270620573616,
      -- 2583741570113386,2200965061232814,7468477865167537,6595204382112637,1536647461678167,2062944636673760)
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
          join previous_90_day_users pu on hui.heap_user_id = pu.user_id
      )
      , active_user_events_last_90 as (
      select
          heap_user_id,
          es_user_id,
          ae.event_id,
          ae.time,
          ae.session_id
      from
          active_users au
          join heap_t3_platform_production.heap.all_events ae on au.heap_user_id = ae.user_id
      where
          time >= dateadd(day,-180,current_date)
      )
      --, sessions_by_device_type as (
      -- select
      --     heap_user_id,
      --     round(sum(case when device_type = 'Mobile' then 1 end)/count(session_id),2) as percent_of_mobile_sessions,
      --     round(sum(case when device_type = 'Tablet' then 1 end)/count(session_id),2) as percent_of_tablet_sessions,
      --     round(sum(case when device_type = 'Desktop' then 1 end)/count(session_id),2) as percent_of_desktop_sessions
      -- from
      --     active_users au
      --     join heap_t3_platform_production.heap.sessions s on au.heap_user_id = s.user_id
      -- where
      --     time >= dateadd(day,-90,current_date)
      -- group by
      --     heap_user_id
      --)
      , events_per_user as (
      select
          aue.heap_user_id,
          aue.es_user_id,
          'analytics_app' as heap_event,
          coalesce(count(ANALYTICS_APP.event_id),0) as total_events
      from
          active_user_events_last_90 aue
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
          active_user_events_last_90 aue
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
          active_user_events_last_90 aue
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
          active_user_events_last_90 aue
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
          active_user_events_last_90 aue
          left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.INVENTORY_BROWSER_LOAD_APP INVENTORYB on aue.heap_user_id = INVENTORYB.user_id AND aue.event_id = INVENTORYB.event_id
       group by
          aue.heap_user_id,
          aue.es_user_id
      UNION
      select
          aue.heap_user_id,
          aue.es_user_id,
          'link_mobile' as heap_event,
          coalesce(count(LINKM.event_id),0) as total_events
      from
          active_user_events_last_90 aue
          left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.LINKAPP_MOBILE_APP_LOAD_APP LINKM on aue.heap_user_id = LINKM.user_id AND aue.event_id = LINKM.event_id

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
      active_user_events_last_90 aue
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
      active_user_events_last_90 aue
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
      active_user_events_last_90 aue
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
      active_user_events_last_90 aue
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
      active_user_events_last_90 aue
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
      active_user_events_last_90 aue
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
      active_user_events_last_90 aue
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
      active_user_events_last_90 aue
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
      active_user_events_last_90 aue
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
      active_user_events_last_90 aue
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
      active_user_events_last_90 aue
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
      active_user_events_last_90 aue
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
      active_user_events_last_90 aue
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
      active_user_events_last_90 aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.USER_SEGMENTS_FLEET__FLEET_NAVIGATION_MENU_CLICK_SERVICE FLEET_SERVICE on aue.heap_user_id = FLEET_SERVICE.user_id AND aue.event_id = FLEET_SERVICE.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'work_orders_closed' as heap_event,
      coalesce(count(WO_CLOSED.event_id),0) as total_events
      from
      active_user_events_last_90 aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.WORK_ORDERS_WORK_ORDERS_TAB_CLICK_CLOSED WO_CLOSED on aue.heap_user_id = WO_CLOSED.user_id AND aue.event_id = WO_CLOSED.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      UNION
      select
      aue.heap_user_id,
      aue.es_user_id,
      'work_orders_open' as heap_event,
      coalesce(count(WO_OPEN.event_id),0) as total_events
      from
      active_user_events_last_90 aue
      left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.WORK_ORDERS_WORK_ORDERS_TAB_CLICK_OPEN WO_OPEN on aue.heap_user_id = WO_OPEN.user_id AND aue.event_id = WO_OPEN.event_id
      group by
      aue.heap_user_id,
      aue.es_user_id
      )
      , user_usage_by_app as (
      select
      heap_user_id,
      es_user_id,
      heap_event,
      round(ratio_to_report(total_events) over (partition by heap_user_id),3) as usage_percent
      from
      events_per_user
      where
      total_events > 0
      )
      , user_app_running_total as (
      select
      heap_user_id,
      es_user_id,
      heap_event,
      usage_percent,
      --case when usage_percent = running_total then 'primary_usage' end as primary_usage_flag,
      sum(usage_percent) over (partition by heap_user_id order by usage_percent desc) as running_total
      from
      user_usage_by_app
      )
      select
      heap_user_id,
      es_user_id,
      --     case when heap_user_id in (6963518929631460,6551117199636535,6551117199636535,3770172573704642,5878611466536383,6391878732081974,
      -- 2990537645748898,4353580851249931,622618406828387,6963518929631460,
      -- 3223145324511890,8137130372262148,8233139334785183,2205416556728188,5392754847463266,6486179903093643,
      -- 5347215259921387,1786597174100824,6821171531451121,710148809260048,8768274214880626,5878611466536383
      --                               ) then 'equipment_manager' --assuming fleet manager and equipment manager is the same
      --     when heap_user_id in (6088050822619715,8828911543242233,6953693027479776,6198372953323763,7748280057152809,5389277761711610,
      -- 6198372953323763,6953693027479776,8651180931611638,
      -- 5217450373909453,8828911543242233,6365403627671317,7693047617491924,434913377614141,
      -- 7748280057152809,5389277761711610,1904211878787028,1629492153964239,5822211321144092,8889147489505515,
      -- 8847929030745090,3476865871149269,2376892165903115,3430433836604913,5850125552500782,3551455236138021,
      -- 7180093877220246,6396539745012007,2173891279318159,8580317734986232,4028981520377266,2461525251302231
      --                          ) then 'superintendent'
      --     when heap_user_id in (1912913226424870,4270532652252836,8721145330583965,8184444750426970,2464963706095940,2419707940313040,
      -- 5665562126295538,4120660754348859,3839250428949293,8283800329194182,
      -- 7088923188125015,5774671131848836,4417780657114883,1553911033798874,1384620706018444,8671588833697337,
      -- 4888447252530807,5477208567825461,4834349447539562,2077115515950633,3319173343961805,3367078229705552,
      -- 6009235878416527,6547130814660803,4387301345134413,800406424323508,8407723697478993,4546601285608613,
      -- 5094621309995748,5950315045512354,2975331400796791,7442705392003979,8284369629637989,4091562246737720,
      -- 6024076609065121,2017290806157649,7321905099447803,2812503114287007,7879024756620878,2368670199418802,
      -- 6129545519097080,8838015357176331,3144970084386499,8014176419447404,7503115202862042,5286713555295882,
      -- 6230821253174301,4270532652252836,8620695119719395,4998447336748294,8721145330583965,8442828773619952,
      -- 5192287176005480,4936767299416160,1322117921687259,8289263492892578,8302045411355921,3222454268823909,
      -- 6101367662980419,3391992685779058,1883435629175529,439370659948282,2676064349857487,1736135669780430,
      -- 6726822857075987,2419707940313040,8893990724261632,198439690762702,1481042189679854,8283287053728190,2740784430534952,
      -- 6502662950301774,1783121096091229,2325879773494169,6233587515167639,1350168988898538,8184444750426970
      --                          ) then 'mechanic'
      --     --when heap_user_id in (834217275233871) then 'financial_analyst'
      --     --when heap_user_id in (631158562416515) then 'comptroller'
      --     when heap_user_id in (3404506503777423,3852811505943975,522470454363515,6881161914665961,7075802167871856,5388043629378901,
      -- 7075802167871856,522470454363515,5388043629378901,6881161914665961
      --                          ) then 'vice_president'
      --     when heap_user_id in (855645871169433,5498293970557942,6922149481761627,6077904676390419,1736191130148804,8619045898346985,
      -- 6286440613011009,3309827838740222,
      -- 6077904676390419,8619045898346985,248397838120127,5498293970557942,855645871169433,4898853415658640,
      -- 7049897492203481,793595530702242,6162105762773480,7738712585263209,6157523874676805,5578031496757878,
      -- 8634702644275299,3847466668026714,975812912430005,1736191130148804,8100622535995545,6922149481761627
      --                          ) then 'ops_manager'
      --     when heap_user_id in (2500270620573616,7549680092220063,8661748149033571,6595204382112637,1536647461678167,5082436784462771,7549680092220063,
      -- 2994886975497743,5822441828306297,5494200311572616,6841669419363632,6736241789689227,7110673022882066,
      -- 4934428980196919,4861594635500407,5082436784462771,8661748149033571,2722175949597802,2500270620573616,
      -- 2583741570113386,2200965061232814,7468477865167537,6595204382112637,1536647461678167,2062944636673760
      --                          ) then 'project_manager'
      --     else 'unknown' end as job_title,
      --lsr.ROLE_GROUP,
      --lower(lsr.link_role_type) as link_role,
      heap_event,
      usage_percent,
      running_total,
      running_total,
      rank ()
      over (
      partition by
      heap_user_id
      order by
      usage_percent desc
      ) app_ranking_usage
      from
      user_app_running_total art
      --join analytics.t3_analytics.link_survey_results lsr on lsr.user_id = art.es_user_id
      where
      running_total <= .85
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: heap_user_id {
    type: number
    sql: ${TABLE}."HEAP_USER_ID" ;;
  }

  dimension: es_user_id {
    type: string
    sql: ${TABLE}."ES_USER_ID" ;;
  }

  dimension: heap_event {
    type: string
    sql: ${TABLE}."HEAP_EVENT" ;;
  }

  dimension: usage_percent {
    type: number
    sql: ${TABLE}."USAGE_PERCENT" ;;
  }

  dimension: running_total {
    type: number
    sql: ${TABLE}."RUNNING_TOTAL" ;;
  }

  dimension: app_ranking_usage {
    type: number
    sql: ${TABLE}."APP_RANKING_USAGE" ;;
  }

  measure: avg_usage {
    type: average
    sql: ${usage_percent} ;;
  }

  measure: min_usage {
    type: min
    sql: ${usage_percent} ;;
  }

  measure: max_usage {
    type: max
    sql: ${usage_percent} ;;
  }

  dimension: rank_app_text {
    type: string
    sql: concat(${app_ranking_usage},' - ',${heap_event}) ;;
  }

  set: detail {
    fields: [heap_user_id, es_user_id, heap_event, usage_percent, running_total]
  }
}
