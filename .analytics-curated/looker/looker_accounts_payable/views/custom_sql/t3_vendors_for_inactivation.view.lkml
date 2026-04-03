view: t3_vendors_for_inactivation {
  derived_table: {
    sql: Select
          V.VENDORID AS "Vendor ID",
          V.NAME as "Name",
          V.TOTALDUE AS "Total Due",
          V.STATUS AS "Status",
          E.ENTITY_ID AS "T3 Entity ID",
          E.NAME AS "T3 Name",
          E.ACTIVE AS "T3 Active"

      From "ANALYTICS"."INTACCT"."VENDOR" V

      left join "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" EVS

      on v.vendorid = EVS.EXTERNAL_ERP_VENDOR_REF

      left join "ES_WAREHOUSE"."PURCHASES"."ENTITIES" E

      on EVS.ENTITY_ID = E.ENTITY_ID

      where v.status = 'inactive' and e.active = 'TRUE'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendor_id {
    type: string
    label: "Vendor ID"
    sql: ${TABLE}."Vendor ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."Name" ;;
  }

  dimension: total_due {
    type: number
    label: "Total Due"
    sql: ${TABLE}."Total Due" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."Status" ;;
  }

  dimension: t3_entity_id {
    type: number
    label: "T3 Entity ID"
    sql: ${TABLE}."T3 Entity ID" ;;
  }

  dimension: t3_name {
    type: string
    label: "T3 Name"
    sql: ${TABLE}."T3 Name" ;;
  }

  dimension: t3_active {
    type: yesno
    label: "T3 Active"
    sql: ${TABLE}."T3 Active" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      name,
      total_due,
      status,
      t3_entity_id,
      t3_name,
      t3_active
    ]
  }
}
