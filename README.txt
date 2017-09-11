Following is the process to execute the script:

This script performs below 3 tasks of SQL query:
	1: Group by & Aggregation 
	2: Nested Query
	3: join

copy all the three files that is assignment2.sh, department.CSV, employee.CSV in your desktop directory 
1. Copy the attached files to Desktop.
2. Open Bash on Ubuntu on Windows 10 shell prompt
3. cd to Desktop directory
	eg: cd /mnt/c/Users/Goutham/Desktop
	here "replace Goutham" with your user name in system 
4. execute the command---> bash assignment2.sh
-----------------------------------------------------------------------------------------------------------------------------

1) when you run the script it gives you 3 options to select as below
	1: Group by & Aggregation 
	2: Nested Query
	3: join
	you have to enter the number of required option. eg: for join I have to enter 3
2) Next it asks to select the grouping coloumn number. So select a coloumn that required for you.
Note: select "0" here if you have opted for "Nested Query" above because we are not grouping on any column in our query (see our qury in option 2 below)
3) Next it asks to select the aggregation function column.    

<group_by_col> ==> Represents column that you selected for grouping. (above 2nd point)
<agg_col> ==> Represents column that you selected for aggregation function column. (above 3rd point)

---------------------------------------------------------------------------------------------------------------------
option 1. Group by & Aggregation:
	SELECT MIN(<agg_col>), MAX(<agg_col>), COUNT(<agg_col>), SUM(<agg_col>), AVG(<agg_col>) FROM EMPLOYEE GROUP BY <group_by_col> HAVING count(*) > 1;
eg:
In the above query if I select group by column as 9 (<group_by_col> = Emp_Dept_id) and Aggregation function column as 5 (<agg_col> = Emp_sal)  
So result of query:
 SELECT MIN(Emp_sal), MAX(Emp_sal), COUNT(Emp_sal), SUM(Emp_sal), AVG(Emp_sal) FROM EMPLOYEE GROUP BY Emp_Dept_id; 

(for department id = 1)	Value = 1        Min = 76000     Max = 95000     Count = 3       Sum = 266000    Avg = 88666
(for department id = 2) Value = 2        Min = 76000     Max = 85000     Count = 2       Sum = 161000    Avg = 80500
(for department id = 3) Value = 3        Min = 65000     Max = 95000     Count = 2       Sum = 160000    Avg = 80000

------------------------------------------------------------------------------------------------------------------------
option 2. Nested Query:
SELECT * FROM EMPLOYEE WHERE <agg_col> >= (SELECT AVG(<agg_col>) FROM EMPLOYEE);

below result appears if we select "n" (not) to ignore null values at starting of script 
eg: 
SELECT * FROM EMPLOYEE WHERE Emp_sal >= (SELECT AVG(Emp_sal) FROM EMPLOYEE);
Emp_id  | Emp_fname     | Emp_lname     | Emp_DOB       | Emp_sal       | Emp_gender    | Emp_address   | Emp_phn       | Emp_Dept_id
1       | Sameer        | Gadne 	| 09-17-1989    | 95000 	| Male  	| Northbrook    | 2242009771    | 1
3       | Akanksha      | Singh 	| 08-20-1990    | 95000 	| Female        | Northbrook    | 2242009773    | 1
7       | Aneeka        | Gadne 	| 08-28-1988    | 95000 	| Female        | Chicago       | 2242009777    | 3
NULL    | Aditya        | Gangwar       | NULL      	| 97000 	| Male  	| Northbrook    | 2242009778    |NULL



-------------------------------------------------------------------------------------------------------------------------
option 3. Join:
SELECT E.*, D.*
FROM EMPLOYEE E, DEPARTMENT D
WHERE E.EMP_DEPT_ID = D.DEPT_ID;

Performs below joins on above query:
Inner Join (also natural )
Left outer join
Anti Join

--------------------------------------------------------------------------------------------------------------------------

