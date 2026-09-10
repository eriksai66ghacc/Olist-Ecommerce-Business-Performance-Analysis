select * from dbo.customers
select * from orders

-- Customer table null values check
select * from customers
where customer_id is null
select * from customers
where customer_unique_id is null
select * from customers
where customer_zip_code_prefix is null
select * from customers
where customer_city is null
select * from customers
where customer_state is null
select * from order_reviews

-- Customer table duplicate ID check

select customer_id, count(*) as duplicate_cid from customers
group by customer_id
having count(*) >1;

select customer_unique_id, count(*) as duplicate_uid from customers
group by customer_unique_id
having count(*) >1
order by duplicate_uid desc; -- found 2997 row duplicate, 

select customer_id, customer_unique_id from customers
where customer_unique_id = '8d50f5eadf50201ccdcedfb9e2ac8455'; -- confirm duplicate random uid
-- 

select c.customer_unique_id, count (o.order_id) as total_orders from customers c
join orders o
on c.customer_id = o.customer_id
group by c.customer_unique_id
having count(o.order_id) > 1
order by total_orders desc; -- how many customers makes multiple purchase?

-- Order table

select * from orders; -- total orders 99441

select * from orders
where order_id is null; -- result no null values

select order_id, count(*) as duplicate_oid from orders
group by order_id
having count(*) >1; -- result no duplicate

select * from orders
where customer_id is null; -- cid no null values.

select distinct(order_status) from orders -- check order status unique values

select * from orders
where order_status = 'canceled'; -- found 625 , 

select * from orders
where order_purchase_timestamp is null; -- found 0

-- Order_approved_at null check

select * from orders
where order_approved_at is null; -- found 160
-- And
select * from orders
where order_approved_at is null
and order_delivered_carrier_date is null
and order_delivered_customer_date is null; -- 3ခုလုံး null, found 146

select * from orders
where order_status = 'canceled' -- found 141, accept
and order_approved_at is null;

select * from orders -- 141 result တူ , apprv null ရင် ကျန်၂ခုလည်း null, normal
where order_status = 'canceled'
and order_approved_at is null
and order_delivered_carrier_date is null
and order_delivered_customer_date is null; -- ၃ခု null and canceled

select * from orders
where order_status = 'created' -- found 5, accept
and order_approved_at is null; -- 3ခုစစ်စရာမလို, customer ကဝယ်ပီးတာနဲ့ တန်း cancel လုပ်, normal

select * from orders
where order_status = 'approved' -- found 0 error, accept
and order_approved_at is null;

select * from orders
where order_status = 'processing' -- found 0 error, accept
and order_approved_at is null;

select * from orders
where order_status = 'unavailable' -- found 0 error, accept
and order_approved_at is null;

select * from orders
where order_status = 'invoiced' -- found 0 error, accept
and order_approved_at is null;

select * from orders
where order_status = 'shipped' -- found 0 error, accept
and order_approved_at is null;

-- ပြသနာကဂီမှာ 

select * from orders
where order_status = 'delivered'
and order_approved_at is null; -- found 14 count(*) as delivered_without_approval, credit pay နောက်ကျတာ ETL error တက်တာဖစ်နိုင်, boleto
-- သူနဲ့ဆိုင်တဲ့ KPI တွက်ရင်တော့ဖယ်ထားသင့်တ်ယ် , ord appro ကလွဲရင်ကျန်တာ valid ဖစ်လို့  

select o.order_id, o.order_status, o.order_approved_at, p.payment_type,p.payment_value from orders o
left join order_payments p
on o.order_id = p.order_id
where o.order_status = 'delivered'
and o.order_approved_at is null; -- payment လုပ်မလုပ်ကိုစစ် , payment လုပ်ထားတယ် approval ပဲမလုပ်တာ

-- ပြသနာကဒီမှာ
select * from orders -- 
where order_status = 'delivered' -- anyone null
and (order_purchase_timestamp is null
or order_approved_at is null
or order_delivered_carrier_date is null
or order_delivered_customer_date is null); -- result 0

