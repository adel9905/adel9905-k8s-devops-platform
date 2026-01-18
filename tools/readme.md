# Jenkins install on Amazon Linux:
====================================
`sudo dnf install -y java-21-amazon-corretto`
`java -version`

`sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo`
`sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key`


`sudo dnf install -y jenkins`

`sudo systemctl enable jenkins`
`sudo systemctl start jenkins`
`sudo systemctl status jenkins`


`cat /var/lib/jenkins/secrets/initialAdminPassword`

** Install suggested plugins

create first admin user


Slave:
============
`sudo dnf install -y java-21-amazon-corretto`
`java -`version`



From Master-
Manage Jenkins -> Set up agent -> Node name -> Select Permanent agent -> create -> 

Remote root directory - /home/jenkins

Labels - common

SSH way to connect node from agent to master: https://devopscube.com/setup-slaves-on-jenkins-2/


SonarQube:
==============
`sudo dnf install -y java-21-amazon-corretto`
`java -version`

SonarQube requires database:
===============
`sudo dnf install -y postgresql15 postgresql15-server`
`sudo /usr/bin/postgresql-setup --initdb`
`sudo systemctl enable postgresql`
`sudo systemctl start postgresql`
`sudo -u postgres psql -c "CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonar';"`
`sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"`


Download and configure sonarqube:
==================
`cd /opt`
`sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-26.1.0.118079.zip`
`sudo dnf install unzip`
`sudo unzip sonarqube-*.zip`
`sudo mv sonarqube-26.1.0.118079 sonarqube`
`sudo adduser sonar`
`sudo chown -R sonar:sonar /opt/sonarqube`

  
Configure DB properties: Configure DB in /opt/sonarqube/conf/sonar.properties
=================

sonar.jdbc.username=sonar
sonar.jdbc.password=sonar
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube

Create file for systemd:
==============
Create file /etc/systemd/system/sonarqube.service
-------------------
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
-------------------

`sudo systemctl daemon-reload`
`sudo systemctl enable sonarqube`
`sudo systemctl start sonarqube`
`sudo systemctl status sonarqube`


`sudo vi /var/lib/pgsql/data/pg_hba.conf`
change to md5 for both IPv4 and IPv6

`sudo -u postgres psql`
`ALTER USER sonar WITH ENCRYPTED PASSWORD 'sonar';`

`sudo systemctl restart postgresql`
`psql -U sonar -d sonarqube -h localhost -W`


Set swap for small instances
=================================
`sudo fallocate -l 2G /swapfile`
`sudo chmod 600 /swapfile`
`sudo mkswap /swapfile`
`sudo swapon /swapfile`
`echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab`

`sudo sysctl -w vm.max_map_count=262144`
`echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf`

`sudo systemctl restart sonarqube`
`sudo systemctl status sonarqube`

tail -f /opt/sonarqube/logs/es.log


Other tools:
===============
Install Docker on Amazon linux:
# Update packages
sudo yum update -y

# Install Docker
sudo yum install -y docker

# Start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Add Jenkins user to docker group
sudo usermod -aG docker jenkins


Install AWS CLI:

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version


Install Kubectl:
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

Install Trivy:
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.68.2
trivy --version