import geopandas as gpd
import osmnx as ox
from sqlalchemy import create_engine

ox.settings.overpass_endpoint = "https://overpass.kumi.systems/api/interpreter"
engine = create_engine('postgresql+psycopg2://gis_user:gis_password@localhost:5433/spatial_db')

print("Pobieranie poligonów budynkow")
gdf_buildings = ox.features_from_place("Pabianice, Poland", {'building': True})
gdf_buildings = gdf_buildings.to_crs(epsg=2180)

gdf_buildings = gdf_buildings.reset_index()

gdf_buildings = gdf_buildings[gdf_buildings.geometry.type.isin(['Polygon', 'MultiPolygon'])]

kolumny = ['osmid', 'name', 'building', 'geometry']

gdf_buildings =gdf_buildings[gdf_buildings.columns.intersection(kolumny)]

for col in gdf_buildings.columns:
    if col != 'geometry':
        if gdf_buildings[col].apply(type).eq(list).any():
            gdf_buildings = gdf_buildings[col].astype(str)

print("Ładowanie do bazy PostGIS...")
gdf_buildings.to_postgis(
    'budynki_osm', 
    con=engine, 
    if_exists='replace', 
    index=False
)
print("Zakończono.")
