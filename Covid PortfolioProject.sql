select *
from portfolioproject.coviddeaths
where continent is not null 
order by 3,4;

 select * 
 from portfolioproject.covidvaccinactions
 order by 3,4; 

-- select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject.coviddeaths
order by 1,2;

-- looking at the total cases vs total deaths 
-- shows the likelihood of dying if you contract covid in your country  
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentageofpopulationinfected
from portfolioproject.coviddeaths
-- where location like '%states%'
order by 1,2;

-- looking at the total cases vs the population 
-- shows what percentage of population got covid 
select location, date, total_cases, population, (total_deaths/population)*100 as Percentageofpopulationinfected
from portfolioproject.coviddeaths
-- where location like '%states%'
group by location, population
order by 1,2;

-- Looking at countries with highest infection rate compared to population 
select location, population, Max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as DeathPercentage
from portfolioproject.coviddeaths
-- where location like '%states%'
group by location, population
order by populationinfected desc; 

-- showing the countries with the highest death count per population 
SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS totaldeathcount
FROM portfolioproject.coviddeaths
-- WHERE location LIKE '%states%'
where continent is not null
GROUP BY location
ORDER BY totaldeathcount DESC;

-- Lets Break things down by continent 
-- showing the continents with the highest death count per population 
SELECT continent, MAX(CAST(total_deaths AS Signed)) AS totaldeathcount
FROM portfolioproject.coviddeaths
-- WHERE location LIKE '%states%'
where continent is not null
GROUP BY continent
ORDER BY totaldeathcount DESC;

-- Global numbers 
select  date, Sum(new_cases) as totalcases, Sum(cast(new_deaths as signed)) as totaldeaths, Sum(new_deaths)/sum(new_cases)*100
as deathpercentage
from portfolioproject.coviddeaths 
-- where location like '%states%'
where continent is not null
order by 1,2; 

-- Global numbers total
select  date, Sum(new_cases) as totalcases, Sum(cast(new_deaths as signed)) as totaldeaths, Sum(new_deaths)/sum(new_cases)*100
as deathpercentage
from portfolioproject.coviddeaths 
-- where location like '%states%'
where continent is not null
group by date 
order by 1,2; 

-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(vac.new_vaccinations, signed))  over (partition by dea.location order by dea.location, dea.date) 
as rollingPeopleVaccinanted 
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinactions vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- Use Cte 
 with popvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(vac.new_vaccinations, signed))  over (partition by dea.location order by dea.location, dea.date) 
as rollingPeopleVaccinanted 
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinactions vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3
)
select *, (RollingPeopleVaccinated/population)*100 
from popvsVac; 

Use portfolioproject;
CREATE TABLE PercentPopulationVaccinated 
(
continent VARCHAR(255), 
location VARCHAR(255), 
date DATETIME, 
population NUMERIC, 
new_vaccinations NUMERIC,
rollingPeopleVaccinated NUMERIC
);

-- Insert data into the table
INSERT INTO PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM
    portfolioproject.coviddeaths dea
JOIN
    portfolioproject.covidvaccinactions vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

-- Select from the table with the calculated percentage
SELECT *,
(rollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;

-- creating view to store data for later visualizations
DROP VIEW IF EXISTS percentpopulationvaccinated_View;
Create view PercentageVaccinated_View AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS rollingPeopleVaccinated
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinactions vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
select * 
from Percentagevaccinated_view;
