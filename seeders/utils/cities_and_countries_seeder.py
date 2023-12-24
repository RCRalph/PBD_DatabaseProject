import os, pyodbc, json

def seed_cities_and_countries(cursor: pyodbc.Cursor, schema: str):
    print("Seeding cities and countries...")

    files = [item for item in os.listdir("seeders/data/cities") if item.endswith(".geojson")]

    cursor.execute(f"""
        SELECT id, name
        FROM {schema}.countries
    """)

    countries = cursor.fetchall()

    country_ids = list(map(lambda x: x[0], countries))
    country_names = list(map(lambda x: x[1], countries))

    for filename in files:
        country_name = filename.split(".")[0]

        if country_name not in country_names:
            cursor.execute(f"""
                INSERT INTO {schema}.countries (name)
                VALUES (?)
            """, country_name)

            cursor.execute("SELECT @@IDENTITY;")
            result = cursor.fetchone()
            if result is None:
                raise ValueError()

            country_id = result[0]
        else:
            country_id = country_ids[country_names.index(country_name)]

        with open(f"seeders/data/cities/{filename}") as file:
            data = json.load(file)

            cities = set(map(
                lambda x: x["properties"]["name"], # type: ignore
                filter(lambda x: "name" in x["properties"], data["features"]) # type: ignore
            ))

            cursor.execute(f"""
                SELECT id, name
                FROM {schema}.cities
            """)

            print(country_name, len(cities))
            cities_in_db = cursor.fetchall()

            for city_name in sorted(cities):
                if (country_id, city_name) not in cities_in_db:
                    cursor.execute(f"""
                        INSERT INTO {schema}.cities (country_id, name)
                        VALUES (?, ?)
                    """, country_id, city_name)
