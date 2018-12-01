

## https://dbafromthecold.com/2016/11/16/sql-server-containers-part-one/
## Running your first SQL container



# search for an image
docker search microsoft/mssql



# pull the image down
docker pull microsoft/mssql-server-linux:latest



# run a container
docker run -d -p 15111:1433 \
--env ACCEPT_EULA=Y --env SA_PASSWORD=Testing1122 \
--name testcontainer1 \
microsoft/mssql-server-linux:latest



# verify container is running
docker ps -a



# copy a database backup into the container
docker cp ~/git/Docker-Databases/Demos/DatabaseA.bak \
testcontainer1:/var/opt/mssql/data/



# connect to the sql instance
mssql-cli -S localhost,15111 -U sa -P Testing1122



# restore the database
RESTORE DATABASE [DatabaseA] FROM DISK = '/var/opt/mssql/data/DatabaseA.bak';



# check that the database is there
SELECT name FROM sys.databases;



# exit mssql-cli
EXIT



# clean up
docker rm $(docker ps -a -q) -f
