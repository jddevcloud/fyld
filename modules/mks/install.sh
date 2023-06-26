#! /bin/bash

# Install docker, compose and other utils
sudo amazon-linux-extras install -y docker
sudo service docker start
sudo chkconfig docker on
sudo usermod -a -G docker ec2-user
sudo yum install -y htop git
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Set up local transfer image
# TODO: Create image
curl -OL https://github.com/sitestream/transfer/archive/refs/heads/master.zip
unzip master.zip
rm master.zip
cd transfer-master
sudo docker build -t transfer-local .
cd ..

# Set up GitHub deploy keys
ssh-keyscan github.com >> ~/.ssh/known_hosts

sudo cat << EOF > ~/.ssh/id_ed25519
${private_key}
EOF

chmod 400 ~/.ssh/id_ed25519

sudo cat << EOF > ~/.ssh/config
Host github.com
    Hostname github.com
    IdentityFile=~/.ssh/id_ed25519
EOF

git clone --depth 1 git@github.com:sitestream/artie-transfer.git
cd artie-transfer

# Add Snowflake credentials
head -n -8 config-1.yaml > config-1-tmp.yaml
mv config-1-tmp.yaml config-1.yaml
sed -i 's/\$ENV/${env}/g' config-1.yaml
sed -i 's/\kafka:9092/${kafka_endpoint_1}/g' config-1.yaml
cat << EOF >> ./config-1.yaml
snowflake:
  account: kq33960
  username: ARTIESYNC
  password: ${snowflake_password}
  warehouse: LOADING
  region: eu-west-2.aws
  database: RAW
  schema: ${snowflake_schema}
EOF

head -n -8 config-2.yaml > config-2-tmp.yaml
mv config-2-tmp.yaml config-2.yaml
sed -i 's/\$ENV/${env}/g' config-2.yaml
sed -i 's/\kafka:9092/${kafka_endpoint_2}/g' config-2.yaml
cat << EOF >> ./config-2.yaml
snowflake:
  account: kq33960
  username: ARTIESYNC
  password: ${snowflake_password}
  warehouse: LOADING
  region: eu-west-2.aws
  database: RAW
  schema: ${snowflake_schema}
EOF

# Update kafka endpoints
sed -i 's/\kafka:9092/${kafka_endpoints}/g' docker-compose.yaml
sed -i 's/\kafka:9092/${kafka_endpoints}/g' connect/connect-distributed.properties

# Add RDS credentials
cat << EOF > ./register-postgres-connector.json
{
    "name": "postgres-connector-${env}",
    "config": {
        "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
        "tasks.max": "1",
        "database.hostname": "${db_host}",
        "database.port": "5432",
        "database.user": "sitestream",
        "database.password": "${db_password}",
        "database.dbname": "sitestream",
        "schema.include.list": "public",
        "topic.prefix": "sitestream-${env}",
        "tombstones.on.delete": "false",
        "decimal.handling.mode": "double",
        "after.state.only": "false",
        "plugin.name": "pgoutput"
    }
}
EOF

docker-compose build 
docker-compose up -d

sleep 10

docker-compose ps
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-postgres-connector.json
