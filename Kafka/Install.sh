cd
cd ..
yes | apt-get update
yes | apt install python3-pip
yes | pip3 install pykafka
#install java 
yes | apt install default-jdk
wget -qO - https://packages.confluent.io/deb/5.3/archive.key | apt-key add -
add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/5.3 stable main"
yes | apt-get update 
yes | sudo apt-get install confluent-community-2.12
mkdir confluent-hub
cd confluent-hub
wget https://s3-us-west-2.amazonaws.com/confluent-hub-client/confluent-hub-client-latest.tar.gz
tar -zxvf confluent-hub*
yes | bin/confluent-hub install mongodb/kafka-connect-mongodb:0.2
cd 
#setup partitions
echo -n "Set number of partitions <int>, default 300 [ENTER]: "
read partitions
if [ -z "$partitions" ]
then
    partitions=300
fi
sed -i 's/num.partitions=1/num.partitions='$partitions'/g' /etc/kafka/server.properties
#external IP

echo -n "Enter your IP to bind Kafka e.g. 192.168.100.17 and press, if you don't provide it, script will try to setup it automatically [ENTER]: "
read IP
if [ -z "$IP" ]
then
    IP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
fi
if [ -z "$IP" ]
then
    IPs=$(hostname -I)
    IP=(${IPs})
fi
#for local usage
#IPs=$(hostname -I)
#IP=(${IPs})
#setup listeners for kafka - needs to be done also for zookeeper
sed -i "s/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/$IP:9092/g" /etc/kafka/server.properties
sed -i "s/localhost/$IP/g" /etc/kafka/connect-standalone.properties
#listeners=PLAINTEXT://:9092
#enabling  services
#setup networking
ufw enable
ufw allow ssh
echo -n "Enter IPs, delimited by comma without whitespace to be whitelisted [ENTER]:" 
read IPS
IFS=',' read -r -a array_ips <<< "$IPS"
for element in "${array_ips[@]}"
do
    ufw allow from $element to any port 9092 
    ufw allow from $element to any port 2181
    ufw allow from $element to any port 2888
    ufw allow from $element to any port 3888
    echo "$element"
done
ufw allow from $IP to any port 9092
ufw allow from $IP to any port 2181
ufw allow from $IP to any port 2888
ufw allow from $IP to any port 3888
ufw allow from 127.0.0.1 to any port 9092
ufw allow from 127.0.0.1 to any port 2181
ufw allow from 127.0.0.1 to any port 2888
ufw allow from 127.0.0.1 to any port 3888
#enable services
systemctl enable confluent-zookeeper
systemctl enable confluent-kafka
systemctl enable confluent-schema-registry
#starting services
systemctl start confluent-zookeeper
sleep 20
systemctl start confluent-kafka
sleep 10
systemctl start confluent-schema-registry
sleep 5
#for distributed system only
#systemctl enable confluent-kafka-connect
#systemctl start confluent-kafka-connect
echo "Running test. Please wait for results"
echo -e "from pykafka import KafkaClient\nclient = KafkaClient(hosts='$IP:9092')\ntopic = client.topics['TEST']\nwith topic.get_sync_producer() as producer:\n\tfor i in range(1):\n\t\tmessage = 'Consumer test SUCESS'\n\t\tproducer.produce(message.encode())\nprint('Producer test SUCESS')\nconsumer = topic.get_simple_consumer(consumer_group='testgroup')\nmsg =consumer.consume()\nconsumer.commit_offsets()\nprint(msg.value.decode())" >> test_producer_consumer.py
python3 test_producer_consumer.py


#ALso /etc/kafka/connect-standalone.properties change listeners bootstrap.servers=192.168.100.14:9092 ( original bootstrap.servers=localhost:9092)
#and to plugin.path=home/oktogen/Downloads/confluent-hub/share/confluent-hub-components/ (original plugin.path=/usr/share/java)

#delete and your_command >> file_to_append_to
echo "Setting up connector to MongoDB"
sudo sed -i -e "s/plugin\.path=\/usr\/share\/java//g" /etc/kafka/connect-standalone.properties
echo "plugin.path=/usr/share/java,/confluent-hub/share/confluent-hub-components/" >> /etc/kafka/connect-standalone.properties
sudo sed -i -e "s/collection=source/collection=Source/g" /confluent-hub/share/confluent-hub-components/mongodb-kafka-connect-mongodb/etc/MongoSourceConnector.properties
sudo sed -i -e "s/database=test/database=Kafka/g" /confluent-hub/share/confluent-hub-components/mongodb-kafka-connect-mongodb/etc/MongoSourceConnector.properties
sudo sed -i -e 's/pipeline=\[\]//g' /confluent-hub/share/confluent-hub-components/mongodb-kafka-connect-mongodb/etc/MongoSourceConnector.properties
sudo sed -i -e 's/5000/10/g' /confluent-hub/share/confluent-hub-components/mongodb-kafka-connect-mongodb/etc/MongoSourceConnector.properties
sudo sed -i -e 's/topic\.prefix=/topic\.prefix=Mongo/g' /confluent-hub/share/confluent-hub-components/mongodb-kafka-connect-mongodb/etc/MongoSourceConnector.properties
echo "Default database is Kafka, collection Source and topic Mongo"
echo -n "Enter MongoDB URI in format <username>:<password>@<ip>:<port>/<authenticationDatabase> [ENTER]"
read MONGO_URI
sudo sed -i -e "s/mongo1:27017,mongo2:27017,mongo3:27017/$MONGO_URI/g" /confluent-hub/share/confluent-hub-components/mongodb-kafka-connect-mongodb/etc/MongoSourceConnector.properties
echo 'pipeline=[{"$match": {"operationType": "insert"}}]' >> /confluent-hub/share/confluent-hub-components/mongodb-kafka-connect-mongodb/etc/MongoSourceConnector.properties
echo 'plugin.path =/confluent-hub/share/confluent-hub-components' >> /confluent-hub/share/confluent-hub-components/mongodb-kafka-connect-mongodb/etc/MongoSourceConnector.properties
echo 'publish.full.document.only=true' >> /confluent-hub/share/confluent-hub-components/mongodb-kafka-connect-mongodb/etc/MongoSourceConnector.properties
#connect-standalone /etc/kafka/connect-standalone.properties /confluent-hub/share/confluent-hub-components/mongodb-kafka-connect-mongodb/etc/MongoSourceConnector.properties
#using circus
pip3 install circus
echo "[watcher:program]" >> connect-standalone.ini
echo "cmd = connect-standalone /etc/kafka/connect-standalone.properties /confluent-hub/share/confluent-hub-components/mongodb-kafka-connect-mongodb/etc/MongoSourceConnector.properties" >> connect-standalone.ini
echo "numprocesses = 1" >> connect-standalone.ini
circusd --daemon connect-standalone.ini
