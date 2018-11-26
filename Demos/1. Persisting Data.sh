
# https://dbafromthecold.com/2017/06/21/persisting-data-in-docker-containers-partone/

## Mounting volumes from the host


# create volume on host
sudo mkdir /sqldata



# run a container mapping the host volume
docker run -d -p 15777:1433 \
    -v /sqldata:/sqlserver \
        --env ACCEPT_EULA=Y --env SA_PASSWORD=Testing1122 \
            --name testcontainer1 \
                mcr.microsoft.com/mssql/server:2019-CTP2.1-ubuntu



# verify container is running
docker ps -a



# verify volume is mapped
docker exec -it testcontainer7 bash



# create a database within the container
mssql-cli -S 'localhost,15777' -U sa -P Testing1122

CREATE DATABASE [DatabaseA]
ON PRIMARY
    (NAME = N'DatabaseD', FILENAME = N'/sqlserver/DatabaseA.mdf')
LOG ON
    (NAME = N'DatabaseD_log', FILENAME = N'/sqlserver/DatabaseA_log.ldf');



# check the database is there
SELECT [name] FROM sys.databases;



# create a test table and insert some data
USE [DatabaseA];

CREATE TABLE dbo.TestTable1(ID INT);

INSERT INTO dbo.TestTable1(ID) SELECT TOP 100 1 FROM sys.all_columns;



# query the test table
SELECT COUNT(*) AS Records FROM dbo.TestTable1;



EXIT


           


# blow away container        
docker rm $(docker ps -q -a) -f



# confirm container is gone
docker ps -a



# verify database files still in host folder
find /sqldata -type f



# spin up another container with the volume mapped
docker run -d -p 15888:1433 \
    -v /sqldata:/sqlserver \
        --env ACCEPT_EULA=Y --env SA_PASSWORD=Testing1122 \
            --name testcontainer2 \
                mcr.microsoft.com/mssql/server:2019-CTP2.1-ubuntu



# verify container is running
docker ps -a



# check database is there
mssql-cli -S 'localhost,15888' -U sa -P Testing1122

SELECT [name] FROM sys.databases;

EXIT



# 'course not! We need to attach it, first check the files are there
docker exec -it testcontainer2 bash



# now attach the database
mssql-cli -S 'localhost,15888' -U sa -P Testing1122

CREATE DATABASE [DatabaseA] ON 
(FILENAME = '/sqlserver/DatabaseA.mdf'),
(FILENAME = '/sqlserver/DatabaseA_log.ldf') FOR ATTACH;



# check database is there
SELECT [name] FROM sys.databases;



# query the test table
USE [DatabaseD];

SELECT COUNT(*) AS Records FROM dbo.TestTable1;

EXIT



# clean up
docker rm $(docker ps -a -q) -f





# https://dbafromthecold.com/2017/06/28/persisting-data-in-docker-containers-part-two/
## Named Volumes



# remove unused volumes
docker volume prune



# create the named volume
docker volume create sqlserver



# verify named volume is there
docker volume ls



# spin up a container with named volume mapped
docker run -d -p 15999:1433 \
    -v sqlserver:/sqlserver \
        --env ACCEPT_EULA=Y --env SA_PASSWORD=Testing1122 \
            --name testcontainer3 \
                mcr.microsoft.com/mssql/server:2019-CTP2.1-ubuntu



# check the container is running
docker ps -a



# create database on the named volume
mssql-cli -S 'localhost,15999' -U sa -P Testing1122 

CREATE DATABASE [DatabaseB]
ON PRIMARY
    (NAME = N'DatabaseB', FILENAME = N'/sqlserver/DatabaseB.mdf')
LOG ON
    (NAME = N'DatabaseB_log', FILENAME = N'/sqlserver/DatabaseB_log.ldf');

                

# check the database is there
SELECT [name] FROM sys.databases;



# create a test table and insert some data
USE [DatabaseB];

CREATE TABLE dbo.TestTable2(ID INT);

INSERT INTO dbo.TestTable2(ID) SELECT TOP 200 1 FROM sys.all_columns;



# query the test table
SELECT COUNT(*) AS Records FROM dbo.TestTable2;



EXIT



# blow away container
docker rm $(docker ps -q -a) -f



# check that named volume is still there
docker volume ls



# spin up another container
docker run -d -p 16100:1433 \
    -v sqlserver:/sqlserver \
        --env ACCEPT_EULA=Y --env SA_PASSWORD=Testing1122 \
            --name testcontainer4 \
                mcr.microsoft.com/mssql/server:2019-CTP2.1-ubuntu



# verify container is running
docker ps -a



# now attach the database
mssql-cli -S 'localhost,16100' -U sa -P Testing1122

CREATE DATABASE [DatabaseB] ON 
(FILENAME = '/sqlserver/DatabaseB.mdf'),
(FILENAME = '/sqlserver/DatabaseB_log.ldf') FOR ATTACH;



# check database is there
SELECT [name] FROM sys.databases;



# query the test table       
USE [DatabaseB];

SELECT COUNT(*) AS Records FROM dbo.TestTable2;



EXIT



# clean up
docker rm $(docker ps -q -a) -f
docker volume rm sqlserver





# https://dbafromthecold.com/2017/07/05/persisting-data-in-docker-containers-part-three/
## Data volume containers


# create the data volume container
docker create -v /sqldata -v /sqllog --name datastore ubuntu



# verify container
docker ps -a



# spin up a sql container with volume mapped from data container
docker run -d -p 16110:1433 \
    --volumes-from datastore \
        --env ACCEPT_EULA=Y --env SA_PASSWORD=Testing1122 \
            --name testcontainer5 \
                mcr.microsoft.com/mssql/server:2019-CTP2.1-ubuntu



# verify container
docker ps -a



# create database
mssql-cli -S 'localhost,16110' -U sa -P Testing1122

CREATE DATABASE [DatabaseC]
ON PRIMARY
    (NAME = N'DatabaseC', FILENAME = N'/sqldata/DatabaseC.mdf')
LOG ON
    (NAME = N'DatabaseC_log', FILENAME = N'/sqllog/DatabaseC_log.ldf');



# check database is there
SELECT [name] FROM sys.databases;



# create a test table and insert some data 
USE [DatabaseC];

CREATE TABLE dbo.TestTable3(ID INT);

INSERT INTO dbo.TestTable3(ID) SELECT TOP 300 1 FROM sys.all_columns;



# query the test table
SELECT COUNT(*) AS Records FROM dbo.TestTable3;



EXIT


# blow away container
docker rm $(docker -q -a) -f



# verify data container is still there
docker ps -a



# spin up another container
docker run -d -p 16120:1433 \
    --volumes-from datastore \
        --env ACCEPT_EULA=Y --env SA_PASSWORD=Testing1122 \
            --name testcontainer6 \
                mcr.microsoft.com/mssql/server:2019-CTP2.1-ubuntu 
            


# now attach the database
mssql-cli -S 'localhost,16120' -U sa -P Testing1122

CREATE DATABASE [DatabaseC] ON 
(FILENAME = '/sqldata/DatabaseC.mdf'),
(FILENAME = '/sqllog/DatabaseC_log.ldf') FOR ATTACH;



# check database is there
SELECT [name] FROM sys.databases;


            
# query the test table
USE [DatabaseC];

SELECT COUNT(*) AS Records FROM dbo.TestTable3;



EXIT



# clean up
docker rm $(docker ps -q -a) -f
sudo rm -rf /sqldata
