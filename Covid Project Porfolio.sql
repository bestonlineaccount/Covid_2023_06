/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


select *
from PortfolioProject..CovidDeaths
Where continent is NOT NULL
order by 3, 4

select *
from PortfolioProject..CovidVaccinations
order by 3, 4


-- Select Data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country


select location, date, total_cases, total_deaths, CAST(total_deaths as Decimal)/CAST (total_cases as Decimal)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2



--Total Cases vs Population
--shows what percentage pf population got Covid

select location, date, population, total_cases,  CAST(total_cases as Decimal)/CAST (population as Decimal)*100 as PercentagePopulation
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Order by 1,2


--Countries with Highest Infection Rate campared to Population
select Location, Population, date,  MAX(total_cases) as HighestInfectionCount,  
	Max(CAST(total_cases as Decimal)/CAST(population as Decimal))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population, date
Order by PercentagePopulationInfected desc



--Countries with highest Death Count per Population

Select location, Max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is NOT NULL
Group by location
Order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

Select continent, Max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is Not NULL
Group by continent
Order by TotalDeathCount desc


-- Continents with highest death counts per population
Select continent as Location, Max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is Not NULL
Group by continent
Order by TotalDeathCount desc


-- Global Numbers
select date, SUM(new_cases), SUM(new_deaths), 
	SUM(new_deaths)/NULLIF(SUM(cast(new_cases as decimal)),0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

-- Total Global Numbers
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
	SUM(new_deaths)/NULLIF(SUM(cast(new_cases as decimal)),0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2




--Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,	SUM(Cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinationed
--,	(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3




-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,	SUM(Cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinationed
--,	(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visulization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,	SUM(Cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinationed
--,	(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
from PercentPopulationVaccinated

