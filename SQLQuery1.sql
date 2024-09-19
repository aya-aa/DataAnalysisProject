select * 
From PortfolioProject..CovidDeaths
order by 3,4 


--select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4 

-- Selecting Data 

select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2 


-- Total cases vs total deaths 
--Likelihood of dying contracting Covid
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location='Tunisia'
order by 1,2 


--Total cases vs Population

select Location, date, population, total_cases, total_deaths, (total_cases/population)*100 as PercentofPopulation
From PortfolioProject..CovidDeaths
where location='Tunisia'
order by 1,2 



-- Countries with Highest Infection Rate compared to Population

select Location, population, MAX(total_cases) as TotalInfectionCount ,  Max((total_cases/population))*100 as 
PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location='Tunisia'
Group by location, population
order by PercentPopulationInfected desc


--Countries with Highest Death Count per Population 

select Location,  MAX(cast(total_deaths as int )) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--where location='Tunisia'
where continent is not null
Group by location
order by  TotalDeathCount  desc


--DeathCountbyContinent

select location,  MAX(cast(total_deaths as int )) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--where location='Tunisia'
where continent is null
Group by location
order by  TotalDeathCount  desc


-- Showing continents with Highest death count per location

select continent,  MAX(cast(total_deaths as int )) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--where location='Tunisia'
where continent is not null
Group by continent
order by  TotalDeathCount  desc



-- Global Numbers 

select date, SUM(new_cases) as New_Cases, SUM(cast(new_deaths as int)) as new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 4 desc


select  SUM(new_cases) as New_Cases, SUM(cast(new_deaths as int)) as new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null



-- Joined tables

select * 
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM( convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 


-- USE CTE

with PopvcVac (continent, location, Date, population , new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM( convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select * , (RollingPeopleVaccinated/population)*100
From PopvcVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location varchar(255),
date datetime,
population numeric, 
new_vaccination numeric, 
RollingPeopleVaccinated numeric
)


Insert into  #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM( convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating view for data storage

DROP VIEW IF EXISTS PercentPopulationVaccinated;

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM( convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated