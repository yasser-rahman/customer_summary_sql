  -- Customers' Summary TABLE
WITH
  customers_first_order AS(
  SELECT
    *
  FROM (
    SELECT
      customer_id,
      amount,
      payment_date,
      ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS order_nth
    FROM
      `jrjames83-1171.sampledata.payments`
    ORDER BY
      1)
  WHERE
    order_nth = 1 ),
  summary_so_far AS (
  SELECT
    p.customer_id,
    c.amount AS first_order_amount,
    MIN(p.payment_date) AS first_order_date,
    ROUND(SUM(p.amount), 2) AS total_revenue,
    ROUND(c.amount / SUM(p.amount) * 100, 2) || '%' AS first_order_as_pct_total_revenue
  FROM
    `jrjames83-1171.sampledata.payments` AS p
  JOIN
    customers_first_order AS c
  ON
    c.customer_id = p.customer_id
  GROUP BY
    1,
    2
  ORDER BY
    4 DESC)
SELECT
  sf.*,
  (
  SELECT
    SUM(p2.amount)
  FROM
    `jrjames83-1171.sampledata.payments` AS p2
  WHERE
    sf.customer_id = p2.customer_id
    AND DATE(p2.payment_date) BETWEEN DATE(sf.first_order_date)
    AND DATE_ADD(DATE(sf.first_order_date), INTERVAL 30 DAY) ) AS first_30_days_customer_value,
  (
  SELECT
    SUM(p2.amount)
  FROM
    `jrjames83-1171.sampledata.payments` AS p2
  WHERE
    sf.customer_id = p2.customer_id
    AND DATE(p2.payment_date) BETWEEN DATE(sf.first_order_date)
    AND DATE_ADD(DATE(sf.first_order_date), INTERVAL 60 DAY) ) AS first_60_days_customer_value
FROM
  summary_so_far AS sf
