Select Location, date, total_cases, total_deaths, Round(((total_deaths / total_cases) * 100) , 5) as deathpercentage
From CovidDeaths
Where location = 'Russia'
order by 1,2

Select Location, date, total_cases, population, Round(((total_cases / population) * 100) , 5) as CasestoPopulation
From CovidDeaths
Where location = 'Russia' and continent is not null
order by 1,2

Select Location, max(total_cases) as max_case, population, Round(((max(total_cases) / population) * 100) , 5) as Infection_Rate
From CovidDeaths
Where continent is not null
group by location, population
order by 4 desc

Select Location, max(cast(total_deaths as int)) as max_death, population, Round(((max(total_deaths) / population) * 100) , 5) as Death_Rate
From CovidDeaths
Where continent is not null
group by location, population
order by 2 desc


Select *
From PortfolioProject..CovidDeaths
order by 3,4

Select continent, max(cast(total_deaths as int)) as max_death
From CovidDeaths
Where continent is not null
group by continent
order by 2 desc

Select Location, max(cast(total_deaths as int)) as max_death, population, Round(((max(cast(total_deaths as int)) / population) * 100) , 5) as Death_Rate
From CovidDeaths
Where continent is null
group by location, population
order by 2 desc

Select continent, max(cast(total_deaths as int)) as max_death
From CovidDeaths
Where continent is not null
group by continent
order by 2 desc

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUm(New_cases) * 100 as DeathPercentage
From CovidDeaths
Where continent is not null
Group by date
order by 1,2 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUm(New_cases) * 100 as DeathPercentage
From CovidDeaths
Where continent is not null
--Group by date
order by 1,2


-- CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, SumOfPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.date) as SumOfPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3
)
Select * , (SumOfPeopleVaccinated / Population) * 100
From PopvsVac


--Temp


Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
SumOfPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.date) as SumOfPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select * , (SumOfPeopleVaccinated / Population) * 100
From #PercentPopulationVaccinated 



--

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.date) as SumOfPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select *
From PercentPopulationVaccinated
