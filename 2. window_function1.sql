## WINDOWS FUNCTION ##

 
-- lets understand why we need use of wnindow functions , for applying window function we use OVER() clause--

CREATE DATABASE IF NOT EXISTS windows;
use  windows ;

create table employee ( emp_ID int , emp_NAME varchar(50) , DEPT_NAME varchar(50) , SALARY int);

insert into employee values
(101, 'Mohan', 'Admin', 4000),
(102, 'Rajkumar', 'HR', 3000),
(103, 'Akbar', 'IT', 4000),
(104, 'Dorvin', 'Finance', 6500),
(105, 'Rohit', 'HR', 3000),
(106, 'Rajesh',  'Finance', 5000),
(107, 'Preet', 'HR', 7000),
(108, 'Maryam', 'Admin', 4000),
(109, 'Sanjay', 'IT', 6500),
(110, 'Vasudha', 'IT', 7000),
(111, 'Melinda', 'IT', 8000),
(112, 'Komal', 'IT', 10000),
(113, 'Gautham', 'Admin', 2000),
(114, 'Manisha', 'HR', 3000),
(115, 'Chandni', 'IT', 4500),
(116, 'Satya', 'Finance', 6500),
(117, 'Adarsh', 'HR', 3500),
(118, 'Tejaswi', 'Finance', 5500),
(119, 'Cory', 'HR', 8000),
(120, 'Monica', 'Admin', 5000),
(121, 'Rosalin', 'IT', 6000),
(122, 'Ibrahim', 'IT', 8000),
(123, 'Vikram', 'IT', 8000),
(124, 'Dheeraj', 'IT', 11000);

select * from employee ;

-- lets find out the max salary 
select max(salary) as max_salary from employee;

-- lets find out dept wise max salary
select dept_name , max(salary) from employee group by  dept_name ;

-- now suppose we want to see department wise max salary and other details also , so we have to use window function bcz group by will not work here
select * from employee;
select * , max(salary) over (partition by dept_name) as Max_Salary from employee ;
select * , max(salary) over () as Max_Salary from employee ;      -- Here we have not provided any info in OVER() clause so it will treat each record as single window 

-- Lets use aggregate function with WINDOW
-- 1. Find out  department wise min, max , avg , sum of slary
select * , min(salary) over(partition by dept_name) as Min_Salary from employee ;
select * , max(salary) over(partition by dept_name) as Max_Salary from employee ;
select * , Avg(salary) over(partition by dept_name) as Avg_Salary from employee ;
select * , Sum(salary) over(partition by dept_name) as Sum_Salary from employee ;
select * , count(emp_id) over(partition by dept_name) as Count_Dept_wise from employee ;


-- ## -- ## -- ## -- ## -- ## -- ## -- ## -- ## 
-- Lets use ranking function with WINDOW
-- Imp note : We do not use any column name inside ranking functions --

## 1. ROW_NUMBER() => It will assign unique row number to each record
 -- 1(i) assign each records a unique row number
		select * , row_number() OVER() AS Row_numbers FROM employee;
        
 -- 1(ii) assign dept wise each records a unique row number	
        select * , row_number() OVER(partition by dept_name) AS Dept_wise_numbers FROM employee;
        
 -- 1(iii) assign dept wise each records a unique row number order by salary min to max
        select * , row_number() OVER(partition by dept_name order by salary) AS Dept_wise_numbers FROM employee;
        
 -- 1(iv) assign dept wise each records a unique row number order by salary max to min
        select * , row_number() OVER(partition by dept_name order by salary desc) AS Dept_wise_numbers FROM employee; 
        
 -- 1(v) fetch the first two employee from each dept who join the company
	Select * , row_number() over( partition by dept_name order by emp_id ) from employee ;  -- it will give department wise and order by employee id row numbers
	Select * FROM ( SELECT *, row_number() over( partition by dept_name order by emp_id ) as rn from employee ) as sub_query where rn < 3 ;   -- Here we used sub-query  and it is important to give alias to a sub-query without alias sub-query does not works

## 2. RANK() : Assigns a unique rank to each row within a partition, based on the specified order. If there are ties, the same rank is assigned to the tied rows, but the next rank is skipped.
-- 2(i) : Assign rank to each department as per max salary
	Select * , rank() over(partition by dept_name order by salary desc) from employee ;
-- 2(ii) : Fetch top 3 employees in each department earning max salary
	select * from (Select * , rank() over(partition by dept_name order by salary desc) as rnk from employee) as sub_query where rnk < 4 ;    
    
    
## 3. DENSE RANK() : Assigns a rank to rows within a partition, without skipping any ranks.  Tied rows get the same rank, but the next rank is consecutive.
-- 3(i) : Assign rank to each department as per max salary
	Select * , dense_rank() over(partition by dept_name order by salary desc) as rnk from employee ;
-- 3(ii) : Fetch top 3 employees in each department earning max salary
	select * from (Select * , dense_rank() over(partition by dept_name order by salary desc) as rnk from employee) as sub_query where rnk < 4 ;    

## 4. RANK , DENSE RANK AND ROW NUMBER ALL TOGETHER
	 Select * ,
     rank() over(partition by dept_name order by salary desc) as rank_col  ,
     dense_rank() over(partition by dept_name order by salary desc) as Dense_Rank_col ,
	 row_number() over(partition by dept_name order by salary desc) as row_num_col 
     from employee ;
     
## 5. PERCENT RANK 


-- ex-1 calculate the PERCENT_RANK for employees based on their salaries across the entire dataset.
Select * , percent_rank() over(order by salary ) as Percent_salary 
	from employee ;
    
Select * , 
round(percent_rank() over(order by salary ),2) as Percent_salary 
	from employee ;    
    
    
