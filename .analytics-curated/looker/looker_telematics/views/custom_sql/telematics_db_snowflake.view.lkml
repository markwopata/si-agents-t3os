view: telematics_db_snowflake {

  derived_table: {
    sql:  select a.asset_id as asset_id,
a.serial_number as serial_number,
cat.category as category,
a.make as make,
a.model as model,
a.tracker_id as tracker_id,
a.company_id as company_id,
r.rental_id as rental_id,
rs.name as rental_status,
m.name as inventory_branch,
l.nickname as job_site,
l.street_1 as street_address_1,
l.city as city,
s.name as state,
l.zip_code as zip_code,
l.latitude as latitude,
l.longitude as longitude,
a.tracker_id as tracker_on_asset_table,
ata.tracker_id as tracker_from_assignments,
ata.date_installed as date_installed,
ata.date_uninstalled as date_uninstalled,
ea2.start_date::date as start_date,
ea2.start_date::time as start_date_time,
xwalk.region_name as region_name,
rc.NAME AS renting_company,
u.first_name || ' ' || u.last_name as contact_name,
u.email_address as email_address,
u.phone_number as phone_number,
r.start_date as rental_start_date,
r.end_date as rental_end_date,
tt.name as tracker_type
from ES_WAREHOUSE."PUBLIC".assets a
  left join (select max(equipment_assignment_id) max_id, asset_id from ES_WAREHOUSE."PUBLIC".equipment_assignments group by asset_id) as ea on ea.asset_id = a.asset_id
  left join ES_WAREHOUSE."PUBLIC".equipment_assignments ea2 on ea2.equipment_assignment_id = ea.max_id
  left join ES_WAREHOUSE."PUBLIC".rentals r on r.rental_id = ea2.rental_id
  left join ANALYTICS.public.rental_statuses rs on rs.rental_status_id = r.rental_status_id
  left join (select max(rental_location_assignment_id) max_rla_id, rental_id from ES_WAREHOUSE."PUBLIC".rental_location_assignments group by rental_id) as rla on rla.rental_id = r.rental_id
  left join ES_WAREHOUSE."PUBLIC".rental_location_assignments rla2 on rla2.rental_location_assignment_id = rla.max_rla_id
  left join ES_WAREHOUSE."PUBLIC".locations l on l.location_id = rla2.location_id
  left join ES_WAREHOUSE."PUBLIC".states s on s.state_id = l.state_id
  left join ES_WAREHOUSE."PUBLIC".assets_aggregate cat on a.asset_id = cat.asset_id
  left join ES_WAREHOUSE."PUBLIC".equipment_classes_models_xref x on a.equipment_model_id = x.equipment_model_id
  left join ES_WAREHOUSE."PUBLIC".asset_tracker_assignments ata on a.asset_id=ata.asset_id
  left join ES_WAREHOUSE."PUBLIC".markets m on a.inventory_branch_id = m.market_id
  left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as xwalk on m.market_id = xwalk.market_id
  left join ES_WAREHOUSE.public.orders as o on r.order_id = o.order_id
  left join ES_WAREHOUSE.public.users as u on o.user_id = u.user_id
  LEFT JOIN ES_WAREHOUSE.public.companies as rc on rc.company_id = u.company_id
  left join ES_WAREHOUSE.PUBLIC.TRACKERS as trk on a.tracker_id = trk.tracker_id
  left join ES_WAREHOUSE.PUBLIC.TRACKER_TYPES as tt on trk.TRACKER_TYPE_ID = tt.TRACKER_TYPE_ID
where a.tracker_id is null and a.company_id in(1854,61036) and SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-'
and cat.category not in ('Attachments','AG Tractors','Agriculture & Landscaping','Cutting & Coring','Electrical Equipment','Fans',
'Fans & Dehumidifiers','Forklift Attachments','Forklift and Telehandler Attachments','Fuel Storage','Heaters','Masonry & Tile Saws','Mixers','Power Tools','Power Tools & Small Equipment',
'Pressure Washers & Pumps','Rammers','Surface Preparation','Storage Containers','Water Truck','Water Trailer','Waste Containers', 'Pony Motors',
'Attachments - CTL and Skid Steers',
'Attachments - Mini Excavators',
'Attachments - Track Excavators','Plate Compactors',
'Ramps','Tractor Trailers','Trailers','Water Trailers','Misc. Trailers','Equipment Trailers''Centrifugal Pumps','Submersible Pumps',
'Attachments - Dozers')
and a.make not in ('AIRMASTER','AMERICAN PNEUMATIC TOOL','ARMADILLO','ARROW MATERIAL HANDLING', 'ARROW MATERIAL','BLUE DIAMOND','B&B','B&B STEEL PRODUCTS','Big Tex','BOBCAT 250','BOSCH','BS60-4As','B-RAD','CEPCO','CDI','CENTRAL MACHINERY','CENTEX',
'CHICAGO PNEUMATIC','Clarke','CONSTRUCTION ELECTRICAL PRODUCTS','COPPUS','CORE CUT','DAYTON','DEWALT','D&E MANUFACTURING','Diamond','Drill','DRI-EAZ','E-BOX','EDCO','EQUIPRITE','FIRMAN','FOSTORIA','GAR-BRO','GEARENCG MFG','Generic','GENERAC','GME','GODWIN','GREENLEE','HAUL MASTER','HARRINGTON','HILMAN ROLLERS','HILTI','Hilti','H&M','HUSQVARNA','LIND EQUIPMENT','Industrial Air Tool','IRONTON','Jobox',
'LoadTrail','MAKITA','MAGNUM','Mi-T-M Corporation','MESTEK','MICHIGAN PNEUMATIC','MILWAUKEE','MILLER','MISKIN','MSA','Motorola','MOTOROLA','PALADIN','Pallet Jack','POTTY PORTABLES','Powerhorse','POWER BREEZER','POWER TEAM','PINNACLE','Portacool','PORTACOOL','PROTO','PT3','RIDGID','Salvation','SATELLITE INDUSTRIES','SIMPSON','SOUTHWIRE','SOUTHWIRE COMPANY','STAR INDUSTRIES','STIHL',
'STRONGWAY','Sumner','SUMNER','TEXAS','Texas Pneumatic Tools, Inc.','TITAN','TPI','TOKU','TORCUP','TRYSTAR','UNIVERSAL TOOL','US HAMMER','WERK-BRAU','WOODS','VESTIL','VIRNIG')
and a.model not in ('1001142247','01970-3R02','1YNW7','6 Fork Extensions','413-R','4HDX2','444-624','48" Pallet Forks','8-Way Distribution Box','15H','10 Ton Hook','17L53-SS-ES','24" Shop Fan','AERO 40FP','Aero 40FP','BS50-4As','BS60-4As','BVP 18/45',
'CICST-280','CP1260','CP1290','CP4608','CST-280','CST280','CRT48','CT36','CT48','DG150','DPU90r','DPU4545HEH','DPU4545','Dump Hopper','DPH-38','Drill','EMP 205IC','eu2200i','EU2200i','FLEXTEC 350X','FT350X','FX25','GP2500A','GP5500','GP6600',
'GP6600A','GP9700','GP9700V','GPS9700V','HB36','HB980','HI400','H1400','HDR155','H51','Invertec V275-FS',' Invertec V275-S','INVERTEC V275-S','J6014C','Jib Winch','LF100','LN-25X','LN25','LN25 PRO','LM25 PRO','MCH-3','Millermatic 211','MOTRDU4100','Multimatic 215','MPB 60A','MPB 90A',
'MC94SH8','M2500','Pallet Jack','Pallet fork attachment','PAS2400','PST2','PT2','PT3','PT3A','PT4','PT4A','RB300ME','S3C','SB552','SLA-10','SLC-24','Telehandler Bucket','TE-50 AVR','TE 1000-AVR','THUNDERBOLT 160 DC',
'TE-3000 AVR','TOMAHAWK 375 AIR Plasma Cutter','TLR33','TNB-4M','Triple L 4610','TZ-34/20','TPB-90','UT7K','V275-S','WMS-100','WP1550AW','WP1550Aw','WP1550Aw US','WT5C','X-Tractor 1GC',
'JT2500','804536','8000','GP3800','GP3800A','QP-3TH','QP3TK','MQ-QP3TH','QP3TH','QT4TH','QP-4TH','KONECRANES' , 'ENERPAC', 'PT20100', 'PT40100', '5100004048', '5000610015'
)
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
'WACKER NEUSONPDT3',
'WACKER NEUSONPDT2',
'MULTIQUIPGAW180HEA',
'KENT125R',
'CLARKCGC40',
'MIKASAMVC-82VHW',
'VERMEERVPT300',
'JETJBC-2',
'ABATEMENT TECHNOLOGIESAG3000MCCK',
'ABATEMENT TECHNOLOGIESAG8000PAS',
'ABATEMENT TECHNOLOGIESPAS750',
'AEROSPACE9143',
'AGRILAND500gal Fuel Cell',
'ALLEGRO9518-03',
'ALLEN436VP',
'ALLENTWP4365HF',
'ALLENTWP4469HF',
'AMERICANAPG3009N',
'ASCOAVTRON 2705',
'ASCO2805',
'BesseySC 110V',
'BESTTB6X12',
'BESTTB82X16T',
'BETTER BUILT100 Gallon Transfer Tank',
'BETTER BUILT29211677',
'BILLY GOATKV650H',
'BRIGGS & STRATTONP3000',
'BULLDOG1000W Light Cart',
'CLARKWPX45',
'CLEMCOBLASTER 11260',
'Columbus McKinnon09002W',
'CORNELL8NNT-RP-EM18DB-3',
'CROWNWP3035-45',
'DIAMOND C TRAILERSDSA-12T',
'DIAMOND C TRAILERSHDT-20',
'DIAMOND C TRAILERSHDT-22T',
'DIAMOND C TRAILERSHDT-18T',
'DOOLITTLEDeckover',
'DOOLITTLEEZ Load GT',
'DOOLITTLEMD821414KSR',
'DOOSANAC25',
'DURALIFTHPT27X48PH-12H',
'ENERPACHCG-2006',
'ESCOAPS-438',
'ESCOM-300',
'ESSEX SILVER-LINE1218R',
'ESSEX SILVER-LINEESL17',
'GARDNER BENDERB2000',
'GEARWRENCHP95-525 GEARWRENCH',
'GEARWRENCHPHD0535 GEARWRENCH',
'GENIEGL-8',
'GENIESLC-18',
'SULLAIRMPB 30A',
'GRACOUltimate MX II 650',
'HOBARTIronman 230',
'HONEYWELLBWC2-H',
'HOUGEN MFGHMD934',
'HydrotechSC Pressure Washer',
'HYSTERW45ZHD',
'INGERSOLL RAND285B-6',
'INGERSOLL RAND2145QiMAX',
'INGERSOLL-RANDW7152P-K22',
'INGERSOLL-RAND3A2SA',
'INGERSOLL-RAND5980A1',
'INGERSOLL-RAND2171XP',
'INTERQUIPLKS450-3.2',
'JLGTriple L 7614',
'KARCHERKM 75/40 W BP',
'KEEN OVENSK-10',
'KEEN OVENSK-50',
'KEMCOU14',
'KEY PLANTAHPS4',
'KOBALT1/2" Torque Wrench',
'KOSHINKTH-80S',
'LAMARDL',
'LANDAMHC3',
'LANDAPHW4-30024B',
'LE JEUNEGS-91EZ',
'LedwelPony Motor',
'LINCOLNLHC857-100',
'LINCOLN ELECTRICDual Maverick 200/200X',
'LINCOLN ELECTRICK2269-3',
'LINCOLN ELECTRICK3430-1',
'LINCOLN ELECTRICK4277-1',
'LINCOLN ELECTRICPOWER MIG 210MP',
'LINCOLN ELECTRICRanger 305 LPG',
'LINCOLN ELECTRICTOMAHAWK 1000',
'LOADTRAILSH7712',
'LOADTRAILTilt-Deck Rental Trailer',
'MAXXDG6X8320',
'MILLER ELECTRICDynasty 210 DX',
'MILLER ELECTRICMILLERMATIC 252',
'MILLER ELECTRICWELDER 4 PACK',
'MINE SAFETY APPLIANCES (MSA)10105756',
'MINE SAFETY APPLIANCES (MSA)10127422',
'MINE SAFETY APPLIANCES (MSA)10152669',
'MINE SAFETY APPLIANCES (MSA)10127427',
'MINE SAFETY APPLIANCES (MSA)10128627',
'MINNICHSD1',
'MULTIQUIPBPX',
'MULTIQUIPGA6HR',
'MULTIQUIPJ36H55',
'MULTIQUIPMB25A',
'MULTIQUIPMC12PH',
'MULTIQUIPMC94PH8',
'MULTIQUIPMQ600HTB',
'MULTIQUIPWM120PHD',
'MULTIQUIPWM90PH8',
'MULTIQUIPGA6HR',
'New BreedTW6900',
'NIKONXS5',
'NORSTAR22T',
'NORTHERN1131',
'NORTHROCKModel 2',
'NORTHSTAR20" Surface Cleaner',
'PARAGON PROPanellft 460',
'PetolP95-525',
'PetolPHD0535',
'PHOENIX4038550',
'POWERHORSE7000',
'POWR-FLITENM2000',
'QUINCYQT-7.5',
'RAD TORQUE SYSTEMSBL500',
'RED ROOTile Scraper',
'RICEPTH20',
'RICE HYDRODPH-3B',
'RICE HYDROMTP-1',
'RICE HYDROMTP-5',
'RICE HYDROHP-1/55',
'ROPER WHITNEYModel 20',
'RUBBERMAIDA23i Shop Cart',
'SOKKIAB20 32X',
'SPANCOF4000',
'SPECTRALL300N-2',
'SPX POWER TEAM9644',
'TAMCOTOKUSLCH-3R-S',
'TENNANTT600E',
'TORNADO98451',
'TRANSCUBE20TCG(G)W-NA',
'TRELAWNYHAND-HELD SCABBLER',
'UNITEC21" Chain Saw',
'UNITECCS 536664-3',
'WACKER NEUSONPG2A',
'WACKER NEUSONBTS635',
'WACKER NEUSONGP 5600A',
'WACKER NEUSONGP3800A',
'WACKER NEUSONGPS9700A',
'WACKER NEUSONIEC58/120/8',
'WACKER NEUSONIRFU65',
'WACKER NEUSONM1500',
'WACKER NEUSONSurge Trailer',
'WERNERWRD6204',
'WERNERWRD6206 ',
'WERNERWRD6212',
'WOBBLE LIGHT111104',
'WORKSITE LIGHTINGDWXPLEDIL50-12V',
'WORKSITE LIGHTINGPetroPRO-MAX',
'WORKSITE LIGHTINGPetroPRO-Handy',
'WACKER NEUSONPG3A',
'WACKERP35A',
'WACKER NEUSONP35A',
'Diesel LaptopsDIESEL LAPTOP',
'MEGADECK103635 Mat',
'JOHN DEERE96""Fork Carriage',
'TAG MANUFACTURINGBucket 18"" Backhoe',
'JOHN DEERE2.75 yd Bucket',
'TAG MANUFACTURING24"" Backhoe Bucket',
'CATERPILLAR973C',
'TOPCONRL200',
'KUBOTASVL90-2',
'MAKINEXPHT2-140-US',
'JOHN DEERE96"Fork Carriage',
'TAG MANUFACTURINGBucket 18" Backhoe',
'TAG MANUFACTURING24" Backhoe Bucket',
'WACKERGP5600A',
'CROWNPTH50',
'MAGNI10 Ton Hook',
'LINCOLN ELECTRICINVERTEC V276',
'JOHN DEERE12" Backhoe Bucket',
'JOHN DEEREStandard General Purpose Bucket',
'INGERSOLL-RANDPD20P-FPS-PTT',
'ULINERolling Ladder',
'KEY PLANTKPJH-100A',
'NORTHERN49413',
'CURRENT TOOLS824',
'LDJEV500',
'METABOWEPBA17-150Q',
'KEY PLANTKP-RED-603',
'GTIPSH05',
'DUZCARTDistributor Cart',
'CURRENT TOOLS77SR',
'KEY PLANTKPDR-400A',
'Mathey Dearman4SA',
'INGERSOLL-RANDLC2A180TIP2C6M5-E',
'CURRENT TOOLS100A',
'GUARDIAN15046',
'NORTHERN4-way Pallet Jack',
'LINCOLN ELECTRICLN-25-PRO',
'KEY PLANTKPDR-400A- 401',
'WERNERStep Ladder',
'ATLAS COPCOTEX P90',
'INTERQUIPLKS450-5.5',
'JCB332/E5282',
'KEY PLANTKPJH-100A- 106',
'ASHLAND31277',
'KEY PLANTCC16',
'RYANJr. Sod Cutter',
'LINCOLN ELECTRICRanger 250',
'CURRENT TOOLS99',
'KEY PLANTCC20',
'GPIFuel Tank',
'CURRENT TOOLS8890A',
'THUNDER CREEKEV500',
'JLG1.5 Yd Bucket',
'KEY PLANTKP-RED-602',
'KEY PLANTKP-AOS-ST 2-IDLER',
'RIGID300 PMK',
'L&W SUPPLYDrywall Cart',
'Columbus McKinnon09003W',
'RDOWheel Loader Fork Attachment',
'LANDAMHC4',
'CURRENT TOOLS660',
'CLEMCO1648',
'ATLAS COPCO10X2.75',
'PHOENIXR250',
'ElephantP-5',
'MAGNI16 Ton Hook',
'MAGNI10 TON HOOK',
'MANITOUSwing Carriage',
'LINCOLN ELECTRICKS613-6',
'NORTHSTAR2" Trash pump',
'LINCOLN ELECTRICLHC857-100',
'JCBF7377',
'MAGNIFC5TSHI',
'WORKSITE LIGHTINGSLDWXPLED8-12',
'ROCKLANDWA270',
'KEY PLANTCC8',
'KEY PLANTCC18',
'CASE24" Bucket',
'KEY PLANTPipe Conveyor',
'CURRENT TOOLS951TR',
'CASEBucket 1.5 cu yd CASE',
'JOHN DEEREBucket 1.5 cu yd',
'Cratos31" Grapple Bucket',
'SAFETY CARTShort Barrel Torch',
'INGERSOLL-RANDPD20A-ASS-STT-B',
'DOOSAN3.5 Yd Loader Bucket',
'JCBSwing Carriage - JCB',
'JOHN DEERE24" Bucket',
'MONROEPJ552748',
'CURRENT TOOLS505',
'INGERSOLL-RAND3955B2TI',
'GUARDIAN42001',
'CURRENT TOOLS812',
'LiftSmartMLC-24',
'INGERSOLL RAND2925P1TI',
'INGERSOLL-RANDW7172-K22',
'KEY PLANTCC24',
'KEY PLANTCC12',
'SIOUX FORCE5450R',
'Mathey DearmanD236',
'Mathey Dearman3SA',
'ULINEH-5230-20',
'JLGSwing Carriage - JLG',
'FUELCUBEFCP250',
'INGERSOLL RANDIR-HUL',
'MILLER ELECTRICSUITCASE 12RC',
'TVHHJ5500',
'IROCKRDS-20',
'ACS3.5 CU YD',
'ElephantYA-320-20',
'TAMCOTHA2BR',
'RWNQuad 8" Flange',
'FALLTECH7509',
'LANDAPHW4-30024C',
'MCCLANAHANForklift Hopper',
'ATLAS COPCOTEX P60',
'MANITOUPH 2500/14000',
'KEY PLANTCC10',
'CASEJM0102',
'MASTERCRAFTP307A-HEPA',
'JLG1001095418S',
'DIMETEMG 135',
'MAGNI5 TON HOOK',
'CURRENT TOOLS254P',
'ALLEGRO9518-06',
'KEY PLANTKP-SCC-803',
'DOOSAN3.5 Smooth Edge bucket',
'ENFORCER96" Magnetic Sweeper Bar',
'JLGMAN BASKET',
'FEMA72" Loader Forks',
'GUARDIAN32205',
'BN ProductsDBR-25WH',
'MANITOUR805501',
'GUARDIAN32091',
'LINCOLN ELECTRICINVERTEC V350 PRO',
'CURRENT TOOLS252-CT',
'LINCOLN ELECTRICNVERTEC V275-S',
'JLGWork Platform, Fork Mounted',
'TAG MANUFACTURINGBucket 48" Mini Excavator 15,000 - 19,000 lbs',
'INTERQUIPLKS450-4.4',
'WTCFP100',
'NATIONAL FLOORING8274-4',
'MASTERMH-80T-KFA',
'ASCOSIGMA-LT',
'KEY PLANTKP-SCC-804',
'INGERSOLL-RANDIRT2135PQXPA',
'LOKTOOLMTK60',
'GUARDIANBosun Chair',
'INGERSOLL RANDPS2-10000RGC-L',
'HONDAGX200',
'MANITOU820347',
'MAGNI6 TON WINCH',
'LedwellHydraulic Power Unit',
'CURRENT TOOLS154PM',
'LINCOLN ELECTRICK3972-5',
'UPRIGHTForklift Hopper',
'MANITOUSwing Carriage - Manitou',
'METABO5"Angle Grinder',
'JLG94" Bucket',
'GENIESwing Carriage - Genie',
'HUGHES500gal Fuel Tank',
'HYUNDAIForks - HL940',
'WOBBLE LIGHT101-111104',
'X-TREME01972',
'INGERSOLL-RANDPD20A-AAP-CCC-B',
'INGERSOLL-RANDPD30A-AAP-CCC-C','NORTHWESTExcavator Rake',
'ATLAS COPCOWEDA S08N' , 'ATLAS COPCOWEDA S50N',
'JET J107231',
'R&MCRANE - R&M',
'KENCOKL9000',
'BARRETOE4X6TBT',
'INGERSOLL-RANDPD30A-ASS-STT-C',
'INGERSOLL-RANDPD30P-DPS-PTT-A','ATLAS COPCOQAS70 IS T4F','PATRONE9','PATRONE1.5','YASKAWADW-4025','WANCOWCTS-520' , 'SOTCHER311','PHOENIXDryMAX XL',
'STRICKLAND100873','ATLAS COPCOWEDA S04N','YASKAWASI-EN3','KWIKOOLKPAC2421-2','KWIKOOLKPAC1411-2','ULINEH-1043','INGERSOLL RANDPD30A-AAP-CCC-C',
'KEEN OVENSKT-50',
'INGERSOLL RANDPD30A-ASS-STT-C',
'INGERSOLL RANDPD20A-AAP-CCC-B',
'INGERSOLL RANDPD20A-ASS-STT-B',
'TAG MANUFACTURINGStandard Fork Frame',
'JOHN DEERERoot Rake','PHOENIXGuardian R Hepa','PHOENIXR250','MATCO-NORCA200WD','THUNDER BAYY43Z08','WATTSC515','Avery Weigh-TronixFLI 225',
'JLG1001095418S',
'GLOBAL4cy Self-Dump Hopper w/Poly Caster Kit Global',
'JOHN DEERE18" HD, Backhoe Loaders','HYPERTHERMPowermax 45XP',
'JOHN DEERE96" Loader Fork Carriage',
'JOHN DEERE96" Loader Fork Carriage - 624P','LINCOLN ELECTRICK652-1',
'BERCOCP100','NORTHSTAR3" Trash Pump',
'NORTHROCK25L2',
'STRICKLAND100906','ATLAS COPCOTEX 319',
'AIRCAT1778-VXL','HondaEU2200ITAN','KOBALT3332644','MCCULLOUGH IND40099-GRY','FLECOLoader Rake',
'INGERSOLL RANDPD30P-DPS-PTT-A','INGERSOLL RANDPD20P-FPS-PTT','NATIONAL FLOORING550','FRONTIERBB2060',
'DITCH WITCH1CM',
'CROWN5,500lb Manual Pallet Jack - Crown',
'MAGNIFC6T72X72IFIX','ABATEMENT TECHNOLOGIESBD2KM','WRIGHTCRANE - WRIGHT','RICE HYDRODPH-3B','SKILSAWMedusaw','RICE HYDRODPV-3B', 'STRICKLAND100906','JOHN DEERE96" Loader Fork Carriage - 624P','JOHN DEEREStandard Construction Fork Frame',
'CASEWBLR3','FLECO96" Root Rake - Fleco','FLECO108" Root Rake - Fleco','JOHN DEERE96\" Loader Fork Carriage - John Deere',
'JOHN DEERE96\" Loader Fork Carriage','PHOENIXR250 ','PHOENIXR250','EPIROCBP3050R'

) and a.model <> 'Dozer Rake') and a.asset_id not in (129442,129438,125855)
and a.asset_id not in (131277,75798,135200,126657,116163,132500,137948,137949,102636,130341,137947,746,33487,30376,
31448,
117664,
117665,
117749,
117750,
117775,
117856,141102,144099,144106,116486,150,678,142905,149347,149451,153945,148837,107919,74178,74177,148838,74179,
151804,
160573,
166729,
133159,
164681,
151491,
152360,
152357,
145114,
135553,161523,39356,54627,75671,75672,75676,75677,75679,75680,75681,75682,103194,104806,107918,132392,132394,132395,133722,162824,162825,162829,57335,
173128,172699,63706,174599,176378,164678,178371,138732,172990,172991,158753,158754,168013,174597,150149,181314,181317,181316,181315,62363,62364,173007,
167210,41260,165960,173726,153895,158614,158615,165996,73594,46871,158737,172993,173825,172497,
172494,172493,172496,173013,173014,170988,172495,170987,170989,128109,187122,172992,142593,142594,197995,206934,198274,2367,4162,2371,2379,2372,183980,207118,204850,210624,189539,
192054,80416,102694,214155,209135,17054,179695,194175,215448,208730,
202354,
202353,
208731,217306,130409,215560,
215561,
215557,
215552,
215555,
215558,
215550,
215554,
215551,
215553,
215556,
215559,47493,
183913,
213100,
213101,
213102,
213103,
213104,
213105,
213106,
213107,
226505,
226506,
226507,
226508,
226516,
226522,
226527,
226531,
226534,
227809,
227810,
227811,
227812,
227813,
227814,
227815,
227821,
227822,
227904,
227905,
227906,
227907,
227908,
230191,
230254,
230255,
230256,
230257,
230258,
230259,
230260,
230261,
230262,
230263,
230265,
230265,
230266,
230266,
230267,
230268,
230269,
230270,
230271,
230272,
230273,
230274,
230275,
230276,
230277,
230278,
230279,
230280,
230281,
230282,
230283,
230284,
230285,
230286,
230287,
230288,
230289,
230290,
230291,
231205,
232183,
232184,
234175,
234176,
234177,
234178,
234601,
234602,240410, 240417, 240411, 240413, 240415,253887,234263,247930
)
and lower(a.description) not like '%bucket%'
and lower(a.model) not like '%bucket%'
and a.make||a.model not like '%RWNRoad Crossing 12%SF%'
--and lower(m.name) not like '%industrial%' and lower(m.name) not like '%onsite%' and lower(m.name) not like '%tool%'
and m.market_id <> 58065
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

  dimension: region_name {
    type: string
    sql: ${TABLE}.region_name ;;
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

  dimension:job_site {
    type: string
    sql: ${TABLE}.job_site ;;
  }

  dimension:street_address_1 {
    type: string
    sql: ${TABLE}.street_address_1 ;;
  }

  dimension:city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension:state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension:zip_code {
    type: number
    sql: ${TABLE}.zip_code ;;
  }

  dimension:latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension:longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: location {
    type:  location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }

  dimension:tracker_on_asset_table {
    type: number
    sql: ${TABLE}.tracker_on_asset_table ;;
  }

  dimension:tracker_from_assignments {
    type: number
    sql: ${TABLE}.tracker_from_assignments ;;
  }

  dimension:date_installed {
    type: date_time
    sql: ${TABLE}.date_installed ;;
  }

  dimension:date_uninstalled {
    type: date_time
    sql: ${TABLE}.date_uninstalled ;;
  }

  dimension:start_date {
    type: date_time
    sql: ${TABLE}.start_date ;;
  }

  #dimension: start_date_time {
  #  type: time
  #  sql: ${TABLE}."start_date_time" ;;
#  }

  dimension: tracker_type {
    type: string
    sql: ${TABLE}.tracker_type ;;
  }


  set: telematics_db_details {
    fields: [asset_id,serial_number,category,make,model,tracker_id,company_id,rental_id,rental_status,inventory_branch,job_site,street_address_1,city,state,zip_code,
      latitude,longitude,tracker_on_asset_table,tracker_from_assignments,date_installed,start_date, asset_inventory_status.asset_inventory_status,tracker_type]
  }

  measure: asset_count {
    type: count_distinct
    drill_fields: [telematics_db_details*]
    sql: ${asset_id} ;;
  }



}
