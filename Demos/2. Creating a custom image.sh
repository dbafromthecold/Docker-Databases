

## https://dbafromthecold.com/2017/02/08/sql-container-from-dockerfile/
## Creating SQL containers from a dockerfile



# view the dockerfile
cat dockerfile



# build custom image
docker build -t testimage .



# view image
docker images



# run container from image
docker run -d -p 15222:1433 \
--env ACCEPT_EULA=Y --env SA_PASSWORD=Testing1122 \
--name testcontainer2 \
testimage




# 
docker ps -a



# connect to the sql instance
mssql-cli -S localhost,15222 -U sa -P Testing1122



# check that the database is there
SELECT name FROM sys.databases;



# exit mssql-cli
EXIT



# clean up
docker rm $(docker ps -a -q) -f
docker rmi testimage