select payment_type, count(*) as total_orders
from orders o
join order_payments p
on o.order_id = p.order_id
where o.order_status = 'delivered'
and o.order_approved_at is null
group by payment_type; -- result boleto 14 ထုတ်

-- order table, order_delivered_carrier_date

select * from orders
where order_delivered_carrier_date is null; -- found 1783 ,some order_appr_at null. both order_deli_carr_date and order_deli_cust_date null, others ok.

select * from orders
where order_status = 'delivered'
and order_delivered_carrier_date is null; -- found 2 ,1 is order_deli_carr_date null, 2 is both order_deli_carr_date and order_deli_cust_date null, others ok.

select * from orders
where order_status = 'shipped'
and order_delivered_carrier_date is null; -- 0 error

select * from orders
where order_status = 'invoiced'
and order_delivered_carrier_date is null; -- found 314 , order_deli_carr_date and order_deli_cust_date = both null others ok

select * from orders
where order_status = 'canceled'
and order_delivered_carrier_date is null; -- found 550 , order_deli_carr_date and order_deli_cust_date = both null. others ok. some order_appr_at null.

select * from orders
where order_status = 'processing'
and order_delivered_carrier_date is null; -- found 550, order_deli_carr_date and order_deli_cust_date = both null others ok

select distinct order_status from orders
where order_delivered_carrier_date is null; -- order_status mixing

select order_status, count(*) as total_orders from orders
where order_delivered_carrier_date is null
group by order_status
order by total_orders desc;
/*
unavailable	609
canceled	550
invoiced	314
processing	301
created		5
delivered	2
approved	2
*/

-- Order delivered customer date

select * from orders
where order_delivered_customer_date is null;

select order_status, count(*) as total_orders from orders
where order_delivered_customer_date is null
group by order_status
order by total_orders desc;

select * from orders
where order_delivered_customer_date is null
and order_status = 'delivered';

select distinct(order_status) from orders;

-- order table end

select order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date,
count(*) as cnt
from orders
group by order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date
having count(*) > 1; -- check duplicate rows. all



-- order item data cleaning
select * from order_items

select * from order_items
where order_id is null
select * from order_items
where order_item_id is null
select * from order_items
where product_id is null
select * from order_items
where seller_id is null
select * from order_items
where shipping_limit_date is null

select order_id, order_item_id, product_id, seller_id, shipping_limit_date, price,
count(*) as cnt
from order_items
group by order_id, order_item_id, product_id, seller_id, shipping_limit_date, price
having count(*) > 1; -- check duplicate order_items table

select * from order_items
where order_item_id <=0; -- order_item_id should start with null

select * from order_items
where price <0; -- price cannot be negative , result 0 ok

select * from order_items oi
left join products p
on oi.product_id = p.product_id
where p.product_id is null; -- check product_id exist on order_items table, result 0 ok

select * from order_items oi
left join sellers s
on oi.seller_id = s.seller_id
where s.seller_id is null; -- check seller_id exist on order_items table, result 0 ok

-- data quality check end for order_items table

-- start order_payments table

select distinct * from order_payments

select distinct payment_type from order_payments -- credit_card, debit_card, not_defined, voucher, boleto

select distinct payment_sequential from order_payments
order by payment_sequential desc;

select * from order_payments op
join orders o
on op.order_id = o.order_id
where payment_sequential = 29; -- all pay with voucher, unusual case at pay_seq= 13,14

select * from order_payments op
join orders o
on op.order_id = o.order_id
where op.order_id = 'fa65dad1b0e818e3ccc5cb0e39231352'
order by payment_sequential desc; -- ဒီ order အတွက် pay_seq အားလုံးပြခိုင်း

select * from order_payments
where order_id = 'fa65dad1b0e818e3ccc5cb0e39231352'
order by payment_sequential; -- check all payment sequential order for specific order

