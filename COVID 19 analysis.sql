Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- add the where clause to filter contient is not null

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if contract covid in country
Select location, date, total_cases,total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2

--select distinct location from CovidDeaths
--order by 1

-- looking at total cases vs population
--show how many perecentage of people got infected
Select location, date, population, total_cases, (total_cases / population)*100 as PeopleInfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
order by 1,4

-- countries with highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfect, max((total_cases / population))*100 as PercentofPop
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location,population
order by PercentofPop desc


-- Countries with highest death count per population
--MAX (CAST(total_deaths as int))

Select location, MAX(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathcount desc


-- Break down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathcount desc


--Select location, MAX(cast(total_deaths as int)) as TotalDeathcount
--from PortfolioProject..CovidDeaths
----where location like '%india%'
--where continent is null
--group by location
--order by TotalDeathcount desc

-- showing continents with high death count per population

select continent, max(cast(total_deaths as int)) as TotDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotDeathCount desc



-- Global Numbers

Select date, sum(new_cases)--,total_deaths, (total_deaths / total_cases)*100 as PeopleInfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2


Select date, sum(new_cases) as TotCases, sum(new_deaths) as TotDeath, (sum(new_deaths)/sum(new_cases)*100) as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2

--Join two tables

Select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
 SUM(convert(int,vac.new_vaccinations)) OVER (Partition By dea.location)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
 SUM(convert(int,vac.new_vaccinations)) 
 OVER (Partition By dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
 SUM(convert(int,vac.new_vaccinations)) 
 OVER (Partition By dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



-- Temp table

-- use drop table if exists to delete and re execute an update of the table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date varchar(50),
Population int,
new_vaccinations varchar(50),
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
 SUM(convert(int,vac.new_vaccinations)) 
 OVER (Partition By dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Create views
drop view PercentPopulationVaccinated
create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
 SUM(convert(int,vac.new_vaccinations)) 
 OVER (Partition By dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

-- select view

select *
from PercentPopulationVaccinated

