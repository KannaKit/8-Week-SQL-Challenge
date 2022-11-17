---------------------------------
--C. Challenge Payment Question--
---------------------------------

/*
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid 
by each customer in the subscriptions table with the following requirements:
- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments
*/


--Copy the column definition from table [subscriptions], [plans] and paste them to the new table [payments]

SELECT 
  s.customer_id, 
  s.plan_id, 
  p.plan_name, 
  s.start_date AS payment_date, 
  p.price AS amount, 
  ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.start_date) AS payment_order
INTO payments
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE 1=0;

--Use a recursive CTE to increment rows for all paid plans in 2020 by monthly until customers changed the plan, except 'pro annual'

WITH dateRecursion AS (
  SELECT 
    s.customer_id,
    s.plan_id,
    p.plan_name,
    s.start_date AS payment_date,
    CASE 
      --if a customer still used the current plan, next_date = '2020-12-31'
      WHEN LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) IS NULL THEN '2020-12-31'
      -- if a customer changed the plan, next_date = (month difference between start_date and changing date) + start_date
      ELSE DATEADD(MONTH, 
		   DATEDIFF(MONTH, start_date, LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date)),
		   start_date) END AS next_date,
    p.price AS amount
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
	
  --exclude trials because they didn't generate payments 
  WHERE p.plan_name NOT IN ('trial')
    AND YEAR(start_date) = 2020

  UNION ALL

  SELECT 
    customer_id,
    plan_id,
    plan_name,
    --increment payment_date by monthly
    DATEADD(MONTH, 1, payment_date) AS payment_date,
    next_date,
    amount
  FROM dateRecursion
  --stop incrementing when payment_date = next_date
  WHERE DATEADD(MONTH, 1, payment_date) <= next_date
    AND plan_name != 'pro annual'
)

--Insert into table [payments]
INSERT INTO payments 
  (customer_id, plan_id, plan_name, payment_date, amount, payment_order)
SELECT 
  customer_id,
  plan_id,
  plan_name,
  payment_date,
  amount,
  ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM dateRecursion
--exclude churns
WHERE amount IS NOT NULL
ORDER BY customer_id
OPTION (MAXRECURSION 365);
