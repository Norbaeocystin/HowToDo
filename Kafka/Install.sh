cd
yes | apt-get update
yes | apt install python3-pip
yes | apt install pykafka
#install java 
yes | apt install default-jdk
wget -qO - https://packages.confluent.io/deb/5.3/archive.key | apt-key add -
add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/5.3 stable main"
yes | apt-get update 
yes | sudo apt-get install confluent-community-2.12
#mkdir confluent-hub
#cd confluent-hub
#wget https://s3-us-west-2.amazonaws.com/confluent-hub-client/confluent-hub-client-latest.tar.gz
#tar -zxvf confluent-hub*
#yes | bin/confluent-hub install mongodb/kafka-connect-mongodb:0.2
#cd 
#setup partitions
echo -n "Set number of partitions <int>, default 300 [ENTER]: "
read partitions
if [-z "$partitions"]
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
sed -i 's/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/'$IP':9092/g' /etc/kafka/server.properties
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
systemctl enable confluent-kafka-connect
#starting services
systemctl start confluent-zookeeper
sleep 60
systemctl start confluent-kafka
sleep 30
systemctl start confluent-schema-registry
sleep 15
systemctl start confluent-kafka-connect
sleep 7
echo "Running test. Please wait for results"
echo -e "from pykafka import KafkaClient\nclient = KafkaClient(hosts='$IP:9092')\ntopic = client.topics['TEST']\nwith topic.get_sync_producer() as producer:\n\tfor i in range(1):\n\t\tmessage = 'Consumer test SUCESS'\n\t\tproducer.produce(message.encode())\nprint('Producer test SUCESS')\nconsumer = topic.get_simple_consumer(consumer_group='testgroup')\nmsg =consumer.consume()\nconsumer.commit_offsets()\nprint(msg.value.decode())" >> test_producer_consumer.py
python3 test_producer_consumer.py






