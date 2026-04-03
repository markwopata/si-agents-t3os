view: eagleproducts {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: Select t.SKU ProductCode,
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
#
#   # Define your dimensions and measures here, like this:
  dimension: ProductCode {
    type: string
    sql: ${TABLE}.ProductCode ;;
  }

  dimension: BarCode {
    type: string
    sql: ${TABLE}.BarCode ;;
  }

  dimension: BarcodeType {
    type: number
    sql: ${TABLE}.BarcodeType ;;
  }

  dimension: SupplierCode {
    type: number
    sql: ${TABLE}.SupplierCode ;;
  }
}
