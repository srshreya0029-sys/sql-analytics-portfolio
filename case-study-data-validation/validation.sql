-- CASE STUDY: Retail Data Validation & Cleaning (BrightMart-style dataset)
-- Tools: BigQuery SQL
-- Purpose: Validate customer/transaction data quality and create a clean analysis view.

-- 1) Referential integrity / PK consistency: transactions referencing missing customers
SELECT DISTINCT
  t.CustomerID
FROM `project-00-487801.Retail_dataset.transactions` AS t
LEFT JOIN `project-00-487801.Retail_dataset.customers` AS c
  ON t.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

-- 2) NULL checks: customer table
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(CustomerID IS NULL) AS null_customerid,
  COUNTIF(CustomerAge IS NULL) AS null_age,
  COUNTIF(LoyaltyTier IS NULL) AS null_loyaltytier,
  COUNTIF(PreferredChannel IS NULL) AS null_preferredchannel,
  COUNTIF(PreferredStoreLocation IS NULL) AS null_storelocations,
  COUNTIF(OmnichannelStatus IS NULL) AS null_omnichannelstatus,
  COUNTIF(EmailEngagementScore IS NULL) AS null_engagementscore,
  COUNTIF(PromotionResponsiveness IS NULL) AS null_promotionresponsiveness,
  COUNTIF(Referral_Likelihood IS NULL) AS null_referral
FROM `project-00-487801.Retail_dataset.customers`;

-- 3) NULL checks: transactions table
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(ReceiptID IS NULL) AS null_receiptid,
  COUNTIF(CustomerID IS NULL) AS null_customerid,
  COUNTIF(TransactionDate IS NULL) AS null_transactiondate,
  COUNTIF(TotalAfterDiscount IS NULL) AS null_totalafterdiscount,
  COUNTIF(ProductCategory IS NULL) AS null_productcategory,
  COUNTIF(Channel IS NULL) AS null_channel,
  COUNTIF(DeliveryMethod IS NULL) AS null_deliverymethod,
  COUNTIF(DeliveryFee IS NULL) AS null_deliveryfee,
  COUNTIF(Quantity IS NULL) AS null_quantity,
  COUNTIF(UnitPrice IS NULL) AS null_unitprice,
  COUNTIF(SubtotalBeforeDiscount IS NULL) AS null_subtotalbeforediscount,
  COUNTIF(PaymentMethod IS NULL) AS null_paymentmethod,
  COUNTIF(SatisfactionRating IS NULL) AS null_satisfactionrating
FROM `project-00-487801.Retail_dataset.transactions`;

-- 4) Validation check: pricing equation mismatch (> 1 cent)
SELECT
  COUNT(*) AS rows_checked,
  COUNTIF(ABS((SubtotalBeforeDiscount - DiscountAmount) - TotalAfterDiscount) > 0.01)
    AS total_mismatch_over_1cent
FROM `project-00-487801.Retail_dataset.transactions`
WHERE SubtotalBeforeDiscount IS NOT NULL
  AND DiscountAmount IS NOT NULL
  AND TotalAfterDiscount IS NOT NULL;

-- 5) Create a clean view for analysis (standardise delivery + remove delivery fee from net sales)
CREATE OR REPLACE VIEW `project-00-487801.Retail_dataset.v_transactions_clean` AS
SELECT
  t.*,
  COALESCE(t.DeliveryMethod, 'In-Store Purchase') AS DeliveryMethod_clean,
  (t.TotalAfterDiscount - t.DeliveryFee) AS NetSales_ExclDelivery
FROM `project-00-487801.Retail_dataset.transactions` AS t;
