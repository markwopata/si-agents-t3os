view: select_tam_customer_revenue {
  derived_table: {
    sql:
      WITH base AS (
    SELECT
        t.*,
        SPLIT(
            REGEXP_REPLACE(t.SECONDARY_SALESPERSON_IDS, '[\\[\\]\\s]', ''),
            ','
        ) AS secondary_array
    FROM analytics.intacct_models.int_admin_invoice_and_credit_line_detail t
),

exploded AS (
    -- Primary row
    SELECT
        b.*,
        'Primary' AS salesperson_type,
        TO_VARCHAR(b.PRIMARY_SALESPERSON_ID) AS salesperson_id
    FROM base b

    UNION ALL

    -- Secondary rows
    SELECT
        b.*,
        'Secondary' AS salesperson_type,
        sec.value::string AS salesperson_id
    FROM base b,
    LATERAL FLATTEN(input => b.secondary_array) sec
    WHERE sec.value IS NOT NULL
      AND TRIM(sec.value) <> ''
),

-- Count ALL secondary reps per invoice (no salesperson filter here!)
with_counts AS (
    SELECT
        e.*,
        COUNT(
            DISTINCT CASE
                WHEN e.salesperson_type = 'Secondary'
                    THEN e.salesperson_id
            END
        ) OVER (PARTITION BY e.INVOICE_NUMBER) AS num_secondary_salespeople
    FROM exploded e
),

-- Compute adj_revenue using that full count
with_adj AS (
    SELECT
        wc.*,
        CASE
            -- No secondaries → primary gets 100% of amount
            WHEN wc.num_secondary_salespeople = 0
                 AND wc.salesperson_type = 'Primary'
            THEN wc.AMOUNT

            -- Regular primary case when secondaries exist
            WHEN wc.salesperson_type = 'Primary' THEN
                0.5 * wc.AMOUNT

            -- Secondaries split the other 50% across ALL secondaries
            WHEN wc.salesperson_type = 'Secondary' THEN
                0.5 * wc.AMOUNT
                / NULLIF(wc.num_secondary_salespeople, 0)
        END AS adj_revenue
    FROM with_counts wc
)

-- 🔹 Finally: only show the salespeople you care about
SELECT a.*, tal.employee_id, tal.full_name, tal.date_hired, tal.date_rehired, tal.date_terminated
FROM with_adj a
JOIN analytics.commission.terminated_tam_list tal ON a.salesperson_id = tal.user_id
WHERE salesperson_id IN (
    '341727',
    '308280',
    '314297',
    '325329',
    '280954',
    '341987',
    '309757',
    '364717',
    '309767',
    '255171',
    '274641',
    '327331',
    '356234',
    '364819',
    '367093',
    '310171',
    '174100',
    '13852',
    '49832',
    '69019',
    '34645',
    '34319',
    '218415',
    '192996',
    '6432',
    '114199',
    '13289',
    '12437',
    '164048',
    '29897',
    '109985',
    '13482',
    '25073',
    '167723',
    '159748',
    '158619',
    '108075',
    '274592',
    '78171',
    '153897',
    '64292',
    '243631',
    '224557',
    '238174',
    '162539',
    '194514',
    '256527',
    '163270',
    '69002',
    '131652',
    '43983',
    '187390',
    '175129',
    '218442',
    '154497',
    '232817',
    '108059',
    '211767',
    '186597',
    '188572',
    '256147',
    '135960',
    '213580',
    '201936',
    '190431',
    '130815',
    '294992',
    '301632',
    '162527',
    '206506',
    '174863',
    '271434',
    '265878',
    '213589',
    '26271',
    '284799',
    '245890',
    '256489',
    '102223',
    '177300',
    '231556',
    '245125',
    '251047',
    '215978',
    '236282',
    '188994',
    '185830',
    '311995',
    '235751',
    '220076',
    '247142',
    '190397',
    '277487',
    '248398',
    '254739',
    '238646',
    '206521',
    '297051',
    '325303',
    '220819',
    '265086',
    '194543',
    '215987',
    '233306',
    '270395',
    '236256',
    '287734',
    '253957',
    '76056',
    '279311',
    '236241',
    '248603',
    '228869',
    '237055',
    '240704',
    '214151',
    '306195',
    '260198',
    '263647',
    '232335',
    '315883',
    '321851',
    '214754',
    '202602',
    '279388',
    '276457',
    '287694',
    '20861',
    '241278',
    '213540',
    '255443',
    '302887',
    '233286',
    '190782',
    '245879',
    '306120',
    '238800',
    '296427',
    '285701',
    '238634',
    '307920',
    '253157',
    '247154',
    '247192',
    '21982',
    '267121',
    '313637',
    '266852',
    '241023',
    '304965',
    '279092',
    '265893',
    '308004',
    '276451',
    '276752',
    '239613',
    '220820',
    '235747',
    '304401',
    '279386',
    '117267',
    '256518',
    '328849',
    '279652',
    '301129',
    '282643',
    '243426',
    '327944',
    '239513',
    '313715',
    '236264',
    '301002',
    '289929',
    '331035',
    '265121',
    '265081',
    '269734',
    '294933',
    '256523',
    '247164',
    '231552',
    '321310',
    '198954',
    '299462',
    '261621',
    '323331',
    '256214',
    '277497',
    '273567',
    '221837',
    '167708',
    '275161',
    '327732',
    '271443',
    '284395',
    '251547',
    '297061',
    '271433',
    '265879',
    '297063',
    '236253',
    '297919',
    '263648',
    '263649',
    '237052',
    '238637',
    '248359',
    '230694',
    '241905',
    '297104',
    '258945',
    '239879',
    '312222',
    '254861',
    '292673',
    '258978',
    '269687',
    '283016',
    '257829',
    '261632',
    '240987',
    '275165',
    '308621',
    '296428',
    '291574',
    '261697',
    '325299',
    '293830',
    '252496',
    '311982',
    '252613',
    '270390',
    '279421',
    '313647',
    '327260',
    '307935',
    '263345',
    '261635',
    '254864',
    '292672',
    '280061',
    '253815',
    '295511',
    '164235',
    '284403',
    '311978',
    '289397',
    '253098',
    '311589',
    '152362',
    '292684',
    '327305',
    '296439',
    '202593',
    '315882',
    '292681',
    '347554',
    '20991',
    '297900',
    '275158',
    '263951',
    '257631',
    '265578',
    '284099',
    '253986',
    '346077',
    '291798',
    '236238',
    '351627',
    '325381',
    '327943',
    '251431',
    '260478',
    '284093',
    '301055',
    '282639',
    '249568',
    '255441',
    '284397',
    '315891',
    '335228',
    '260494',
    '299468',
    '333221',
    '350073',
    '260278',
    '339757',
    '337898',
    '280884',
    '271305',
    '297917',
    '328848',
    '322128',
    '287732',
    '276749',
    '338658',
    '310172',
    '265582',
    '288055',
    '316174',
    '328853',
    '333217',
    '272863',
    '328910',
    '295237',
    '254957',
    '294000',
    '276456',
    '88678',
    '292189',
    '351719',
    '347533',
    '148654',
    '270093',
    '260196',
    '307996',
    '295244',
    '289579',
    '254868',
    '301636',
    '265077',
    '280064',
    '259154',
    '321317',
    '254194',
    '338582',
    '356969',
    '267114',
    '277517',
    '316214',
    '271442',
    '325292',
    '293854',
    '318121'
    )
          ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}.invoice_id ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}.invoice_number ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}.customer_name ;;
  }

  dimension: line_item_id {
    type: number
    sql: ${TABLE}.line_item_id ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}.line_item_type_id ;;
  }

  dimension: line_item_type_name {
    type: string
    sql: ${TABLE}.line_item_type_name ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}.account_number ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.account_name ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}.amount ;;
  }

  dimension: line_item_description {
    type: string
    sql: ${TABLE}.line_item_description ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}.rental_id ;;
  }

  dimension: salesperson_type {
    type: string
    sql: ${TABLE}.salesperson_type ;;
  }

  dimension: salesperson_id {
    type: string
    sql: ${TABLE}.salesperson_id ;;
  }

  dimension: adj_revenue {
    type: number
    sql: ${TABLE}.adj_revenue ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}.employee_id ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}.full_name ;;
  }

  dimension: date_hired {
    type: date
    sql: ${TABLE}.date_hired ;;
  }

  dimension: date_rehired {
    type: date
    sql: ${TABLE}.date_rehired ;;
  }

  dimension: date_terminated {
    type: date
    sql: ${TABLE}.date_terminated ;;
  }



}
