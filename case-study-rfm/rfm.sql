-- CASE STUDY: Retail Customer Segmentation (RFM)
-- Tools: BigQuery SQL
-- Purpose: Segment customers using Recency, Frequency, Monetary (RFM) scoring for targeting and retention.
 
WITH rfm_base AS (
  SELECT
    CustomerID,
    DATE_DIFF(DATE '2024-12-31', MAX(TransactionDate), DAY) AS recency_days,
    COUNT(DISTINCT ReceiptID) AS frequency,
    SUM(NetSales_ExclDelivery) AS monetary
  FROM `project-00-487801.Retail_dataset.v_transactions_clean`
  GROUP BY CustomerID
),

rfm_scored AS (
  SELECT
    CustomerID,
    recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
    NTILE(5) OVER (ORDER BY frequency) AS frequency_score,
    NTILE(5) OVER (ORDER BY monetary) AS monetary_score
  FROM rfm_base
),

rfm_segmented AS (
  SELECT
    *,
    CONCAT(recency_score, frequency_score, monetary_score) AS rfm_cell,
    CASE
      WHEN CONCAT(recency_score, frequency_score, monetary_score) IN ('355','255')
        THEN 'Cannot Lose'
      WHEN CONCAT(recency_score, frequency_score, monetary_score) IN ('543','542','453','452')
        THEN 'Active Fans'
      WHEN CONCAT(recency_score, frequency_score, monetary_score) IN ('525','524','515','514')
        THEN 'Promising Newbies'
      WHEN CONCAT(recency_score, frequency_score, monetary_score) IN ('335','334','325','324')
        THEN 'Potential Churners'
      ELSE 'Others'
    END AS rfm_segment
  FROM rfm_scored
)	

SELECT
  rfm_segment,
  COUNT(*) AS customers,

  ROUND(AVG(recency_days), 1) AS avg_recency_days,
  ROUND(AVG(frequency), 2) AS avg_frequency,
  ROUND(AVG(monetary), 2) AS avg_monetary,

  ROUND(AVG(recency_score), 2) AS avg_recency_score,
  ROUND(AVG(frequency_score), 2) AS avg_frequency_score,
  ROUND(AVG(monetary_score), 2) AS avg_monetary_score

FROM rfm_segmented
GROUP BY rfm_segment
ORDER BY customers DESC;




