--------------------------------
--D. Outside The Box Questions--
--------------------------------

--1.How would you calculate the rate of growth for Foodie-Fi?

/*
- I choose the year of 2020 to analyze because I already created the [payments] table in part C.
- If you want to incorporate the data in 2021 to see the whole picture (quarterly, 2020-2021 comparison, etc.), 
create a new [payments] table and change all the date conditions in part C to '2021-12-31'.
*/

WITH monthlyRevenue AS (
  SELECT 
    MONTH(payment_date) AS months,
    SUM(amount) AS revenue
  FROM payments
  GROUP BY MONTH(payment_date)
)

SELECT 
  months,
  revenue,
  (revenue-LAG(revenue) OVER(ORDER BY months))/revenue AS revenue_growth
FROM monthlyRevenue;


--2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?

/*
- Monthly revenue growth: How does Foodie-Fi's revenue increase or decrease by monthly? Are there any months that the number of customers increasing significantly?
- Customers growth: How many customers increase by monthly? How does the rate look like (x1.5, x2,... after each month)? 
- Conversion rate: How many customers keep using Foodie-Fi after trial? How does the rate look like (x1.5, x2,...after each month)?
- Churn rate: How many customers cancel the subscription by monthly? What plan they has used?
*/


--3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?

/*
- Customers who downgraded their plan
- Customers who upgraded from basic monthly to pro monthly or pro annual
- Customers who cancelled the subscription
*/


--4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?

/*
- What is the primary reason for the cancellation? Price, Service quality, Found an alternative, Others (please specify)
- Overall, how satisfied were you with the subscription? Very Satisfied, Satisfied, Neutral, Unsatisfied, Very Unsatisfied
- Would you consider using our products / services in the future? Definitely, Probably, Not Sure, Probably Not, Definitely Not
- Would you recommend our company to a colleague, friend or family member? Definitely, Probably, Not Sure, Probably Not, Definitely Not
*/


--5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?

/*
- From the exit survey, collect
