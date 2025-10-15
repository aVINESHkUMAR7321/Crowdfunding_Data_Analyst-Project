create database crowdfunding;
use crowdfunding;

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE projects
ADD COLUMN created_date DATETIME,
ADD COLUMN launched_date DATETIME,
ADD COLUMN deadline_date DATETIME,
ADD COLUMN state_changed_date DATETIME,
ADD COLUMN updated_date DATETIME,
ADD COLUMN successful_date DATETIME;

UPDATE projects
SET 
    created_date = FROM_UNIXTIME(Created_At),
    launched_date = FROM_UNIXTIME(Launched_At),
    deadline_date = FROM_UNIXTIME(Deadline),
    state_changed_date = FROM_UNIXTIME(state_changed_at),
    updated_date = FROM_UNIXTIME(updated_at),
    successful_date = if(successful_at > 0, from_unixtime(successful_at), null);
    
ALTER TABLE projects
	ADD COLUMN Years int,
	ADD COLUMN Months int,
	ADD COLUMN Monthnames varchar(15),
	ADD COLUMN Quarters int,
	ADD COLUMN YearMonthname varchar(20),
	ADD COLUMN Weekdays int,
	ADD COLUMN Weekname varchar(15),
	ADD COLUMN FinancialQuarter varchar(10),
	ADD COLUMN FinancialMonth varchar(20);
    
UPDATE projects
SET 
	Years = year(created_date),
    Months = month(created_date),
    Monthnames = monthname(created_date),
    Quarters = quarter(created_date),
    YearMonthname = date_format(created_date, '%y,%m'),
    Weekdays = weekday(created_date) + 1,
    Weekname = dayname(created_date),
    FinancialQuarter = concat("FQ", round (month(created_date)/3,0)),
    FinancialMonth = concat("FM", month(created_date));
    
ALTER TABLE projects
	MODIFY COLUMN GoalRange varchar(50);

UPDATE projects
SET 
	GoalRange = case
    when goal < 10000 then "<10000"
    when goal < 100000 then ">10000 - <100000"
    when goal < 500000 then " >100000 - <500000"
    when goal < 700000 then " >500000 - <700000"
    else " >700000"
    end;
    
ALTER TABLE projects
	ADD COLUMN ProjectDays int;
    
UPDATE projects
SET 
	Projectdays = datediff(launched_date, created_date);
    
ALTER TABLE projects
	ADD COLUMN USD_Goal int;

UPDATE projects
SET 
	USD_Goal = Goal * static_usd_rate;

----------------------------------------------------------------------------------------------------------------------------------------------
    
-- Total No.of Projects based on outcome 

select state, count(ProjectID) as Total from projects group by state;


----------------------------------------------------------------------------------------------------------------------------------------------

-- Total Number of Projects based on Locations  
    
select count(distinct location_id) as total_location_project from projects;


----------------------------------------------------------------------------------------------------------------------------------------------

-- Total Number of Projects based on  Category

select count(distinct category_id) as total_category_project from projects;


-----------------------------------------------------------------------------------------------------------------------------------------------

-- Total Number of Projects created by Year , Quarter , Month

select Years, Quarters, Monthnames, count(projectID) as total_projects from projects group by years, quarters, Monthnames;


------------------------------------------------------------------------------------------------------------------------------------------------

-- successful Amount Raised 

select projectID as Successful_Backers,concat('$ ',sum(usd_pledged)) as total from projects where state = 'successful' group by projectID;


------------------------------------------------------------------------------------------------------------------------------------------------

-- successful No.of Backers

select count(backers_count) as Successful_Backers from projects where state = 'successful';


------------------------------------------------------------------------------------------------------------------------------------------------

-- Avg No.of Days for successful projects

select avg(ProjectDays) as Average_days from projects where state = 'successful';


------------------------------------------------------------------------------------------------------------------------------------------------

-- Top Successful Projects Based on Number of Backers

select projectID as ID,count(backers_count) as Backer_count, sum(usd_pledged) as Project from projects 
where state = 'successful' group by ID 
order by Project desc
limit 10;


------------------------------------------------------------------------------------------------------------------------------------------------

 -- Top Successful Projects Based on Amount Raised
 
 select projectID as ID, name as Project_name, sum(usd_pledged) as Amount_Raised from projects 
 where state = 'successful' group by ID, Project_name
 order by Amount_Raised desc 
 limit 10;
 
 
 ------------------------------------------------------------------------------------------------------------------------------------------------
 
 -- Percentage of Successful Projects overall
 
 select state, sum(usd_pledged) as Total, 
 concat(round(count(projectID)*100.0 / (select count(projectID) from projects),2),'%') as percentage 
 from projects
 group by state;
 
 
 -------------------------------------------------------------------------------------------------------------------------------------------------
 
-- Percentage of Successful Projects  by Category

select category_id, sum(usd_pledged) as total,
concat(round(count(usd_pledged)*100.0 / (select count(usd_pledged) from projects),2),'%') as percentage from projects
where state = 'successful'
group by category_id;
 
 
 -------------------------------------------------------------------------------------------------------------------------------------------------
 
-- Percentage of Successful Projects by Year , Month etc..

select Years, Monthnames,sum(usd_pledged) as Total,sum(if( state = 'successful', usd_pledged,0)) as Successful_total, count(usd_pledged) as count,
concat(round(sum(usd_pledged)*100.0 / (select sum(usd_pledged) from projects),2),'%') as percentage from projects
group by Years,Monthnames ; 


-------------------------------------------------------------------------------------------------------------------------------------------------

-- Percentage of Successful projects by Goal Range 

select GoalRange, sum(usd_pledged) as Total, sum(if( state = 'successful', usd_pledged,0)) as Successful_total, count(usd_pledged) as count,
concat(round(count(usd_pledged)* 100.0 / (select count(usd_pledged) from projects),2),' %') as Percentage from projects 
group by GoalRange;


--------------------------------------------------------------------------------------------------------------------------------------------------








    
    
    




    
