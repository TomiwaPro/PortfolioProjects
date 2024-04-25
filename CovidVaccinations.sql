Select*
From PortfolioProject..CovidDeath
Where continent is not null
Order by 3, 4

--Select*
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

--Select Data that we re going to be using

select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath
Where continent is not null
Order by 1, 2

--Looking at the Total Cases vs Total Death
--Shows likelihood of dying if you contact covid in the United State

select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
From PortfolioProject..CovidDeath
Where Location like '%state%' 
And continent is not null
Order by 1,2

--Looking at the Total Cases vs Population
--shows what percentage of population got covid in Nigeria

select Location, Date, population, total_cases,
     (total_cases/population) * 100 AS PercentPopulationInfected
From PortfolioProject..CovidDeath
Where Location like '%state%' and continent is not null
Order by 1,2


--Looking that country with highest infection rate compared to polpulation

select Location, population,total_cases, MAX(total_cases) as HigestInfectionCount,
     max(total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeath
--Where Location like '%state%'
Where continent is not null
Group by Location, population, total_cases
Order by PercentPopulationInfected desc

--showing the country with the highest count per population

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
--Where Location like '%state%'
Where continent is not null
Group by Location
Order by  TotalDeathCount desc

--Let's break things down by continent
--Showing the continent with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
--Where Location like '%state%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS

select Date, SUM(new_cases)  total_cases, SUM(cast(new_deaths as int)) total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
--Where Location like '%state%' 
where continent is not null and new_cases <> 0 and new_deaths <> 0 
Group by date
Order by 1,2

--Looking at Total Population vs Vaccinations
--
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--Or like this--,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location)
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent,location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--Or like this--,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location)
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #percentpopulationvaccinatinated
Create Table #percentpopulationvaccinatinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #percentpopulationvaccinatinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #percentpopulationvaccinatinated


--Creating view to store data for later visualizations

Create view percentpopulationvaccinatinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select*
from percentpopulationvaccinatinated