create database crm_anlaysis;
use crm_anlaysis;


-- OBJECTIVE QUESTIONS..
-- 1.What is the distribution of account balance across different regions?

		select ci.GeographyID, g.GeographyLocation, round(sum(bc.Balance),2) as Balance
		from customerinfo ci
		join bank_churn bc ON ci.CustomerId = bc.CustomerId
        join geography g ON ci.GeographyID= g.GeographyID 
		group by ci.GeographyID, g.GeographyLocation
		ORDER BY ci.GeographyID;
        
-- 2.Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year.
Select customerID , surname as Name, EstimatedSalary
from customerinfo
where year(Bankdoj)=2019 and quarter(bankdoj)=4
order by estimatedsalary desc limit 5;

-- 3.Calculate the average number of products used by customers who have a credit card.
select Avg(NumOfProducts)
from bank_churn
where HasCrCard = 1;

-- 4.Determine the churn rate by gender for the most recent year in the dataset.
select g.GenderCategory, 
        cast(count(case when exited= 1 then b.CustomerId end)*100/ count(b.CustomerId) as decimal(10,2)) 
        as churn_rate
        from bank_churn b 
        join customerinfo c on b.CustomerId= c.CustomerId
        join gender g ON g.GenderID= c.GenderID
        where year(bankDOJ)= 2019
        group by GenderCategory;

-- 5.Compare the average credit score of customers who have exited and those who remain.
select 
avg(case when exited = 1 then creditscore end)as Avg_of_Exited,
avg(case when exited = 0 then creditscore end)as Avg_of_Remain
from bank_churn;

-- 6.Which gender has a higher average estimated salary, and how does it relate to the number of active accounts?
use crm_anlaysis;
select 
	g.gendercategory,
    round(avg(c.estimatedsalary),2)as Average_salary,
    round(avg(case when a.activeid=1 then c.estimatedsalary end),2)as Average_Salary_Active
from customerinfo c 
join gender g on c.genderid=g.genderid
join bank_churn b on b.customerid=c.customerid
join activecustomer a on b.isactivemember=a.activeid
group by g.gendercategory
order by Average_salary desc
limit 1;

-- 7.Segment the customers based on their credit score and identify the segment with the highest exit rate.
select * from customerinfo;
select * from bank_churn;
select CreditScore, count(CustomerID) as customer_count
from bank_churn
where Exited=1
group by CreditScore
order by  customer_count desc
limit 1;

-- 8.Find out which geographic region has the highest number of active customers with a tenure greater than 5 years.
select * from activecustomer;
select * from bank_churn;
select g.GeographyLocation, count(case when a.activecategory='Active Member' then 1 end)as count_of_active_member
from customerinfo c
join bank_churn b on c.customerid=b.customerid
join geography g on c.geographyid=g.geographyid
join activecustomer a on b.isactivemember=a.activeid
where b.tenure>5
group by g.geographylocation
order by count_of_active_member desc 
limit 1;

-- 9.What is the impact of having a credit card on customer churn, based on the available data?
SELECT cc.Category,
       COUNT(ci.CustomerId) AS NumCustomers,
       SUM(bc.Exited) AS NumExited,
       cast(count(case when exited= 1 then bc.CustomerId end)*100/ count(bc.CustomerId) as decimal(10,2)) AS ChurnRate
FROM CustomerInfo ci
JOIN Bank_Churn bc ON ci.CustomerId = bc.CustomerId
JOIN CreditCard cc ON bc.HasCrCard = cc.CreditID
GROUP BY cc.Category;

-- 10.For customers who have exited, what is the most common number of products they had used?
select NumOfProducts, count(NumOfProducts) as total_count 
        from bank_churn
		where exited= 1
		group by NumOfProducts
		order by total_count desc limit 1;
        
-- 11.Examine the trend of customer exits over time and identify 
-- 		any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.    
select year(bankDOJ) as year, count(c.CustomerId) as count_customer_churn
        from bank_churn b 
		inner join customerinfo c ON b.CustomerId= c.CustomerId
		where Exited= 1
		group by year(bankdoj)
        order by year;
        
-- 12.Analyze the relationship between the number of products and the 
--      account balance for customers who have exited.
SELECT 
	NumofProducts as Num_of_Products,
	Round(AVG(Balance),2) AS Avg_Balance,
	COUNT(ci.CustomerId) AS Num_of_Customers
FROM CustomerInfo ci
JOIN Bank_Churn bc ON ci.CustomerId = bc.CustomerId
WHERE bc.Exited = 1
GROUP BY NumOfProducts;

-- 13.Identify any potential outliers in terms of spend among customers who have remained with the bank.
select * from bank_churn;
select * from customerinfo;
-- SELECT 
   -- PERCENTILE_CONT(0.25) OVER (ORDER BY (c.estimatedsalary - b.balance)) AS q1,
   -- PERCENTILE_CONT(0.75) OVER (ORDER BY (c.estimatedsalary - b.balance)) AS q3
