USE PortfolioProject;

SELECT * 
FROM coviddeath
WHERE continent is not NULL
ORDER BY 3,4;

-- Select data that we are going to be using 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM coviddeath
ORDER BY 1,2;

-- Looking at Total Cases vs. Total Deaths
-- Show likelihood of dying if you contract covid in United States
SELECT Location, date, total_cases, total_deaths, round((total_deaths/total_cases),5) * 100 as DeathPercentage
FROM coviddeath
WHERE location like '%states%';

-- Looking at Total Cases vs Population
SELECT Location, date, total_cases, population, round((total_cases/population),5) * 100 as CasePercentage
FROM coviddeath
WHERE location like '%states%';

-- Looking at Countries with Highest Infection Rate campared to Population
SELECT Location, population, MAX(total_cases) as MaxInfection, 
	MAX(round((total_cases/population),5) * 100) as PercentageMaxInfection
FROM coviddeath
GROUP BY Location, population
ORDER BY 4 DESC;

-- LET's BREAK THiNGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM coviddeath
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Looking at Countries with Highest Death Count compared to Population
SELECT Location, population, MAX(total_deaths) as MaxTotalDeaths, 
	MAX(round((total_deaths/total_cases),5) * 100) as PercentageMaxDeaths
FROM coviddeath
WHERE continent is not NULL
GROUP BY Location, population
ORDER BY MaxTotalDeaths DESC;

-- GLOBAL NUMBERS
SELECT Location, continent, date, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeath
WHERE continent is not null
GROUP BY date
ORDER BY 1;

	-- numbers of new deaths over new cases for each dates
SELECT date, SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths, 
		(SUM(new_deaths)/SUM(new_cases)) * 100 as DeathPercentage
FROM coviddeath
WHERE continent is not null
GROUP BY date;

-- Looking at Total Population vs. Vaccination
SELECT cd.continent, cd.location, CONVERT(cd.date,date) AS date, cd.population, 
		cv.new_vaccinations, 
        SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPplVaccinated
FROM coviddeath cd JOIN covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 1,2;

-- USE CTE

WITH PopvsVac (continent, Location, date, population, new_vaccinations, RollingPplVaccinated) 
AS 
(
SELECT cd.continent, cd.location, CONVERT(cd.date,date) AS date, cd.population, 
		cv.new_vaccinations, 
        SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPplVaccinated
FROM coviddeath cd JOIN covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 1,2
)
SELECT *, (RollingPplVaccinated / population) * 100
FROM PopvsVac
GROUP BY continent;

-- Temp Table
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent varchar(255), 
Location varchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPplVaccinated numeric
);

SELECT new_vaccinations
FROM covidvaccinations;

SET SESSION sql_mode = '';

INSERT INTO PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
        SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPplVaccinated
FROM coviddeath cd JOIN covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null;

SELECT *, (RollingPplVaccinated / Population) * 100
FROM PercentPopulationVaccinated;

-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated1 as
SELECT cd.continent, cd.location, CONVERT(cd.date,date) AS date, cd.population, 
		cv.new_vaccinations, 
        SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPplVaccinated
FROM coviddeath cd JOIN covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null;

SELECT * 
FROM PercentPopulationVaccinated;
