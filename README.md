# 📊 Gresikafe Sales Data Analysis (BigQuery + Looker Studio)
## 📌 Project Overview
This project analyzes Gresikafe sales transaction data using Google BigQuery and visualizes insights in Looker Studio. The goal is to uncover sales trends, best-selling products, and revenue patterns to support data-driven business decisions.  

## 🛠 Tools & Technologies
- SQL (BigQuery)
- Google Looker Studio
- Google Sheets / CSV
- GitHub

## 📄 Data Source
This dataset was obtained from Kaggle:  
***Cafe Sales - Dirty Data for Cleaning Training*** by ***Ahmed Mohamed***  
[Link to the Dataset](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training)  
Used for educational and portfolio purposes only.  

## 📂 Dataset
The dataset contains transactional sales data with the following fields:  
transaction_date  
item  
quantity  
price_per_unit  
total_spent  
payment_method  
location  
*(Data was cleaned and validated before analysis.)*

## 🎯 Key Objectives
1. Clean and validate raw sales data
2. Analyze revenue trends over time
3. Identify top-selling products
4. Compare sales by location and payment method
5. Build an interactive dashboard

## 🔍 Key Analysis Performed
1. Removed and handled missing values
2. Standardized item names using CASE WHEN
3. Calculated total revenue and average order value
4. Grouped sales by month, product, and location
5. Built KPI metrics in Looker Studio

## 📈 Dashboard
🔗 Live Dashboard: [Gresikafe Sales Dashboard](https://lookerstudio.google.com/reporting/263ca17e-fcf6-4494-824d-33ebcd0abf81)  
📸 Screenshots: Available in the `/gresikafe_screenshots` folder  

## 📁 Project Structure
```
gresikafe_sales_project/  
├── gresikafe_sales_project.sql  
├── gresikafe_screenshots/  
├── cleaned_cafe_sales.csv  
├── dirty_cafe_sales.csv  
├── menu.csv  
└── README.md
```
## 🚀 Results & Insights
- Coffee and Sandwiches generated the highest revenue
- Peak sales occurred during weekends
- Card payments were the most common payment method

## 📌 How to Run This Project
1. Upload dataset to BigQuery
2. Run SQL queries from queries.sql
3. Connect BigQuery results to Looker Studio
4. Build visualizations and KPIs

## 👤 Author
***Akmal Rizky Fauzan***  
Aspiring Data Analyst | SQL | BigQuery | Looker Studio  
[LinkedIn](https://www.linkedin.com/in/akmalrizk/) | [Portfolio](https://akmalrizk.github.io/akmal-s_portfolio/) | [Medium](https://medium.com/@akmalrizk)