select sum(payment_value) as total_paid from order_payments
where order_id = 'fa65dad1b0e818e3ccc5cb0e39231352'; -- calculate order value from order_payments

select sum(price + freight_value) as order_total
from order_items
where order_id = 'fa65dad1b0e818e3ccc5cb0e39231352'; -- calculate order value from order_items

select count(*) as payment_records,count(distinct order_id) as orders
from order_payments
group by order_id
order by payment_records desc; -- check outliers 29 voucher , order is financially consistent.

with payment_totals as (
select order_id, sum(payment_value) as total_paid
from order_payments
group by order_id
),
order_totals as (
select order_id, sum(price + freight_value) as order_total
from order_items
group by order_id
)
select p.order_id, p.total_paid, o.order_total
from payment_totals p
join order_totals o
on p.order_id = o.order_id
where abs(p.total_paid - o.order_total) > 0.01; -- prevent total multiple, multiple payment records and multiple items
-- table ၂ခု 

select * from order_items
where order_id = '00789ce015e7e5791c7914f32bb4fad4'; -- 168.83

select * from order_payments
where order_id = '00789ce015e7e5791c7914f32bb4fad4'; -- 190  difference 21.98

WITH payment_totals AS (
    SELECT
        order_id,
        payment_type,
        SUM(payment_value) AS total_paid
    FROM order_payments
    GROUP BY order_id, payment_type
),
order_totals AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS order_total
    FROM order_items
    GROUP BY order_id
)
SELECT
    p.payment_type,
    COUNT(*) AS orders,
    AVG(p.total_paid - o.order_total) AS avg_difference,
    MIN(p.total_paid - o.order_total) AS min_difference,
    MAX(p.total_paid - o.order_total) AS max_difference
FROM payment_totals p
JOIN order_totals o
    ON p.order_id = o.order_id
WHERE ABS(p.total_paid - o.order_total) > 0.01
GROUP BY p.payment_type
ORDER BY orders DESC;

/*
paymenttype, orders, avg_difference, min_difference, max_difference
credit_card	2557	-73.4233985138834	-1522.42	182.81
voucher	2225	-64.6631325842697	-2442.82	-0.0100000000000051
boleto	29	0.00241379310346617	-0.0400000000000773	0.0300000000002001
debit_card	11	-14.0709090909091	-102.82	0.0100000000000193
*/

with payment_totals as (
select order_id, sum(payment_value) as total_paid from order_payments
group by order_id
),
order_totals as (
select order_id, sum(price + freight_value) as order_total from order_items
group by order_id
)
select op.payment_type, count(distinct op.order_id) as mismatched_orders
from order_payments op
join payment_totals pt
on op.order_id = pt.order_id
join order_totals ot
on op.order_id = ot.order_id
where abs(pt.total_paid - ot.order_total) > 0.01
group by op.payment_type
order by mismatched_orders desc; -- isolated business exceptions

/*
credit_card	340
boleto	29
voucher	11
debit_card	10
*/

SELECT *
FROM orders
WHERE order_id='00789ce015e7e5791c7914f32bb4fad4';

with payment_totals as (
select order_id, max(payment_installments) as installments, sum(payment_value) as total_paid from order_payments
group by order_id
),
order_totals as 
(
select order_id, sum(price + freight_value) as order_total from order_items
group by order_id
)
select installments, count (*) as orders, avg(total_paid - order_total) as average_difference from payment_totals p
join order_totals o
on p.order_id = o.order_id
group by installments
order by installments; -- installment relationship

with payment_totals as (
select order_id, sum(payment_value) as total_paid from order_payments
group by order_id
),
order_totals as (
select order_id, sum(price + freight_value) as order_total from order_items
group by order_id
)
select round(total_paid - order_total, 2) as difference, count(*) as orders from payment_totals p
join order_totals o
on p.order_id = o.order_id
where abs(total_paid - order_total) >0.01
group by round (total_paid - order_total,2)
order by abs(round(total_paid - order_total,2)) desc; -- check the differnce of total_payment values, large differences are rare

