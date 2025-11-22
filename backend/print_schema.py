import os
import sqlite3

# Automatically find the correct path (script safe)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "database.db")   # <-- your real DB

def print_schema():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    print(f"\n📌 Using database: {DB_PATH}\n")
    print("📌 Tables in database:\n")

    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()

    for (table_name,) in tables:
        print(f"=== {table_name} ===")

        cursor.execute(f"PRAGMA table_info({table_name});")
        columns = cursor.fetchall()

        for col in columns:
            col_name = col[1]
            col_type = col[2]
            pk = " [PK]" if col[5] == 1 else ""
            print(f" - {col_name} ({col_type}){pk}")

        print()

    conn.close()


if __name__ == "__main__":
    print_schema()
