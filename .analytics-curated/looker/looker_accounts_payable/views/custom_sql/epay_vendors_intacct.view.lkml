view: epay_vendors_intacct {
  derived_table: {
    sql:
    SELECT
    V.VENDORID              as VENDOR_ID,
    V.NAME                  as VENDOR_NAME,
    C.CONTACTNAME           as CONTACT_ID,
    C.FULL_NAME             as CONTACT_NAME,
    C.EMAIL                 as CONTACT_EMAIL,
    C.PHONE                 as CONTACT_PHONE
FROM
    ANALYTICS.INTACCT.VENDOR V
INNER JOIN
    (
        SELECT
            CONCAT(FIRSTNAME, ' ', LASTNAME) AS FULL_NAME,
            EMAIL1 AS EMAIL,
            LEFT(CONTACTNAME, CHARINDEX('_FT_EPAY', CONTACTNAME) - 1) AS Vendor_ID,
            STATUS,
            PHONE1 AS PHONE,
            CONTACTNAME
        FROM ANALYTICS.INTACCT.CONTACT
        WHERE CONTACTNAME LIKE '%_FT_EPAY'
          AND STATUS = 'active'
    ) C
ON V.VENDORID = C.Vendor_ID
WHERE
    V.ALT_PAY_METHOD = 'FifthThird Epay'
    AND V.STATUS = 'active'
    ;;
  }

  dimension: vendor_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: contact_id {
    type: string
    sql: ${TABLE}."CONTACT_ID" ;;
  }

  dimension: contact_name {
    type: string
    sql: ${TABLE}."CONTACT_NAME" ;;
  }

  dimension: contact_email {
    type: string
    sql: ${TABLE}."CONTACT_EMAIL" ;;
  }

  dimension: contact_phone {
    type: string
    sql: ${TABLE}."CONTACT_PHONE" ;;
  }

}
