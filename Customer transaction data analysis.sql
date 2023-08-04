SELECT * FROM transaction.transaction_data;

-- 1.Data cleaning:

-- 1.1 check the datatype:

ALTER TABLE `transaction`.`transaction_data` 
CHANGE COLUMN `date` `date` DATE NULL DEFAULT NULL ;

-- 1.2 modidy the name of column to delete the blank space:

ALTER TABLE `transaction`.`transaction_data` 
CHANGE COLUMN `customer id` `customer_id` TEXT NULL DEFAULT NULL ;

-- 1.3 check the missing value: have no missing value

SELECT customer_id
FROM transaction.transaction_data
WHERE customer_id IS NULL;

-- 2. General transaction data analysis

-- 2.1 transaction quantity by month 

SELECT 
DATE_FORMAT(order_date,'%Y-%m') as 'year_month',
SUM(quantity) as 'sum_quantity'
FROM transaction.transaction_data
GROUP BY DATE_FORMAT(order_date,'%Y-%m')
ORDER BY 1;

-- 2.2 transaction amount by month 

SELECT 
DATE_FORMAT(order_date,'%Y-%m') as 'year_month',
ROUND(SUM(money),2) as 'sum_money' 
FROM transaction.transaction_data
GROUP BY DATE_FORMAT(order_date,'%Y-%m')
ORDER BY 1;

-- 2.3 order numbers by month 
SELECT 
DATE_FORMAT(order_date,'%Y-%m') as 'year_month',
COUNT(customer_id) as ' order_numbers'
FROM transaction.transaction_data
GROUP BY DATE_FORMAT(order_date,'%Y-%m')
ORDER BY 1;

-- 2.4 customer numbers by month 

SELECT 
DATE_FORMAT(order_date,'%Y-%m') as 'year_month',
COUNT(DISTINCT(customer_id)) as ' customer_numbers'
FROM transaction.transaction_data
GROUP BY DATE_FORMAT(order_date,'%Y-%m')
ORDER BY 1;

-- 3. transaction data analysis by individual customer

-- 3.1 sum quantity and amount by individual customer

SELECT 
customer_id,
SUM(quantity) as 'sum_quantity',
ROUND(SUM(money),2) as 'sum_money' 
FROM transaction.transaction_data
GROUP BY customer_id
ORDER BY 3 DESC;

-- 3.2 average quantity and amount by individual customer
SELECT
customer_id,
ROUND(AVG(quantity)) as 'avg_quantity',
ROUND(AVG(money),2) as 'avg_money' 
FROM transaction.transaction_data
GROUP BY customer_id
ORDER BY 3 DESC;

-- 3.3  sum quantity by individual customer

SELECT 
customer_id,
SUM(quantity) as 'sum_quantity'
FROM transaction.transaction_data
GROUP BY customer_id
ORDER BY 2 DESC;

-- 3.4 the datetime distribution of the first purchase
SELECT 
first_purchase_date,
count(first_purchase_date) as "num_first_purchase_date"
FROM
(SELECT 
customer_id,
min(order_date) as first_purchase_date 
FROM transaction.transaction_data
GROUP BY customer_id) t
GROUP BY first_purchase_date
ORDER BY count(first_purchase_date) DESC;

-- 3.5 the datetime distribution of the last purchase

SELECT 
last_purchase_date,
count(last_purchase_date) as "num_last_purchase_date"
FROM
(SELECT 
customer_id,
max(order_date) as last_purchase_date 
FROM transaction.transaction_data
GROUP BY customer_id) t
GROUP BY last_purchase_date
ORDER BY count(last_purchase_date) DESC;


-- 4. RFM MODEL
SELECT 
customer_id,
DATEDIFF(DATE(NOW()), MAX(order_date)) AS recency,
COUNT(customer_id) as frequency,
ROUND(SUM(money)) as monetary
FROM transaction.transaction_data
GROUP BY customer_id;



WITH base AS (
SELECT 
customer_id,
DATEDIFF(DATE(NOW()), MAX(order_date)) AS recency,
COUNT(customer_id) as frequency,
ROUND(SUM(money)) as monetary
FROM transaction.transaction_data
GROUP BY customer_id
) , RFM AS(
SELECT 
customer_id,
recency,
frequency,
monetary,
NTILE(5) OVER (ORDER BY recency DESC) AS R,
NTILE(5) OVER (ORDER BY frequency ASC) AS F,
NTILE(5) OVER (ORDER BY monetary ASC) AS M
FROM base
) , RFM_2 AS(
SELECT customer_id,
recency,
frequency,
monetary,
CONCAT(R,F,M) AS RFM_score
FROM RFM
) SELECT
customer_id,
recency,
frequency,
monetary,
RFM_score,
CASE 
WHEN RFM_score IN (555,554,544,545,454,455,445) THEN 'champions'
WHEN RFM_score IN (543,444,435,355,354,345,344,335) THEN 'loyalist'
WHEN RFM_score IN (553,551,552,541,542,533,532,531,452,451,442,441,431,453,433,432,423,353,352,351,342,341,333,323) THEN 'potential loyalist'
WHEN RFM_score IN (512,511,422,421,412,411,311) THEN 'new_customer'
WHEN RFM_score IN (525,524,523,522,521,515,514,513,425,424,413,414,415,315,314,313) THEN 'promising'
WHEN RFM_score IN (535,534,443,434,343,334,325,324) THEN 'need_attention'
WHEN RFM_score IN (331,321,312,221,213,231,241,251) THEN 'about_to_sleep'
WHEN RFM_score IN (255,254,245,244,253,252,243,242,235,234,225,224,153,152,145,143,142,135,134,133,125,124) THEN 'at_risk'
WHEN RFM_score IN (155,154,144,214,215,115,114,113) THEN 'can_not_lose_them'
WHEN RFM_score IN (332,322,231,241,251,233,232,223,222,132,123,122,212,211) THEN 'hibernation_customer'
WHEN RFM_score IN (111,112,121,131,141,151) THEN 'lost_customer'
END AS rfm_segment
FROM RFM_2;

-- the average value of customer lifetime is 135 days
SELECT AVG(lifetime_value) AS avg_lifetime_value
FROM (
SELECT customer_id,
DATEDIFF(max(order_date),min(order_date)) as lifetime_value
FROM transaction.transaction_data
GROUP BY customer_id
ORDER BY lifetime_value DESC) a;

-- the general lifetime value 
SELECT customer_id,
DATEDIFF(max(order_date),min(order_date)) as lifetime_value
FROM transaction.transaction_data
GROUP BY customer_id
ORDER BY lifetime_value DESC;

-- customer lifetime value =0 -----low quality customer
SELECT customer_id,
DATEDIFF(max(order_date),min(order_date)) as lifetime_value
FROM transaction.transaction_data
GROUP BY customer_id
HAVING lifetime_value=0
ORDER BY lifetime_value DESC;

-- multiple purchase

SELECT customer_id,
DATEDIFF(max(order_date),min(order_date)) as lifetime_value
FROM transaction.transaction_data
GROUP BY customer_id
HAVING lifetime_value>0
ORDER BY lifetime_value DESC;












