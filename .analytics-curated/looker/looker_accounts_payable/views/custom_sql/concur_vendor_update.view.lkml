view: concur_vendor_update {
  derived_table: {
    sql: SELECT
          vend.VENDORID AS VENDOR_ID,
          vend.name AS VENDOR_NAME,
          CONCAT(IFNULL(CASE WHEN ROW_NUMBER() OVER(ORDER BY vend.VENDORID ASC) = 1 THEN '<?xml version="1.0" encoding="UTF-8"?><Vendors>' ELSE NULL END,''),IFNULL(CONCAT('<Vendor><AddressCode>',REPLACE(REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IfNull(VEND.VENDORID,''),char(9),'')),'&','&amp;'),'''','&apos;'),'"','&quot;'),'<','&lt;'),'</AddressCode><VendorCode>', REPLACE(REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IfNull(VEND.VENDORID,''),char(9),'')),'&','&amp;'),'''','&apos;'),'"','&quot;'),'<','&lt;'),'</VendorCode><AccountNumber></AccountNumber><PaymentTerms></PaymentTerms><TaxID>',REPLACE(REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IfNull(VEND.TAXID,''),char(9),'')),'&','&amp;'),'''','&apos;'),'"','&quot;'),'<','&lt;'),'</TaxID><ContactPhoneNumber>',REPLACE(REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IfNull(LEFT(CONTACT.PHONE1,25),''),char(9),'')),'&','&amp;'),'''','&apos;'),'"','&quot;'),'<','&lt;'),'</ContactPhoneNumber><VendorName>',REPLACE(REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IfNull(VEND.NAME,''),char(9),'')),'&','&amp;'),'''','&apos;'),'"','&quot;'),'<','&lt;'),'</VendorName><PostalCode>',REPLACE(REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IfNull(CONTACT.MAILADDRESS_ZIP,''),char(9),'')),'&','&amp;'),'''','&apos;'),'"','&quot;'),'<','&lt;'),'</PostalCode><State>',REPLACE(REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IfNull(CONTACT.MAILADDRESS_STATE,''),char(9),'')),'&','&amp;'),'''','&apos;'),'"','&quot;'),'<','&lt;'),'</State><CountryCode>',REPLACE(REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IfNull(CONTACT.MAILADDRESS_COUNTRYCODE,''),char(9),'')),'&','&amp;'),'''','&apos;'),'"','&quot;'),'<','&lt;'),'</CountryCode><City>',REPLACE(REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IfNull(CONTACT.MAILADDRESS_CITY,''),char(9),'')),'&','&amp;'),'''','&apos;'),'"','&quot;'),'<','&lt;'),'</City><Address2></Address2><Address1>',REPLACE(REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IfNull(left(CONTACT.MAILADDRESS_ADDRESS1,50),''),char(9),'')),'&','&amp;'),'''','&apos;'),'"','&quot;'),'<','&lt;'),'</Address1><ContactLastName>',REPLACE(REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IfNull(CONTACT.LASTNAME,''),char(9),'')),'&','&amp;'),'''','&apos;'),'"','&quot;'),'<','&lt;'),'</ContactLastName><ContactFirstName>',REPLACE(REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IfNull(CONTACT.FIRSTNAME,''),char(9),'')),'&','&amp;'),'''','&apos;'),'"','&quot;'),'<','&lt;'),'</ContactFirstName><ContactEmail>',REPLACE(REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IfNull(CONTACT.EMAIL1,''),char(9),'')),'&','&amp;'),'''','&apos;'),'"','&quot;'),'<','&lt;'),'</ContactEmail><PaymentMethodType>','</PaymentMethodType>','<CurrencyCode>USD</CurrencyCode><VoucherNotes>',REPLACE(REPLACE(REPLACE(REPLACE(TRIM(REPLACE(IfNull(VEND.COMMENTS,''),char(9),'')),'&','&amp;'),'</LineItem>''','&apos;'),'"','&quot;'),'<','&lt;'),'</VoucherNotes><IsVisibleForContentExtraction>true','</IsVisibleForContentExtraction>','</Vendor>'),''),IFNULL(CASE WHEN ROW_NUMBER() OVER(ORDER BY vend.VENDORID DESC) = 1 THEN '</Vendors>' ELSE NULL END,'')) AS FULL_PAYLOAD
      FROM
          ANALYTICS.INTACCT.VENDOR VEND
              LEFT JOIN ANALYTICS.INTACCT.CONTACT CONTACT ON VEND.DISPLAYCONTACTKEY = CONTACT.RECORDNO
      ORDER BY
          VEND.VENDORID ASC
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: full_payload {
    type: string
    sql: ${TABLE}."FULL_PAYLOAD" ;;
  }

  set: detail {
    fields: [vendor_id, vendor_name, full_payload]
  }
}
