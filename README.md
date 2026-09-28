# 📊 Olist E-Commerce Cohort & Retention Analysis (SQL & Python)

This project performs an end-to-end **Customer Cohort and Retention Analysis** on Brazilian e-commerce data from Olist. The analysis focuses on building a monthly retention matrix entirely in SQL, visualizing customer behavior patterns, and calculating revenue retention over time.

---

## 📌 Project Overview
Customer retention is a key metric for evaluating business growth and customer lifetime value (LTV). Using SQL CTEs and window functions, this project identifies customer first-purchase cohorts, tracks repeat purchases across subsequent months, and evaluates marketplace dynamics.

### Key Objectives:
- **Cohort Assignment:** Group customers by the month of their very first order (`cohort_month`).
- **Period Indexing:** Track order behavior over time (`period_number` from Month 0 onward).
- **Retention Rate:** Measure the percentage of returning active customers per period.
- **Revenue Retention:** Calculate cumulative revenue per customer per cohort.

---

## ⚠️ Important Methodological Note: The `customer_unique_id` Trap
In the Olist dataset:
- `customer_id` is a temporary key assigned **per order** (unique per transaction).
- `customer_unique_id` represents the **actual individual customer**.

> **Crucial Finding:** Using `customer_id` for retention calculations creates a false 0% retention rate across all periods because every order appears to belong to a new customer. Joining with `olist_customers_dataset` to use `customer_unique_id` is mandatory to observe real repeat behavior.

---

## 🛠️ Tech Stack & Methodology
- **SQL Engine:** SQLite (CTEs, Window Functions `MIN() OVER (...)`, Conditional Aggregation)
- **Data Wrangling:** Python (`pandas`)
- **Data Visualization:** `seaborn` (Heatmaps) and `matplotlib` (Retention curves)
- **Environment:** GitHub Codespaces / Jupyter Notebook

---

## 🗄️ Database & Setup
The project utilizes an optimized SQLite database file (`olist_ecommerce.db`) containing only the necessary tables required for cohort and retention calculations:
- `orders`: Order dates, statuses, and customer mappings.
- `customers`: Customer unique identifiers (`customer_unique_id`).
- `order_items`: Product pricing and financial values for revenue retention.
- `order_reviews`: Review scores and delivery satisfaction metrics.

> **Execution:** You can open and query `olist_ecommerce.db` directly inside GitHub Codespaces or any local SQLite client.

---

## 📁 Repository Structure
```text
├── olist_ecommerce.db        # SQLite database containing essential cleaned tables
├── queries.sql               # Full SQL pipeline (CTEs, cohort matrix, revenue metrics)
├── retention_analysis.ipynb  # Jupyter notebook executing SQL and generating charts
├── note.md                   # Comprehensive business findings & strategic insights
└── README.md                 # Project documentation & overview