-- FROM customerinfo c
-- INNER JOIN bank_churn b ON c.cutomerId = b.customerId;

-- 15.	Using SQL, write a query to find out the gender-wise average income of males
--  and females in each geography id. Also, rank the gender according to the average value. (SQL)
 with temp as
		  (
		  select c.GeographyID,g.GenderCategory , 
          round(AVG(c.EstimatedSalary),2) as avg_salary
			from customerinfo c 
		  inner join gender g ON c.GenderID= g.GenderID
		  group by c.GeographyID,g.GenderCategory
		  )
		  select *, rank() over(order by avg_salary desc) 
          as ranking from temp
		  ;
          
-- 16.	Using SQL, write a query to find out the average tenure of the 
-- people who have exited in each age bracket (18-30, 30-50, 50+).
  
		  with AgeBucket as
		  (
		  select c.CustomerId,c.surname,c.age,c.GenderID,
          c.EstimatedSalary,c.GeographyID,c.bankDOJ,
		  b.CreditScore,b.tenure,b.balance,b.NumOfProducts,
          b.HasCrCard,b.IsActiveMember,b.Exited,
		  case when c.age between 18 and 30 then '18-30'
			   when c.age between 31 and 50 then '30-50'
			   else '50+'
			   end as age_bracket
		  from bank_churn b 
		  inner join customerinfo c ON b.CustomerId= c.CustomerId
		  where exited=1
		  )
		  select age_bracket, round(avg(tenure),2) avg_tenure from AgeBucket
		  group by age_bracket
		  ;
          
-- 17.  Is there any direct correlation between salary and balance of the customers? And is it different for people who have exited or not?
SELECT bc.Exited,
       Round(AVG(ci.EstimatedSalary),2) AS AvgSalary,
       Round(AVG(bc.Balance),2) AS AvgBalance,
       COUNT(ci.CustomerId) AS NumCustomers
FROM CustomerInfo ci
JOIN Bank_Churn bc ON ci.CustomerId = bc.CustomerId
GROUP BY bc.Exited;
          
-- 18. Is there any correlation between salary and Credit score of customers?
SELECT COUNT(*) AS Num_of_Customers,
	   Round(AVG(ci.EstimatedSalary),2) AS AvgSalary,
       round(AVG(bc.CreditScore),0) AS AvgCreditScore       
FROM CustomerInfo ci
join bank_churn bc on ci.customerid = bc.customerid;

-- 19. Rank each bucket of credit score as per the number of customers who have churned the bank.
  
		  with creditbucket as
		  (
		  select *,
		  case when creditscore between 0 and 579 then 'Poor'
			   when creditscore between 580 and 669 then 'Fair'
			   when creditscore between 670 and 739 then 'Good'
			   when creditscore between 740 and 800 then 'Very Good'
			   else 'Excellent'
			   end as creditBucket
		  from bank_churn
		  where exited = 1
		  )
		  select creditbucket, count(customerid) as total_count,
		  dense_rank() over(order by count(customerid) desc) as ranking  
		  from creditbucket
		  group by creditbucket
		  ;
          
-- 20.	According to the age buckets find the number of customers who have a credit card. 
-- Also, retrieve those buckets that have a lesser than average number of credit cards per bucket.

		create view ageBucket1 as
		(
		select c.CustomerId,c.surname,c.age,c.GenderID,
			   c.EstimatedSalary,c.GeographyID,c.bankDOJ,
			   b.CreditScore,b.tenure,b.balance,b.NumOfProducts,
               b.HasCrCard,b.IsActiveMember,b.Exited,
		  case when c.age between 18 and 30 then '18-30'
			   when c.age between 31 and 50 then '30-50'
			   else '50+'
			   end as age_bracket
		  from bank_churn b 
		  inner join customerinfo c ON b.CustomerId= c.CustomerId
		  );
          with cte1 as
		  (select age_bracket, count(customerid) total_customer,
		  count(case when hascrcard=1 then customerid end) as count_customer_with_credit
		  from agebucket1
		  group by 1)
		  select *, round((select avg(count_customer_with_credit) from cte1),2) as avg_customer_with_credit from cte1
		  having count_customer_with_credit < (select avg(count_customer_with_credit) from cte1)
		  ;
  
-- 21.	Rank the Locations as per the number of people who have churned
--  the bank and the average balance of the learners.  

		with cte as(
		select g.GeographyLocation, count(distinct b.CustomerId) as count_churn
		from bank_churn b 
		join customerinfo c on b.CustomerId= c.CustomerId
		join geography g ON c.GeographyID= g.GeographyID
		where b.exited= 1
		group by 1)
		select *, rank() over(order by count_churn desc) as rnk from cte
		;
        