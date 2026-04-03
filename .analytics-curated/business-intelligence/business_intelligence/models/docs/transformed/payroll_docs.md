# Payroll Transformation Documentation

This file contains documentation for columns created in intermediate payroll/employee transformations.

## SCD2 Implementation Fields

## Organizational Hierarchy Parsing

{% docs division_name %}
Derived organizational division name parsed from cost center path using pattern recognition. Represents the highest level of organizational hierarchy.
{% enddocs %}

{% docs region_name %}
Extracted region name from cost center path hierarchy. Parsed using regex patterns to identify rental market regions (R1-R9, RH patterns).
{% enddocs %}

{% docs is_region %}
Classification flag using regex pattern matching to identify region-level organizational assignments. Used for territory management and reporting hierarchy.
{% enddocs %}

{% docs is_district %}
Classification flag identifying district-level assignments within the organizational hierarchy. Derived from cost center path pattern analysis.
{% enddocs %}

## Salesperson Classification Logic

## Employee Status Hybrid Logic