-- ex-2 calculate the PERCENT_RANK for employees within their respective departments based on their salaries?  
Select * , percent_rank() over(partition by dept_name order by salary ) as Per_RAnk
	from employee ; 
Select * , 
round(percent_rank() over(partition by  dept_name order by salary ),2) as Per_Rank 
	from employee ;       
   
   
-- ## -- ## -- ## -- -- ## -- ## -- ## -- -- ## -- ## -- ## --
     
##  Value/Analytics function with WINDOW  ##    

## LEAD() : Accesses data from the next row within the same partition. (basically it shows the next record )
-- Use Case: To compare a row's value with the value in the next row.

-- 1. Fetch a  query to display if the salary of an employee is higher, lower or equal to the next employee 
select * , lead(salary) over(partition by dept_name order by emp_id) as next_emp_salary from employee ;   -- for the record which has no next record it will show NULL
select * , lead(salary,1,0) over(partition by dept_name order by emp_id) as next_emp_salary from employee ; -- for the record which has no next record it will show 0 {here 1 means next one record and 0 means to show zero) 
select * , lead(salary,2,0) over(partition by dept_name order by emp_id) as next_emp_salary from employee ; --  {here 2 means to show record from next 2nd  record and 0 means to show zero)

## LAG() : Accesses data from the previous row within the same partition. (basically it shows the previous record )
-- Use Case: To compare a row's value with the value in the previous row.

-- 1. Fetch a  query to display if the salary of an employee is higher, lower or equal to the previous employee 
select * , lag(salary) over(partition by dept_name order by emp_id) as prev_emp_salary from employee ;   -- for the record which has no next record it will show NULL
select * , lag(salary,1,0) over(partition by dept_name order by emp_id) as prev_emp_salary from employee ; -- for the record which has no next record it will show 0 {here 1 means previous one record and 0 means to show zero) 
select * , lag(salary,2,0) over(partition by dept_name order by emp_id) as prev_emp_salary from employee ; --  {here 2 means to show record from previous 2nd  record and 0 means to show zero)

-- 2. Fetch a  query to display if the salary of an employee is higher, lower or equal to the previous employee it ust show higehr or lower
select * , lag(salary) over(partition by dept_name order by emp_id) as prev_emp_salary ,
case when salary >  lag(salary) over(partition by dept_name order by emp_id) then "Higher than previous employee"
	 when salary <  lag(salary) over(partition by dept_name order by emp_id) then "Lower than previous employee"
     when salary =  lag(salary) over(partition by dept_name order by emp_id) then "Equal as previous employee"
     end sal_range
from employee ;

-- proper way --
SELECT *, 
       LAG(salary) OVER (PARTITION BY dept_name ORDER BY emp_id) AS prev_emp_salary,
       CASE 
           WHEN salary > LAG(salary) OVER (PARTITION BY dept_name ORDER BY emp_id) THEN "Higher than previous employee"
           WHEN salary < LAG(salary) OVER (PARTITION BY dept_name ORDER BY emp_id) THEN "Lower than previous employee"
           WHEN salary = LAG(salary) OVER (PARTITION BY dept_name ORDER BY emp_id) THEN "Equal to previous employee"
       END AS sal_range
FROM employee;


## FIRST_VALUE  

-- 1.  Retrieve the First Salary in Each Department
select * ,
first_value(Salary) over(partition by Dept_name order by emp_id) as first_vl
from employee ; 




## LAST_VALUE  -(MOST OF THE TIME USED WITH - ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING )


-- 1. Retrieve the Last Salary in Each Department 
select * ,
last_value(salary) over(partition by dept_name order by emp_id  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Last_Salary 
from employee ;

SELECT * ,
       LAST_VALUE(Salary) OVER (PARTITION BY Dept_name ORDER BY emp_id ASC 
       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Last_Salary
FROM Employee;

-- CONCEPT OF ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING in SQL --



-- fIRST_VALUE & LAST_VALUE TOGETHER.
-- 1.  Identify the First and Last Employee (Alphabetically) in Each Department
SELECT * ,
       FIRST_VALUE(emp_name) OVER (PARTITION BY Dept_name ORDER BY emp_name ASC) AS First_Employee,
       LAST_VALUE(emp_name) OVER (PARTITION BY Dept_name ORDER BY emp_name ASC 
	   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Last_Employee
FROM Employee;

-- 2. Compare Each Employee's Salary to the First Salary in Their Department
SELECT * ,
       FIRST_VALUE(Salary) OVER (PARTITION BY Dept_name ORDER BY Salary ASC) AS Min_Salary,
       Salary - FIRST_VALUE(Salary) OVER (PARTITION BY Dept_name ORDER BY Salary ASC) AS Salary_Difference
FROM Employee;


-- 3. Retrieve the First and Last Salary in Each Department
SELECT * ,
       FIRST_VALUE(Salary) OVER (PARTITION BY Dept_name ORDER BY Salary ASC) AS Min_Salary,
       LAST_VALUE(Salary) OVER (PARTITION BY Dept_name ORDER BY Salary ASC 
	   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Max_Salary
FROM Employee;


-- ## -- ## -- ## -- ## -- ## -- ## -- ## -- ## 
-- Lets use NTILE() window function

-- 1. divide employees into 4 salary quartile
SELECT 
    emp_ID,
    emp_NAME,
    DEPT_NAME,
    SALARY,
    NTILE(4) OVER (ORDER BY SALARY DESC) AS salary_quartile
FROM employee;

-- 2. Divide 4 employees into 2 groups
SELECT 
    emp_ID,
    emp_NAME,
    DEPT_NAME,
    SALARY,
    ntile(2) over(order by salary desc) as salary_group
    from employee;



# select emp_id , emp_name . dept_name , salary , ntile(4) over(order by Salary desc) as salary_quartile
# from employee;



 
