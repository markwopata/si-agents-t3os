# Documentation Organization

This directory contains dbt documentation organized by data lineage and business context.

## Structure

```
docs/
├── common/          # Commonly used fields, including metadata and fields
├── source/          # Source system fields (raw, unmodified)
├── transformed/     # Derived/calculated fields
└── gold/            # Mart-layer only fields
```

## Documentation Layer Rules

### Common (`common/`)
**Purpose**: Metadata columns used across ALL data layers, agnostic to business context

**Contains**:
- SCD2 fields: `_valid_from`, `_valid_to`, `_is_current`
- CDC fields: `_effective_start_utc_datetime`, `_effective_end_utc_datetime`
- Technical metadata: `_dbt_updated_timestamp`, `_created_recordtimestamp`
- Fivetran fields: `fivetran_synced`, `fivetran_start`, `fivetran_end`
- Core ES system fields: `es_user_id`, `es_company_id`, `es_market_id`
- Platform Gold fields: Manually bringing in definitions from platform project

### Source (`source/`)
**Purpose**: Fields that exist in source systems and propagate downstream without modification

**Contains**:
- Raw source system fields (Heap, Intercom, ESDB fields)
- System-specific identifiers and attributes
- Source timestamps and flags that pass through unchanged
- Business identifiers that come directly from sources

**Files**: `[system]_docs.md` (e.g., `heap_built_in_properties.md`, `quotes_docs.md`)

### Transformed (`transformed/`)
**Purpose**: Fields that are derived, calculated, or modified from source data

**Contains**:
- Calculated business logic fields (`conversion_status`, `is_new_account`)
- Derived classifications (`company_flag`, `asset_ownership`)
- Aggregated values (`total_amount`, `days_since_last_order`)
- Business rules implementation (`is_vip`, `activity_status`)
- Data quality flags and cleansing results

**Files**: `[domain]_docs.md` (e.g., `companies_docs.md`, `invoices_docs.md`)

### Mart (`mart/`)
**Purpose**: Fields that exist ONLY in the mart layer (dimensions, facts, bridges)

**Contains**:
- Surrogate keys (`quote_key`, `company_key`, `order_key`)
- Foreign key references to dimension tables (`created_date_key`, `user_key`)
- Mart-specific derived fields that don't exist in intermediate layers
- Platform project field definitions (`platform_gold_docs.md`)

**Organization**:
- `dimensions.md` - All dimension table specific fields
- `facts.md` - All fact table specific fields  
- `bridges.md` - All bridge table specific fields

## Best Practices

1. **Follow Data Lineage**: Place documentation based on where the field is first created/modified
2. **Avoid Duplication**: Each field should be documented in only one location
3. **Use Descriptive Names**: Include business context and relationships
4. **Reference Sources**: Link to upstream systems and tables when relevant
5. **Include Valid Values**: Document enums, flags, and constrained values

## Migration Guidelines

When moving fields between layers:
1. Check usage with: `grep -r "doc('field_name')" models/`
2. Move to appropriate layer file (create if needed)
3. Update references in YAML files
4. Follow naming conventions for new files