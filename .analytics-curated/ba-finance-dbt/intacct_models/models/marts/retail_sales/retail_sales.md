# Retail Sales DBT Setup

This document outlines the data transformation pipeline for retail sales data in our DBT project.

## 📊 Data Pipeline Overview

### 1. Stages
**Purpose:** Convert the data into a usable, normalized form

- **Quotes** - Raw quote data processing
- **Assets** - Asset information standardization  
- **Cost Items** - Cost-related data normalization
- **Rebate Items** - Rebate and discount processing
- **Trade Ins** - Trade-in value calculations

### 2. Intermediates
**Purpose:** Using ONLY retail sales data, combine stages by level of detail

- **Quotes** → Aggregated at the quote level
- **Assets** → Aggregated at the asset level  
- **Line Detail** → Individual line items with full detail

### 3. Marts
**Purpose:** Combine intermediates with external data (users, markets, etc.) & filter to current version only

**Final outputs:**
- **Quotes** - Complete quote-level metrics
- **Assets** - Asset-level analytics
- **Line Detail** - Granular line-item reporting

---

## 🔄 Data Flow

```
Raw Data → Stages → Intermediates → Marts → Analytics
```

Each layer builds upon the previous, ensuring data quality and consistency throughout the transformation process.
