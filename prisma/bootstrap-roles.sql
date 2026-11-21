-- Jalankan oleh administrator PostgreSQL, konek ke database aplikasi.
-- Contoh: psql "$MIGRATION_DATABASE_URL" -v app_password='...' -v migrator_password='...' -f prisma/bootstrap-roles.sql
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'bioscoop_app') THEN
    CREATE ROLE bioscoop_app LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'bioscoop_migrator') THEN
    CREATE ROLE bioscoop_migrator LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
  END IF;
END $$;
ALTER ROLE bioscoop_app PASSWORD :'app_password';
ALTER ROLE bioscoop_migrator PASSWORD :'migrator_password';
GRANT CONNECT ON DATABASE bioscoop TO bioscoop_app, bioscoop_migrator;
GRANT USAGE, CREATE ON SCHEMA public TO bioscoop_migrator;
GRANT bioscoop_app TO bioscoop_migrator;
