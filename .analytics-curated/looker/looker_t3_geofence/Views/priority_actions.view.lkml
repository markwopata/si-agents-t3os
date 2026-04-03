view: priority_actions {

  derived_table: {
    sql:
select
    asset_id, null as geofence_id, FALSE AS ASSET_TRANSFER_SUGGESTION, FALSE AS ON_RENT_SUGGESTION, FALSE AS OFF_RENT_SUGGESTION,
    ownership,

    CASE
    WHEN TRACKER_HEALTH_STATUS = 'Healthy - HEALTHY' THEN 'OPTIMIZE (Opportunity)'
    WHEN TRACKER_HEALTH_STATUS NOT IN (
      'Asset Likely In Low Cell Coverage Area - LIKELY IN LOW CELL COVERAGE AREA',
      'Asset Likely Under Cover or Inside Building - LIKELY UNDER COVER OR INSIDE BUILDING',
      'Asset Likely Under Cover or Inside Building - STALE GPS > 90 DAYS',
      'Asset Likely Under Cover or Inside Building - STALE GPS > 96 HRS',
      'Needs Tracker Attention - STALE GPS 60-180 DAYS AERIAL'
    ) THEN 'ACT NOW (Critical)'
    ELSE 'DECIDE THIS WEEK (Warning)'
    END AS PRIORITY_ACTION_TYPE,

    CASE WHEN TRACKER_HEALTH_STATUS = 'Healthy - HEALTHY' THEN 'Description: test opportunity. Recommendation: test opportunity.'
    WHEN TRACKER_HEALTH_STATUS IN ('Dead Asset Battery - DEAD ASSET BATTERY', 'Drained Asset Battery - DRAINED ASSET BATTERY')
        THEN 'Description: Battery of this asset is dead. Recommendation: Communicate with fleet or rental manager to get the battery replaced.'
    WHEN TRACKER_HEALTH_STATUS IN (
      'Asset Likely In Low Cell Coverage Area - LIKELY IN LOW CELL COVERAGE AREA',
      'Asset Likely Under Cover or Inside Building - LIKELY UNDER COVER OR INSIDE BUILDING',
      'Asset Likely Under Cover or Inside Building - STALE GPS > 90 DAYS',
      'Asset Likely Under Cover or Inside Building - STALE GPS > 96 HRS',
      'Needs Tracker Attention - STALE GPS 60-180 DAYS AERIAL'
    ) THEN 'Description: Stale GPS, possibly due to location interference. Recommendation: Have a technician inspect the GPS and/or have an operator check for location interfence of signal.'
    WHEN TRACKER_HEALTH_STATUS IN ('No Tracker Installed - NO TRACKER INSTALLED', 'Master Cutoff Switch/Tracker Disconnected - MASTER CUTOFF SWITCH/TRACKER DISCONNECTED')
        THEN 'Description: No tracker installed or tracker disconnected. Recommendation: Determine if intentional. If not, address immediately to start tracking utilization of asset.'
    ELSE 'Description: Stale communications from tracker for an extended period of time. Recommendation: Have a technician inspect and diagnose the problem.'
    END AS DESCRIPTION_AND_RECOMMENDATION
from business_intelligence.triage.stg_t3__geofence_asset_usage gau
    WHERE gau.TRACKER_HEALTH_STATUS is not null
    AND gau.ownership != 'PAST RENTAL'
    AND gau.COMPANY_ID =
    CASE WHEN {{ _user_attributes['company_id'] }}::numeric = 1854
    THEN 109154
    ELSE  {{ _user_attributes['company_id'] }}::numeric END
GROUP BY ALL
          ;;
  }


    dimension: asset_id {
      type: number
      primary_key: yes
      sql: ${TABLE}.ASSET_ID ;;
    }

    dimension: geofence_id {
      type: number
      sql: ${TABLE}.GEOFENCE_ID ;;
    }

    dimension: asset_transfer_suggestion {
      type: string
      sql: ${TABLE}.ASSET_TRANSFER_SUGGESTION ;;
    }

    dimension: on_rent_suggestion {
      type: string
      sql: ${TABLE}.ON_RENT_SUGGESTION ;;
    }

    dimension: off_rent_suggestion {
      type: string
      sql: ${TABLE}.OFF_RENT_SUGGESTION ;;
    }

    dimension: ownership {
      type: string
      sql: ${TABLE}.OWNERSHIP ;;
    }

    dimension: priority_action_type {
      type: string
      sql: ${TABLE}.PRIORITY_ACTION_TYPE ;;
    }

    dimension: description_and_recommendation {
      type: string
      sql: ${TABLE}.DESCRIPTION_AND_RECOMMENDATION ;;
    }





}
