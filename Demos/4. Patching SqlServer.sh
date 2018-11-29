

## Upgrading SQL Server


# check images
docker images



# make a directory on the host
mkdir /sqldata



# run a container for SQL 2017 CU10
docker run -d -p 15555:1433 \
-v /sqldata:/sqlserver \
--env ACCEPT_EULA=Y --env SA_PASSWORD=Testing11 \
--name testcontainer5 \
microsoft/mssql-server-linux:latest



# connect to sql
mssql-cli -S localhost,15555 -U sa -P Testing11



# create a database on the mounted volume
CREATE DATABASE [DatabaseC] ON PRIMARY (NAME = N'DatabaseC', FILENAME = N'/sqlserver/DatabaseC.mdf') LOG ON (NAME = N'DatabaseC_log', FILENAME = N'/sqlserver/DatabaseC_log.ldf');



# confirm the database is there
select name from sys.databases;



# exit mssql-cli
EXIT



# stop the container
docker stop testcontainer5



# run another container with SQL 2017 CU11
docker run -d -p 15666:1433 \
-v /sqldata:/sqlserver \
--env ACCEPT_EULA=Y --env SA_PASSWORD=Testing11 \
--name testcontainer6 \
mcr.microsoft.com/mssql/server:2019-CTP2.1-ubuntu



# connect to sql
mssql-cli -S localhost,15666 -U sa -P Testing11



# attach the database
CREATE DATABASE [DatabaseC] ON (FILENAME = N'/sqlserver/DatabaseC.mdf'), (FILENAME = '/sqlserver/DatabaseC_log.ldf') FOR ATTACH



# confirm the database is there
SELECT name FROM sys.databases;



# confirm version of SQL Server
SELECT @@VERSION;



# exit mssql-cli
EXIT



# clean up
docker rm $(docker ps -q -a) -f