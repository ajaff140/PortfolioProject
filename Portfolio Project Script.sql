
select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject.dbo.CovidVacinations
--order by 3,4

--Data that is going to be used

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2;

--Total cases vs Total Deaths--
--Fatality percentage if you contract Covid--

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location = 'United Kingdom'
order by 1,2;

--Total cases vs population--
select Location, date, total_cases, population, (total_cases/population)*100 as PercentpopulationInfected
from PortfolioProject.dbo.CovidDeaths
where location = 'United Kingdom'
order by 1,2;

--Looking at countries with highest infection rates compared to population--
select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentpopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location = 'United Kingdom'
Group by Location, population
order by PercentpopulationInfected desc


--Showing countries with the highest death count per population--
select Location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location = 'United Kingdom'
where continent is not null
Group by Location
order by TotalDeathCount desc


--Continent--
select continent, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location = 'United Kingdom'
where continent is not null
Group by continent 
order by TotalDeathCount desc

--More Accurate results--
select location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location = 'United Kingdom'
where continent is null
Group by location
order by TotalDeathCount desc

--Total Population vs Vacinations--

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
, --(RollingPeopleVaccinated/population)*100  
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 


--CTE--
with popvsvac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
, --(RollingPeopleVaccinated/population)*100  
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
select*, (RollingPeopleVaccinated/population)*100 
from popvsvac 

--Temp Table--
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
, --(RollingPeopleVaccinated/population)*100  
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Create View--

CREATE VIEW PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
, --(RollingPeopleVaccinated/population)*100  
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 