with payment_totals as (
select order_id, sum(payment_value) as total_paid from order_payments
group by order_id
),
order_totals as (
select order_id, sum(price + freight_value) as order_total
from order_items
group by order_id
)
select top (10) p.order_id, p.total_paid, o.order_total,
round(p.total_paid - o.order_total, 2) as difference
from payment_totals p
join order_totals o
on p.order_id = o.order_id
join order_payments op
on p.order_id = op.order_id
where op.payment_type = 'boleto'
and abs(p.total_paid - o.order_total) > 0.01
order by abs(p.total_paid - o.order_total) desc;

-- confirmation end

select * from sellers
where seller_state is null
or seller_city is null
or seller_zip_code_prefix is null
or seller_id is null;

select * from products -- 32951
where product_category_name is null
or product_id is null
or product_description_lenght is null
or product_name_lenght is null
or product_photos_qty is null
or product_weight_g is null
or product_length_cm is null
or product_height_cm is null
or product_width_cm is null; -- 611 nulls

select * from products -- 32951
where product_weight_g is null
or product_length_cm is null
or product_height_cm is null
or product_width_cm is null; -- 

select * from product_category_name_translation

select * from products p
join order_items ot
on p.product_id = ot.product_id
where ot.product_id = 'a41e356c76fab66334f36de622ecbd3a'
or p.product_description_lenght is null
or p.product_name_lenght is null
or p.product_photos_qty is null
or (p.product_category_name is null
and ot.order_item_id >1 )
order by ot.order_id; -- random product id ၁ခုယူပီးစစ်ကြည့်တာ 1603 

select count (*) as null_category_products from products
where product_category_name is null; -- 610

select * from products
where product_category_name is null;

select 
    count(*) as total_null_category,
    sum(case when product_id is null then 1 else 0 end) as null_product_id,
    sum(case when product_weight_g is null then 1 else 0 end) as null_weight,
    sum(case when product_length_cm is null then 1 else 0 end) as null_length,
    sum(case when product_height_cm is null then 1 else 0 end) as null_height,
    sum(case when product_width_cm is null then 1 else 0 end) as null_width
from products
where product_category_name is null;

select * from products
where product_category_name is null
and product_weight_g is null
and product_height_cm is null
and product_length_cm is null
and product_width_cm is null; -- 5eb564652db742ff8f28759cd8d2652a

select * from order_items where product_id = '5eb564652db742ff8f28759cd8d2652a'; -- 4ခု null group
select * from order_items where product_id = '09ff539a621711667c43eba6a3bd8466'; -- 


select 
    count(*) as order_item_rows,
    count(distinct order_id) as distinct_orders,
    sum (price) as total_sales
from order_items
where product_id = '5eb564652db742ff8f28759cd8d2652a';

update products
set product_category_name = 'unknown'
where product_category_name is null; -- 610 rows effected

select sum(price) as total_product_sales,
sum(case
when product_id = '5eb564652db742ff8f28759cd8d2652a'
then price else 0
end) as missing_product_sales 
from order_items; --563 ÷ 13,591,643.70 × 100 ≈ 0.0041%

--610 case

select count(distinct p.product_id) as uncategorized_products_sold,
count(*) as order_item_rows,
sum(oi.price) as total_sales
from products p
join order_items oi
on p.product_id = oi.product_id
where p.product_category_name = 'unknown'; -- 1.32%

select sum(price) as total_product_sales,
sum(case when product_id = '09ff539a621711667c43eba6a3bd8466'
then price else 0 end) as missing_dimension_product_sales
from order_items; -- 13591643.7000142,	1934

-- end of product table

select count(*) as total_sellers,
    sum(case when seller_id is null then 1 else 0 end) as null_sellerid,
    sum(case when seller_zip_code_prefix is null then 1 else 0 end) as null_zipcode,
    sum(case when seller_city is null then 1 else 0 end) as null_city,
    sum(case when seller_state is null then 1 else 0 end) as null_state
