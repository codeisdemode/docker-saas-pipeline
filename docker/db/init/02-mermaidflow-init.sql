-- Create mermaidflow database
CREATE DATABASE mermaidflow;

-- Create mermaidflow user
CREATE USER mermaidflow WITH PASSWORD 'mermaidflow_password';

-- Grant privileges to mermaidflow user
GRANT ALL PRIVILEGES ON DATABASE mermaidflow TO mermaidflow;

\connect mermaidflow

-- Create schema and set as default for mermaidflow user
CREATE SCHEMA IF NOT EXISTS mermaidflow;
ALTER USER mermaidflow SET search_path TO mermaidflow;

-- Grant privileges on schema
GRANT ALL ON SCHEMA mermaidflow TO mermaidflow;

-- Create tables will be handled by the application 