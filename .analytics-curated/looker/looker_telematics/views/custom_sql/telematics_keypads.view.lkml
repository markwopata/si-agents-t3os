view: telematics_keypads {

  derived_table: {
    sql:select a.asset_id as asset_id, a.serial_number as serial_number, cat.name as category, a.make as make, a.model as model,
a.tracker_id as tracker_id, a.company_id as company_id, r.rental_id as rental_id, rs.name as rental_status, m.name as inventory_branch,
    l.nickname as job_site, l.street_1 as street_address_1, l.city as city, s.name as state,
    l.zip_code as zip_code, l.latitude as latitude, l.longitude as longitude, k.keypad_id as keypad_id,
    a.tracker_id as tracker_on_asset_table, ata.tracker_id as tracker_from_assignments,
    ata.date_installed as date_installed, ata.date_uninstalled as date_uninstalled, ea2.start_date::date as start_date, ec.name as equipment_category, ec.company_division_id as comapny_division_id, cd.name as division,
    xwalk.region_name as region_name
  from ES_WAREHOUSE."PUBLIC".assets a left join ES_WAREHOUSE."PUBLIC".keypads k on a.asset_id = k.asset_id
  join (select max(equipment_assignment_id) max_id, asset_id from ES_WAREHOUSE."PUBLIC".equipment_assignments group by asset_id) as ea on ea.asset_id = a.asset_id
  join ES_WAREHOUSE."PUBLIC".equipment_assignments ea2 on ea2.equipment_assignment_id = ea.max_id
  join ES_WAREHOUSE."PUBLIC".rentals r on r.rental_id = ea2.rental_id
  join analytics."PUBLIC".rental_statuses rs on rs.rental_status_id = r.rental_status_id
  join (select max(rental_location_assignment_id) max_rla_id, rental_id from ES_WAREHOUSE."PUBLIC".rental_location_assignments group by rental_id) as rla on rla.rental_id = r.rental_id
  join ES_WAREHOUSE."PUBLIC".rental_location_assignments rla2 on rla2.rental_location_assignment_id = rla.max_rla_id
  join ES_WAREHOUSE."PUBLIC".locations l on l.location_id = rla2.location_id
  join ES_WAREHOUSE."PUBLIC".states s on s.state_id = l.state_id
  left join ES_WAREHOUSE."PUBLIC".categories cat on a.category_id = cat.category_id
  left join ES_WAREHOUSE."PUBLIC".equipment_models as em on a.equipment_model_id = em.equipment_model_id
  left join ES_WAREHOUSE."PUBLIC".equipment_classes_models_xref x
  on (a.equipment_model_id = x.equipment_model_id) and (em.equipment_model_id = x.equipment_model_id)
  left join ES_WAREHOUSE."PUBLIC".equipment_classes as ec
  on x.equipment_class_id = ec.equipment_class_id
  left join ES_WAREHOUSE."PUBLIC".company_divisions as cd
on ec.company_division_id = cd.company_division_id
  left join ES_WAREHOUSE."PUBLIC".asset_tracker_assignments ata on a.asset_id=ata.asset_id
  left join ES_WAREHOUSE."PUBLIC".markets m on a.inventory_branch_id = m.market_id
  left join analytics."PUBLIC".market_region_xwalk as xwalk on m.market_id = xwalk.market_id
where a.tracker_id is null and a.company_id in(1854,61036) and SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-'
and a.make not in ('AIRMASTER','AMERICAN PNEUMATIC TOOL','ARMADILLO','ARROW MATERIAL HANDLING', 'ARROW MATERIAL','BLUE DIAMOND','B&B','B&B STEEL PRODUCTS','Big Tex','BOBCAT 250','BOSCH','BS60-4As','B-RAD','CEPCO','CDI','CENTRAL MACHINERY','CENTEX',
'CHICAGO PNEUMATIC','Clarke','CONSTRUCTION ELECTRICAL PRODUCTS','COPPUS','CORE CUT','DAYTON','DEWALT','D&E MANUFACTURING','Diamond','Drill','DRI-EAZ','E-BOX','EDCO','EQUIPRITE','FIRMAN','FOSTORIA','GAR-BRO','GEARENCG MFG','Generic','GENERAC','GME','GODWIN','GREENLEE','HAUL MASTER','HARRINGTON','HILMAN ROLLERS','HILTI','Hilti','H&M','HUSQVARNA','LIND EQUIPMENT','Industrial Air Tool','IRONTON','Jobox',
'LoadTrail','MAKITA','MAGNUM','Mi-T-M Corporation','MESTEK','MICHIGAN PNEUMATIC','MILWAUKEE','MILLER','MISKIN','MSA','Motorola','MOTOROLA','PALADIN','Pallet Jack','POTTY PORTABLES','Powerhorse','POWER BREEZER','POWER TEAM','PINNACLE','Portacool','PORTACOOL','PROTO','PT3','RIDGID','Salvation','SATELLITE INDUSTRIES','SIMPSON','SOUTHWIRE','SOUTHWIRE COMPANY','STAR INDUSTRIES','STIHL',
'STRONGWAY','Sumner','SUMNER','TEXAS','Texas Pneumatic Tools, Inc.','TITAN','TPI','TOKU','TORCUP','TRYSTAR','UNIVERSAL TOOL','US HAMMER','WERK-BRAU','WOODS','VESTIL','VIRNIG')
and a.model not in ('1001142247','01970-3R02','1YNW7','6 Fork Extensions','413-R','4HDX2','444-624','48" Pallet Forks','8-Way Distribution Box','15H','10 Ton Hook','17L53-SS-ES','24" Shop Fan','AERO 40FP','Aero 40FP','BS50-4As','BS60-4As','BVP 18/45',
'CICST-280','CP1260','CP1290','CP4608','CST-280','CST280','CRT48','CT36','CT48','DG150','DPU90r','DPU4545HEH','DPU4545','Dump Hopper','DPH-38','Drill','EMP 205IC','eu2200i','EU2200i','FLEXTEC 350X','FT350X','FX25','GP2500A','GP5500','GP6600',
'GP6600A','GP9700','GP9700V','GPS9700V','HB36','HB980','HI400','H1400','HDR155','H51','Invertec V275-FS',' Invertec V275-S','INVERTEC V275-S','J6014C','Jib Winch','LF100','LN-25X','LN25','LN25 PRO','LM25 PRO','MCH-3','Millermatic 211','MOTRDU4100','Multimatic 215','MPB 60A','MPB 90A',
'MC94SH8','M2500','Pallet Jack','Pallet fork attachment','PAS2400','PST2','PT2','PT3','PT3A','PT4','PT4A','RB300ME','S3C','SB552','SLA-10','SLC-24','Telehandler Bucket','TE-50 AVR','TE 1000-AVR','THUNDERBOLT 160 DC',
'TE-3000 AVR','TOMAHAWK 375 AIR Plasma Cutter','TLR33','TNB-4M','Triple L 4610','TZ-34/20','TPB-90','UT7K','V275-S','WMS-100','WP1550AW','WP1550Aw','WP1550Aw US','WT5C','X-Tractor 1GC')
and cat.name not in  ('Attachments - CTL and Skid Steers',
'Attachments - Mini Excavators',
'Attachments - Track Excavators','Plate Compactors','Pony Motors',
'Attachments - Dozers',
'Ramps','Tractor Trailers','Trailers','Water Trailers','Misc. Trailers','Equipment Trailers''Centrifugal Pumps','Submersible Pumps')
and ata.tracker_id is null
and (
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
'WACKER NEUSON-PDT3',
'WACKER NEUSON-PDT2',
'MULTIQUIP-GAW180HEA',
'VERMEER-VPT300',
'KENT-125R',
'CLARK-CGC40',
'MIKASA-MVC-82VHW',
'MULTIQUIP-GAW180HEA',
'KENT-125R',
'MIKASA-MVC-82VHW',
'VERMEER-VPT300',
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
    sql: ${TABLE}.serial_number ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}.tracker_id ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}.rental_id ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}.rental_status ;;
  }

  dimension: inventory_branch {
    type: string
    sql: ${TABLE}.inventory_branch ;;
  }

  dimension: job_site {
    type: string
    sql: ${TABLE}.job_site ;;
  }

  dimension: street_address_1 {
    type: string
    sql: ${TABLE}.street_address_1 ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}.region_name ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: zip_code {
    type: number
    sql: ${TABLE}.zip_code ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: keypad_id {
    type: number
    sql: ${TABLE}.keypad_id ;;
  }

  dimension: tracker_on_asset_table {
    type: number
    sql: ${TABLE}.tracker_on_asset_table ;;
  }

  dimension: tracker_from_assignments {
    type: number
    sql: ${TABLE}.tracker_from_assignments ;;
  }

  dimension: date_installed {
    type: date
    sql: ${TABLE}.date_installed ;;
  }

  dimension: date_uninstalled {
    type: date
    sql: ${TABLE}.date_uninstalled ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}.start_date ;;
  }

  dimension: equipment_category {
    type: string
    sql: ${TABLE}.equipment_category ;;
  }

  dimension: company_division_id {
    type: number
    sql: ${TABLE}.company_division_id ;;
  }

  dimension: division {
    type: string
    sql: ${TABLE}.division ;;
  }

  set: telematics_db_details {
    fields: [asset_id,serial_number,equipment_category,make,model,tracker_id,company_id,rental_id,rental_status,inventory_branch,job_site,street_address_1,city,state,zip_code,
      latitude,longitude,tracker_on_asset_table,tracker_from_assignments,date_installed,start_date, division]
  }


  measure: asset_count {
    type: count_distinct
    drill_fields: [telematics_db_details*]
    sql: ${asset_id} ;;
  }


}
