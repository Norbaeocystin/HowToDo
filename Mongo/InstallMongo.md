##### How to install and setup MongoDB on Ubuntu 18.04

[Installation](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/)

```
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt-get update
sudo apt--get install -y  mongodb
```
To enable authentication and be able to connect remotely you need to do this steps:
```
#start mongodb
sudo systemctl start mongodb
#start mongo
mongo
# create administrator
db.createUser( { user: "Admin", pwd: "password", roles: [ { role: "userAdminAnyDatabase", db: "admin" } ] } )
# create root
db.createUser( { user: "Admin", pwd: "password", roles: [ { role: "root", db: "admin" } ] } )
exit
#now open configuration file for mongodb
sudo nano /etc/mongodb.conf
#change bindIp: 127.0.0.1 to bindIp: 0.0.0.0
  bindIp: 0.0.0.0
# change authentication by writing:
security:
  authorization: enabled
#restart mongod
sudo systemctl restart mongodb
