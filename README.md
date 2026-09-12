# Olist Brazilian E-commerce Business Performance Analysis

## Project Overview

An end-to-end e-commerce business analysis using **SQL Server and Power BI** based on the Olist Brazilian E-Commerce Public Dataset.

The project analyzes commercial performance, product concentration, customer purchasing behaviour, delivery reliability, and customer satisfaction to identify business opportunities and operational improvement areas.

## Business Questions

* What is driving Olist's revenue and where are the biggest commercial opportunities?
* Is revenue dependent on a small number of individual products?
* Are customers mostly one-time buyers, or is there evidence of repeat purchasing?
* How reliable was Olist's delivery performance?
* How satisfied were customers, and were there unusual periods of decline?

## Tools & Technologies

* **SQL Server / SSMS** — Data validation, cleaning, transformation, analysis and business metrics
* **Power BI** — Data modelling, DAX, visualization and interactive dashboards

## Key Analysis & Findings

### Revenue & Commercial Performance

* Total revenue: **13.59M**
* Total orders: **99,441**
* Average order value: **136.68**
* `beleza_saude` was the highest-revenue product category.
* Revenue performance was influenced by both order volume and order value.

### Product Concentration

* The Top 10 products contributed approximately **3.32% of total product revenue**.
* This indicates relatively low product-level concentration and a broadly diversified product portfolio.

### Customer Behaviour

* **97%** of customers were one-time buyers.
* Only **3%** were repeat customers.
* Repeat customers generated approximately **260.05 revenue per customer**, compared with **137.96** for one-time customers.
* This highlights a significant customer-retention opportunity.

### Delivery Performance

* **96,470** delivered orders were included in the delivery analysis.
* **93.23%** were delivered on time.
* **6.77%** were delivered late.
* On-time delivery performance declined from **98.88% in 2016 to 92.27% in 2018**.

### Customer Satisfaction

* Overall average review score: **4.09 / 5**
* **77.07%** of reviews were positive (4–5 stars).
* December 2016 showed an unusual decline to **2.36 / 5** based on only 45 reviews.
* Further investigation found that **29 of 45 reviews (64.44%) were 1-star ratings**.
* Customer comments indicated broader issues involving non-delivery, fulfilment, inventory, communication, refund/payment concerns and product quality.

The December 2016 review decline was treated as an early-warning signal. The analysis identified potential contributing issues but did not establish a single direct root cause.

## Business Recommendations

Based on the analysis:

* Prioritize high-performing product categories while monitoring revenue per order.
* Maintain product diversification while monitoring high-performing products.
* Develop strategies to increase repeat purchasing and customer retention.
* Monitor delivery reliability and investigate recurring delays by seller, region and operational process.
* Investigate unusual changes in customer satisfaction using delivery, fulfilment, seller and customer-service data.

## Dashboard

The Power BI dashboard contains six analytical pages:

1. **Revenue & Commercial Performance**
2. **Product & Commercial Concentration**
3. **Monthly Revenue Trend**
4. **Customer & Repeat-Purchase Behaviour**
5. **Delivery & Logistics Performance**
6. **Customer Satisfaction & Reviews**

## Project Structure

Olist-Ecommerce-Business-Performance-Analysis/

- README.md
- Documentation/
 	  Portfolio_Documentation.pdf
- PowerBI/
   	Olist_Ecommerce_Project.pbix
- SQL/
   	01_Data_cleaning_&_data_validation.sql
 	  02_timestamp_consistent_check.sql
   	03_Revenue & Commercial Performance.sql
 	  04_Order_reviews.sql
    05_Customer Behavior.sql
 	  06_Customer review.sql
 	  07_Logistics & Delivery Performance.sql
- Notes/
  	SQL_Investigation_Notes.md


## Skills Demonstrated

* SQL data analysis
* Data validation and cleaning
* Relational data analysis and JOINs
* CTEs and aggregation
* COUNT(DISTINCT ...)
* Business metric development
* Power BI data modelling
* DAX measures
* Dashboard development
* Data visualization
* Business analysis
* Problem solving
* Data storytelling
* Translating analysis into business recommendations

## Conclusion

This project demonstrates an end-to-end data analysis workflow: **data validation → SQL analysis → business metrics → Power BI modelling → dashboard development → business insights → recommendations**.

The analysis shows how transactional e-commerce data can be transformed into practical insights for commercial performance, customer retention, operational reliability and customer experience.
