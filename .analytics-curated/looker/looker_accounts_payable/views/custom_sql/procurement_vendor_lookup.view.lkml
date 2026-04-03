view: procurement_vendor_lookup {

    derived_table: {
      sql: SELECT
          SV.VENDORID AS "SAGE_VENDOR_ID",
          SV.NAME AS "SAGE_VENDOR_NAME",
          CONCAT(CONTACT.MAILADDRESS_ADDRESS1,' ',CONTACT.MAILADDRESS_CITY,' ',CONTACT.MAILADDRESS_STATE,' ',CONTACT.MAILADDRESS_ZIP) AS "SAGE_VENDOR_ADDRESS",
          SV.VENDOR_CATEGORY,
          CONCAT(CONTACT.FIRSTNAME,' ',CONTACT.LASTNAME) AS "CONTACT_NAME",
          CONTACT.PHONE1 AS "PHONE_NUMBER",
          CONTACT.EMAIL1 AS "EMAIL",
          SV.TERMNAME AS "TERM_NAME",
          //    EVS.EXTERNAL_ERP_VENDOR_REF AS "COSTCAPTURE_VENDOR_ID",
          E.ENTITY_ID AS "COSTCAPTURE_ENTITY_ID",
          E.NAME AS "COSTCAPTURE_VENDOR_NAME",
          sv.alt_pay_method,
          sv.alt_pay_due_date_deduction,
          contact.mailaddress_state,
          contact.mailaddress_city,
          sv.whenmodified,
          sv.whencreated,
          sv.new_vendor_category,
          sv.vendor_sub_category,
          sv.status,
          sv.vendtype,
          sv.vendor_redirect,
          sv.prevent_new_poe_in_sage,
          sv.totaldue,
          sv.external_sync_override,
          sv.approved_entities,
          sv.is_cip_vendor,
          pm.pay_method_desc,
          sv.comments,
          sv.vendor_provisional_approval

        FROM
        "ANALYTICS"."INTACCT"."VENDOR" SV
        LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" EVS ON EVS.EXTERNAL_ERP_VENDOR_REF = SV.VENDORID
        LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITIES" E ON E.ENTITY_ID = EVS.ENTITY_ID
        LEFT JOIN "ANALYTICS"."INTACCT"."CONTACT" CONTACT ON SV.DISPLAYCONTACTKEY = CONTACT.RECORDNO
        left join analytics.intacct.appaymethod pm on sv.paymethodrec = pm.paymethodrec
        WHERE

        --SV.STATUS
        --AND
        SV.VENDTYPE NOT IN (
        'Customer Refund',
        'Employee',
        --'Public Utility',
        --'Government',
        '501c',
        'W-9 Exempt',
        'W-8'


        )
        AND SV.VENDORID NOT IN ('V27149','V21326','V11391','V24718','V21176')

        ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

  dimension: vendor_provisional_approval {
    type: string
    sql: ${TABLE}.vendor_provisional_approval ;;
  }
  dimension: comments {
    type: string
    sql: ${TABLE}.comments ;;
  }
  dimension: preferred_payment_method {
    type: string
    sql: ${TABLE}.pay_method_desc ;;
  }
  dimension: City {
    type: string
    sql: ${TABLE}.mailaddress_city ;;
  }
  dimension: is_cip_vendor {
    type: yesno
    sql: ${TABLE}.is_cip_vendor ;;
  }
  dimension: approved_entities {
    type: string
    sql: ${TABLE}.approved_entities ;;
  }
  dimension: total_due {
    type: number
    sql: ${TABLE}.totaldue ;;
    value_format_name: "usd"
  }
  dimension: external_sync_override {
    type: string
    sql: ${TABLE}.external_sync_override ;;
  }
  dimension: vendor_redirect {
    type: string
    sql: ${TABLE}.vendor_redirect ;;
  }
  dimension: prevent_new_poe_in_sage {
    type: string
    sql: ${TABLE}.prevent_new_poe_in_sage ;;
    label: "Prevent New POE In Sage"
  }
  dimension: vendor_type {
    type: string
    sql: ${TABLE}.vendtype ;;
  }

    dimension: status {
      type: string
      sql: ${TABLE}.status ;;
    }
    dimension: whenmodified {
      type: date
      sql: ${TABLE}.whenmodified ;;
      label: "When Modified"
    }
    dimension: whencreated {
      type: date
      sql: ${TABLE}.whencreated ;;
      label: "When Created"
    }
    dimension: new_vendor_category {
      type: string
      sql: ${TABLE}.new_vendor_category ;;
    }
    dimension: vendor_sub_category {
      type: string
      sql: ${TABLE}.vendor_sub_category ;;
    }
    dimension: US_State {
      type: string
      sql: ${TABLE}.mailaddress_state ;;
    }
    dimension: alt_pay_method {
      type: string
      sql: ${TABLE}."ALT_PAY_METHOD" ;;
    }
    dimension: alt_pay_due_date_deduction {
      type: string
      sql: ${TABLE}."ALT_PAY_DUE_DATE_DEDUCTION" ;;
    }
    dimension: sage_vendor_id {
      type: string
      sql: ${TABLE}."SAGE_VENDOR_ID" ;;
    }

    dimension: sage_vendor_name {
      type: string
      sql: ${TABLE}."SAGE_VENDOR_NAME" ;;
    }

    dimension: sage_vendor_address {
      type: string
      sql: ${TABLE}."SAGE_VENDOR_ADDRESS" ;;
    }

    dimension: vendor_category {
      type: string
      sql: ${TABLE}."VENDOR_CATEGORY" ;;
    }

    dimension: contact_name {
      type: string
      sql: ${TABLE}."CONTACT_NAME" ;;
    }

    dimension: phone_number {
      type: string
      sql: ${TABLE}."PHONE_NUMBER" ;;
    }

    dimension: email {
      type: string
      sql: ${TABLE}."EMAIL" ;;
    }

    dimension: term_name {
      type: string
      sql: ${TABLE}."TERM_NAME" ;;
    }

    dimension: costcapture_entity_id {
      type: number
      sql: ${TABLE}."COSTCAPTURE_ENTITY_ID" ;;
    }

    dimension: costcapture_vendor_name {
      type: string
      sql: ${TABLE}."COSTCAPTURE_VENDOR_NAME" ;;
    }

    set: detail {
      fields: [
        sage_vendor_id,
        sage_vendor_name,
        sage_vendor_address,
        vendor_category,
        contact_name,
        phone_number,
        email,
        term_name,
        costcapture_entity_id,
        costcapture_vendor_name
      ]
    }
  }
