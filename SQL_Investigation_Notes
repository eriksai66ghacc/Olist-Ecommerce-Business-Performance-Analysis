# Olist E-commerce — SQL Investigation Notes

## Purpose

These notes document the main SQL investigations, validation checks, troubleshooting steps, and analytical decisions made during the Olist E-commerce Business Performance Analysis project.

This file is primarily a **technical reference for future SQL practice and interview preparation**. Not every exploratory query is included; the focus is on useful investigations and problems that required analytical reasoning.

---

## 1. Data Validation

### 1.1 Row Counts

Validated the number of records in the main Olist tables before beginning analysis.

Key tables included:

* Orders
* Order Items
* Products
* Customers
* Reviews
* Sellers
* Payments

The row-count checks helped confirm that the imported datasets were complete and provided a baseline for later validation.

---

## 2. Missing Values

### Product Category

The Products table contained missing product-category values.

The analysis identified approximately **610 products** with missing category information.

These values were replaced with:

```text
unknown
```

This prevented products from being excluded from category-level analysis.

### Lesson

Missing values should be handled according to their business meaning rather than simply removing records.

---

## 3. Duplicate Review IDs

The Reviews table contained duplicate `review_id` values.

Some review IDs appeared more than once, including cases where the same ID appeared multiple times.

This required investigation before using review counts in analysis.

### Lesson

A duplicate identifier does not automatically mean the entire record is a duplicate. The underlying data structure and relationships must be examined before removing records.

---

## 4. Timestamp Validation

Investigated relationships between important order and delivery timestamps, including:

* Order purchase date
* Estimated delivery date
* Actual delivery date
* Review creation date

Timestamp checks were important for calculating delivery performance and identifying potentially inconsistent records.

For delivery analysis, orders marked as delivered without the required delivery timestamps were excluded from the delivery-time calculation.

---

## 5. Revenue Validation

The project consistently defined revenue as:

```sql
SUM(order_items.price)
```

Freight was excluded from the portfolio revenue definition.

The final validated revenue was approximately:

```text
13,591,643.70
```

### Lesson

A business metric must have a clearly defined calculation rule and should be applied consistently across SQL and Power BI.

---

## 6. Order Count and AOV Validation

The final Power BI validation produced:

```text
Total Orders = 99,441
Revenue = 13,591,643.70
AOV = 136.68
```

The AOV calculation is consistent with:

```text
13,591,643.70 / 99,441 ≈ 136.68
```

This validation helped resolve earlier differences between order counts and AOV calculations.

### Lesson

When a KPI does not match expectations, validate the numerator, denominator, filters, relationships, and aggregation logic rather than assuming the calculation is correct.

---

## 7. One-to-Many Relationship Checks

Olist contains several one-to-many relationships.

For example:

```text
One Order
   ↓
Many Order Items
```

Counting rows from `order_items` can therefore inflate order counts.

For order-level metrics, `COUNT(DISTINCT order_id)` was used where appropriate.

Example:

```sql
COUNT(DISTINCT order_id)
```

### Lesson

Understanding table relationships is essential when calculating business metrics from relational e-commerce data.

---

## 8. Customer Repeat-Purchase Investigation

Customer purchasing behaviour was analysed using `customer_unique_id`.

Customers were classified into:

* One-time customers
* Repeat customers

The analysis found approximately:

```text
97% one-time customers
3% repeat customers
```

Repeat customers generated substantially higher average revenue per customer.

Repeat-purchase intervals were also investigated to understand the time between purchases.

### Lesson

Customer-level analysis should use a stable customer identifier rather than relying only on individual order IDs.

---

## 9. Delivery Performance Investigation

Delivery performance was analysed using orders with valid delivery timestamps.

Key metrics included:

* Delivered orders
* Average delivery days
* Median delivery days
* On-time orders
* Late orders
* Delay severity
* Monthly delivery performance

Final results:

```text
Delivered orders = 96,470
Average delivery time = 12.5 days
Median delivery time = 10 days
On-time = 93.23%
Late = 6.77%
```

The monthly analysis also showed declining on-time performance:

```text
2016 = 98.88%
2017 = 94.35%
2018 = 92.27%
```

### Lesson

Looking only at the overall delivery rate can hide changes over time. Trend analysis provides additional operational insight.

---

## 10. Review Score Investigation

Customer reviews were analysed using the review score and review creation date.

Overall:

```text
Reviews = 99,224
Average score = 4.09 / 5
```

The review distribution was also examined to understand the difference between positive and negative customer experiences.

---

## 11. December 2016 Review Anomaly

December 2016 showed an unusually low average review score:

```text
Average review score = 2.36 / 5
Reviews = 45
```

Further investigation showed:

```text
1-star reviews = 29
1-star share = 64.44%
```

