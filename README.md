# Data Warehouse and Analytics Project

Building a modern data warehouse with SQL Server, including ETL processes, data modeling and analytics.



**Open the setup guide in the `00_setup` folder.** It walks you through installing SQL Server and creating the database, on Windows and Mac, with the fixes for the common errors.

```
sql-data-warehouse-project/
├── 00_setup/               the setup guide, and the one-click Docker start for Mac
├── 01_datasets/            the six source files the project loads
│   ├── source_crm/         three files from the CRM system
│   └── source_erp/         three files from the ERP system
├── 02_docs/                the requirements, the diagrams and the notes
├── 03_scripts/             the project scripts, in the order of the videos
│   ├── init_database.sql   creates the database: run it first
│   ├── bronze/             loads the raw files
│   ├── silver/             cleans and prepares the data
│   └── gold/               builds the tables for analysis
└── 04_tests/               checks the quality of the silver and gold data
```

The project reads the six files from `C:\sql\dwh_project\01_datasets\`. Put the folder there, or change the six paths in `03_scripts/bronze/proc_load_bronze.sql`. The videos show the folders without numbers: `datasets` there is `01_datasets` here, `scripts` is `03_scripts`.

---
## 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:
![Data Architecture](02_docs/data_architecture.png)

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---
## 📖 Project Overview

In this project, I:

1. **Design the architecture:** a modern data warehouse with three layers, bronze, silver and gold.
2. **Build the ETL pipelines:** load the source files and move the data through the layers.
3. **Model the data:** facts and dimensions, ready for reports.
4. **Analyze it:** answer business questions with SQL.

---

##  Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

### BI: Analytics & Reporting (Data Analysis)

#### Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.  

For more details, refer to [02_docs/requirements.md](02_docs/requirements.md).

---



## My SQL Journey

Hello, I am Pujitha Jujjarapu!

I recently completed over 30 hours of SQL training through the Data with Baraa YouTube channel. Throughout this course, I learned a lot, from the fundamentals of SQL to advanced concepts.

Alongside the course, I regularly practiced SQL problems on LeetCode and maintained this GitHub repository to document my practice queries and learning progress.

I have always enjoyed writing SQL queries and working with databases and tables. However, before taking this course, I hadn't explored many advanced SQL concepts, such as CTEs, views, and indexes, in depth. This course helped me understand these concepts and gave me more confidence in writing complex queries.

One of the things I appreciated most about this course was learning from Baraa's industry experience of over 15 years. He didn't just explain how to write queries; he also explained why he chose a particular approach and how to write queries more efficiently. This helped me understand the importance of not only getting the correct result but also writing SQL that is efficient, maintainable, and backed by sound reasoning.

I am grateful for the knowledge I've gained through this course and look forward to continuing my SQL journey, learning more, and improving my skills.

**There's still a lot to learn, and this is just the beginning!**
## Acknowledgment

This project was built by following the tutorials and instructions provided by [Data with Baraa](https://www.youtube.com/@DataWithBaraa) on YouTube. Credit goes to Baraa for the educational content and guidance.
