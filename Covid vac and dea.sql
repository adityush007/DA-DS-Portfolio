SELECT * FROM
[Portfolio Project]..['Covid deaths']
WHERE continent is NOT NULL
ORDER BY 3,4

SELECT * FROM
[Portfolio Project]..['Covid Vaccinations']
ORDER BY 3,4; 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM
[Portfolio Project]..['Covid deaths']
order by 1,2 

--Looking at Total Cases Vs Total Deaths
--Mortality rate of covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM
[Portfolio Project]..['Covid deaths']
WHERE location='India'
and continent is NOT NULL
order by 1,2 

--Looking at total cases and population
--Show infection percentage
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS infection_percentage
FROM
[Portfolio Project]..['Covid deaths']
WHERE location='India'
order by 1,2 

--Highest Infection Rate
SELECT Location, population, MAX(total_cases) as Highest_Infected, MAX((total_cases/population)*100) AS infection_percentage
FROM
[Portfolio Project]..['Covid deaths']
GROUP BY location, population
order by 4 DESC

--Breaking things down by continent

--Continent having highest deaths
SELECT continent, MAX(cast(total_deaths as int)) as Total_Death
FROM
[Portfolio Project]..['Covid deaths']
WHERE continent is NOT NULL
GROUP BY continent
order by 2 DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 
as Death_percentage
FROM
[Portfolio Project]..['Covid deaths']
--WHERE location='India'
WHERE continent is NOT NULL
--GROUP BY date
order by 1,2

--Vaccination Table join with death table:

SELECT * FROM 
[Portfolio Project]..['Covid deaths'] dea
Join [Portfolio Project]..['Covid Vaccinations'] vac
	ON dea.location=vac.location and dea.date=vac.date

-- Looking at total population Vs total vaccinated

--USE CTE

With popvsvac (continent, location, date, population, new_vaccinations, Rolling_Total_vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_Total_vaccinations
FROM 
[Portfolio Project]..['Covid deaths'] dea
Join [Portfolio Project]..['Covid Vaccinations'] vac
	ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is NOT NULL
)
SELECT *, (Rolling_Total_vaccinations/population)*100 as Percentage_vaccinated FROM popvsvac

--TEMP TABLE

DROP Table IF exists #percentpopvac
CREATE TABLE #percentpopvac(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric,
new_vaccinations numeric,
Rolling_Total_vaccinations numeric
)
Insert INTO #percentpopvac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_Total_vaccinations
FROM 
[Portfolio Project]..['Covid deaths'] dea
Join [Portfolio Project]..['Covid Vaccinations'] vac
	ON dea.location=vac.location and dea.date=vac.date
--WHERE dea.continent is NOT NULL

SELECT *, (Rolling_Total_vaccinations/population)*100 as Percentage_vaccinated FROM #percentpopvac ORDER BY 1,2

--Creating View for visualisations

CREATE VIEW perppopvac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_Total_vaccinations
FROM 
[Portfolio Project]..['Covid deaths'] dea
Join [Portfolio Project]..['Covid Vaccinations'] vac
	ON dea.location=vac.location 
	and dea.date=vac.date
WHERE dea.continent is NOT NULL

 --View
SELECT * FROM perppopvac