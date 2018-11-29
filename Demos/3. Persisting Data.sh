

## https://dbafromthecold.com/2017/07/05/persisting-data-in-docker-containers-part-three/
## Data volume containers



# create the data volume container
docker create -v /sqldata -v /sqllog --name datastore ubuntu



# verify container
docker ps -a



# spin up a sql container with volume mapped from data container
docker run -d -p 15333:1433 \
--volumes-from datastore \
--env ACCEPT_EULA=Y --env SA_PASSWORD=Testing1122 \
--name testcontainer3 \
microsoft/mssql-server-linux:latest



# verify container
docker ps -a



# connec to sql server within the container
mssql-cli -S 'localhost,15333' -U sa -P Testing1122



# create the database
CREATE DATABASE [DatabaseB] ON PRIMARY (NAME = N'DatabaseB', FILENAME = N'/sqldata/DatabaseB.mdf') LOG ON (NAME = N'DatabaseB_log', FILENAME = N'/sqllog/DatabaseB_log.ldf');



# check database is there
SELECT [name] FROM sys.databases;



# create a test table 
CREATE TABLE DatabaseB.dbo.TestTable(ID INT);



# insert some data 
INSERT INTO DatabaseB.dbo.TestTable(ID) SELECT TOP 200 1 FROM sys.all_columns;



# query the test table
SELECT COUNT(*) AS Records FROM DatabaseB.dbo.TestTable;



# exit mssql-cli
EXIT



# blow away container
docker kill testcontainer3
docker rm testcontainer3



# verify data container is still there
docker ps -a



# spin up another container
docker run -d -p 15444:1433 \
--volumes-from datastore \
--env ACCEPT_EULA=Y --env SA_PASSWORD=Testing1122 \
--name testcontainer4 \
microsoft/mssql-server-linux:latest
            


# connect to the new instance
mssql-cli -S 'localhost,15444' -U sa -P Testing1122



# attach the database
CREATE DATABASE [DatabaseB] ON (FILENAME = '/sqldata/DatabaseB.mdf'),(FILENAME = '/sqllog/DatabaseB_log.ldf') FOR ATTACH;



# check database is there
SELECT [name] FROM sys.databases;


            
# query the test table
SELECT COUNT(*) AS Records FROM DatabaseB.dbo.TestTable;



# exit mssql-cli
EXIT



# clean up
docker rm $(docker ps -q -a) -f
