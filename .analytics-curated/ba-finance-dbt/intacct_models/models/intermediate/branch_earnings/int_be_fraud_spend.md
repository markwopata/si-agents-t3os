/*
 Ask: POs/Credit Card Spend at markets less than 12 months.
 Goal: Capture/Research spend pushed from >12 markets to <12 markets for purposes of hiding expenses.

 Possible Quirks:
 - How do I tell normal spend from spend at wrong market? The delivery address is probably not on the PO/credit card
   transaction?

 Approaches/Data:
 - Ignores
    - PO closed by Closed PO - ignore
    - Manual JE activity/BE entries - ignore
 - Data to look at
    - POs
    - Invoices - maybe we just do invoices, ignore the corrections and POs?
    - Credit Card Spend
    - WOs coded to u12s?

 - Add peg to revenue so you can see worst offenders

 Dashboards:
 - 2x
    - One by market/district
    - One with the detail

 Filters:
 - Markets <12 months
 - Add filter for markets <=0 months
 - Filter for $x


 */

 select 1
 