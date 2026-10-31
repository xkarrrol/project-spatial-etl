-- Ten plik to zbiór wszystkich zapytań SQL, które napisano w celu wykoniania projektu

-- 1. Agregacja i statystyki drogowe: Łączna długość dróg w kilometrach według typu
SELECT 
    highway AS kategoria_drogi,
    COUNT(*) AS liczba_segmentow,
    ROUND(CAST(SUM(ST_Length(geometry)) / 1000 AS numeric), 2) AS suma_dlugosci_km
FROM drogi_osm
GROUP BY highway
ORDER BY suma_dlugosci_km DESC;

-- 2. Zaawansowane filtrowanie geometryczne: Top 10 najdłuższych segmentów ulic
SELECT 
    name AS ulica,
    highway AS kategoria_drogi,
    ROUND(CAST(ST_Length(geometry) AS numeric), 2) AS dlugosc_metry
FROM drogi_osm
WHERE name IS NOT NULL AND name != 'None'
ORDER BY ST_Length(geometry) DESC
LIMIT 10;

-- 3. Złączenie przestrzenne: Ulice przecinające 200-metrowy bufor
WITH strefa_pilsudskiego AS (
    SELECT ST_Union(geometry) AS pelna_geometria
    FROM drogi_osm 
    WHERE name = 'Marszałka Józefa Piłsudskiego'
)
SELECT DISTINCT 
    d.name AS ulica_w_zasięgu,
    d.highway AS typ_drogi,
    d.geometry
FROM drogi_osm d
JOIN strefa_pilsudskiego AS sp
    ON ST_Intersects(d.geometry, ST_Buffer(sp.pelna_geometria, 200))
WHERE d.name IS NOT NULL
    AND d.name != 'Marszałka Józefa Piłsudskiego'
    AND d.name != 'None'
ORDER BY d.name;

-- 4. Agregacja powierzchniowa: Łączna powierzchnia zabudowy w buforze
WITH strefa_pilsudskiego AS (
    SELECT ST_Buffer(ST_Union(geometry), 200) AS bufor_200m
    FROM drogi_osm 
    WHERE name = 'Marszałka Józefa Piłsudskiego'
)
SELECT 
    b.building AS kategoria_zabudowy,
    COUNT(*) AS liczba_budynkow,
    ROUND(CAST(SUM(ST_Area(b.geometry)) AS numeric), 2) AS laczna_powierzchnia_m2
FROM budynki_osm b 
JOIN strefa_pilsudskiego sp
    ON ST_Intersects(b.geometry, sp.bufor_200m)
GROUP BY b.building
ORDER BY laczna_powierzchnia_m2 DESC;

-- 5. Przygotowanie warstwy dla QGIS
WITH strefa_pilsudskiego AS (
    SELECT ST_Buffer(ST_Union(geometry), 200) AS bufor_200m
    FROM drogi_osm 
    WHERE name = 'Marszałka Józefa Piłsudskiego'
)
SELECT 
    row_number() OVER () AS id,
    b.building AS kategoria,
    b.name AS nazwa,
    b.geometry
FROM budynki_osm b
JOIN strefa_pilsudskiego sp
    ON ST_Intersects(b.geometry, sp.bufor_200m);