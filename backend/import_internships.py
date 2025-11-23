import os
import sqlite3
import csv

# ---------------------------------------------------------
# 1) Locate the SAME database used by app.py
# ---------------------------------------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "database.db")

# Optional CSV file (if you ever want to use one)
CSV_PATH = os.path.join(BASE_DIR, "internship_offers_300.csv")


def ensure_table(cursor):
  """Create internships table if it does not exist."""
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


def insert_from_csv(cursor):
  """Try to insert data from CSV if the file exists. Returns True if used."""
  if not os.path.exists(CSV_PATH):
    print(f"⚠ No CSV found at: {CSV_PATH}")
    return False

  print(f"📄 Importing internships from CSV: {CSV_PATH}")

  with open(CSV_PATH, newline="", encoding="utf-8") as csvfile:
    reader = csv.DictReader(csvfile)
    rows = list(reader)

  if not rows:
    print("⚠ CSV is empty, skipping.")
    return False

  for row in rows:
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
      row.get("other"),
    ))

  print(f"✅ Imported {len(rows)} internships from CSV.")
  return True


def insert_sample_data(cursor):
  """Insert a small set of sample internships (used if no CSV)."""
  print("📦 Inserting sample internships into database...")

  sample_internships = [
    {
      "name": "DataForge Labs",
      "domains": "Data Science, Machine Learning",
      "skills": "Python, Pandas, SQL, TensorFlow",
      "paid": "Yes",
      "duration": "3 months",
      "role": "Data Science Intern",
      "location": "Chennai",
      "mode": "onsite",
      "prerequisites": "Strong Python skills and curiosity to explore data.",
      "stipend": "₹15000",
      "other": "Certificate, LOR, chance for full-time offer."
    },
    {
      "name": "FinTrack",
      "domains": "Data Science, Analytics",
      "skills": "Python, SQL, Tableau",
      "paid": "Yes",
      "duration": "2–4 months",
      "role": "Data Analyst Intern",
      "location": "Remote",
      "mode": "remote",
      "prerequisites": "Basic statistics and good communication.",
      "stipend": "₹13000",
      "other": "Flexible timings, remote-first culture."
    },
    {
      "name": "PixelCraft Studios",
      "domains": "Web Development",
      "skills": "HTML, CSS, JavaScript, React",
      "paid": "Yes",
      "duration": "3 months",
      "role": "Frontend Web Intern",
      "location": "Bengaluru",
      "mode": "onsite",
      "prerequisites": "Basic React knowledge and small portfolio.",
      "stipend": "₹10000",
      "other": "Work with designers and senior devs."
    },
    {
      "name": "CloudNova",
      "domains": "Cloud Computing",
      "skills": "AWS, Docker, CI/CD",
      "paid": "No",
      "duration": "2 months",
      "role": "Cloud & DevOps Intern",
      "location": "Hyderabad",
      "mode": "remote",
      "prerequisites": "Linux basics and networking concepts.",
      "stipend": "0",
      "other": "Hands-on deployments on AWS."
    },
    {
      "name": "SecureGate",
      "domains": "Cybersecurity",
      "skills": "Python, Kali Linux, Burp Suite",
      "paid": "Yes",
      "duration": "3 months",
      "role": "Cybersecurity Intern",
      "location": "Pune",
      "mode": "onsite",
      "prerequisites": "Basics of networks and web apps.",
      "stipend": "₹8000",
      "other": "Shadow senior security engineers on audits."
    },
  ]

  for row in sample_internships:
    cursor.execute("""
      INSERT INTO internships
      (name, domains, skills, paid, duration, role, location, mode, prerequisites, stipend, other)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
      row["name"],
      row["domains"],
      row["skills"],
      row["paid"],
      row["duration"],
      row["role"],
      row["location"],
      row["mode"],
      row["prerequisites"],
      row["stipend"],
      row["other"],
    ))

  print(f"✅ Inserted {len(sample_internships)} sample internships.")


def main():
  print(f"\n📌 Using database: {DB_PATH}")
  conn = sqlite3.connect(DB_PATH)
  cursor = conn.cursor()

  ensure_table(cursor)

  # Clear existing data if you want a fresh import each time
  cursor.execute("DELETE FROM internships")

  # 1) Try CSV
  used_csv = insert_from_csv(cursor)

  # 2) If no CSV or error, fall back to sample data
  if not used_csv:
    insert_sample_data(cursor)

  conn.commit()
  conn.close()
  print("\n🎉 Done! Internships are now in the database.\n")


if __name__ == "__main__":
  main()
