
--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT 
	Location, date,total_cases, new_cases, total_deaths, population
FROM
	PortfolioProject..CovidDeaths
ORDER BY
	1,2;

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
--SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
SELECT 
	Location, date,total_cases, total_deaths,(total_deaths / total_cases)*100 AS Percentage_of_Deaths
FROM
	PortfolioProject..CovidDeaths
ORDER BY
	1,2;

--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

SELECT 
	Location, date,Population, total_cases,(total_cases/ population)*100 AS Percentage_of_Cases
FROM
	PortfolioProject..CovidDeaths
WHERE
	location like '%Turkey%'
ORDER BY
	1,2;

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT 
	Location,population, MAX(total_cases) AS HIGHEST_INFECTION_COUNT,MAX((total_cases/ population))*100 AS Percentage_of_Population_Infected
FROM
	PortfolioProject..CovidDeaths
GROUP BY
	Location,population
ORDER BY
	Percentage_of_Population_Infected DESC;


-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
-- WE NEED TO CAST TOTAL_DEATHS COLUMN INTO INT

SELECT 
	Location, MAX(cast(Total_deaths as int)) as Total_Deaths_Count
FROM
	PortfolioProject..CovidDeaths
WHERE	
	continent IS NOT NULL
GROUP BY
	Location
ORDER BY
	Total_Deaths_Count DESC;

-- EXPLORING THINGS BY CONTINENT

SELECT 
	location, MAX(cast(Total_deaths as int)) as Total_Deaths_Count
FROM
	PortfolioProject..CovidDeaths
WHERE	
	continent IS NULL
GROUP BY
	location
ORDER BY
	Total_Deaths_Count DESC;

-- SHOWING CONTINENTS WITH THE HIGHEST DEATCH COUNT PER POPULATION

SELECT 
	continent, MAX(cast(Total_deaths as int)) as Total_Deaths_Count
FROM
	PortfolioProject..CovidDeaths
WHERE	
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	Total_Deaths_Count DESC;

-- INVESTIGATE THE DEATH PERCENTAGE DAY BY DAY IN THE WORLD

SELECT 
	date,SUM(new_cases) AS total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 AS Percentage_of_Deaths
FROM
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY
	date
ORDER BY
	1;


-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM 
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date= vac.date
WHERE
	dea.continent IS NOT NULL
ORDER BY
	1,2,3;


-- USING CTE

With PopVsVac (Continent, Location, Date,Population, New_Vaccinations, RollingPeopleVaccinated)
as(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
FROM 
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date= vac.date
WHERE
	dea.continent IS NOT NULL
--ORDER BY
	--1,2,3
)

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopVsVac;


-- CREATING A TEMP TABLE AND INVESTIGATING VACCINATIONS RATE 

--DROP Table if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
FROM 
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date= vac.date
WHERE
	dea.continent IS NOT NULL


SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated;


--CREATING VIEW TO STORE DATA FOR LATER PURPOSES

CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
FROM 
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date= vac.date
WHERE
	dea.continent IS NOT NULL


