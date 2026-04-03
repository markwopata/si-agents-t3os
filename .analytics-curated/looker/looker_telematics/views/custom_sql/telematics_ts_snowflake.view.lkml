view: telematics_ts_snowflake {
  derived_table: {
    sql:
    with date_series as
    (
    SELECT dateadd(month,'+' || row_number() over (order by null),
    dateadd(month, '-1','2018-01-01'::timestamp))::date as date
    from table (generator(rowcount => (36)))
    )
    select (date_trunc('month', ds.date) + interval '1 month' - interval '1 day')::date as date
     , a.asset_id, ata.tracker_id, ata.date_installed::date, ata.date_uninstalled::date ,
    case when ata.date_uninstalled is null then 0
    when ata.date_uninstalled > ds.date then 0
    when ata.date_uninstalled <= ds.date then 1 end as deactivated,
    case when ata.date_installed <= date then 1
    else 0 end as installed,
    case when ata.date_uninstalled is null then 1
    when ata.date_uninstalled > ds.date then 1
    when ata.date_uninstalled <= ds.date then 0 end as active,
    xwalk.region_name as region_name
    from ES_WAREHOUSE.PUBLIC.assets as a
    left join ES_WAREHOUSE.PUBLIC.asset_tracker_assignments as ata
    on a.asset_id = ata.asset_id
    left join ES_WAREHOUSE.public.markets as m
    on  a.inventory_branch_id = m.market_id
    left join analytics.PUBLIC.market_region_xwalk as xwalk
    on m.market_id = xwalk.market_id
    inner join date_series ds
    on ds.date BETWEEN ata.date_installed and '2099-12-31'
    where (ata.date_installed::date <> '1970-01-01'
    or ata.date_uninstalled <> '1970-01-01')
    and   (
    a.make||a.model not in (
    'KENT125R',
    'FRDCW24III',
    'CLARKCJ55',
    'MIKASAMVC-82VHW',
    'ESSEX SILVER-LINESL-8',
    'MILLER ELECTRICFILTAIR 130',
    'POWERHORSE52313',
    'WACKER NEUSONPT2A',
    'SANY36" HD BUCKET',
    'SANY12" Mini Excavator Bucket',
    'JOHN DEERE60" Loader Forks',
    'CASE51469715',
    'SPX POWER TEAMP159',
    'STRIKERSC-80',
    'WACKER NEUSONPDT3A',
    'WACKER NEUSONBPU5545A',
    'PRO-LINK4048-U448',
    'LOWEBP-210',
    'CIDHHDFF',
    'HOUGEN MFGHMD130',
    'HOUGEN MFGHMD917',
    'ANTHONY WELDED PROD.85-10',
    'HOUGEN MFGHMD904',
    'WACKER NEUSON80" Bucket',
    'M&B MAGSPT785',
    'YALEMPB040-E',
    'JETPTW-2748',
    'WERNERR410050',
    'EDGE72" Angle Broom',
    'RITRONRLR-465-N',
    'FURUKAWAHPI35IIFB',
    'SPY785',
    'JOHN DEEREWheel Loader Jib',
    'Great NorthernSURFACE CLEANER',
    'TAG MANUFACTURING5R094497',
    'EDGELAF5672-0032',
    'LINCOLN ELECTRICRemote Output Control',
    'ULINEDF25',
    'BILLY GOATSC181H',
    'BOBCAT76" LANDPLANE',
    'TOMAHAWK78" Brush Grapple',
    'GROUND HOGC-71-5 Two Man Auger',
    'BOBCATGRPL 72 ROOT',
    'UNITECEBM 352/3 PSV',
    'JOHN DEEREStandard Construction Fork Frame',
    'DOOSAN72" Pallet Fork 106W',
    'POWERHORSE9000 ES',
    'BALLYMOREBALLYPAL45N',
    'SANY24" HD BUCKET',
    'TSURUMILB-480',
    'BOBCATPALLET FORKS HD',
    'DANUSERT3',
    'FELCO36" Bucket',
    'SKID PROLFFG',
    'SKID PROLXG420S',
    'STRIKERTNB-7J'
    ) or a.model <> 'Dozer Rake')
                                   ;;
  }



  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}.tracker_id ;;
  }

  dimension: date_installed {
    type: date
    sql: ${TABLE}.date_installed ;;
  }

  dimension:region_name {
    type: string
    sql: ${TABLE}.region_name ;;
  }

  dimension: date_uninstalled {
    type: date
    sql: ${TABLE}.date_uninstalled ;;
  }

  dimension: deactivated {
    type: number
    sql: ${TABLE}.deactivated ;;
  }

  dimension: installed {
    type: number
    sql: ${TABLE}.installed ;;
  }

  dimension: active {
    type: number
    sql: ${TABLE}.active ;;
  }

  set: telematics_details {
    fields: [
      asset_id,
      telematics_set.serial_vin,
      telematics_set.asset_year,
      telematics_set.asset_make,
      telematics_set.asset_model,
      telematics_set.tracker_id,
      telematics_set.market_name,
      telematics_set.company_id,
      telematics_set.company_name,
      telematics_set.device_serial,
      telematics_set.tracker_vendor_id,
      telematics_set.tracker_phone_number,
      telematics_set.tracker_type_id,
      telematics_set.tracker_date_created,
      telematics_set.tracker_date_updated,
      telematics_set.tracker_type_desc,
      telematics_set.tracker_type_image,
      telematics_set.tracker_type_name,
      telematics_set.tracker_type_vendor_id,
      telematics_set.is_ble_node,
      telematics_set.tracker_vendor_name
    ]
  }

  measure: active_by_month {
    type: sum
    #label: "61-90 Days"
    drill_fields: [telematics_details*]
    value_format: "#,##0"
    sql: ${active} ;;
  }

  measure: deactivated_by_month {
    type: sum
    #label: "61-90 Days"
    drill_fields: [telematics_details*]
    value_format: "#,##0"
    sql: ${deactivated} ;;
  }

  measure: installed_by_month {
    type: sum
    #label: "61-90 Days"
    drill_fields: [telematics_details*]
    value_format: "#,##0"
    sql: ${installed} ;;
  }




}
