--COVID 19 DATA EXPLORATION

--Skills Used: Aggregate Functions,Converting Data Types, Joins, CTE's, Temp Tables, Windows Functions, Views



Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4



-- Selecting data 

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null
Order  by 1,2



-- Total Cases vs Total Deaths
-- Shows likeihood of dying if you are tested covid positive in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where Location = 'United Kingdom'
Where continent is not null
Order  by 1,2



-- Total cases vs Population
-- Shows what percentage of population got infected by covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopluationInfected
From CovidDeaths
--Where Location = 'United Kingdom'
Order  by 1,2



-- Countries with highest infection rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopluationInfected
From CovidDeaths
--Where Location = 'United Kingdom'
Group By Location, population
Order  by PercentPopluationInfected desc



-- Countries with Highest Death Count per population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where Location = 'United Kingdom'
Where continent is not null
Group By Location
Order  by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT


-- Continents with highest death counts per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where Location = 'United Kingdom'
Where continent is not null
Group By continent
Order  by TotalDeathCount desc



--  GLOBAL NUMBERS - Death percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where Location = 'United Kingdom'
Where continent is not null	
--Group By date
Order  by 1,2

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where Location = 'United Kingdom'
Where continent is not null	
Group By date
Order  by 1,2



--Total Population vs Vaccination
--Percentage of population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/Population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3



--Using CTE to perform calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/Population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac




-- TEMP TABLE 
-- Using temp table to perform calculation on Partition By in previous query 


Drop Table if exists #PercentagePopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,ROllingPeopleVaccinated/Population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating View to store data 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,ROllingPeopleVaccinated/Population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated






