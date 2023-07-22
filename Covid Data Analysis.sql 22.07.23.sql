Select * from covid_death;

COPY covid_death 
FROM '\\KFASH\Users\X1 CARBON\Documents\Portfolio Project SQL\coviddeath.csv'
DELIMITER ',' CSV 
HEADER;

COPY covid_vaccin 
FROM 'C:\Users\X1 CARBON\Documents\Portfolio Project SQL\covidvaccin.csv'
DELIMITER ',' CSV 
HEADER;

C:\Users\X1 CARBON\Documents\Portfolio Project SQL

Select * from covid_vaccin;

ALTER TABLE covid_death
ALTER COLUMN total_deaths TYPE BIGINT;

Select location,date,total_cases,new_cases,total_deaths,population
From covid_death
Order by 1,2;

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as 
DeathPercentage 
From covid_death
Order by 1,2;

SELECT location, date, total_cases, total_deaths, (total_deaths::float / total_cases) * 100 AS death_percentage
FROM covid_death
ORDER BY 1, 2;

/* This show the likelihood of dieing in Nigeria */

SELECT location, date, total_cases, total_deaths, (total_deaths::float / total_cases) * 100 AS death_percentage
FROM covid_death
Where location like '%Nigeria%'
ORDER BY 1, 2;

/* Total cases vs population*/

SELECT location, date, total_cases, population, (total_cases::float / population) * 100 AS population_percentage
FROM covid_death
Where location like '%Nigeria%'
ORDER BY 1, 2;

Select location,population, max(total_cases) as highestinfectioncount,Max (total_cases::float/ population) * 100 AS populationpercentageinfected
from covid_death 
where location like '%States%'
group by location,population 
order by populationpercentageinfected  desc


Select location,population, max(total_cases) as highestinfectioncount,Max (total_cases::float/ population) * 100 AS populationpercentageinfected
from covid_death 
--where location like '%states%'
group by location,population 
order by populationpercentageinfected  desc

Select * from covid_death 
Select location,population, max(total_cases) as highestinfectioncount,
max (total_cases::float/ population) * 100 AS populationpercentageinfected,
max (total_death::float/ population) * 100 AS populationpercentagedeath
from covid_death 
--where location like '%states%'
group by location,population 
order by populationpercentagedeath  desc

Select location,population, max(total_cases) as highestinfectioncount,
max(total_deaths) as highestdeathcount,
max (total_cases::float/ population) * 100 AS populationpercentageinfected,
max (total_deaths::float/ population) * 100 AS populationpercentagedeath
from covid_death 
--where location like '%states%'
group by location,population 
order by populationpercentageinfected  desc

Select location, max(total_deaths) as highestdeathcount,
max (total_deaths::float/ population) * 100 AS populationpercentagedeath
from covid_death 
--where location like '%states%'
group by location 
order by populationpercentagedeath  desc

-- Showing countries with the highest death count per population 
Select location, max(total_deaths) as highestdeathcount
From covid_death 
--where location like '%states%'
where continent is null
group by location 
order by highestdeathcount desc

-- Breakdown by continent 
Select continent, max(total_deaths) as highestdeathcount
From covid_death 
--where location like '%states%'
where continent is not null
group by continent
order by highestdeathcount desc

--- Total Global number of Cases and Deaths by day
Select * from covid_death 

Select date, sum(total_cases) as totalinfection, 
sum(total_deaths) as totaldeaths
from covid_death
group by date
order by totalinfection

-- Total Global new cases and deaths per day
Select date, sum(new_cases) as totalnewinfection, 
sum(new_deaths) as totalnewdeaths
from covid_death
group by date
order by totalnewinfection

-- Total Global percentage of new cases on deaths per day
Select date, sum(new_cases) as totalnewinfection, 
sum(new_deaths) as totalnewdeaths,
sum(new_deaths::float/nullif(new_cases,0))* 100 as deathpercentage
from covid_death
where continent is not null
group by date
order by totalnewinfection