from sellers

select seller_id, count(*) as duplicate_count
from sellers
group by seller_id
having count(*) > 1; -- no duplicate

select min(seller_zip_code_prefix) as min_zip,
max(seller_zip_code_prefix) as max_zip from sellers; -- 1001	99730

select seller_state, count(*) as sellercount from sellers
group by seller_state
order by sellercount desc;

select seller_city, count(*) as sellercount from sellers
group by seller_city
order by sellercount desc;


-- Date Integrity Check

--
-- Data Integrity Check, relationရှိတဲ့ table တိုင်းကိုစစ်ရမယ် 
--

select o.order_id from orders o
left join customers c
on o.customer_id = c.customer_id
where c.customer_id is null; -- order <> customer စစစ် , result 0 ပြသနာမရှိ

select o.order_id from orders o
left join order_items oi
on o.order_id = oi.order_id
where oi.order_id is null; -- 775 found error

select o.order_status, count(*) as total_orders from orders o
left join order_items oi on o.order_id = oi.order_id
where oi.order_id is null
group by o.order_status
order by total_orders desc; -- order table ga order_id နဲ့ order_items table ga order_id ရှိလားစစ် 
/* unavailable	603 expected
canceled	164 expected
created	5 expected
invoiced	2 ပြသနာ
shipped	1     ပြသနာ */

select * from orders o
left join order_items oi
on o.order_id = oi.order_id
where oi.order_id is null
and o.order_status = 'invoiced'; -- document

select * from orders o
left join order_items oi
on o.order_id = oi.order_id
where oi.order_id is null
and o.order_status = 'shipped'; -- shipdate have, customer not received inconsistant, payment လုပ်ထား
-- +
select o.order_id, o.order_status, o.order_approved_at, p.payment_type,p.payment_value from orders o
left join order_payments p
on o.order_id = p.order_id
where o.order_status = 'shipped'
and o.order_delivered_customer_date is null
and o.order_id ='a68ce1686d536ca72bd2dadc4b8671e5'; -- payment ရှိမရှိ စစ်
/*
KPI	Include?
Order Count	✅
Order Status Distribution	✅
Revenue by Payment Type	✅ (payment exists if you're analysing payments)
Product Sales	❌ (no order_items)
Product Category Analysis	❌
Seller Performance	❌
*/

-- shipping_limit_date

--1 approve မဖစ်ခင် shipping date မထွက်
select * from order_items oi
join orders o
on oi.order_id = o.order_id
where oi.shipping_limit_date < o.order_approved_at; -- expected 0 result 127, illogical so timeline anomalies

select top (20)oi.order_id, o.order_status, o.order_purchase_timestamp, o.order_approved_at, oi.shipping_limit_date,
datediff(minute, oi.shipping_limit_date, o.order_approved_at) as diff_minutes
from order_items oi
join orders o
on oi.order_id = o.order_id
where oi.shipping_limit_date < o.order_approved_at
order by diff_minutes desc; -- check difference , big time delays

select * from order_items oi
join orders o
on oi.order_id = o.order_id
where oi.shipping_limit_date < o.order_purchase_timestamp; -- 0 rows found ok, မ၀ယ်ရသေးခင် shipping limit date အရင်ထွက်လားစစ် .. မထွက်မှမှန်

select * from order_items oi
join orders o
on oi.order_id = o.order_id -- < မှာ 10423 , valid expected "late shipment"
where oi.shipping_limit_date < o.order_delivered_carrier_date;  -- > 100892 hands the package before the deadline , ဒီ၂ခုက performance metrics နဲ့ဆိုင်

select * from order_items oi -- မစစ်လဲရ , အပေါက၂ခုပဲစစ်
join orders o
on oi.order_id = o.order_id -- "<" normal check,87183 rows found
where oi.shipping_limit_date > o.order_delivered_customer_date; -- ">" 23000 rows found, customer receive before deadline. possible

