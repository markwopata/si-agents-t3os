view: bistrack_product_import {
  derived_table: {
    sql:select t.SKU ProductCode,
t.UPC_NUMBER BarCode,
case when t.SEQ like '1' then '0' else '4' end BarcodeType,
case when try_to_numeric(t.SKU) and LENGTH(t.SKU) = 7 then t.SKU else null end as SupplierCode
from
(
select SKU,
UPC_NUMBER,
Row_Number() over (partition by SKU order by SKU) as SEQ
from ANALYTICS.BISTRACK.UPC as UPC
where UPC_NUMBER is not null
) as t
order by t.SKU
                        ;;
  }
  dimension: ProductCode {
    type: number
    sql: ${TABLE}.ProductCode ;;
  }
  dimension: BarCode {
    type: number
    sql: ${TABLE}.BarCode ;;
  }
  dimension: BarcodeType {
    type: string
    sql: ${TABLE}.BarcodeType ;;
  }
  dimension: SupplierCode {
    type: string
    sql: ${TABLE}.SupplierCode ;;
  }
}
