create  database project11;
use project11;
CREATE TABLE sales (customer_id  VARCHAR(1),
  order_date  DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id  INTEGER,
  product_name  VARCHAR(5),
price  INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date )
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  select * from sales;
  select * from menu;
  select * from members;
  
  -- What is the total amount each customer spent at the restaurant?
  
  select  customer_id,sum(price) as total_spent from sales inner join menu 
  on sales.product_id =menu.product_id
  group by customer_id;
  
  --  How many days has each customer visited the restaurant?
  select customer_id,count(distinct(order_date)) as no_of_days from sales
  group by customer_id
  order by no_of_days desc;
  
  
  -- What was the first item from the menu purchased by each customer?

with t1 as 
(select customer_id,product_name,row_number() over (partition by customer_id order by order_date asc, sales.product_id asc) as rn from sales 
inner join menu 
on sales.product_id =menu.product_id)
  
  select customer_id,product_name from t1 where rn=1;
  
 --  What is the most purchased item on the menu and how many times was it purchased by all customers?
  select product_name,count(sales.product_id) as most_tyms from sales inner join menu 
 on sales.product_id=menu.product_id  
 group by product_name
 order by most_tyms desc 
 limit 1;
 
 -- Which item was the most popular for each customer?
 
 with t1 as(
 select customer_id,product_name,rank() over (partition by customer_id order by count(sales.product_id) desc ) as rnk from sales
 inner join menu 
 on sales.product_id=menu.product_id
 group by sales.customer_id,product_name)
 select * from t1
 where rnk=1;
 
 select * from sales;
 select * from menu;
 select * from members;
 
 
 
 -- Which item was purchased first by the customer after they became a member?
 with t1 as 
 (select sales.customer_id,product_name,sales.product_id, rank()  over (partition by customer_id order by order_date,sales.product_id) as row_ from sales 
 inner join menu 
 on sales.product_id=menu.product_id 
 inner join 
 members
 on sales.customer_id=members.customer_id
 where order_date>= join_date)
 select customer_id,product_name from t1
 where row_=1;
 
-- Which item was purchased just before the customer became a member?
  with t1 as 
 (select sales.customer_id,product_name,sales.product_id, rank()  over (partition by customer_id order by order_date desc) as row_ from sales 
 inner join menu 
 on sales.product_id=menu.product_id 
 inner join 
 members
 on sales.customer_id=members.customer_id
 where order_date < join_date)
 select customer_id,product_name from t1
 where row_=1;
 
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select sales.customer_id, sum(
case 
when menu.product_name="sushi" then price*20
else price*10
end ) as score
from sales inner join menu 
on sales.product_id = menu.product_id
inner join members on sales.customer_id = members.customer_id
group by customer_id;

/*In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
 not just sushi - how many points do customer A and B have at the end of January?*/
 select sales. customer_id,
sum(
case 
when order_date < join_date then 
case when product_name="sushi" then price*20
else price * 10
end
when (order_date >= join_date+6)then 
case 
when product_name="sushi" then price*20
else price*10
end
else price*20
end ) as points 
from members inner join sales 
on members.customer_id=sales.customer_id
inner join menu 
on sales.product_id=menu.product_id
where order_date  <= '2021-01-31'
group by customer_id;


 /*In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
 not just sushi - how many points do customer A and B have at the end of January?*/
 
 select sales.customer_id,
 sum(
 case when order_date < join_date then 
 case 
 when product_name ="sushi" then price*20
 else price*10
 end
 when  (order_date >=join_date+6) then 
 case 
 when product_name="sushi" then price*20
 else price*10 
 end 
 else price*20 
 end )as score
from members inner join sales
on sales.customer_id=members.customer_id 
inner join menu 
on sales.product_id=menu.product_id 
where 
order_date <="2021-01-31"
group by customer_id;







 
 