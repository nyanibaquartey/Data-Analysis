/*
COVID 19 DATA EXPLORATION

Skills Used: Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions,
			Creating Views, Converting Data Types

*/

----View Data

--SELECT *
--FROM PortfolioProjects.dbo.CovidDeaths$
--WHERE continent IS NOT NULL
--ORDER BY 3, 4;



----Select data to start exploring

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProjects.dbo.CovidDeaths$
--WHERE continent IS NOT NULL
--ORDER BY location, date




----DEATH PERCENTAGE FOR GHANA

--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
--FROM PortfolioProjects.dbo.CovidDeaths$
--WHERE location = 'Ghana' AND continent IS NOT NULL
--ORDER BY location, date




----INFECTION PERCENTAGE FOR GHANA

--SELECT location, date, population, CAST(total_cases AS INT) AS case_count, (CAST(total_cases AS INT)/population)*100 AS infection_percentage
--FROM PortfolioProjects.dbo.CovidDeaths$
--WHERE location = 'Ghana' AND continent IS NOT NULL
--ORDER BY case_count DESC


--SELECT DISTINCT median_age
--FROM CovidDeaths$
--WHERE location = 'Ghana'

----TOTAL CASES VS POPULATION

--SELECT location, date, population, total_cases, (total_cases/population)*100 AS infection_percentage
--FROM PortfolioProjects.dbo.CovidDeaths$
--WHERE continent IS NOT NULL
--ORDER BY 1, 2 




----COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

--SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases)/population*100 AS percent_population_infected
--FROM PortfolioProjects.dbo.CovidDeaths$
--WHERE continent IS NOT NULL
--GROUP BY location, population, continent
--ORDER BY percent_population_infected DESC



--HIGHEST DEATH COUNT BY COUNTRY

--SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
--FROM PortfolioProjects.dbo.CovidDeaths$
--WHERE continent IS NOT NULL
--GROUP BY continent, location
--ORDER BY total_death_count DESC



----HIGHEST DEATH COUNT BY CONTINENT

--SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
--FROM PortfolioProjects.dbo.CovidDeaths$
--WHERE continent IS NOT NULL
--GROUP BY continent
--ORDER BY total_death_count DESC



--GLOBAL NUMBERS (GLOBAL DEATH PERCENTAGE)

--SELECT SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS INT)) AS total_death_cases,
--SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
--FROM PortfolioProjects.dbo.CovidDeaths$
--WHERE continent IS NOT NULL
--ORDER BY 1, 2



--POPULATIONS vs TOTAL COVID VACCINATIONS RECEIVED

--SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
--SUM(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION BY cd.Location ORDER BY cd.location, cd.Date) as people_vaccinated_rolling_total
--FROM CovidDeaths$ cd
--JOIN CovidVaccinations$ cv
--	ON cd.location = cv.location
--	AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL
--ORDER BY 2, 3




--CTE TO PERFORM CALCULATION ON WINDOW FUNCTION

--WITH PopVsVac (Continent, Location,Date, Population, New_Vaccinations, RollingPeopleVaccinated)
--AS
--(
--SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
--SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.Location ORDER BY cd.location, cd.Date) as people_vaccinated_rolling_total
--FROM CovidDeaths$ cd
--JOIN CovidVaccinations$ cv
--	ON cd.location = cv.location
--	AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL
--)

--SELECT *, (RollingPeopleVaccinated/Population)*100
--from PopVsVac




----ALTERNATIVE APPROACH WITH TEMP TABLE

--DROP TABLE IF EXISTS #PercentPopulationVaccinated
--CREATE TABLE #PercentPopulationVaccinated
--(
--Continent NVARCHAR(255),
--Location NVARCHAR(255),
--Date DATETIME,
--Population NUMERIC,
--New_vaccinations NUMERIC,
--RollingPeopleVaccinated NUMERIC
--)

--INSERT INTO #PercentPopulationVaccinated
--SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
--, SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.Location ORDER BY cd.Location, cd.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--FROM PortfolioProjects..CovidDeaths$ cd
--JOIN PortfolioProjects..CovidVaccinations$ cv
--	ON cd.location = cv.location
--	and cd.date = cv.date
--WHERE cd.continent IS NOT NULL


--SELECT *, (RollingPeopleVaccinated/Population)*100
--FROM #PercentPopulationVaccinated



---- VIEW TO BE VISUALIZED

--CREATE VIEW PercentPopulationVaccinated AS
--SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
--, SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.Location ORDER BY cd.location, cd.Date) as RollingPeopleVaccinated

--FROM PortfolioProjects..CovidDeaths$ cd
--JOIN PortfolioProjects..CovidVaccinations$ cv
--	ON cd.location = cv.location
--	AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL