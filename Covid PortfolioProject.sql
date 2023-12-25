Use portfolioproject;
CREATE TABLE PercentPopulationVaccinated 
(
continent VARCHAR(255), 
location VARCHAR(255), 
date DATETIME, 
population NUMERIC, 
new_vaccinations NUMERIC,
rollingPeopleVaccinated NUMERIC
);

-- Insert data into the table
INSERT INTO PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM
    portfolioproject.coviddeaths dea
JOIN
    portfolioproject.covidvaccinactions vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

-- Select from the table with the calculated percentage
SELECT *,
(rollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;

-- creating view to store data for later visualizations
DROP VIEW IF EXISTS percentpopulationvaccinated_View;
Create view PercentageVaccinated_View AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS rollingPeopleVaccinated
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinactions vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

select * 
from PercentPopulationVaccinated;