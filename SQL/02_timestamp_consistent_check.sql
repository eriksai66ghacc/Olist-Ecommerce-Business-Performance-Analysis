--
-- validate timestamp order
--

select * from orders
where order_approved_at < order_purchase_timestamp; -- purchase before approval , result 0 no error
-- --
select * from orders
where order_delivered_carrier_date < order_approved_at; -- approval before carrier pickup , 1359 found

select count(*) as total, -- how much the problem is ?
round(100.0 * count(*) / (select count(*) from orders),2) as percentages
from orders
where order_delivered_carrier_date < order_approved_at; -- result 1359	1.370000000000 %

select top (20) order_id, order_status, order_approved_at, order_delivered_carrier_date, -- time difference
DATEDIFF(minute, order_delivered_carrier_date, order_approved_at) as minute_difference
from orders
where order_delivered_carrier_date < order_approved_at
order by minute_difference desc; /* 
*/
select order_status, count (*) as total from orders
where order_delivered_carrier_date < order_approved_at
group by order_status; -- order status check

SELECT
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM orders
WHERE order_id = '7c48bb55e8e4f7e56d412e9653db37bc';
-- --

select * from orders
where order_delivered_customer_date < order_delivered_carrier_date; -- customer delivered before carrier pickup, 23 found

select order_id, order_status,  order_delivered_carrier_date ,order_delivered_customer_date,
DATEDIFF(DAY, order_delivered_customer_date,order_delivered_carrier_date) as date_difference
from orders
where order_delivered_customer_date < order_delivered_carrier_date
order by date_difference desc; -- inconsistent customer received before delivery

select * from orders
where order_delivered_customer_date < order_purchase_timestamp; -- purchase before customer delivery , result 0 ok

select * from orders -- 0 found no error
where order_purchase_timestamp > order_estimated_delivery_date; -- delivered after estimated date, check for late deliveries

