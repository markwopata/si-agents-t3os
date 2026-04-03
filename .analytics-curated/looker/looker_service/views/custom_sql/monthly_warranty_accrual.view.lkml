view: monthly_warranty_accrual {
  derived_table: {
    sql:
  with parts_to_eliminate AS ( -- Part Exclusion
    SELECT DISTINCT master_part_id as part_id
    FROM ANALYTICS.PARTS_INVENTORY.PARTS p
    join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
        on pt.part_type_id = p.part_type_id
    WHERE part_id in
    (11830, 105032, 651234, 79945, 86216, 113589, 10129, 19, 100531, 16, 10289, 6803, 13518,
    9577, 158, 397, 2850, 2020, 7079, 79942, 6449, 2059, 2182, 2183, 2022, 6117, 6433,
    984, 7402, 12164, 2018278, 2007, 116076, 4065, 2064, 47280, 5588, 3801, 2054546,
    75251, 75767, 75236, 75210, 11835, 11836, 56926, 11661, 85716, 75551, 11585, 6450,
    1991, 2014, 2060, 85028, 86106, 3837, 3920, 4072, 4559, 11832, 5249, 67633, 78426,
    4148, 2040209, 11831, 46697, 10229, 10230, 106, 2561, 2562, 2758, 7078, 44936, 56924,
    6109, 6111, 6135, 6157, 7423, 56923, 2059, 1093, 75252, 96252, 5251, 75434, 5252, 5450,
    42777, 85331, 1856, 4191, 6500, 6502, 6501, 4165, 1713, 10009, 67982, 84147, 90041, 342086,
    1276732, 1769, 1765, 1766, 1792, 2415, 3704, 12342, 1589, 12514, 1793, 75681, 1589, 44806, 4486,
    3994, 3997, 1594, 18, 783541, 2903, 58677, 53947, 4486, 3997, 3994, 1594, 71330, 5003, 1105, 71920,
    49715, 1159, 5791, 4504, 44858, 10288, 99787, 898, 641298, 40290, 54181, 56173, 1096, 6428, 1016,
    75232, 73103, 5957, 3575, 3764, 6110, 4296, 40357, 3871, 3870, 12023, 5491, 2011, 1338435, 3407,
    860, 76896, 46263, 1997, 52104, 1638213, 2005, 14216, 65719, 64520
    )
    --case fluids/oils, updated
    or part_id in
    (102845, 70529, 128900, 84269, 91095, 7084, 70119, 75384, 79642, 79819, 85433,
    108316, 81174, 91093, 95053, 120767, 64704, 102846, 65782, 91092, 75383, 342014,
    72812, 2060100, 75189, 9594, 44848, 42736, 79644, 78623, 78622, 81402, 129742, 7083,
    75221, 81530, 91096, 341988, 141649)
    --non-case fluids/oils, updated
    or part_id in
    (82011, 1550991, 45668, 142138, 63570, 2035457, 104013, 68390, 119619, 774877, 82005,
    104012, 1250770, 139987, 51517, 51509, 128899, 142137, 652128, 104024, 91096, 59839,
    39343, 65177, 68066, 49830, 7082, 60438, 12980, 69632, 139987, 52402, 1250744, 64359,
    3554850, 3695479, 3998750, 775344, 1326908, 4028468, 12425, 4003776, 4120659, 47389,
    105033, 4002792, 73804, 4003254, 2052652, 62338, 782103, 3836887, 3976978, 1326932,
    3998754, 12981, 4132799, 3751550, 86175, 69022, 64185, 775223, 2034785, 64358, 650274,
    3842, 3548890, 4124794, 3872928, 3878434, 14206, 4124993, 107809, 52404, 92883)
    --batteries
    -- or part_id IN (
    --  40156, 1081, 45619, 1079, 2034000, 4214, 1085, 773526, 1082, 13176,
    --  9462, 1080, 14460, 55743, 42124, 14405, 48331, 14404, 9466, 6009, 5887,
    --  13201, 3194, 3486, 1525, 145535, 12208, 118629, 9311, 2259812, 62177,
    --  121363, 7236, 11838, 782473, 1680, 44209, 3784, 9965, 55551, 53533)
    --fire ext, updated
    or part_id in (11826, 2071, 10909, 92858, 9180, 8164, 14454, 67028, 2815, 130377, 57264,
    228, 89706, 64246, 10910, 108386, 783879, 4508, 8955, 3815, 62878, 46982,
    3746226, 4126576, 3548826, 116457, 113145, 62480, 96225, 3993599, 3990973, 4125932,
    126115, 4103, 3694593, 120038, 4120928, 13486, 1234, 1235, 12333, 47377, 4125933,
    654183, 13485, 5132, 69255, 67028, 654183)
    and pt.description ilike '%fire ext%'
    --bolts, nuts, oring, updated
    or part_id in (547480 ,271069 ,51727 ,598000 ,271068 ,1425212 ,171435 ,126788 ,1927613 ,
    63429 ,1986889 ,198608 ,426596 ,85369 ,129468 ,271794 ,271070, 94886,
    109803, 75069, 75062, 129470, 199021, 42924, 141862, 80350, 75639,
    81532, 13220, 75287, 59332, 1674, 91705, 119249, 71221, 9370, 105792,
    14310, 46933, 9017, 57677, 652552, 79774, 9017, 11871, 69431, 126977,
    77655, 142670, 74184, 40931, 5587, 128427, 72190, 113616, 60884,
    126308, 90137, 142874, 117471, 117474, 145812, 2025269, 79948, 145613,
    121072, 107368, 1928003, 2031140, 12045, 62711, 12045, 113136, 10004,
    54153, 109652, 57842, 782042, 57995, 76895, 65178, 2218, 114317, 3873095,
    78494, 37529, 56875, 782995, 71076, 3476062, 1926310, 66549, 72292, 113726, 4125630,
    1448863, 775383, 73855, 47910, 113099, 120333, 3548953,
    78389, 3994054, 72527, 1472578, 783030, 81513, 1908719, 2030830, 3836815, 42451,
    72881, 260323, 4130711, 8908, 655055, 58744, 2261745, 1937922, 618078, 142459,
    674301, 4125535, 4125796, 59953, 653166, 4121862, 493413, 650506, 1393265, 2057222,
    773713, 1954644, 64084, 147611, 1486433, 2923120, 75637, 96762, 53697, 4159258, 100491,
    427628, 3743060, 9295, 121689, 9771, 83380, 641752, 48260, 120890, 80782, 1927630, 63406,
    13221, 1228794, 59292, 133115, 111651, 76876, 1924895, 426546, 2581491, 2888361, 773611,
    4130838, 1684, 50131, 845281, 117479, 68350, 96636, 123144, 3878093, 4127593, 4127706,
    1927695, 110488, 47266, 72870, 1928260, 1983552, 1928027, 3832015, 121007, 48264, 8973,
    2026626, 66332, 138932, 783767, 524726, 80611, 3976544, 59688, 3872924, 80013, 171433, 3996451,
    226410, 3468934, 2909334, 52906, 4128166, 48781, 3681800, 3992980, 2587015, 42402, 859519, 63286,
    133001, 147612, 99106, 69912, 2581645, 97607, 833407, 3044, 100490, 12449, 101150, 3690387, 54191,
    103011, 4133385, 142808, 955197, 50894, 45418, 99263, 100749, 40350, 3388866, 4131831, 39933, 4122187,
    80386, 775135, 72230, 4132567, 3998354, 3834066, 4127499, 12707, 3751689, 59851, 67232, 72667, 1549713,
    96532, 782128, 99264, 53507, 54849, 1206689, 782449, 2249649, 143739, 102379, 169662, 4127586, 4125414,
    79081, 758924, 1469907, 4131797, 1986503, 120467, 9385, 64055, 4130749, 55910, 493412, 71850, 1691317,
    1955663, 1928182, 1549714, 54006, 80482, 4003005, 3463562, 69353, 118519, 83430, 12319, 140546, 73513,
    420608, 127529, 4131792, 4132356, 1653, 132924, 52915, 2034623, 1926321, 1206768, 124039, 4132178, 4125685,
    260321, 125194, 3408765, 84811, 4121114, 108301, 107450, 3557124, 3481472, 954210, 47927, 1938061, 118520,
    120465, 113882, 1550122, 3832104, 76416, 498033, 4028734, 2624531, 11816, 52446, 110483, 46159, 96656, 1697236,
    41239, 79972, 117652, 48606, 109043, 1472519, 4132565, 68349, 1550123, 76566, 143742, 111855, 47267, 3473200,
    3524426, 66694, 2458737, 2040505, 4131791, 91318, 1209842, 394200, 144181, 4124380, 75602, 59330, 44491,
    4125415, 47669, 3557123, 144356, 102216, 747680, 141792, 4132394, 90810, 3756727, 12330, 55471, 1426637, 1354986,
    782726, 118545, 4122028, 3993695, 70227, 67500, 89814, 96904, 72685, 49722, 114335, 85093, 46383, 47296,
    4125416, 74795, 83794, 1710, 652437, 63982, 104665, 1549985, 91479, 4002967, 94874, 12398, 743796, 4131465,
    4120395, 3862468, 74086, 80457, 102276, 90475, 102514, 4120389, 142285, 83822, 90474, 59603, 1937810, 783132,
    42574, 782447, 4125413, 4126233, 2060371, 650735, 60391, 4122030, 63650, 1550180, 102933, 7955, 31407, 3835412,
    170748, 3553995, 142286, 55893, 4129792, 4078446, 2249799, 4131525, 3695488, 1985030, 8991, 107237, 3756737, 41802,
    105845, 67218, 782446, 4060302, 1551003, 47593, 105685, 104768, 4125437, 1698881, 142284, 2034588, 52488, 4120391,
    4120390, 71815, 1551002, 90460, 1985241, 1224381, 7954, 1957210, 131626, 1490050, 51296, 1247091, 4065075, 42688,
    4124701, 4126238, 121957, 3990995, 110728, 641528, 4078487, 122543, 90461, 650752, 3750844, 2879753, 2056928, 101604,
    92177, 4132932, 102341, 41911, 3109, 122619, 52828, 653162, 3975389, 72686, 126141, 31411, 10572, 94868, 626741,
    783131, 3679413, 126150, 67439, 76489, 67219, 741122, 1937584, 1696387, 2056927, 60392, 3831807, 3689545, 782725, 46933, 65178,
    619021, 2025269, 3679756, 650506, 2066387, 143742, 117471, 783767, 126308, 2102826, 2067334, 129470, 126150, 129468, 126150, 1937584, 2218,
    1710)
    or pt.description ilike 'bolt%'
    or pt.description ilike 'nut'
    or pt.description ilike 'oring%'
    or pt.description ilike 'o-ring%'
    or pt.description ilike 'washer'
    or pt.description ilike 'screw'
    --contains filter broad search
    or part_id in (45556, 3841, 3947, 21, 400, 2001, 2806, 6174, 7380, 2810
    , 6170, 1189, 75469, 3828, 2750, 3718, 368, 72922, 6162, 200, 4563, 2067,
    13025, 70225, 75349, 69911, 11833, 75162, 11834, 2572, 63442, 367, 90893,
    75971, 1192, 40893, 840787, 96255, 2754, 112338, 44385, 782976, 108935,
    42532, 8935, 1535, 55035, 7398, 7399, 7401, 75172, 1537, 2035854, 2013,
    115583, 207, 122729, 70226, 80614, 47278, 51029, 68567, 942, 2057, 5250,
    85300, 63135, 2035453, 1248, 1249, 6141, 195, 75499, 60109, 962, 41988,
    651233, 129354, 75509, 773774, 112496, 80182, 236, 5949, 6856, 59976, 648175
    , 60426, 293404, 85029, 85030, 652098, 126464, 1998, 2040204, 2040206, 2040210, 144909,
    76022, 55754, 81230, 45940, 85332, 6168, 42783, 8750, 1305, 52104, 2685, 1305, 2807, 60106,
    8763, 87311, 75708, 1125, 727, 75452, 4454, 87732, 2037, 10856, 146355, 4291, 87732, 6060, 403,
    7195, 127182, 1091, 71920, 1241, 42908, 4240, 4241, 1709, 38575, 7143, 3665, 13620, 77654, 77655,
    49104, 57913, 12699, 2068, 30303, 6436, 127139, 129475, 56088, 129354, 1230276, 236, 14282, 2060604,
    70225, 3830894, 3830892, 80614, 3830893, 72922, 1230276, 14282, 236, 1230291, 80182,
    4027333, 3548642, 2060, 2059, 4027334, 87311, 1520, 1367069, 132007, 60268, 112338, 1711, 112342, 1709,
    1286095, 2685, 6436, 1338445, 2806, 1338058, 6428, 127139, 7144, 112340, 38575, 4124794
)
    or pt.description ilike 'air filter%'
    or pt.description ilike 'oil filter%'
    --telematics
    or p.part_ID in (129148, 129152, 129157, 129155, 129154, 129146, 129151, 129162, 129150, 129149, 129160, 129153, 129158,
    129156, 129159, 129080, 129084, 129081, 129143, 129140, 129141, 129131, 129137, 129116, 129119, 129118,
    129138, 1373, 2262145, 59067, 3556602, 129147, 129096, 125611, 125695, 125626, 125713, 125714, 125669,
    125618, 125612, 125680, 125717, 125671, 125679, 125662, 125702, 125642, 125692, 129120, 2059913, 2041034,
    118571, 62530, 144094, 3060694, 2054054, 2054231, 2057037, 652401, 2040129, 3425720, 2057296, 833136,
    2034415, 2034412, 129099, 129095, 125607, 125661, 125720, 125585, 125587, 125625, 125603, 125698, 125579,
    125699, 125601, 125647, 125637, 125643, 125663, 125622, 125615, 125590, 125606, 125678, 125670, 125672,
    125655, 125638, 125708, 125719, 125677, 125584, 125634, 125573, 125574, 125598, 125696, 125667, 125644,
    125580, 125665, 125723, 125686, 125659, 125674, 125697, 125578, 125572, 125576, 125694, 125645, 125715,
    125604, 125707, 125725, 125709, 125706, 125700, 125676, 125649, 125599, 125648, 125593, 125724, 125718,
    125586, 125721, 125668, 125588, 125609, 125703, 125636, 125701, 125633, 125666, 125583, 125591, 125592,
    125605, 125595, 125704, 125693, 125653, 125716, 125722, 125689, 125712, 125619, 125610, 129109, 129103,
    129105, 129107, 129104, 129106, 129108, 125664, 129100, 129111, 125705, 125597, 125658, 129102, 652394,
    125681, 125685, 125682, 125684, 129079, 129078, 129070, 129066, 129067, 125683, 129072, 775762, 775768,
    654699, 699566, 117068, 125690, 120187, 125656, 125691, 125710, 125777, 129090, 832591, 3549093, 92132,
    59579, 122946, 54350, 131214)
    or p.part_ID IN (4120596, 59882, 650145, 2947392, 131707, 54576, 62538, 54574, 62538, 47390, 47391, 130945,
    120523, 47387, 47397, 49599, 58470, 47382, 121048, 121290, 54022, 3750681, 69682, 47395,
    55999, 47388, 73807, 96068, 39903, 45522, 113510, 64067, 47393, 105421, 653952, 2039232,
    699116, 2056711, 66661, 71391, 2261801, 2038803, 58019, 2052718, 3034, 47396, 47394,
    58625, 118256, 3878363, 73590, 87379, 2036261, 781756, 70223, 47398, 101573, 2039970, 1505,
    92598, 2056923, 42933, 52992, 7383, 13384, 59397, 11870, 46581, 125981, 47381, 79432, 140046,
    142347, 55047, 110697, 42202, 2038807, 56268, 1908203, 49473, 3831387, 78777, 3871619, 1250761,
    45854, 7198, 70224, 2035582, 92963, 39352, 1507, 549771, 139937, 11574, 122712, 91439, 72837,
    2257916, 122406, 6024, 3994052, 46609, 52808, 1550479, 774967, 47174, 3745882, 45937, 4468, 12157,
    415)
)

, warrantable_parts as ( --Parts that have 100% been paid by a specific OEM
    select distinct aa.make, p.master_part_id as part_id
    from ANALYTICS.WARRANTIES.WARRANTY_INVOICES wi
    join ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
        on li.invoice_id = wi.invoice_id
    join ANALYTICS.PARTS_INVENTORY.PARTS p
        on li.extended_data:part_id = p.part_id
    left join ES_WAREHOUSE.inventory.part_types pt
        on pt.part_type_id = p.part_type_id
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on aa.asset_id = wi.asset_id
    left join parts_to_eliminate pte
        on pte.part_id = p.master_part_id
    where wi.paid_amt = wi.total_amt --Paid in Full
        and pte.part_id is null --Not in elimination list
)

, own as ( --OWN Program Assignments
    select aa.asset_id, vpp.start_date, coalesce(vpp.end_date, '2099-12-31') as end_date
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    join ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS vpp
        on vpp.asset_id = aa.asset_id
    WHERE (aa.ASSET_TYPE_ID = 1  /*equipment*/ or  (aa.equipment_make_id = 11333 and aa.category_id = 514))
)

, es as ( --ES Ownership
    select aa.asset_id, scd.date_start, scd.date_end
    from ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY scd
    join ANALYTICS.PUBLIC.ES_COMPANIES esc
        on esc.company_id = scd.company_id
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on scd.asset_id = aa.asset_id
    where (aa.ASSET_TYPE_ID = 1  /*equipment*/ or  (aa.equipment_make_id = 11333 and aa.category_id = 514))
        and esc.owned = true --not in Jeffs Junkyard, etc
)

, warrantable_assets as ( --List of relevant assets
    select distinct asset_id
    from own

    union

    select distinct asset_id
    from es
)

, asset_hour_limits as ( --All warrantable assets over on hours
    select aa.asset_id
        , case
            --Allmand Light Towers/Heaters (1000 hours/1 Year)
            when aa.model in ('350 Night-Lite', 'MAXI-LITE II', 'NIGHT-LITE', 'Night-Lite Pro II', 'NLPROii-LD', 'NLV3GR', 'GR-Series') then 1000
            --Allmand Generators
            when aa.model in ('MA185', 'Maxi-Power 150', 'MP25', 'MP65') or aa.make in ('TAKEUCHI' , 'JOHN DEERE' , 'JCB') then 2000
            --Sany Telehandlers
            when aa.model in ('STH1256', 'STH1056', 'STH844', 'STH1056A') or aa.make in ('BOBCAT' , 'ATLAS COPCO') then 3000
            --Genie and JLG ultras, sany excavators and wheel loaders
            when aa.model in ('SX-125 XC', 'S-125', 'SX-150', 'SX-180', '1200SJP', '1350SJP', '1500SJ', '1850SJ', 'SW405K', 'SY135C', 'SY155', 'SY155U', 'SY16', 'SY215', 'SY225C', 'SY235C', 'SY26', 'SY265C LC', 'SY35U', 'SY365C LC', 'SY50', 'SY500', 'SY60C', 'SY75C', 'SY95C') then 5000
            else 1000000000 end as hour_limits
        , min(scd.date_start)::DATE as over_hour_limit --exact moment the asset went over on warrantable hours
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    join ES_WAREHOUSE.SCD.SCD_ASSET_HOURS scd
        on scd.asset_id = aa.asset_id
    join warrantable_assets wa
        on wa.asset_id = aa.asset_id
    where hour_limits < scd.hours --over the hour limit
    group by aa.asset_id, hour_limits
)

, warranty_final as (
    SELECT DISTINCT eppa.asset_id
        , eppa.make
        , eppa.model
        , ad.delivery_date::DATE as warranty_start_date
        , DATEADD(month, (MAX(TIME_VALUE) OVER (PARTITION BY eppa.ASSET_ID )), ad.delivery_date::DATE) as Warranty_End_Date_prep --Max Warranty End Date
        , iff(Warranty_End_Date_prep > coalesce(over_hour_limit, '2099-12-31'), over_hour_limit, Warranty_End_Date_prep) as warranty_end_date --If the hour limit was reached before the max warranty end date, then th ehour limit date will be considered the warranty end date
        , MAX(TIME_VALUE) OVER (PARTITION BY eppa.ASSET_ID ) AS Max_Warranty_Duration
        , listagg(distinct w.description, ', ') over (partition by eppa.ASSET_ID) as warranties
        , listagg(wd.description, ', ') over (partition by eppa.ASSET_ID) as warranties_description
    FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE eppa
    join warrantable_assets wa
        on wa.asset_id = eppa.asset_id
    left join asset_hour_limits ahl --left joined and using coalesce above, will not eliminate assets by mistake
        on ahl.asset_id = eppa.asset_id
    JOIN es_warehouse.public.asset_warranty_xref awx
        On eppa.asset_id = awx.asset_id
    LEFT JOIN es_warehouse.public.equipment_classes ec
        On ec.equipment_class_id = eppa.equipment_class_id
    LEFT JOIN es_warehouse.public.companies c
        ON c.company_id = eppa.company_id
    JOIN es_warehouse.public.warranties w
        ON w.warranty_id = awx.warranty_id
    JOIN (
            select ad.asset_id
                , coalesce(ad.delivery_date, min(wo.date_created)) as delivery_date
            from analytics.PARTS_INVENTORY.asset_delivery_date ad
            left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
                on wo.asset_id = ad.asset_id
            group by ad.asset_id, ad.delivery_date ) ad
        ON eppa.asset_ID = ad.asset_ID
    JOIN (
            SELECT Warranty_ID
                , description
                , TIME_VALUE
            FROM ES_WAREHOUSE.PUBLIC.WARRANTY_ITEMS
            where description not ilike '%Structural%' and description not ilike '%EPA%'--use this for the overall warranty pull
            -- description ilike any ('%standard%','%comprehensive%','%general%','%limited%','%full%','%life%','%base%') --use this for standard warranties pull
                 and warranty_id not in
                    (4173, 1774, 1773, 1288, 1246, 1247,
                    1276, 1278, 1277, 1279, 1285,
                    1275, 2035, 1375,
                    900)
                AND DATE_DELETED is null
                AND (TIME_UNIT_ID is null or TIME_UNIT_ID = 20)) wd
        ON w.WARRANTY_ID = wd.WARRANTY_ID
    WHERE eppa.year >= 2018
        AND eppa.equipment_model_id not in (select equipment_model_id from ANALYTICS.WARRANTIES.UNWARRANTABLE_MODELS) --mostly buckets
        -- AND eppa.service_branch_id != 1492 --"main branch"
        -- AND eppa.ASSET_TYPE_ID = 1         --equipment
        and ad.delivery_date is not null --sure to give us a warranty end date
)

, wo_time as ( --Labor Rate by OEM
    select te.work_order_ID
        , sum(zeroifnull(te.regular_hours) + zeroifnull(te.overtime_hours)) total_hours
        , case
            when aa.make ilike 'ALLMAND' then 0
            when aa.make ilike 'JOHN DEERE' then 85
            when aa.make ilike any ('JLG', 'SANY') then 100
            when aa.make ilike any ('SKYJACK', 'TAKEUCHI', 'BOBCAT') then 110
            when aa.make ilike any ('CASE', 'GENIE') then 120
            when aa.make ilike any ('ATLAS COPCO', 'JCB') then 135
            else 100 end as warranty_labor_rate
        , total_hours * warranty_labor_rate as estimated_labor
        , max(te.end_date::DATE) as last_tech_entry
    from ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRIES te
    join ES_WAREHOUSE.PUBLIC.USERS u
        on te.user_id = u.user_id
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        on wo.work_order_id = te.work_order_id
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on aa.asset_id = wo.asset_id
    where te.ARCHIVED_DATE is null
        and te.NEEDS_REVISION = false
        and te.WORK_ORDER_ID is not null --wo time entries only
        AND te.APPROVAL_STATUS = 'Approved'
        and te.EVENT_TYPE_ID = 1 --"on duty"
        and datediff('day', te.START_DATE, te.END_DATE) <= 1 -- historical time entry has instances where it exceed 24 consecutive hours
        and datediff('hour', te.START_DATE, te.END_DATE) < 24
        and u.company_id = 1854
    GROUP BY te.work_order_ID, aa.make
)

, wo_note_invoice_number as ( --Need to make sure the correct Invoice is being considered for each work order
    select won.work_order_id
        , i.invoice_id
        , replace(upper(won.note), 'MANUAL INVOICE #', '') as invoice_number
        , lead(won.date_created) over (partition by won.work_order_id order by won.date_created asc) next_note_date
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_NOTES won
    join ES_WAREHOUSE.PUBLIC.INVOICES i
        on replace(i.invoice_no,'-000','') = ltrim(replace(REGEXP_REPLACE(invoice_number,'[A-z]',''),'-000',''), ':#/-_,$.* ')
    where won.note ilike 'Manual Invoice #%'
    qualify next_note_date is null
)

, work_orders_to_invoices as (
    select wo.work_order_id, i.invoice_id
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    left join wo_note_invoice_number wnin --If we have already linked an invoice from the notes we don't want to consider it again
        on wnin.work_order_id = wo.work_order_id
    left join ES_WAREHOUSE.PUBLIC.INVOICES i1
        on i1.invoice_id = wo.invoice_id
    left join ES_WAREHOUSE.PUBLIC.INVOICES i2
        on replace(i2.invoice_no,'-000','') = ltrim(replace(REGEXP_REPLACE(wo.invoice_number,'[A-z]',''),'-000',''), ':#/-_,$.* ')
    join ES_WAREHOUSE.PUBLIC.INVOICES i
        on i.invoice_id = coalesce(i1.invoice_id, i2.invoice_id)
    where wnin.work_order_id is null

    union

    select work_order_id, invoice_id
    from wo_note_invoice_number
)

, externally_billed_parts as ( --Parts billed externally in the quarter
    select woti.work_order_id
        , i.invoice_id
        , p.master_part_id as part_id
        , concat(i.invoice_id, p.master_part_id) as keys
        , sum(li.amount) as net_amount
    from ES_WAREHOUSE.PUBLIC.INVOICES i
    join ANALYTICS.PUBLIC.V_LINE_ITEMS li
        on li.invoice_id = i.invoice_id
    join ANALYTICS.PARTS_INVENTORY.PARTS p
        on li.extended_data:part_id = p.part_id
    join work_orders_to_invoices woti
        on woti.invoice_id = i.invoice_id
    where i.company_id not in (
            select company_id
            from ANALYTICS.PUBLIC.ES_COMPANIES
        )
    group by woti.work_order_id
        , i.invoice_id
        , p.master_part_id
        , concat(i.invoice_id, p.master_part_id)
    having net_amount <> 0 --Remove those credited off
)

, externally_billed_labor as (
    select woti.work_order_id
        , i.invoice_id
        , sum(li.number_of_units) as billed_hours
        , sum(li.amount) as net_amount
    from ES_WAREHOUSE.PUBLIC.INVOICES i
    join ANALYTICS.PUBLIC.V_LINE_ITEMS li
        on li.invoice_id = i.invoice_id
    join work_orders_to_invoices woti
        on woti.invoice_id = i.invoice_id
    where i.company_id not in (
            select company_id
            from ANALYTICS.PUBLIC.ES_COMPANIES
        )
        and li.line_item_type_id in (134, 22, 19, 20, 13, 26)
    group by woti.work_order_id
        , i.invoice_id
    having net_amount <> 0 --Remove those credited off
)

, work_orders as (
    select wo.work_order_id
        , wo.date_completed::date as date_completed
        , bt.name as billing_type
        , ot.name as originator
        , wo.asset_id
        , wf.make
        , wf.model
        , wf.warranties
        , wf.warranties_description
        , pit.root_part_number as part_number
        , pit.root_part_description as part_description
        , sum(-pit.quantity) as p_quantity
        , pit.weighted_average_cost * p_quantity as part_cost
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    join ES_WAREHOUSE.WORK_ORDERS.BILLING_TYPES bt
        on bt.billing_type_id = wo.billing_type_id
    --Under Warranty and ES OWNED or OWN
    join warranty_final wf
        on wf.asset_id = wo.asset_id
            and wo.date_completed <= wf.warranty_end_date
            and wo.date_completed >= wf.warranty_start_date
    left join own
        on own.asset_id = wo.asset_id
            and own.start_date::DATE < wo.date_completed
            and own.end_date::DATE >= wo.date_completed
    left join es
        on es.asset_id = wo.asset_id
            and es.date_start::DATE < wo.date_completed
            and es.date_end::DATE >= wo.date_completed
    --Work Order Parts. Only want parts not already externally billed and that have been paid warranty before by that OEM
    left join ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS pit
        on pit.work_order_id = wo.work_order_id
    left join externally_billed_parts ebp
        on ebp.work_order_id = wo.work_order_id --Part already billed externally on this work order if connected
            and ebp.part_id = pit.root_part_id
    join warrantable_parts wp
        on wp.make = wf.make
            and wp.part_id = pit.root_part_id
    --Unwarrantable Work Orders
    left join (
            select distinct work_order_id
            from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS  woct
            join ES_WAREHOUSE.WORK_ORDERS.COMPANY_TAGS ct
                on ct.company_tag_id = woct.company_tag_id
            where woct.company_tag_id in (23, 45, 41, 7624) --telematics or customer damage
            ) woct
        on woct.work_order_id = wo.work_order_id
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_ORIGINATORS woo
        on woo.work_order_id = wo.work_order_id
    join ES_WAREHOUSE.WORK_ORDERS.ORIGINATOR_TYPES ot
        on ot.originator_type_id = woo.originator_type_id
    --Already Reviewed Work Orders
    left join (
            select distinct parameters:work_order_id work_order_id
            from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT
            where parameters:changes:description is not null --reviewed
                and user_id in (15641, 29401, 222408) --henry's team
            ) reviewed
        on reviewed.work_order_id = wo.work_order_id
    --ES did the Work
    join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
        on m.market_id = wo.branch_id
    where wo.archived_date is null
        and date_trunc(month, wo.date_completed) = date_trunc(month, dateadd(month, -1, current_date()))
        and coalesce(es.asset_id, own.asset_id) is not null --ES OWNED or OWN
        and ebp.keys is null -- not externally billed part
        and wo.creator_user_id not in (28868, 15919) --Not created by Aaron Glass or Charles Carrington (service bulletin WO's)
        and woo.originator_type_id <> 3 --not an mgi
        and wo.work_order_type_id = 1 --general
        and wo.work_order_status_id = 4 --billed
        and woct.work_order_id is null --not customer damage or telematics
        -- and reviewed.work_order_id is null --not reviewed by Henry's team. As of 10/25 we are not longer filting out things already touched by "Henry's team"
    group by wo.work_order_id
        , wo.asset_id
        , wf.make
        , wf.model
        , wf.warranties
        , wf.warranties_description
        , pit.root_part_number
        , pit.root_part_description
        , pit.weighted_average_cost
        , wo.date_completed
        , bt.name
        , ot.name
    having p_quantity > 0
)

select concat('https://app.estrack.com/#/service/work-orders/', wo.work_order_id) as link_to_t3
    , wo.work_order_id
    , wo.date_completed
    , wot.last_tech_entry
    , wo.billing_type
    , wo.originator
    , wo.asset_id
    , wo.make
    , wo.model
    , wo.warranties
    , wo.warranties_description
    , listagg(wo.part_number, ' / ') as part_numbers
    , listagg(wo.part_description, ' / ') as part_descriptions
    , sum(zeroifnull(wo.part_cost)) as parts_cost
    , iff(zeroifnull(wot.total_hours) - zeroifnull(ebl.billed_hours) < 0, 0, zeroifnull(wot.total_hours) - zeroifnull(ebl.billed_hours))  as unbilled_hours
    , wot.warranty_labor_rate
    , zeroifnull(unbilled_hours * wot.warranty_labor_rate) as labor_cost
    , labor_cost + parts_cost as warranty_value
from work_orders wo
left join wo_time wot
    on wot.work_order_id = wo.work_order_id
left join externally_billed_labor ebl
    on ebl.work_order_id = wo.work_order_id
where wo.make ilike any ('JLG', 'Genie', 'Case', 'Sany', 'Atlas Copco', 'Bobcat', 'JCB', 'John Deere', 'Takeuchi', 'Skyjack', 'Allmand')
group by wo.work_order_id
    , wo.date_completed
    , wot.last_tech_entry
    , wo.billing_type
    , wo.originator
    , wo.asset_id
    , wo.make
    , wo.model
    , wo.warranties
    , wo.warranties_description
    , wot.total_hours
    , wot.warranty_labor_rate
    , ebl.billed_hours
order by warranty_value desc ;;
  }

 dimension: work_order_id {
   type: number
  value_format_name: id
  sql: ${TABLE}.work_order_id ;;
  html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
 }

  dimension: completed {
    type: date
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

 dimension: last_tech_entry {
   type: date
  sql: ${TABLE}.last_tech_entry ;;
 }

dimension: billing_type {
  type: string
  sql: ${TABLE}.billing_type ;;
}

dimension: originator {
  type: string
  sql: ${TABLE}.originator ;;
}

dimension: asset_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.asset_id ;;
}

dimension: make {
  type: string
  sql: ${TABLE}.make ;;
}

dimension: model {
  type: string
  sql: ${TABLE}.model ;;
}

  dimension: warranties {
    type: string
    sql: ${TABLE}.warranties;;
  }

  dimension: warranties_description {
    type: string
    sql: ${TABLE}.warranties_description ;;
  }

  dimension: part_numbers {
    type: string
    sql: ${TABLE}.part_numbers ;;
  }

  dimension: part_descriptions {
    type: string
    sql: ${TABLE}.part_descriptions ;;
  }

  dimension: parts_cost {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.parts_cost ;;
  }

  dimension: unbilled_hours {
    type: number
    sql: ${TABLE}.unbilled_hours ;;
  }

  dimension: warranty_labor_rate {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.warranty_labor_rate ;;
  }

  dimension: labor_cost {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.labor_cost ;;
  }

  dimension: warranty_value {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.warranty_value;;
  }
}
