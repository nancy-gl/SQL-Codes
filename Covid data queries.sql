Select * 
From [dbo].[Covid-Deaths]
Order by 3,4

-- Selecting Data that we are going to use in our BI visualization
Select location, date, population, total_cases, new_cases, total_deaths
From [dbo].[Covid-Deaths]
Order by 1,2

-- Looking at total_cases and total_deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From [dbo].[Covid-Deaths]
Where location like '%states%'
	And continent is not null
Order by 1,2

-- Looking at the total_cases vs Population
Select location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
From [dbo].[Covid-Deaths]
--Where location like '%states%'
Order by 1,2

-- Looking at countries with highest infection rate
Select location, population, max(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as PercentPopulationInfected
From [dbo].[Covid-Deaths]
--Where location like '%states%'
Group by location, population
Order by 4 Desc

-- Countries with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathcount
From [dbo].[Covid-Deaths]
--Where continent is not null
Group by location
Order by TotalDeathcount Desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathcount
From [dbo].[Covid-Deaths]
Where continent is null
Group by location
Order by TotalDeathcount Desc

-- Breaking down by continent (might not be check) for highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathcount
From [dbo].[Covid-Deaths]
Where continent is not null
Group by continent
Order by TotalDeathcount Desc

-- Global Numbers
Select date, Sum(total_cases) as TotalCases, SUM(Cast(total_deaths as int)) as TotalDeaths
		,SUM(Cast(total_deaths as int))/Sum(total_cases)*100 as DeathRate
From [dbo].[Covid-Deaths]
Where continent is not null
Group by date
Order by 1

Select Sum(new_cases) as TotalCases, SUM(Cast(new_deaths as int)) as TotalDeaths
		,SUM(Cast(new_deaths as int))/Sum(new_cases)*100 as DeathRate
From [dbo].[Covid-Deaths]
Where continent is not null


-- Joining Vaccination table
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [dbo].[Covid-Deaths] dea
JOIN [dbo].[Covid-Vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Getting the running total per location
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		,SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.date) as RollingTotnewVaccination
From [dbo].[Covid-Deaths] dea
JOIN [dbo].[Covid-Vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Create CTE to find percentage of total people vaccinated
With PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingTotnewVaccination) 
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		,SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.date) as RollingTotnewVaccination
From [dbo].[Covid-Deaths] dea
JOIN [dbo].[Covid-Vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3   --cannot use order by clause in the CTE
)
Select * , (RollingTotnewVaccination/Population)*100 as PercentVaccinated
From PopsVac
--Where Location like 'Albania'

--Using Temp Table for the same
Drop Table if exists #PercentPopulationVaccinated  --drop table everytime you make a change in the query
Create Table #PercentPopulationVaccinated
(	Continent nvarchar(255),
	Location nvarchar(255), 
	date datetime, 
	Population numeric, 
	New_Vaccinations numeric,
	RollingTotnewVaccination numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		,SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.date) as RollingTotnewVaccination
From [dbo].[Covid-Deaths] dea
JOIN [dbo].[Covid-Vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select * , (RollingTotnewVaccination/Population)*100 as PercentVaccinated
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated
As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		,SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.date) as RollingTotnewVaccination
From [dbo].[Covid-Deaths] dea
JOIN [dbo].[Covid-Vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3