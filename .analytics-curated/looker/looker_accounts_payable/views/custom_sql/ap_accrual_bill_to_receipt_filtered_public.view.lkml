view: ap_accrual_bill_to_receipt_filtered_public {

    derived_table: {
      sql:





  with master as (
      SELECT distinct
      --mrx.market_id,
      aph.recordno,
          APH.VENDORID                                                                                 AS VENDOR_ID,
          VEND.NAME                                                                                    AS VENDOR_NAME,
          VEND.TERMNAME                                                                                AS TERMS,
          PM.PAY_METHOD_DESC                                                                           AS PAY_METHOD,
          aph.recordno as record_no,
          userinfo.loginid as created_by,
          aph.whenmodified as when_modified,
          aph.onhold as place_this_bill_on_hold,
          ents.entity_name as created_at_entity_name,
          vend.totaldue as vendor_due,
          aph.supdocid as attachment,
          APH.RECORDID                                                                                 AS BILL_NUMBER,
          APH.WHENCREATED                                                                              AS BILL_DATE,
          APH.WHENPOSTED                                                                               AS POST_DATE,
          APH.WHENDUE                                                                                  AS DUE_DATE,
          APH.WHENPAID                                                                                 AS DATE_FULLY_PAID,
          CASE WHEN APH.DOCNUMBER = 'nan' THEN NULL ELSE APH.DOCNUMBER END                             AS PO_OR_REFERENCE,
          APH.STATE                                                                                    AS STATE,
          APH.DESCRIPTION                                                                              AS HEADER_DESCRIPTION,
          APH.PRBATCH                                                                                  AS SUMMARY,
          CASE WHEN LEFT(APH.YOOZ_URL, 23) = 'https://www2.justyoozit' THEN NULL ELSE APH.YOOZ_URL END AS URL,
          APD.LINE_NO                                                                                  AS LINE,
          APD.ITEMID                                                                                   AS ITEM_ID,
          APD.ACCOUNTNO                                                                                AS ACCOUNT_SHOWN,
          COALESCE(SUBSTR(COALESCE(ITEM.NEW_ITEM_ID, APD.ITEMID), 2, 4), APD.ACCOUNTNO)                AS ACCOUNT_NUMBER,
          APD.DEPARTMENTID                                                                             AS DEPT_ID,
          APD.LOCATIONID                                                                               AS ENTITY,
          APD.GLDIMEXPENSE_LINE                                                                        AS EXPENSE_LINE,
          APD.AMOUNT                                                                                   AS AMOUNT,
          apd.totalpaid                                                                                as total_paid,
          APD.AMOUNT - apd.totalpaid as total_due,
          APD.ENTRYDESCRIPTION                                                                         AS LINE_DESCRIPTION,
          VIH.DOCNO                                                                                    AS VI_NUMBER,
          VIL.LINE_NO + 1                                                                              AS VI_LINE_NO,
          VIL.UIQTY                                                                                    AS VI_QTY,
          VIL.UIPRICE                                                                                  AS VI_UNIT_PRICE,
          VIL.TOTAL                                                                                    AS VI_EXT_COST,
          POH.DOCNO                                                                                    AS PO_NUMBER,
          poh.whencreated                                                                               as receipt_date, --kendall add jul 2 2024
          POL.LINE_NO + 1                                                                              AS PO_LINE_NO,
          POL.UIQTY                                                                                    AS PO_QTY,
          POL.UIPRICE                                                                                  AS PO_UNIT_PRICE,
          POL.TOTAL                                                                                    AS PO_EXT_COST,
          GLB.JOURNAL                                                                                  AS REC_JOURNAL,
          GLB.MODULE                                                                                   AS REC_MODULE,
          GLB.BATCHNO                                                                                  AS REC_BATCH_NO
         -- , mrx.market_id


        FROM
        ANALYTICS.INTACCT.APRECORD APH
        LEFT JOIN ANALYTICS.INTACCT.APDETAIL APD ON APH.RECORDNO = APD.RECORDKEY
        LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON APH.VENDORID = VEND.VENDORID
        LEFT JOIN ANALYTICS.INTACCT.APPAYMETHOD PM ON VEND.PAYMETHODREC = PM.PAYMETHODREC
        LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON APD.DEPARTMENTID = DEPT.DEPARTMENTID
        LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.OGITEM_TO_NEWITEM ITEM ON APD.ITEMID = ITEM.OG_ITEM_ID
        LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT VIH ON APH.DESCRIPTION2 = VIH.DOCID
        LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY VIL ON VIH.DOCID = VIL.DOCHDRID AND APD.LINE_NO = (VIL.LINE_NO + 1)
        LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT POH ON VIH.CREATEDFROM = POH.DOCID
        LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY POL
        ON POH.DOCID = POL.DOCHDRID AND VIL.SOURCE_DOCLINEKEY = POL.RECORDNO
        LEFT JOIN ANALYTICS.INTACCT.GLRESOLVE GLR ON POH.RECORDNO = GLR.DOCHDRKEY
        LEFT JOIN ANALYTICS.INTACCT.GLENTRY GLE ON GLR.GLENTRYKEY = GLE.RECORDNO
        LEFT JOIN ANALYTICS.INTACCT.GLBATCH GLB ON GLE.BATCHNO = GLB.RECORDNO
        left join analytics.intacct.userinfo on aph.createdby = userinfo.recordno
        --left join ANALYTICS.LS_DBT.STG_ANALYTICS_INTACCT__ENTITY ents on aph.megaentityid = ents.entity_id
        left join analytics.intacct_models.stg_analytics_intacct__entity ents on aph.megaentityid = ents.entity_id
        --left join analytics.public.market_region_xwalk mrx on cast(dept.departmentid as varchar) = cast(mrx.market_id as varchar)
-- CAST(a.id AS VARCHAR)


        WHERE
        APH.RECORDTYPE = 'apbill'
        and APD.LOCATIONID = 'E1'
        -- and APH.VENDORID <> 'V26330'
        AND BILL_DATE BETWEEN {% date_start date_filter %} AND {% date_end date_filter %}
),
urls as (select distinct fk_ap_header_id, mod_apd.url_invoice from analytics.intacct_models.ap_detail mod_apd

),
marks as (
 select
          mrx.market_id,
          mrx.market_name,
          mrx.district,
          mrx.region_name,
          mrx.market_type,
          IFF(
          ({{ _user_attributes['job_role'] }} = 'developer')
          OR
          ({{ _user_attributes['job_role'] }} = 'regional_ops')
          OR
          ({{ _user_attributes['job_role'] }} = 'regional_service_mgr' AND (substr(split_part(default_cost_centers_full_path, '/', 2),2,1) = mrx.region OR substr(split_part(default_cost_centers_full_path, '/', 2),2,1) = 'N' OR mrx.region_name in ({{ _user_attributes['region'] }})))
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'region'
          )
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'district' AND substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = mrx.region OR mrx.region_name in ({{ _user_attributes['region'] }}))
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'market' AND substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = mrx.region OR mrx.region_name in ({{ _user_attributes['region'] }}))
          OR
          (substr(split_part(default_cost_centers_full_path, '/', 3),0,1) = 'N')
          ,
          TRUE,
          FALSE
          ) as region_access,
         IFF(
          ({{ _user_attributes['job_role'] }} = 'developer')
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'region' AND (split_part(default_cost_centers_full_path, '/', 3) = mrx.district OR mrx.district in ({{ _user_attributes['district'] }})) OR region_access = TRUE)
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'district' AND (split_part(default_cost_centers_full_path, '/', 3) = mrx.district OR mrx.district in ({{ _user_attributes['district'] }})) OR region_access = TRUE)
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'market' AND (split_part(default_cost_centers_full_path, '/', 3) = mrx.district OR mrx.district in ({{ _user_attributes['district'] }})))
          ,
          TRUE,
          FALSE
          ) as district_access,
          IFF(
          ({{ _user_attributes['job_role'] }} = 'developer')
          OR
          {{ _user_attributes['hierarchy_level_access'] }} = 'market' AND ((cd.market_id = mrx.market_id) OR mrx.market_id in ({{ _user_attributes['market_id'] }}) OR mrx.district in ({{ _user_attributes['district'] }}))
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'region' AND (district_access = TRUE OR (mrx.market_id in ({{ _user_attributes['market_id'] }}))))
          OR
          ({{ _user_attributes['hierarchy_level_access'] }} = 'district' AND (district_access = TRUE OR (mrx.market_id in ({{ _user_attributes['market_id'] }}))))
          ,TRUE,FALSE) as market_access
      from
          analytics.public.market_region_xwalk mrx
          left join analytics.payroll.company_directory cd on 1=1
      where
          lower(work_email) = lower('{{ _user_attributes['email'] }}')
)


       select *
        from master
        join urls on master.recordno = urls.fk_ap_header_id
        join marks on cast(master.dept_id as varchar) = cast(marks.market_id as varchar)
















        ;;
    }

    measure: count {type: count drill_fields: [detail*]}
    dimension: vendor_id {type: string sql: ${TABLE}."VENDOR_ID" ;;}
    dimension: vendor_name {type: string sql: ${TABLE}."VENDOR_NAME" ;;}
    dimension: terms {type: string sql: ${TABLE}."TERMS" ;;}
    dimension: pay_method {type: string sql: ${TABLE}."PAY_METHOD" ;;}
    dimension: bill_number {type: string sql: ${TABLE}."BILL_NUMBER" ;;}
    dimension: bill_date {convert_tz: no type: date sql: ${TABLE}."BILL_DATE" ;;}
    dimension: post_date {convert_tz: no type: date sql: ${TABLE}."POST_DATE" ;;}
    dimension: due_date {convert_tz: no type: date sql: ${TABLE}."DUE_DATE" ;;}
    dimension: po_or_reference {type: string sql: ${TABLE}."PO_OR_REFERENCE" ;;}
    dimension: state {type: string sql: ${TABLE}."STATE" ;;}
    dimension: header_description {type: string sql: ${TABLE}."HEADER_DESCRIPTION" ;;}
    dimension: url {type: string sql: ${TABLE}."URL" ;;}
    dimension: line {type: number sql: ${TABLE}."LINE" ;;}
    dimension: item_id {type: string sql: ${TABLE}."ITEM_ID" ;;}
    dimension: account_shown {type: string sql: ${TABLE}."ACCOUNT_SHOWN" ;;}
    dimension: account_number {type: string sql: ${TABLE}."ACCOUNT_NUMBER" ;;}
    dimension: dept_id {type: string sql: ${TABLE}."DEPT_ID" ;;}
    dimension: entity {type: string sql: ${TABLE}."ENTITY" ;;}
    dimension: expense_line {type: string sql: ${TABLE}."EXPENSE_LINE" ;;}
    dimension: amount {type: number sql: ${TABLE}."AMOUNT" ;;}
    dimension: line_description {type: string sql: ${TABLE}."LINE_DESCRIPTION" ;;}
    dimension: vi_number {type: string sql: ${TABLE}."VI_NUMBER" ;;}
    dimension: vi_line_no {type: number sql: ${TABLE}."VI_LINE_NO" ;;}
    dimension: vi_qty {type: number sql: ${TABLE}."VI_QTY" ;;}
    dimension: vi_unit_price {type: number sql: ${TABLE}."VI_UNIT_PRICE" ;;}
    dimension: vi_ext_cost {type: number sql: ${TABLE}."VI_EXT_COST" ;;}
    dimension: po_number {type: string sql: ${TABLE}."PO_NUMBER" ;;}
    dimension: po_line_no {type: number sql: ${TABLE}."PO_LINE_NO" ;;}
    dimension: po_qty {type: number sql: ${TABLE}."PO_QTY" ;;}
    dimension: po_unit_price {type: number sql: ${TABLE}."PO_UNIT_PRICE" ;;}
    dimension: po_ext_cost {type: number sql: ${TABLE}."PO_EXT_COST" ;;}
    dimension: rec_journal {type: string sql: ${TABLE}."REC_JOURNAL" ;;}
    dimension: rec_module {type: string sql: ${TABLE}."REC_MODULE" ;;}
    dimension: rec_batch_no {type: number sql: ${TABLE}."REC_BATCH_NO" ;;}
    dimension: receipt_date {type: string sql: ${TABLE}."RECEIPT_DATE" ;;}
    dimension: date_fully_paid {type: string sql: ${TABLE}."DATE_FULLY_PAID" ;;}
    dimension: summary {type: string sql: ${TABLE}."SUMMARY" ;;}
    dimension: created_by {type: string sql: ${TABLE}."CREATED_BY" ;;}
    dimension: when_modified {type: string sql: ${TABLE}."WHEN_MODIFIED" ;;}
    dimension: place_this_bill_on_hold {type: string sql: ${TABLE}."PLACE_THIS_BILL_ON_HOLD" ;;}
    dimension: vendor_due {type: number sql: ${TABLE}."VENDOR_DUE" ;;}
    dimension: total_due {type: number sql: ${TABLE}."TOTAL_DUE" ;;}
    dimension: total_paid {type: number sql: ${TABLE}."TOTAL_PAID" ;;}
    dimension: record_no {type: string sql: ${TABLE}."RECORD_NO" ;;}
    dimension: created_at_entity_name {type: string sql: ${TABLE}."CREATED_AT_ENTITY_NAME" ;;}

    dimension: attachment {type: string sql: ${TABLE}."ATTACHMENT" ;;}
    # measure: sum_distinct_amount {type: sum_distinct sql: ${TABLE}."AMOUNT" ;;}

    dimension: url_invoice {type: string sql: ${TABLE}."URL_INVOICE" ;;}

    # dimension: sage_link {
    #   type: string sql: ${TABLE}."URL_INVOICE"
    #     link: {
    #       label: "label"  # The URL will be displayed as the text

    #       url: "{{url_invoice}}"    # The same URL will be used as the link destination
    #     }
    #   ;;}

    dimension: sage_link {
      type: string
      sql: ${TABLE}.URL_INVOICE ;;
      html: "<a href='{{ value }}' target='_blank'>'{{ value }}'</a>"
        ;;}

    dimension: url_pdf {
      type: string
      sql: ${TABLE}."URL";;
      html: "<a href='{{ value }}' target='_blank'>'{{ value }}'</a>"
      ;;
    }
  # dimension: raw_url {
  #   sql: ${TABLE}.URL_INVOICE ;;  # Replace with your actual column name
  #   type: string
  # }
  # dimension: clickable_link {
  #   sql: ${raw_url} ;;  # References the raw URL dimension
  #   html: "<a href='${raw_url}' target='_blank' style='color: blue; text-decoration: underline;'>Visit Site</a>"
  # ;;}

  # dimension: clickable_link {
  #   type: string
  #   sql: ${TABLE}.URL_INVOICE ;;

  #   # This will render the URL as a clickable link
  #   html: <a href="{{ value }}" target="_blank">{{ value }}</a> ;;
  # }
  dimension: clickable_link {
    type: string
    sql: ${TABLE}.URL_INVOICE ;;
    label: "Bill Number Link"
    # Use the value from another column as the link text
    html: <a href="{{ value }}" target="_blank" style="color: blue;" >{{ bill_number._value }}</a> ;;
  }


    filter: date_filter {
      label: "Date Range"
      type: date
    }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: market_access {
    type: yesno
    sql: ${TABLE}."MARKET_ACCESS" ;;
  }

  dimension: district_access {
    type: yesno
    sql: ${TABLE}."DISTRICT_ACCESS" ;;
  }

  dimension: region_access {
    type: yesno
    sql: ${TABLE}."REGION_ACCESS" ;;
  }

  dimension: months_open_over_12 {
    type: yesno
    sql: ${TABLE}."MONTHS_OPEN_OVER_12" ;;
  }

  dimension: market_permissions {
    type: string
    sql: case when ${market_access} = TRUE then ${market_name}
          else ' '
          end;;
  }

  dimension: district_permissions {
    type: string
    sql: case when ${district_access} = TRUE then ${district}
          else ' '
          end;;
  }

  dimension: region_permissions {
    type: string
    sql: case when ${region_access} = TRUE then ${region}
          else ' '
          end;;
  }

  dimension: region_district_navigation {
    group_label: "Navigation Grouping"
    label: "View Region District Breakdowns"
    type: string
    sql: ${region_permissions} ;;
    html:
    <button style="background-color: rgba(49, 140, 231, 0.25); border-radius: 5px; border: none; width: 75%; height: 40px; margin-bottom: 15px; margin-top: 5px; border: 1px solid #318CE7;"><font color="#202020"><u>
    <a href="https://equipmentshare.looker.com/dashboards/1321?Region={{ region_permissions._filterable_value | url_encode }}" target="_blank">
    <b> {{rendered_value}} District Breakdown ➔ </b></a></font></u> <tr> <font color="#202020"> {{count._value}} Markets  </tr> </button>
     ;;
  }

  dimension: district_market_navigation {
    group_label: "Navigation Grouping"
    label: "View District Market Breakdowns"
    type: string
    sql: ${district_permissions} ;;
    html:
    <button style="background-color: rgba(49, 140, 231, 0.25); border-radius: 5px; border: none; width: 75%; height: 40px; margin-bottom: 15px; margin-top: 5px; border: 1px solid #318CE7;"><font color="#202020"><u>
    <a href="https://equipmentshare.looker.com/dashboards/1322?District={{ district_permissions._filterable_value | url_encode }}" target="_blank">
    <b> {{rendered_value}} Market Breakdown ➔ </b></a></font></u> <tr> <font color="#202020"> {{count._value}} Markets </tr> </button>
     ;;
  }

  dimension: market_navigation {
    group_label: "Navigation Grouping"
    label: "View Market Breakdowns"
    type: string
    sql: ${market_permissions} ;;
    html:
    <button style="background-color: rgba(49, 140, 231, 0.25); border-radius: 5px; border: none; width: 75%; height: 30px; margin-bottom: 10px; margin-top: 5px; border: 1px solid #318CE7;"><font color="#202020"><u>
    <a href="https://equipmentshare.looker.com/dashboards/1328?Market={{ market_permissions._filterable_value | url_encode }}" target="_blank">
    <b> {{rendered_value}} ➔ </b></a></font></u></button>
     ;;
}
    set: detail {
      fields: [
        vendor_id,
        vendor_name,
        terms,
        pay_method,
        bill_number,
        bill_date,
        post_date,
        due_date,
        date_fully_paid,
        po_or_reference,
        state,
        header_description,
        url,
        line,
        item_id,
        account_shown,
        account_number,
        dept_id,
        entity,
        expense_line,
        amount,
        line_description,
        vi_number,
        vi_line_no,
        vi_qty,
        vi_unit_price,
        vi_ext_cost,
        po_number,
        po_line_no,
        po_qty,
        po_unit_price,
        po_ext_cost,
        rec_journal,
        rec_module,
        rec_batch_no
      ]
    }
  }
