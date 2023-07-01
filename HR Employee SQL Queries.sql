create database sql_project;
use sql_project;
select*from HR;
alter table HR change column ï»¿id emp_id varchar(20)null;
desc HR;
select birthdate from HR;
update HR
set birthdate=case
	when birthdate like '%/%' then date_format(str_to_date(birthdate, '%m/%d/%Y'),'%y-%m-%d')
    when birthdate like '%-%' then date_format(str_to_date(birthdate, '%m-%d-%Y'),'%y-%m-%d')
    else null
end;
select birthdate from HR;
alter table HR
modify column birthdate date;
update HR
set hire_date=case
	when hire_date like '%/%' then date_format(str_to_date(hire_date, '%m/%d/%Y'),'%y-%m-%d')
    when hire_date like '%-%' then date_format(str_to_date(hire_date, '%m-%d-%Y'),'%y-%m-%d')
    else null
end;
alter table HR
modify column hire_date date;
select termdate from HR;

update HR
set termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != ' ';

alter table HR
modify column termdate date;

describe HR;

select * from HR;

alter table HR add column age int;
#to find age
update HR
set age=timestampdiff(year,birthdate,curdate());

select
min(age)as youngest,
max(age) as oldest
from HR;

select count(*) from HR where age < 18;

# 1. What is the gender breakdown of employees in the company?
select gender, count(*) as count
from HR
where age >=18 and termdate = ''
group by gender;
# 2. What is the race/ethnicity breakdown of employees in the company?
select race, count(*) as count
from HR
where age >=18 and termdate = ''
group by race
order by count(*) desc;
# 3. What is the age distribution of employees in the company?
select
min(age) as youngest,
max(age) as oldest
from HR
where age >=18 and termdate = '';

select 
case
when age >= 18 and age <= 24 then'18-24'
when age >= 25 and age <= 34 then '25-34'
when age >= 35 and age <= 44 then '35-44'
when age >= 45 and age <= 54 then '45-54'
when age >= 55 and age <= 64 then '55-64'
else '65+'
end as age_group,
count(*) as count
from HR
where age >=18 and termdate = ''
group by age_group
order by age_group;

select 
case
when age >= 18 and age <= 24 then'18-24'
when age >= 25 and age <= 34 then '25-34'
when age >= 35 and age <= 44 then '35-44'
when age >= 45 and age <= 54 then '45-54'
when age >= 55 and age <= 64 then '55-64'
else '65+'
end as age_group, gender,
count(*) as count
from HR
where age >=18 and termdate = ''
group by age_group, gender
order by age_group, gender;
# 4. How many employees work at headquarters versus remote location?
select location, count(*) as count
from HR
where age >=18 and termdate = ''
group by location;

# 5. What is the average length of employment for employees who have been terminated?
select
round(avg(datediff(termdate,hire_date))/365) as avg_length_emp
from HR
where termdate <= curdate() and termdate<> '' and age >= 18;

# How does the gender distribution vary across departments and job titles?
select department, gender, count(*) as count
from HR
where age >=18 and termdate = ''
group by department, gender
order by department;

# 7. What is the ditribution of job titles across the company?
select jobtitle, count(*) as count
from HR
where age >=18 and termdate = ''
group by jobtitle
order by jobtitle desc;

# 8. Which department has the highest turnover rate?
select department, 
total_count,
terminated_count,
terminated_count/total_count as termination_rate
from (
select department,
count(*) as total_count,
sum(case when termdate<> '' and termdate <= curdate() then 1 else 0 end) as terminated_count
from HR
where age >= 18
group by department
) as subquery
order by termination_rate desc;

# 9. What is the distribution of employees across location across city and states?
select location_state, count(*) as count
from HR
where age >=18 and termdate = ''
group by location_state
order by count desc;

# 10. How has the employeews count changed over time based on hire and term dates?
select
 year,
 hires,
 terminations,
 hires - terminations as net_change,
 round((hires - terminations)/hires * 100,2) as net_change_percent
from(
select 
 year(hire_date) as year,
 count(*) as hires,
 sum(case when termdate <> '' and termdate <= curdate() then 1 else 0 end) as terminations
 from HR
 where age >= 18
 group by year(hire_date)
 ) as subquery
 order by year asc;
 
# 11. What is the tenure distribution for each department?
select department, round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
from HR
where termdate <= curdate() and termdate <> '' and age >= 18
group by department;