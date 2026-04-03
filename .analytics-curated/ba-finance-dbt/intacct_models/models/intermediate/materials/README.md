# Materials

Documented business logic for Materials metric calculations

Purpose: documentation for calculating Materials Metrics and providing definitions


## Table of Contents
- [Materials](#Materials)
  - [Table of Contents](#table-of-contents)
    - [TODO](#todo)
  - [Common Definitions](#common-definitions)
  - [Rules](#rules)
  - [Calculating Metrics](#calculating-metrics)
    - [Inventory Turnover Ratio](#rInventory-Turnover-Ratio)
    - [Sales per Sqft](#Sales-per-sqft)
  - [Appendix](#appendix)


### TODO
- Payroll to Revenue
- 

## Common Definitions


## Calculating Metrics

#### Inventory-Turnover-Ratio
*Inventory turnover Ratio for Material. Use analytics.materials.int_inventory_turnover_ratio*

Calculation: (sum(total_cost))/((opening_value + closing_value)/2) * 100

#### Sales-per-sqft
*Sales per sqft calucation for Materials. Use analytics.materials.int_sales_per_sq_ft*

Calculation: round(total_revenue / nullif(square_footage, 0), 2)