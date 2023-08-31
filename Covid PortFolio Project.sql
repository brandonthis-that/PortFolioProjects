Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Selecting Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at the total cases vs the total deaths & death percentage/ probability

	Select Location, date, total_cases,total_deaths, (total_deaths/	total_cases)	*100 as DeathPercentage 
	From PortfolioProject..CovidDeaths
	Where location like '%kenya%'
	order by 1,2
	-- Changing column data type
	--ALTER TABLE [dbo].[CovidDeaths]
	--ALTER COLUMN [total_cases] FLOAT
	--Go

	-- Looking at the Total Cases vs Population
	-- Shows percentage of population with covid
	Select Location, date,population, total_cases, (total_cases/population)	*100 as PercentageWithCovid 
	From PortfolioProject..CovidDeaths
	Where location like '%kenya%'
	order by 1,2

	-- Looking at countries with the highest infection rate according to population
	Select Location, population, MAX(total_cases) HighestInfectionCount	, MAX((total_cases/population))*100 as PercentageInfected 
	From PortfolioProject..CovidDeaths
	--Where location like '%kenya%'
	GROUP BY Location, population
	order by PercentageInfected desc

	-- Showing the countries with the highest deathcounts
	Select Location, MAX(Total_deaths) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	--Where location like '%kenya%'
	Where continent is not null
	GROUP BY Location
	order by TotalDeathCount desc

	-- By continent
	Select continent, MAX(Total_deaths) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	--Where location like '%kenya%'
	Where continent is  not null
	GROUP BY continent
	order by TotalDeathCount desc
	

	ALTER TABLE [dbo].[CovidVaccinations]
	ALTER COLUMN [new_vaccinations] FLOAT
	Go

	-- Looking at total population vs vaccination
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations ) OVER (partition by dea.location order by dea.location, dea.date)	as CumulativePeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
	where dea.continent is not null
	order by 2,3

	--   CTE 	

	With PopvsVac (Continent, location, date, population, new_vaccinations, CumulativePeopleVaccinated)
	as 
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations ) OVER (partition by dea.location order by dea.location, dea.date)	as CumulativePeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
	where dea.continent is not null
	-- order by 2,3
	)
	Select *, (CumulativePeopleVaccinated/population)*100
	From PopvsVac

	-- TEMP TABLE

	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar (255),
	location nvarchar (255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	CumulativePeopleVaccinated numeric
	)

	INSERT INTO	#PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations ) OVER (partition by dea.location order by dea.location, dea.date)	as CumulativePeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
	where dea.continent is not null
	-- order by 2,3

	Select *, (CumulativePeopleVaccinated/population)*100
	From #PercentPopulationVaccinated