# Docker Setup & Reproducibility (Bonus Task)

## Step-by-Step Reproduction Guide

To easily spin up the database and reproduce this environment locally, follow these steps:

1. **Docker Compose**: Simply run the following command in the project root:
   ```bash
   docker compose up -d
   ```
   This will download the `gvenzl/oracle-xe:21-slim` image and start an Oracle XE database instance.

2. **Automated Seeding**: 
   The `docker-compose.yml` file is configured to mount `TABLE_CREATION_SCRIPTS.sql` into the `/container-entrypoint-initdb.d/` directory. Oracle automatically executes this script upon initialization, meaning the `TARIFFS`, `CUSTOMERS`, and `MONTHLY_STATS` tables (along with their constraints and indexes) are instantly created.

3. **Data Import & Verification**: 
   Connect to the database via DBeaver using the following credentials:
   - **Host:** `localhost`
   - **Port:** `1521`
   - **Service Name:** `telco`
   - **Username:** `telco_user`
   - **Password:** `telco_pass`
   
   Once connected, the provided `.csv` files can be imported seamlessly via DBeaver's "Import Data" utility or loaded using Oracle SQL*Loader (`sqlldr`).

---

## Screenshots

*(Screenshots of Docker Desktop showing the container running, and DBeaver showing the active connection and tables can be placed here.)*

![Docker Desktop Running Container](<insert image link here>)
![DBeaver Tables View](<insert image link here>)