---Joining the two tables
Select *
From covid_vaccin cv
Join covid_death cd
ON cv.location = cd.location
and cv.date = cd.date

--- Total population vs vaccination in the world
Select * from covid_vaccin

Select cd.location,cd.population,cd.date,cv.new_vaccinations,
From covid_vaccin cv
Join covid_death cd
ON cv.location = cd.location
and cv.date = cd.date
order by cd.location

----Using Partition with join table
Select cd.location,cd.population,cd.date,cv.new_vaccinations,
sum (cv.new_vaccinations) OVER (Partition by cd.location)
From covid_vaccin cv
Join covid_death cd
ON cv.location = cd.location
and cv.date = cd.date
order by cd.location

--- using Partition and order by at the same time
Select cd.location,cd.population,cd.date,cv.new_vaccinations,
sum (cv.new_vaccinations) OVER (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccination
From covid_vaccin cv
Join covid_death cd
ON cv.location = cd.location
and cv.date = cd.date
order by cd.location

-- USING WITH 

With PopvsVac (location,population,date,new_vacinations,RollingPeopleVaccination)
as 
(
	Select cd.location,cd.population,cd.date,cv.new_vaccinations,
sum (cv.new_vaccinations) OVER (Partition by cd.location 
								order by cd.location,cd.date) as RollingPeopleVaccination
From covid_vaccin cv
Join covid_death cd
ON cv.location = cd.location
and cv.date = cd.date
--order by cd.location
	)
	Select *,(RollingPeopleVaccination/population )*100
	From PopvsVac
	
	
--Creating a Temp Table
Create table PercentagePopulationVaccinated
(continent varchar,
location varchar,
date date,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccination numeric
);

Insert into PercentagePopulationVaccinated (continent, location, date, population, new_vaccinations, rollingpeoplevaccination)
Select cd.location,cd.population,cd.date,cv.new_vaccinations,
sum (cv.new_vaccinations) OVER (Partition by cd.location 
								order by cd.location,cd.date) as RollingPeopleVaccination
From covid_vaccin cv
Join covid_death cd
ON cv.location = cd.location
and cv.date = cd.date
--order by cd.location
	)
	Select *,(RollingPeopleVaccination/population )*100
	From PercentagePopulationVaccinated


-- Create the table PercentagePopulationVaccinated
CREATE TABLE PercentagePopulationVaccinated (
    continent VARCHAR,
    location VARCHAR,
    date DATE,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rollingpeoplevaccination NUMERIC
);

-- Use a CTE to calculate the rollingpeoplevaccination
WITH PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccination) AS (
    SELECT
        cd.continent,
        cd.location,
        cd.date,
        cd.population,
        cv.new_vaccinations,
        SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS rollingpeoplevaccination
    FROM
        covid_vaccin cv
    JOIN
        covid_death cd ON cv.location = cd.location AND cv.date = cd.date
)

-- Insert data into PercentagePopulationVaccinated table from the CTE
INSERT INTO PercentagePopulationVaccinated (continent, location, date, population, new_vaccinations, rollingpeoplevaccination)
SELECT
    continent,
    location,
    date,
    population,
    new_vaccinations,
    rollingpeoplevaccination
FROM PopvsVac;

-- Calculate the percentage of population vaccinated and select all data
SELECT *, (rollingpeoplevaccination / population) * 100 AS percentage_population_vaccinated
FROM PercentagePopulationVaccinated;

--- Creating a view for visiualization 
Create view PercentagePopulationVaccinated as 
Select cd.location,cd.population,cd.date,cv.new_vaccinations,
sum (cv.new_vaccinations) OVER (Partition by cd.location 
								order by cd.location,cd.date) as RollingPeopleVaccination
From covid_vaccin cv
Join covid_death cd
ON cv.location = cd.location
and cv.date = cd.date
where cd.continent is not null
 