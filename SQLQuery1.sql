--select * from cars
--1. Are there any missing values in the dataset? If so, which columns have missing values?
SELECT 
    COLUMN_NAME
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'cars' AND
    IS_NULLABLE = 'YES';

--2.What are the different columns or attributes present in the dataset?
 SELECT 
    COLUMN_NAME
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'cars'

--3.How many records or entries are there in the dataset?
select count(*) as Total_records from cars

--4.What are the unique car models available in the dataset?
select Distinct Model 
	from 
		cars 
	where Model 
		is not null

--5.How many different car manufacturers are represented in the dataset?
SELECT DISTINCT Make as Car_manufacturer
	FROM 
		cars 
	WHERE Make
		is not null

--6.What is the range of prices for different cars in the dataset?
SELECT MIN(MSRP) as Lowest_Price, MAX(MSRP) as Highest_Price, Type, Make FROM cars where MSRP is not null group by Make, Type
order by Lowest_Price asc

--7.Which cars have the highest horsepower?
Select Top 1 MAX(Horsepower) as Maximum_horsepower,Make, Model, Type, MSRP, EngineSize, Cylinders
from cars 
where Horsepower is not null
group by Make, Type, Model, MSRP, EngineSize, Cylinders
order by Maximum_horsepower desc

--8. Which car has the best fuel efficiency?
SELECT TOP 1
  MIN(EngineSize) as Minimum_enginesize,
  MIN(Cylinders) as Minimum_cylinders,
  MIN(Horsepower) as Minimum_horsepower,
  Make,
  Model,
  Type,
  MSRP
FROM cars
WHERE EngineSize IS NOT NULL AND Cylinders IS NOT NULL AND Horsepower IS NOT NULL
GROUP BY Make, Model, Type, MSRP
ORDER BY Minimum_horsepower ASC

--9. What is the average MSRP (Manufacturer's Suggested Retail Price) for each car origin?
Select Origin, MSRP, AVG(MSRP) Over (Partition By Origin) as AveragePrice from cars where Origin is not null

--Select Distinct Origin, AVG(MSRP) as AveragePrice from cars group by Origin

--10. Which car model has the highest horsepower-to-weight ratio?
select Model, Horsepower, Weight from cars 
	where Horsepower 
			In 
				(select max(Horsepower) from cars 
	where Weight 
			In 
				(select MAX(Weight) from cars)) 

 --select Model from cars
 --    where (Horsepower / Weight) =
	--   (select max(Horsepower / Weight) from cars)

--11. What is the average MPG (Miles Per Gallon) for each type of car (sedan, SUV, etc.)?
select Model,Type, MPG_Highway, AVG(MPG_Highway) Over (Partition by Type) as AverageMPG from cars where Type is not null

--12. Which car has the longest wheelbase?
select Make, Wheelbase from cars where Wheelbase in (select MAX(Wheelbase) from cars)

--13. How does the average MPG vary with engine size across different car types?
select Type, EngineSize, AVG(MPG_Highway)as AverageMPG from cars where Type is not null group by Type, EngineSize order by Type

--14. What is the percentage distribution of car types (sedan, SUV, etc.) for each car origin?
SELECT
    Origin,
    Type,
    COUNT(*) AS CarCount,
    CASE 
        WHEN (SELECT COUNT(*) FROM cars WHERE Origin = t.Origin) <> 0 
        THEN COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cars WHERE Origin = t.Origin) 
        ELSE 0 
    END AS Percentage
FROM
    cars AS t
WHERE
	Type is not null
GROUP BY
    Origin,
    Type
ORDER BY
	Origin

--15. Which car model has the highest MPG in the city and on the highway combined?
select Model, MPG_City, MPG_Highway from cars 
where MPG_City 
IN (select MAX(MPG_City) from cars 
where MPG_Highway 
In (select MAX(MPG_Highway) from cars))

