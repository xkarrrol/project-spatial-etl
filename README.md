# Spatial ETL & Location Intelligence Pipeline

**Cel projektu**
Projekt został zrealizowany w ramach budowy portfolio. Głównym założeniem było pokazanie praktycznego wykorzystania pełnego obiegu danych przestrzennych w Pabianicach - od automatycznego pobierania surowej geometrii przez API (OpenStreetMap), przez jej transformację w Pythonie, aż po zaawansowaną analitykę przestrzenną wykonaną bezpośrednio na silniku bazy danych PostGIS.

---

<img width="3507" height="2480" alt="spatial_etl_result" src="https://github.com/user-attachments/assets/db6987e3-5c74-44d3-97bc-1a99cff22c6a" />

---

**Stack technologiczny:**
*   **Baza danych:** PostgreSQL + PostGIS (Docker)
*   **ETL:** Python (GeoPandas, OSMnx)
*   **Analityka przestrzenna:** PostGIS Spatial SQL
*   **Wizualizacja:** QGIS (bezpośrednie wczytywanie wyników zapytań SQL)

---

**Architektura rozwiązania:**
1.  **Extract:** Skrypty w Pythonie pobierają surowe dane wektorowe z OpenStreetMap (sieć drogowa i zabudowa).
2.  **Transform:** GeoPandas filtruje atrybuty, standaryzuje typy danych (ominięcie zagnieżdżonych list z OSM) i transformuje układy współrzędnych do lokalnego systemu metrycznego (EPSG:2180).
3.  **Load:** Wypchnięcie oczyszczonych ramek danych do izolowanego kontenera PostgreSQL/PostGIS.
4.  **Analyze:** Wykonywanie operacji (np. `ST_Buffer`, `ST_Intersects`, `ST_Area`).

---

**Przykładowy Spatial Join:**
```sql
WITH strefa_pilsudskiego AS (
    SELECT ST_Buffer(ST_Union(geometry), 200) AS bufor_200m
    FROM drogi_osm 
    WHERE name = 'Marszałka Józefa Piłsudskiego'
)
SELECT 
    row_number() OVER () AS id,
    b.building AS kategoria,
    b.geometry
FROM budynki_osm b
JOIN strefa_pilsudskiego sp
    ON ST_Intersects(b.geometry, sp.bufor_200m);
```

---

**Dane wejściowe:**
* **Zbiór:** Sieć drogowa oraz zabudowa miejska – obszar: Pabianice, Polska.
* **Źródło bazowe:** OpenStreetMap (OSM).
* **Metoda ekstrakcji:** Dynamiczne zapytania do Overpass API realizowane przez bibliotekę `osmnx`.
