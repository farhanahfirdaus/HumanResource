-- Data Cleaning

Select *
From hr;

-- Change column name
Alter Table hr
Change Column ï»¿id emp_id varchar(20) null;

-- To check data type
Describe hr;

Select termdate
From hr;

-- to convert data to date form
Update hr
Set birthdate = Case
	When birthdate like '%/%' 
		Then Date_format(Str_to_date(birthdate,'%m/%d/%Y'), '%Y-%m-%d')
    When birthdate like '%-%'
		Then Date_format(Str_to_date(birthdate,'%m-%d-%Y'), '%Y-%m-%d')
	Else Null
End;

-- to change date data type
Alter Table hr
Modify Column birthdate Date;

Update hr
Set birthdate = Date_sub(birthdate, Interval 100 Year)
Where birthdate >= '2060-01-01' and birthdate < '2070-01-01';

Select birthdate
From hr; 

Update hr
Set hire_date = Case
	When hire_date like '%/%' 
		Then Date_format(Str_to_date(hire_date,'%m/%d/%Y'), '%Y-%m-%d')
    When hire_date like '%-%'
		Then Date_format(Str_to_date(hire_date,'%m-%d-%Y'), '%Y-%m-%d')
	Else Null
End;

Alter Table hr
Modify Column hire_date Date;

Update hr
Set termdate = If 
	(termdate is not null and termdate != '', Date(Str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '000-00-00')
Where true;

Select termdate
from hr;

Set sql_mode = 'ALLOW_INVALID_DATES';

Alter Table hr
Modify Column termdate Date;

Alter Table hr
Add Column Age int;

Alter Table hr
Change Column Age age varchar(20) null;

Update hr
Set age = Timestampdiff(Year, birthdate, curdate());

Select 
	Min(age) as youngest,
	Max(age) as oldest
From hr;

Select Count(*)
From hr
Where age < 18;

-- Questions
-- 1. What is the gender breakdown of employees in the company?

Select gender, Count(*) as count
From hr
Where termdate = '000-00-00'
Group by gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?

Select race, Count(*) as count
From hr
Where termdate = '000-00-00'
Group by race
Order by 2 desc;

-- 3. What is the age distribution of employees in the company?

Select 
	Min(age) as youngest,
	Max(age) as oldest
From hr
Where termdate = '000-00-00';

Select 
	Case 
		 When age>=18 and age<=24 Then '18-24'
         When age>=25 and age<=34 Then '25-34'
         When age>=35 and age<=44 Then '35-44'
         When age>=45 and age<=54 Then '45-54'
         When age>=55 and age<=64 Then '55-64'
         Else '65+'
	End as age_group,
    Count(*) as count
From hr
Where termdate = '000-00-00'
Group by age_group
Order by age_group;

Select 
	Case 
		 When age>=18 and age<=24 Then '18-24'
         When age>=25 and age<=34 Then '25-34'
         When age>=35 and age<=44 Then '35-44'
         When age>=45 and age<=54 Then '45-54'
         When age>=55 and age<=64 Then '55-64'
         Else '65+'
	End as age_group, gender,
    Count(*) as count
From hr
Where termdate = '000-00-00'
Group by age_group, gender
Order by age_group, gender;

-- 4. How many employees work at heaquarters versus remote locations

Select location, Count(*) as count
from hr
Where termdate = '000-00-00'
Group by location;

-- 5. What is the average length of employment for employees who have been terminated?

Select 
	-- calculate the difference between two date
    Round(Avg(datediff(termdate, hire_date))/365,0) as avg_length_employment
From hr
Where termdate <= curdate() and termdate <> '000-00-00';

-- 6. How does the gender distribution vary across departments and job titles?

Select department, gender, Count(*) as count
From hr
Where termdate = '000-00-00'
Group by department, gender
Order by 1;

-- 7. What is the distribution of job titles across the company?

Select jobtitle, Count(*) as count
From hr
Where termdate = '000-00-00'
Group by jobtitle
Order by 1 desc;

-- 8. Which department has the higher turnover rate?

Select 
	department, 
	total_count, 
	terminated_count, 
	terminated_count/total_count as termination_rate
From (
	Select department,
	Count(*) as total_count,
    Sum(Case
		When termdate <> '000-00-00' and termdate <= Curdate()
			Then 1 
            Else 0
		End) as terminated_count
	From hr
    Group by department
    ) as subquery
Order by termination_rate desc;

-- 9. What is the distribution of employees across locations by city and state?

Select location_state, Count(*) as count
From hr
Where termdate = '000-00-00'
Group by location_state
Order by 2 desc;

-- 10. How was the company's employee count changed over time based on hire and term dates?

Select 
	year,
    hires,
    terminations,
    hires - terminations as net_change,
    round((hires - terminations)/ hires * 100, 2) as net_change_percent
From (
	Select Year(hire_date) as year,
    Count(*) as hires,
    Sum(Case
		When termdate <> '000-00-00' and termdate <= curdate() 
        Then 1 
        Else 0 
        End) as terminations
	From hr
    Group by Year(hire_date)
    ) as subquery
Order by year asc;

-- 11. What is the tenure distribution for each deartment? (How long each employee stay in the dept before quit/fired)

Select department, Round(Avg(Datediff(termdate, hire_date)/365),0) as avg_tenure
From hr
Where termdate <= curdate() and termdate <> '0000-00-00'
Group by department;