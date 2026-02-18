# Case Study – Retail Customer Segmentation (RFM Analysis)

## Problem
BrightMart, an omnichannel retail business, needed a simple analytical method to identify high-value customers and customers at risk of churn to support targeted marketing and retention strategies.

## Dataset
Simulated retail customer and transaction dataset containing purchase history, delivery channels, and customer engagement attributes.

## Tools
BigQuery SQL

## What I Did
- Built an RFM base table per customer calculating **Recency (days since last purchase), Frequency (number of receipts), and Monetary (total spend)**.
- Applied **NTILE(5) window functions** to score each customer into quintiles for R, F, and M dimensions.
- Created business-oriented customer segments (e.g., *Active Fans*, *Cannot Lose*, *Potential Churners*) using CASE logic and summarised KPIs per segment.

## Key Query Snippet
```sql
NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
NTILE(5) OVER (ORDER BY frequency) AS frequency_score,
NTILE(5) OVER (ORDER BY monetary) AS monetary_score
