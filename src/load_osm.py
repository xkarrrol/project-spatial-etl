import geopandas as gpd
import osmnx as ox
from sqlalchemy import create_engine

ox.settings.overpass_endpoint = "https://overpass.kumi.systems/api/interpreter"

engine = create_engine('postgresql+psycopg2://gis_user:gis_password@localhost:5433/spatial_db')
obszar = "Pabianice, Poland"
tagi = {"highway": True}

print(f"Pobieranie surowych danych wektorowych dla: {obszar}...")

gdf = ox.features_from_place(obszar, tagi)

gdf = gdf.to_crs(epsg=2180)

gdf = gdf[gdf.geometry.type=='LineString']
kolumny_docelowe = ['osmid', 'name', 'highway', 'maxspeed', 'geometry']

gdf = gdf[gdf.columns.intersection(kolumny_docelowe)]


for col in gdf.columns:
    if col != 'geometry':
        if gdf[col].apply(type).eq(list).any():
            gdf[col] = gdf[col].astype(str)

print("Inicjalizacja tabeli przestrzennej w bazie...")

gdf.to_postgis(
    name='drogi_osm',
    con=engine,
    if_exists='replace',
    index=False
)



print("Gotowe. Odśwież połączenie w DBeaverze (F5).")