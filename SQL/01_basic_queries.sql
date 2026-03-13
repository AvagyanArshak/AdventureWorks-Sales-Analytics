/*all orders*/
select  *
from Sales.SalesOrderHeader
order by OrderDate


/*Total sales by year*/
select 
	year(OrderDate) as OrderYear,
	count(*) as TotalOrders,
	sum(TotalDue) as TotalRevenue
from Sales.SalesOrderHeader
group by year(OrderDate)
order by OrderYear

/*List of products by category*/
select 
	pc.Name as Category,
	ps.Name as Subcategory,
	p.Name as ProductName,
	p.ListPrice
from Production.Product p
join Production.ProductSubcategory ps
on p.ProductSubcategoryID = ps.ProductSubcategoryID
join Production.ProductCategory pc
on ps.ProductCategoryID = pc.ProductCategoryID
order by pc.Name,ps.Name


/*Top 10 customers*/
select top 10
	concat(pp.FirstName,' ',pp.LastName) as CustomerName,
	sum(soh.TotalDue) as TotalSpent
from Sales.SalesOrderHeader soh
join Sales.Customer c on soh.CustomerID = c.CustomerID
join Person.Person pp on c.PersonID = pp.BusinessEntityID
group by pp.FirstName,pp.LastName
order by TotalSpent


/*Only months where sales > $1,000,000*/
select
	year(OrderDate) as OrderYear,
	month(OrderDate) as OrderMonth,
	sum(TotalDue) as TotalRevenue
from Sales.SalesOrderHeader
group by year(OrderDate),month(OrderDate)
having sum(TotalDue) > 1000000
order by OrderYear,OrderMonth



/*The most expensive product in each category*/
with RankedProducts as (
	select
		pc.Name as Category,
		p.Name  as ProductName,
		p.ListPrice,
		ROW_NUMBER () over(
			partition by pc.Name
			order by p.ListPrice desc
		) as rn 
	from Production.Product p
	join Production.ProductSubcategory ps
		on p.ProductSubcategoryId = ps.ProductSubcategoryID
	join Production.ProductCategory pc
		on ps.ProductCategoryID = pc.ProductCategoryID
)
select Category, ProductName, ListPrice
from RankedProducts
where rn = 1
order by ListPrice Desc


/*seller rating*/
select
	concat(pp.FirstName,' ',pp.LastName) as SalesPersonName,
	sum(soh.TotalDue)					 as ToralSales,
	rank() over(
		order by sum(soh.TotalDue) desc
	) as SalesRank
from Sales.SalesOrderHeader soh
join Sales.SalesPerson sp
	on soh.SalesPersonID = sp.BusinessEntityID
join Person.Person pp
	on sp.BusinessEntityID = pp.BusinessEntityID
group by pp.FirstName,pp.LastName
order by SalesRank


/*month-to-month comparison*/
select
	year(OrderDate)   as OrderYear,
	month(OrderDate)  as OrderMonth,
	sum(TotalDue)	  as Revenue,
	LAG(Sum(TotalDue)) over(
		order by year(OrderDate),month(OrderDate)
		)	as PrevMonthRevenue,
	sum(TotalDue) - lag(sum(TotalDue)) over(
		order by year(OrderDate), month(OrderDate)
		)   as Difference
from Sales.SalesOrderHeader
group by year(OrderDate), month(OrderDate)
order by OrderYear, OrderMonth


/*cumulative sale*/
select
	year(OrderDate)   as OrderYear,
	month(OrderDate)  as OrderMonth,
	sum(TotalDue)     as MonthlyRevenue,
	sum(sum(TotalDue)) over(
		partition by year(OrderDate)
		order by month(OrderDate)
		)  as RunningTotal
from Sales.SalesOrderHeader
group by year(OrderDate), month(OrderDate)
order by OrderYear,OrderMonth


/*Which year has the highest sales*/
select
	year(OrderDate) as OrderYear,
	sum(TotalDue) as TotalRevenue
from Sales.SalesOrderHeader
group by year(OrderDate)
order by TotalRevenue desc

/*Which month had the biggest growth*/
select
	year(OrderDate)   as OrderYear,
	month(OrderDate)  as OrderMonth,
	sum(TotalDue)	  as Revenue,
	LAG(Sum(TotalDue)) over(
		order by year(OrderDate),month(OrderDate)
		)	as PrevMonthRevenue,
	sum(TotalDue) - lag(sum(TotalDue)) over(
		order by year(OrderDate), month(OrderDate)
		)   as Difference
from Sales.SalesOrderHeader
group by year(OrderDate), month(OrderDate)
order by Difference desc
