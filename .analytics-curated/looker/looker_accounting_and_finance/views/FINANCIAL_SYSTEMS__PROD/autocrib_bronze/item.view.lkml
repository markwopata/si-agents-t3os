view: item {
  sql_table_name: "ANALYTICS"."AUTOCRIB_DBO"."ITEM" ;;

  dimension: abcclass {
    type: string
    sql: ${TABLE}."ABCCLASS" ;;
  }
  dimension: accountno {
    type: string
    sql: ${TABLE}."ACCOUNTNO" ;;
  }
  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }
  dimension: adjustedstandardprice {
    type: number
    sql: ${TABLE}."ADJUSTEDSTANDARDPRICE" ;;
  }
  dimension_group: adjustedstandardpricedate {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."ADJUSTEDSTANDARDPRICEDATE" ;;
  }
  dimension: binheight {
    type: number
    sql: ${TABLE}."BINHEIGHT" ;;
  }
  dimension: binsize {
    type: number
    sql: ${TABLE}."BINSIZE" ;;
  }
  dimension: customerdbid {
    type: number
    sql: ${TABLE}."CUSTOMERDBID" ;;
  }
  dimension: customfield1 {
    type: string
    sql: ${TABLE}."CUSTOMFIELD1" ;;
  }
  dimension: customfield2 {
    type: string
    sql: ${TABLE}."CUSTOMFIELD2" ;;
  }
  dimension: customfield3 {
    type: string
    sql: ${TABLE}."CUSTOMFIELD3" ;;
  }
  dimension: customfield4 {
    type: string
    sql: ${TABLE}."CUSTOMFIELD4" ;;
  }
  dimension: customfield5 {
    type: string
    sql: ${TABLE}."CUSTOMFIELD5" ;;
  }
  dimension: customfield6 {
    type: string
    sql: ${TABLE}."CUSTOMFIELD6" ;;
  }
  dimension: customfield7 {
    type: string
    sql: ${TABLE}."CUSTOMFIELD7" ;;
  }
  dimension: customfield8 {
    type: string
    sql: ${TABLE}."CUSTOMFIELD8" ;;
  }
  dimension: customfield9 {
    type: string
    sql: ${TABLE}."CUSTOMFIELD9" ;;
  }
  dimension: customfield10 {
    type: string
    sql: ${TABLE}."CUSTOMFIELD10" ;;
  }
  dimension: customfield11 {
    type: string
    sql: ${TABLE}."CUSTOMFIELD11" ;;
  }
  dimension: customfield12 {
    type: string
    sql: ${TABLE}."CUSTOMFIELD12" ;;
  }
  dimension_group: datecreated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATECREATED" ;;
  }
  dimension: description1 {
    type: string
    sql: ${TABLE}."DESCRIPTION1" ;;
  }
  dimension: description2 {
    type: string
    sql: ${TABLE}."DESCRIPTION2" ;;
  }
  dimension: filltomax {
    type: yesno
    sql: ${TABLE}."FILLTOMAX" ;;
  }
  dimension: fodcontrol {
    type: yesno
    sql: ${TABLE}."FODCONTROL" ;;
  }
  dimension: fullcharge {
    type: number
    sql: ${TABLE}."FULLCHARGE" ;;
  }
  dimension: issuecost {
    type: number
    sql: ${TABLE}."ISSUECOST" ;;
  }
  dimension: itemclass {
    type: string
    sql: ${TABLE}."ITEMCLASS" ;;
  }
  dimension: itemgroup {
    type: string
    sql: ${TABLE}."ITEMGROUP" ;;
  }
  dimension: itemno {
    type: string
    sql: ${TABLE}."ITEMNO" ;;
  }
  dimension: itemtype {
    type: number
    sql: ${TABLE}."ITEMTYPE" ;;
  }
  dimension: kit {
    type: yesno
    sql: ${TABLE}."KIT" ;;
  }
  dimension_group: lastissue {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."LASTISSUE" ;;
  }
  dimension_group: lastreview {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."LASTREVIEW" ;;
  }
  dimension_group: lastupdated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."LASTUPDATED" ;;
  }
  dimension: lastyearcost {
    type: number
    sql: ${TABLE}."LASTYEARCOST" ;;
  }
  dimension: lastyearissues {
    type: number
    sql: ${TABLE}."LASTYEARISSUES" ;;
  }
  dimension: leadtime {
    type: number
    sql: ${TABLE}."LEADTIME" ;;
  }
  dimension_group: leadtimelockdate {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."LEADTIMELOCKDATE" ;;
  }
  dimension: lotcontrol {
    type: yesno
    sql: ${TABLE}."LOTCONTROL" ;;
  }
  dimension: lotexpiration {
    type: yesno
    sql: ${TABLE}."LOTEXPIRATION" ;;
  }
  dimension: manufacturer {
    type: string
    sql: ${TABLE}."MANUFACTURER" ;;
  }
  dimension: manufactureritem {
    type: string
    sql: ${TABLE}."MANUFACTURERITEM" ;;
  }
  dimension: maxsystemquantity {
    type: number
    sql: ${TABLE}."MAXSYSTEMQUANTITY" ;;
  }
  dimension: minimumcharge {
    type: number
    sql: ${TABLE}."MINIMUMCHARGE" ;;
  }
  dimension: monthtodatecost {
    type: number
    sql: ${TABLE}."MONTHTODATECOST" ;;
  }
  dimension: monthtodateissues {
    type: number
    sql: ${TABLE}."MONTHTODATEISSUES" ;;
  }
  dimension: movingavgcost {
    type: number
    sql: ${TABLE}."MOVINGAVGCOST" ;;
  }
  dimension: movingavgprice {
    type: number
    sql: ${TABLE}."MOVINGAVGPRICE" ;;
  }
  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }
  dimension: orderquantity {
    type: number
    sql: ${TABLE}."ORDERQUANTITY" ;;
  }
  dimension: ped {
    type: yesno
    sql: ${TABLE}."PED" ;;
  }
  dimension: physicalkit {
    type: yesno
    sql: ${TABLE}."PHYSICALKIT" ;;
  }
  dimension: purchaseclass {
    type: string
    sql: ${TABLE}."PURCHASECLASS" ;;
  }
  dimension: recordid {
    type: number
    sql: ${TABLE}."RECORDID" ;;
  }
  dimension: referencedifferentpackqty {
    type: yesno
    sql: ${TABLE}."REFERENCEDIFFERENTPACKQTY" ;;
  }
  dimension: referenceitem {
    type: string
    sql: ${TABLE}."REFERENCEITEM" ;;
  }
  dimension: serialize {
    type: yesno
    sql: ${TABLE}."SERIALIZE" ;;
  }
  dimension: standardprice {
    type: number
    sql: ${TABLE}."STANDARDPRICE" ;;
  }
  dimension_group: standardpricedate {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."STANDARDPRICEDATE" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: supplieritem {
    type: string
    sql: ${TABLE}."SUPPLIERITEM" ;;
  }
  dimension: supplierno {
    type: string
    sql: ${TABLE}."SUPPLIERNO" ;;
  }
  dimension: txbinsize {
    type: string
    sql: ${TABLE}."TXBINSIZE" ;;
  }
  dimension: txheight {
    type: number
    sql: ${TABLE}."TXHEIGHT" ;;
  }
  dimension: unitcost {
    type: number
    sql: ${TABLE}."UNITCOST" ;;
  }
  dimension: unitofmeasure {
    type: string
    sql: ${TABLE}."UNITOFMEASURE" ;;
  }
  dimension: unitprice {
    type: number
    sql: ${TABLE}."UNITPRICE" ;;
  }
  dimension: weigh {
    type: yesno
    sql: ${TABLE}."WEIGH" ;;
  }
  dimension: weight {
    type: number
    sql: ${TABLE}."WEIGHT" ;;
  }
  dimension: yeartodatecost {
    type: number
    sql: ${TABLE}."YEARTODATECOST" ;;
  }
  dimension: yeartodateissues {
    type: number
    sql: ${TABLE}."YEARTODATEISSUES" ;;
  }
  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }
  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  measure: count {
    type: count
    drill_fields: [itemno, description1, manufacturer, supplierno, status]
  }
}
