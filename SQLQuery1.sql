
------------------------------------------------------------------
--- what is the highest empolyee  make sales?

select sum(val)as sales
,CONCAT(h.firstname,' ',h.lastname) as fullname
from Sales.EmpOrders s
inner join HR.Employees h
on h.empid = s.empid
group by CONCAT(h.firstname,' ',h.lastname)
order by sum(val) desc;
-----------------------------------
--which country has the lowest period for shipping?
with sh as (
	select ship.companyname as company,
	DATEDIFF(DAY,orderdate,shippeddate) as diff
	from Sales.Orders as orders
	join Sales.Shippers as ship
	on orders.shipperid = ship.shipperid
	)
select AVG(diff) as avrage,company
from sh
group by company;
----------------------------------
--which month in each country have the most orders?

select MONTH(orderdate) as mon,COUNT(orderid) as order_count,shipcountry
from Sales.Orders
group by shipcountry,MONTH(orderdate)
order by shipcountry  desc;
----------------------------------------------------------------------
---which month has the most profit?
with cte as (
	select month(orderdate) as the_month, (sales.unitprice*qty*discount) as discount ,
		(qty*sales.unitprice)-(sales.unitprice*qty*discount) as profit
	from Sales.Orders
	join Sales.OrderDetails sales
	on Sales.orderid = Sales.Orders.orderid)
select sum(discount) as discount,SUM(profit) as total_after_discount,the_month
from cte
group by the_month
order by 2 desc;

---------------------------------------------------
-------which product make the most revenue?
with cte as (
select (sales.unitprice*qty*discount) as discount ,
	(qty*sales.unitprice)-(sales.unitprice*qty*discount) as profit,
	orderid,products.productname
	from Sales.OrderDetails sales
	join production.Products products
	on sales.productid = products.productid)
select sum(profit),productname
from cte
group by productname;

---------------------------------------------------------------------------
---which percentage profit and discount catagory ?
--select categoryid,productid from Production.Products
--select categoryid,categoryname from Production.Categories
with cte as (
	select 
	round((sales.unitprice*qty*discount),4) as discount ,
	round((qty*sales.unitprice)-(sales.unitprice*qty*discount),4) as profit,
	orderid,products.categoryid as id
	from 
	Sales.OrderDetails sales
	join Production.Products products
	on products.productid = sales.productid),
final as (
	select 
	sum(discount) as discount,
	sum(profit) as profit,
	categoryname
	from 
	cte
	join Production.Categories catagory
	on cte.id = catagory.categoryid
	group by categoryname
)
select  
categoryname,
sum(profit)over(partition by categoryname) as profit,
sum(discount)over(partition by categoryname) as discount,
(sum(profit)over(partition by categoryname)/(select sum(profit) from final) )  * 100 as persentage_profit,
(sum(discount)over(partition by categoryname)/(select sum(discount) from final) )  * 100 as persentage_discount
from final;

------------------------------------------------------------------------------------
------- what is the quantity for every  catagory ?
with cte as(
	select 
	qty,products.categoryid
	from 
	Sales.OrderDetails details
	join 
	Production.Products products
	on details.productid = products.productid
    )
select sum(qty),categoryname
from 
cte
join
Production.Categories 
on cte.categoryid = Production.Categories.categoryid
group by categoryname
order by 1 desc