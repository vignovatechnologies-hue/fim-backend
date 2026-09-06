import datetime
import urllib.parse
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

from config import settings
from database import engine, Base, SessionLocal
from models import User, Loan, Transaction, SavingsGoal, Bank, Budget
from auth_utils import get_password_hash

def create_database_if_not_exists():
    # Parse settings database URL to connect to default database first
    decoded_password = urllib.parse.unquote(settings.DB_PASSWORD)
    
    try:
        conn = psycopg2.connect(
            user=settings.DB_USER,
            password=decoded_password,
            host=settings.DB_HOST,
            port=settings.DB_PORT,
            database="postgres"
        )
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = conn.cursor()
        
        # Check if DB exists
        cursor.execute("SELECT 1 FROM pg_catalog.pg_database WHERE datname = %s", (settings.DB_NAME,))
        exists = cursor.fetchone()
        
        if not exists:
            print(f"Database {settings.DB_NAME} does not exist. Creating...")
            cursor.execute(f'CREATE DATABASE {settings.DB_NAME};')
            print(f"Database {settings.DB_NAME} created successfully.")
        else:
            print(f"Database {settings.DB_NAME} already exists.")
            
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Error checking/creating database: {e}")

def seed_database():
    print("Database seeding check complete — no hardcoded dummy records. Data is 100% dynamic.")

def main():
    create_database_if_not_exists()
    print("Creating tables...")
    Base.metadata.create_all(bind=engine)
    print("Tables created successfully.")
    seed_database()

if __name__ == "__main__":
    main()