The customer comments were then reviewed to identify recurring complaint themes.

Main themes included:

* Non-delivery
* Delivery problems
* Stock and fulfilment problems
* Poor communication
* Refund/payment concerns
* Product-quality issues

### Conclusion

The evidence suggests that the December decline reflected broader customer-experience and fulfilment issues rather than delivery delays alone.

However, the investigation did **not** establish one single direct root cause.

### Important Analytical Limitation

Review creation date and order purchase date represent different stages of the customer journey.

Therefore, monthly review performance should not automatically be interpreted as the delivery performance of orders purchased in the same calendar month.

---

## 12. Review Score vs Delivery Performance

Average review scores were compared between on-time and late orders.

Results:

```text
On-time orders = 4.29 / 5
Late orders = 2.27 / 5
Difference = 2.02 points
```

This showed a strong association between delivery reliability and customer satisfaction.

However:

> Association does not establish causation.

The analysis therefore avoids claiming that late delivery was the sole cause of lower review scores.

---

## 13. December 2016 AOV Anomaly

The Power BI Monthly AOV analysis showed an unusually low AOV of:

```text
December 2016 = 10.90
```

This was treated as a separate anomaly from the December review-score decline.

Although both occurred during December 2016, the analysis does **not** establish that they had the same root cause.

### Interview Position

If asked about this:

> "I noticed two unusual signals in December 2016: a sharp decline in monthly AOV and a decline in customer review scores. I investigated them as separate signals rather than assuming they had the same cause. The review investigation identified broader fulfilment and customer-experience issues, but the available analysis did not prove that those issues directly caused the AOV decline."

---

## 14. SQL vs Power BI Validation

SQL results were compared against Power BI calculations to identify inconsistencies.

This included checking:

* Revenue
* Order counts
* AOV
* Revenue shares
* Customer metrics
* Delivery metrics
* Review metrics

Power BI relationship behaviour was also investigated when dashboard results did not initially match expectations.

### Lesson

SQL and Power BI should be treated as complementary tools. SQL can provide a validation baseline, while Power BI supports modelling, visualization and interactive analysis.

---

## 15. Power BI Relationship Troubleshooting

A monthly revenue calculation initially produced an incorrect flat-line result.

The issue was investigated by checking the Power BI data model and relationships.

The problem was related to the date relationship between the Date Table and Orders table.

After correcting the relationship, the monthly revenue trend behaved as expected.

### Lesson

When a Power BI visual produces an unexpected result, check the data model and relationship configuration before changing the DAX measure.

---

## 16. Important SQL Techniques Practiced

During the project, the main SQL techniques included:

* `SELECT`
* `WHERE`
* `CASE`
* `GROUP BY`
* `ORDER BY`
* Aggregate functions
* `COUNT`
* `COUNT(DISTINCT ...)`
* `SUM`
* `AVG`
* `JOIN`
* `LEFT JOIN`
* Common Table Expressions (CTEs)
* Date functions
* Conditional calculations
* Data-quality validation

---

## 17. Main Problem-Solving Approach

The overall analytical process followed this pattern:

```text
Business Question
       ↓
SQL Investigation
       ↓
Unexpected / Interesting Result
       ↓
Validation
       ↓
Drill-Down Investigation
       ↓
Business Interpretation
       ↓
Power BI Visualization
       ↓
Business Recommendation
```

The project was not only about producing SQL queries. The main goal was to understand whether the results were reliable and what they meant from a business perspective.

---

## 18. Key Lessons from the Project

### Lesson 1 — Validate before interpreting

A number should not be accepted simply because SQL or Power BI produces it.

### Lesson 2 — Understand table relationships

One-to-many relationships can create inflated counts and incorrect metrics.

### Lesson 3 — Investigate anomalies

Unexpected results can reveal important business problems.

### Lesson 4 — Do not overclaim causation

A relationship between two variables does not automatically prove that one caused the other.

### Lesson 5 — Use SQL and Power BI together

SQL is useful for validation and detailed analysis, while Power BI is useful for modelling, visualization and communicating business insights.

### Lesson 6 — Business questions come first

SQL queries should support a business question rather than exist only as technical exercises.

---

## 19. Portfolio SQL vs Investigation SQL

Not every query created during the project needs to appear in the final portfolio.

The portfolio focuses on:

* Business questions
* Key SQL analysis
* Important metrics
* Insights
* Recommendations

These investigation notes preserve additional technical work for:

* Future SQL practice
* Interview preparation
* Troubleshooting reference
* Reviewing analytical decisions
* Reusing SQL techniques in future projects

---

## Final Note

The most valuable part of the project was not simply calculating metrics. It was learning to **validate results, investigate unexpected findings, understand data relationships, recognize analytical limitations, and translate SQL analysis into business decisions**.
