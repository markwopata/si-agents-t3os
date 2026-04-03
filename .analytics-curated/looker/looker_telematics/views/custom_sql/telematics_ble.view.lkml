
view: telematics_ble {

  derived_table: {
    sql: select a.asset_id as asset_id, a.serial_number as serial_number, cat.name as category, a.make as make, a.model as model, a.tracker_id as tracker_id,
      a.company_id as company_id, r.rental_id as rental_id, rs.name as rental_status, m.name as inventory_branch,
      l.nickname as job_site, l.street_1 as street_address_1, l.city as city, s.name as state, l.zip_code as zip_code, l.latitude as latitude, l.longitude as longitude,
      a.tracker_id as tracker_on_asset_table, ata.tracker_id as tracker_from_assignments, ata.date_installed as date_installed, ata.date_uninstalled as date_uninstalled, ea2.start_date::date start_date, xwalk.region_name as region_name
      from ES_WAREHOUSE."PUBLIC".assets a
      join (select max(equipment_assignment_id) max_id, asset_id from ES_WAREHOUSE."PUBLIC".equipment_assignments group by asset_id) as ea on ea.asset_id = a.asset_id
      join ES_WAREHOUSE."PUBLIC".equipment_assignments ea2 on ea2.equipment_assignment_id = ea.max_id
      join ES_WAREHOUSE."PUBLIC".rentals r on r.rental_id = ea2.rental_id
      join analytics."PUBLIC".rental_statuses rs on rs.rental_status_id = r.rental_status_id
      join (select max(rental_location_assignment_id) max_rla_id, rental_id from ES_WAREHOUSE."PUBLIC".rental_location_assignments group by rental_id) as rla on rla.rental_id = r.rental_id
      join ES_WAREHOUSE."PUBLIC".rental_location_assignments rla2 on rla2.rental_location_assignment_id = rla.max_rla_id
      join ES_WAREHOUSE."PUBLIC".locations l on l.location_id = rla2.location_id
      join ES_WAREHOUSE."PUBLIC".states s on s.state_id = l.state_id
      left join ES_WAREHOUSE."PUBLIC".categories cat on a.category_id = cat.category_id
      left join ES_WAREHOUSE."PUBLIC".equipment_classes_models_xref x on a.equipment_model_id = x.equipment_model_id
      left join ES_WAREHOUSE."PUBLIC".asset_tracker_assignments ata on a.asset_id=ata.asset_id
      left join ES_WAREHOUSE."PUBLIC".markets m on a.inventory_branch_id = m.market_id
      left join ANALYTICS.public.MARKET_REGION_XWALK xwalk on m.market_id = xwalk.market_id
      where a.company_id ='1854' and SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-'
      and (cat.name in ('Attachments','AG Tractors','Agriculture & Landscaping','Cutting & Coring','Electrical Equipment',
      'Fans & Dehumidifiers','Forklift Attachments','Fuel Storage','Heaters','Masonry & Tile Saws','Mixers','Power Tools','Power Tools & Small Equipment','Plate Compactors',
      'Pressure Washers & Pumps','Rammers','Surface Preparation','Storage Containers','Water Truck','Water Trailer','Waste Containers','Pony Motors'
      )
      and cat.name  <> 'Submersible Pumps'
      or a.make in ('AMERICAN PNEUMATIC TOOL','ARROW MATERIAL HANDLING', 'ARROW MATERIAL','BLUE DIAMOND','B&B','Big Tex','BS60-4As','CEPCO','CDI','CENTEX',
      'CHICAGO PNEUMATIC','Clarke','CONSTRUCTION ELECTRICAL PRODUCTS','COPPUS','CORE CUT','DEWALT','Diamond','Drill','DRI-EAZ','E-BOX',
      'GAR-BRO','HILMAN ROLLERS','HILTI','Hilti','HUSQVARNA','LoadTrail','Mi-T-M Corporation','MICHIGAN PNEUMATIC','MILLER','MISKIN','PALADIN',
      'Pallet Jack','POTTY PORTABLES','PINNACLE','PT3','Salvation','SATELLITE INDUSTRIES','STAR INDUSTRIES','STIHL','STRONGWAY','Sumner',
      'TEXAS','TITAN','TRYSTAR','UNIVERSAL TOOL','EDGE','NORTHSTAR','Okada')
      or a.model in ('6 Fork Extensions','413-R','4HDX2','8-Way Distribution Box','15H','10 Ton Hook','17L53-SS-ES','24" Shop Fan','AERO 40FP','Aero 40FP','Bobcat 250','BS50-4As','BS60-4As','BVP 18/45',
      'CICST-280','CP1260','CP1290','CP4608','CST-280','CST280','CRT48','CT36','CT48','DG150','Dump Hopper','DPH-38','Drill','EMP 2-5IC','eu2200i','FT350X','GP2500A','GP5500','GP6600',
      'GP6600A','GP9700','GP9700V','GPS9700V','HB36','HI400','H1400','HDR155','Invertec V275-FS',' Invertec V275-S','Jib Winch','LF100','LN25','LN25 PRO','LM25 PRO','MPB 90A',
      'MC94SH8','M2500','Pallet Jack','Pallet fork attachment','PT2','PT3','PT3A','PT4','PT4A','RB300ME','S3C','SB552','SLA-10','SLC-24','Telehandler Bucket','TE-50 AVR','TE 1000-AVR',
      'TE-3000 AVR','TNB-4M','Triple L 4610','TS420','TZ-34/20','TPB-90','UT7K','V275-S','WMS-100','WP1550AW','WP1550Aw','WP1550Aw US','WT5C')
      and a.model not in ('48" Pallet Forks','48" Skid Loader Pallet Forks','60" Loader Forks','42" Pallet Forks'))
      --and cat.category not in ('Attachments - CTL and Skid Steers',
--'Attachments - Mini Excavators',
--'Attachments - Track Excavators',
--'Attachments - Dozers')
      and  (
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
      'STRIKERTNB-7J',
      'WACKER NEUSONPG3A',
'WACKERP35A',
'WACKER NEUSONP35A',
'Diesel LaptopsDIESEL LAPTOP',
'MEGADECK103635 Mat'
      ) or a.model <> 'Dozer Rake')
      and a.asset_id not in (131277,75798,135200,126657,116163,132500,137948,137949,102636,130341,137947)
      ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}.serial_number;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}.region_name;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}.model;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id;;
  }

  dimension:rental_id {
    type: number
    sql: ${TABLE}.rental_id;;
  }

  dimension:rental_status {
    type: string
    sql: ${TABLE}.rental_status;;
  }

  dimension: inventory_branch {
    type: string
    sql: ${TABLE}.inventory_branch;;
  }

  dimension: job_site {
    type: string
    sql: ${TABLE}.job_site;;
  }

  dimension: street_address_1 {
    type: string
    sql: ${TABLE}.street_address_1;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state;;
  }

  dimension: zip_code {
    type: number
    sql: ${TABLE}.zip_code;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.zip_code;;
  }

  dimension: tracker_on_asset_table {
    type: number
    sql: ${TABLE}.tracker_on_asset_table;;
  }

  dimension: tracker_from_assignments {
    type: number
    sql: ${TABLE}.tracker_from_assignments;;
  }

  dimension: date_installed {
    type: date
    sql: ${TABLE}.date_installed;;
  }

  dimension:date_uninstalled {
    type: date
    sql: ${TABLE}.uninstalled;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}.start_date;;
  }

  set: telematics_db_details {
    fields: [asset_id,serial_number,category,make,model,tracker_id,company_id,rental_id,rental_status,inventory_branch,job_site,street_address_1,city,state,zip_code,
      latitude,longitude,tracker_on_asset_table,tracker_from_assignments,date_installed,start_date]
  }

  measure: asset_count {
    type: count_distinct
    drill_fields: [telematics_db_details*]
    sql: ${asset_id} ;;
  }


  dimension: branch_link {
    type: string
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/147" target="_blank">Branch</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: trackers_link {
    type: string
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/148" target="_blank">Trackers</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: wo_link {
    type: string
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/187" target="_blank">Work Orders</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: keypads_link {
    type: string
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/149" target="_blank">Keypads</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: ble_link {
    type: string
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/150" target="_blank">BLE</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: trackers_by_month_link {
    type: string
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/152" target="_blank">Trackers by Month</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: AR_link {
    type: string
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/138" target="_blank">Accounts Receivable</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: Work_Order_Time_Tracking {
    type: string
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/158" target="_blank">Work Order Time Tracking</a></font></u>   ;;
    sql: ${asset_id};;
  }

  dimension: navbar {
    html: <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/147" >
      <img border="0" alt="altText" src="https://img.icons8.com/pastel-glyph/64/000000/warehouse.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      BRANCH
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/148" >
      <img border="0" alt="altText" src="https://img.icons8.com/external-dreamstale-lineal-dreamstale/64/000000/external-tracker-fitness-dreamstale-lineal-dreamstale-2.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      TRACKERS
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/149" >
      <img border="0" alt="altText" src="https://img.icons8.com/ios/50/000000/keypad.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      KEYPADS
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/187" >
      <img border="0" alt="altText" src="https://img.icons8.com/carbon-copy/100/000000/purchase-order.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      WORK ORDERS
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/150" >
      <img border="0" alt="altText" src="https://img.icons8.com/material-two-tone/24/000000/wireless-cloud-access.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      BLE
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/138" >
      <img border="0" alt="altText" src="https://img.icons8.com/wired/64/000000/purchase-order.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      ACCOUNTS RECEIVABLE
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/152" >
      <img border="0" alt="altText" src="https://img.icons8.com/carbon-copy/100/000000/calendar.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      TRACKERS BY MONTH
      </f>
      </i></p>
       <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/294" >
      <img border="0" alt="altText" src="https://img.icons8.com/dotty/80/000000/owl.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      OWLCAM
      </f>
      </i></p>
       <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards-next/302" >
      <img border="0" alt="altText" src="https://img.icons8.com/metro/26/000000/lost-and-found.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      OUT OF LOC
      </f>
      </i></p>
       <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/314" >
      <img border="0" alt="altText" src="https://img.icons8.com/wired/64/000000/engineer.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      CONTRACTOR OWNED
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards-next/326" >
      <img src="https://img.icons8.com/wired/64/000000/tire-track.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      Assets with New Tracker Work Order without Tracker ID
      </f>
      </i></p>
      ;;
    sql: ${asset_id} ;;
  }




}
