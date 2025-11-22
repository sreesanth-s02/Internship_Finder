import sqlite3
import csv

# Path to your SQLite DB
DB_PATH = "database.db"

# Path to your CSV file
CSV_PATH = r"C:\Users\Test\Downloads\internship_offers_300.csv"

# Connect to the database
conn = sqlite3.connect(DB_PATH)
cursor = conn.cursor()

# Ensure the table exists
cursor.execute("""
CREATE TABLE IF NOT EXISTS internships (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    domains TEXT,
    skills TEXT,
    paid TEXT,
    duration TEXT,
    role TEXT,
    location TEXT,
    mode TEXT,
    prerequisites TEXT,
    stipend TEXT,
    other TEXT
)
""")

# Read the CSV and insert values
with open(CSV_PATH, newline='', encoding='utf-8') as csvfile:
    reader = csv.DictReader(csvfile)

    for row in reader:
        cursor.execute("""
            INSERT INTO internships 
            (name, domains, skills, paid, duration, role, location, mode, prerequisites, stipend, other)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            row.get("name"),
            row.get("domains"),
            row.get("skills"),
            row.get("paid"),
            row.get("duration"),
            row.get("role"),
            row.get("location"),
            row.get("mode"),
            row.get("prerequisites"),
            row.get("stipend"),
            row.get("other")
        ))

conn.commit()
conn.close()

print("Successfully imported all internship offers!")
