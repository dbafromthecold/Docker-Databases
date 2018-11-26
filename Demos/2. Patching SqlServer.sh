# pull down the images
docker pull microsoft/mssql-server-linux:2017-GA

docker pull microsoft/mssql-server-linux:2017-CU10

docker pull mcr.microsoft.com/mssql/server:2019-CTP2.1-ubuntu

# make a directory on the host
mkdir /sqldata

# run a container for SQL 2017 CU10
docker run -d -p 15789:1433 \
    -v C:\SQLData:/sqlserver \
        --env ACCEPT_EULA=Y --env SA_PASSWORD=Testing11 \
            --name testcontainer7 \
                microsoft/mssql-server-linux:2017-CU12

# connect to sql
mssql-cli -S localhost,15789 -U sa -P Testing11

# create a database on the mounted volume
CREATE DATABASE [DatabaseD] ON PRIMARY (NAME = N'DatabaseD', FILENAME = N'/sqlserver/DatabaseD.mdf') LOG ON (NAME = N'DatabaseD_log', FILENAME = N'/sqlserver/DatabaseD_log.ldf');

# confirm the database is there
select name from sys.databases;

# exit mssql-cli
EXIT

# stop the container
docker stop container1

# run another container with SQL 2017 CU11
docker run -d -p 15799:1433 \
    -v C:\SQLData:/sqlserver \
        --env ACCEPT_EULA=Y --env SA_PASSWORD=Testing11 \
            --name container2 \
                mcr.microsoft.com/mssql/server:2019-CTP2.1-ubuntu

# connect to sql
mssql-cli -S localhost,15799 -U sa -P Testing11

# attach the database
CREATE DATABASE [DatabaseD] ON (FILENAME = N'/sqlserver/DatabaseD.mdf'), (FILENAME = '/sqlserver/DatabaseD_log.ldf') FOR ATTACH

# confirm the database is there
select name from sys.databases;

# exit mssql-cli
EXIT

# stop the new container
docker stop container2

# start the old container
docker start container1

# connect to sql
mssql-cli -S localhost,15789 -U sa -P Testing11

# confirm the database is there
select name from sys.databases;

# exit mssql-cli
EXIT

# stop the container again (rollback)
docker stop container1

# start the other container
docker start container2

# connect to sql
mssql-cli -S localhost,15799 -U sa -P Testing11

# confirm the database is there
select name from sys.databases;

# exit mssql-cli
EXIT

# stop the container
docker stop container2

# spin up another container on SQL 2017 RTM
docker run -d -p 15777:1433 \
-v C:\SQLData:/sqlserver \
--env ACCEPT_EULA=Y --env SA_PASSWORD=Testing11 \
--name container3 \
microsoft/mssql-server-linux:2017-GA

# connect to sql
mssql-cli -S localhost,15777 -U sa -P Testing11

# attach the database
CREATE DATABASE [DatabaseD] ON (FILENAME = N'/sqlserver/DatabaseD.mdf'), (FILENAME = '/sqlserver/DatabaseD_log.ldf') FOR ATTACH

# confirm the database is there
select name from sys.databases;

# exit mssql-cli
EXIT

# clean up
docker rm $(docker ps -a -q) -f