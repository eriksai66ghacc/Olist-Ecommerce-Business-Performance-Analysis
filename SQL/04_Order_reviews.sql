-- Order Review

select * from order_reviews

select review_id, count(*) as duplicate_rid from order_reviews
group by review_id
having count(*) >1;

select count(*) from order_reviews
where review_id = '00130cbe1f9d422698c812ed8ded1919';

select review_id, count(distinct order_id) as order_count from order_reviews
group by review_id
having count (distinct order_id) > 1;

select * from order_reviews
where review_id is null
or order_id is null;

select distinct(review_score) from order_reviews

select * from order_reviews
where review_score not between 1 and 5;

select * from order_reviews
where review_creation_date > review_answer_timestamp; -- > ကအမှန်

select * from order_reviews
where review_creation_date is null
or review_answer_timestamp is null;

select * from order_reviews r
left join orders o
on r.order_id = o.order_id
where o.order_id is null; -- foreign key validation-

select *,op.payment_value from order_reviews r
join orders o
on r.order_id = o.order_id
join order_payments op
on r.order_id = op.order_id
where r.review_creation_date < o.order_purchase_timestamp -- > ကအမှန်
and o.order_status <> 'canceled';
; -- မ၀ယ်ခင် review မပေးရ

select *,op.payment_value from order_reviews r -- date/time ကို cast နဲ့စစ်ထားတယ်
join orders o
on r.order_id = o.order_id
join order_payments op
on r.order_id = op.order_id
where cast(r.review_creation_date as date) < cast(o.order_purchase_timestamp as date) -- > ကအမှန် , detail hr mm ss ကိုထည့်မတွက် , validation ပို safe ဖြစ် 
and o.order_status <> 'canceled'; -- မ cancel တာကိုစစ်တာ, 7 found, all columns valide except 2 review timestamp look invalid
 -- 

select *,op.payment_value from order_reviews r
join orders o
on r.order_id = o.order_id
join order_items oi
on r.order_id = oi.order_id
join order_payments op
on r.order_id = op.order_id
where cast(r.review_creation_date as date) < cast(o.order_delivered_customer_date as date) -- > ကအမှန် 
and o.order_status <> 'canceled'; -- < 5349 က delivered, 5348 က with cancel
-- > 91990

select * from order_reviews r
join orders o
on r.order_id = o.order_id
join order_payments op
on r.order_id = op.order_id
where cast(r.review_creation_date as date) < cast(o.order_delivered_customer_date as date);

select * from orders

-- check different date

select r.order_id,
cast (r.review_creation_date as date) as review_date,
cast (o.order_delivered_customer_date as date) as delivered_date,
datediff (day, cast(r.review_creation_date as date), cast(o.order_delivered_customer_date as date))as Days_Before_Delivery
from order_reviews r
join orders o
on r.order_id = o.order_id
where cast(r.review_creation_date as date) < cast(o.order_delivered_customer_date as date)
order by Days_Before_Delivery desc;
-- end different date

-- are these really delivered?

select order_status, count (*) as total from orders
where cast(order_delivered_customer_date as date) = '2017-09-19'
group by order_status; -- return 282 rows

select count(*) as totalorders from orders
where cast(order_delivered_customer_date as date) = '2017-09-19'; --returned 282 rows

SELECT
    DATEDIFF(
        DAY,
        CAST(r.review_creation_date AS DATE),
        CAST(o.order_delivered_customer_date AS DATE)
    ) AS Days_Before_Delivery,
    COUNT(*) AS Total_Orders
FROM order_reviews r
JOIN orders o
    ON r.order_id = o.order_id
WHERE CAST(r.review_creation_date AS DATE)
      < CAST(o.order_delivered_customer_date AS DATE)
GROUP BY
    DATEDIFF(
        DAY,
        CAST(r.review_creation_date AS DATE),
        CAST(o.order_delivered_customer_date AS DATE)
    )
ORDER BY Days_Before_Delivery DESC;

SELECT
    MIN(order_purchase_timestamp) AS First_Purchase,
    MAX(order_purchase_timestamp) AS Last_Purchase
FROM orders
WHERE CAST(order_delivered_customer_date AS DATE) = '2017-09-19';












