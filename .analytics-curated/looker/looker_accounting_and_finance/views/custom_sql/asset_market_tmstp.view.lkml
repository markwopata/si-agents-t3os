view: asset_market_tmstp {
  derived_table: {
    sql:with asset_selection as (
select distinct asset_id from es_warehouse.public.assets_aggregate
where asset_id in (114751,
122106,
122443,
128652,
134059,
134069,
134590,
135067,
136062,
136384,
137474,
142633,
143992,
148792,
151028,
155130,
160427,
165184,
173299,
175378,
175934,
175989,
177612,
179350,
180070,
182841,
183798,
187066,
188017,
194972,
195238,
198903,
200187,
200667,
200677,
201953,
210006,
210118,
212530,
213254,
216949,
220406,
221095,
227632,
232893,
237608,
242628,
244079,
249441,
257363,
260155,
267111,
267741,
269191,
269252,
269800,
272234,
272732,
279805,
280398,
281750,
282654,
284504,
294993,
296544,
299816,
305450,
306823,
320187,
321250,
324563,
325703,
330532,
332969,
334058,
334828,
345165,
349388,
353948,
371937,
376398,
376867,
393495,
401221,
421337,
426211,
446951,
446956,
448702,
452137,
455206,
455547,
466520,
466538,
470410,
470413,
470841,
472211,
472255,
472361)
)
,market_history as (

select a.asset_id, sr.rental_branch_id, sr.date_start, sr.date_end, isp.inventory_branch_id, ms.service_branch_id

from asset_selection a
left join ES_WAREHOUSE.SCD.SCD_ASSET_RSP sr
 on a.asset_id = sr.asset_id
left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_SCD__SCD_ASSET_INVENTORY isp
on isp.asset_id = sr.asset_id and sr.date_start >= isp.date_start and sr.date_end <= isp.date_end
left join ES_WAREHOUSE.SCD.SCD_ASSET_MSP ms
on ms.asset_id = sr.asset_id and sr.date_start >= ms.date_start and sr.date_end <= ms.date_end

 )
,filtering as (
  select asset_id, date_start, date_end,
  case when rental_branch_id is not null then rental_branch_id
  when rental_branch_id is null and inventory_branch_id is not null then inventory_branch_id
  when rental_branch_id is null and inventory_branch_id is null then service_branch_id
  end as market_id
  from market_history
  )

  select asset_id, date_start, date_end, f.market_id, m.name market_name, s.abbreviation state
  from filtering f
  left join es_warehouse.public.markets m
    on m.market_id = f.market_id and m.active = TRUE
left join ES_WAREHOUSE.PUBLIC.LOCATIONS l
    on l.location_id = m.location_id
left join ES_WAREHOUSE.PUBLIC.STATES s
    on s.state_id = l.state_id
     {% if timestamp._parameter_value != "" %}
  where {{ timestamp._parameter_value }} between f.date_start and f.date_end
{% endif %};;
  }

   dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
    primary_key: yes
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: MARKET_NAME {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension_group: date_start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_START" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_end {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_END" AS TIMESTAMP_NTZ) ;;
  }

parameter: timestamp {
  type: date_time
  allowed_value: {
    label: "2025-04-30 23:59:59"
    value: "2025-04-30 23:59:59"
  }
}
}