--16. What is the average length of cars for each number of cylinders?
select Model, Cylinders, AVG(Length) as Average_Length_of_Car from cars where Cylinders is not null group by Model, Cylinders

--17. Which car manufacturer has the highest average invoice price?
select Top 1 Make, AVG(Invoice) as Average_Price  from cars where Make is not null group by Make order by Average_Price desc

--18.Which car models have a horsepower greater than the average horsepower of all cars?
select Model, Horsepower from cars where Horsepower > (select AVG(Horsepower) as Max_horsepower from cars ) order by Horsepower desc

--19. What is the rank of each car model based on their MSRP within their respective make?
SELECT Model, Make, MSRP,
RANK() OVER (PARTITION BY Make ORDER BY MSRP desc) as Top_rank
FROM cars 
where Model is not null

--20. Which car models have the highest difference between MPG in the city and on the highway?
--select Model, MPG_City, MPG_Highway from cars where MPG_City In (select Max(MPG_City) from cars as Maximum where MPG_Highway In (select MIN(MPG_Highway) from cars as Minimum))

SELECT Model, MPG_City, MPG_Highway, CAST(MPG_Highway AS smallint) - CAST(MPG_City AS smallint) AS Difference
FROM cars
ORDER BY Difference DESC;

--21. What is the cumulative sum of engine sizes within each car origin, ordered by horsepower?
select Origin, Horsepower, EngineSize,  
SUM(EngineSize) over (Partition by Origin order by Horsepower) as Cumulative_Total  
from cars where EngineSize is not null 
order by Horsepower

--22. For each car type, what is the running average length of cars based on their weight?
select Type, Weight, Length,
AVG(Length) over (Partition by Type order by Weight) as Running_Average_Length
from cars where Type is not null 
order by Weight,Length

--select *,
--  avg(Price) OVER(ORDER BY Date
--     ROWS BETWEEN 2 PRECEDING AND CURRENT ROW )
--     as moving_average
--from stock_price;

--23. Among cars from the USA, which car model has the highest MSRP?
select Model, Origin, MSRP from cars where MSRP In (select MAX(MSRP) from cars where Origin = 'USA' )

--24. Which car models have the same MSRP or Invoice price?
SELECT A.Model, A.MSRP, A.Invoice
FROM cars A
JOIN cars B ON A.Model <> B.Model
WHERE A.MSRP = B.MSRP OR A.Invoice = B.Invoice
ORDER BY A.Model;

--25. What is the combined list of car models available in the USA and Europe?
select Model, Origin from cars where Origin = 'USA' 
union all
select Model, Origin from cars where Origin = 'Europe'

With combined (Model, Origin) AS(
select Model, Origin from cars where Origin = 'USA' 
union all
select Model, Origin from cars where Origin = 'Europe' 
)
select * from combined order by Origin desc 

--26. Which car models are available in both the USA and Asia, but not in Europe?
select Model, Origin from cars 
where Origin 
Not In ('Europe') 
order by Origin

--27.What is the list of car models available in the USA, along with their corresponding MPG in the city?
select Model, Origin, MPG_City from cars
where Origin = 'USA'

--28. What is the combined list of car types (sedan, SUV, etc.) available in the USA and Asia?
With combined (Type, Origin) AS (
select a.Type, a.Origin from cars a where a.Origin = 'USA'
union all
select a.Type, a.Origin from cars a where a.Origin = 'Europe'
)
select * from combined
ORDER BY Type desc

--29. What is the combined list of car manufacturers present in the dataset, along with their respective car models?
select Make, Model from cars where Make is not null order by Make DESC

--30. Which car origins have an average MPG in the city higher than 25?
select Distinct Origin, MPG_City from cars
group by Origin, MPG_City
having AVG(Distinct MPG_City) > 25
order by MPG_City

--31. Among cars with more than six cylinders, which car models have an average horsepower greater than 300?
select Model, Horsepower, Cylinders from cars
where Horsepower > 300
group by Model, Horsepower, Cylinders
having Cylinders > 6
order by Cylinders desc



