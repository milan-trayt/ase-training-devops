-- Revoke privileges from 'public' role
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON DATABASE trayt FROM PUBLIC;

-- Create roles
CREATE ROLE readonly INHERIT;
CREATE ROLE application INHERIT;
CREATE ROLE sqlmigration INHERIT;

-- Schema Migration role
GRANT CREATE ON DATABASE trayt TO sqlmigration;


GRANT SELECT, INSERT, UPDATE, DELETE, TRIGGER, TRUNCATE, REFERENCES ON ALL TABLES IN SCHEMA public TO sqlmigration;
GRANT EXECUTE ON ALL ROUTINES IN SCHEMA public TO sqlmigration;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO sqlmigration;

-- Read-only role
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;

-- Application role
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO application;
GRANT EXECUTE ON ALL ROUTINES IN SCHEMA public TO application;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO application;

-- Users creation
CREATE USER readonly_user;
CREATE USER application_user;
CREATE USER sqlmigration_user;

-- IAM Authentication
GRANT rds_iam TO readonly_user;
GRANT rds_iam TO application_user;
GRANT rds_iam TO sqlmigration_user;

-- Grant roles to users
GRANT readonly TO readonly_user;
GRANT application TO application_user;
GRANT sqlmigration TO sqlmigration_user;

-- Grant connect and usage to the users
GRANT CONNECT ON DATABASE trayt TO sqlmigration_user, application_user, readonly_user;
GRANT USAGE ON SCHEMA public TO sqlmigration_user, application_user, readonly_user;

-- Only sqlmigration user should be able to create on the schema
GRANT CREATE ON SCHEMA public TO sqlmigration_user;

-- Set the default schema for each role
ALTER ROLE sqlmigration_user IN DATABASE trayt SET search_path = 'public';
ALTER ROLE application_user IN DATABASE trayt SET search_path = 'public';
ALTER ROLE readonly_user IN DATABASE trayt SET search_path = 'public';

-- Set default privileges for future tables in the public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO sqlmigration_user, application_user;

-- Set default privileges for future sequences in the public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, USAGE ON SEQUENCES TO sqlmigration_user, application_user;

-- Set default privileges for future functions in the public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT EXECUTE ON FUNCTIONS TO sqlmigration_user, application_user;
-- Audit logging
CREATE ROLE rds_pgaudit;
CREATE EXTENSION PGAUDIT;
