### VARAIBLES ###
DATABASE_PASS=P@ssw0rd
SSH_PORT=22222

# Update System & Utilities
yum remove java*
yum update -y
dnf install epel-release -y
dnf install screen -y
yum install git iptables -y

# Install Java
#wget -O jdk-16.0.1_linux-x64_bin.rpm https://download.oracle.com/otn-pub/java/jdk/16.0.1+9/7147401fd7354114ac51ef3e1328291f/jdk-16.0.1_linux-x64_bin.rpm
#wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/16.0.1+9/7147401fd7354114ac51ef3e1328291f/jdk-16.0.1_linux-x64_bin.rpm
#wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/15.0.1+9/51f4f36ad4ef43e39d0dfdbaf6549e32/jdk-15.0.1_linux-x64_bin.rpm
#rpm -ivh jdk-16.0.1_linux-x64_bin.rpm
#yum install -y git java-16.0.0-openjdk-devel
#yum install -y git java-16*

# BuildTools
mkdir BuildTools
cd BuildTools
wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar 
git config --global --unset core.autocrlf
java -jar BuildTools.jar --rev 1.17

# Prepare Server Directory
mkdir ../Server
cd ../Server
cp ../BuildTools/spigot-1.17.jar ./
echo eula=true > eula.txt
mkdir ./plugins
cd ./plugins
wget -O Geyser-Spigot.jar https://ci.opencollab.dev//job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar

# Startup Script
cd ~
touch Server/startup.sh
echo screen -dmS "spigot" java -Xmx3G -Xms3G -jar spigot-1.17.jar nogui > Server/startup.sh
echo sudo iptables -A INPUT -p tcp --dport 25565 -j ACCEPT -m comment --comment "Minecraft Java" > Server/startup.sh
echo sudo iptables -A INPUT -p udp --dport 19132 -j ACCEPT -m comment --comment "Minecraft Bedrock" > Server/startup.sh

# Restart With Backup Script
touch Server/

# Backups
cd ~
mkdir Backups
mkdir Backups/Live
touch ~/backup.sh
echo if ! screen -list | grep -q "spigot"; then > ~/backup.sh
echo -e \t screen -S spigot -p 0 -X say Server will restart in 5 minutes for backup. >> ~/backup.sh
echo -e \t sleep 1m >> ~/backup.sh
echo -e \t screen -S spigot -p 0 -X say Server will restart in 4 minutes for backup. >> ~/backup.sh
echo -e \t sleep 1m >> ~/backup.sh
echo -e \t screen -S spigot -p 0 -X say Server will restart in 3 minutes for backup. >> ~/backup.sh
echo -e \t sleep 1m >> ~/backup.sh
echo -e \t screen -S spigot -p 0 -X say Server will restart in 2 minutes for backup. >> ~/backup.sh
echo -e \t sleep 1m >> ~/backup.sh
echo -e \t screen -S spigot -p 0 -X say Server will restart in 1 minute for backup. >> ~/backup.sh
echo -e \t sleep 30 >> ~/backup.sh
echo -e \t screen -S spigot -p 0 -X say Server will restart in 30 seconds for backup. >> ~/backup.sh
echo -e \t sleep 20 >> ~/backup.sh
echo -e \t screen -S spigot -p 0 -X say Server will restart in 10 seconds for backup. >> ~/backup.sh
echo -e \t sleep 5 >> ~/backup.sh
echo -e \t screen -S spigot -p 0 -X say Server will restart in 5 seconds for backup. >> ~/backup.sh
echo -e \t sleep 1 >> ~/backup.sh
echo -e \t screen -S spigot -p 0 -X say Server will restart in 4 seconds for backup. >> ~/backup.sh
echo -e \t sleep 1 >> ~/backup.sh
echo -e \t screen -S spigot -p 0 -X say Server will restart in 3 seconds for backup. >> ~/backup.sh
echo -e \t sleep 1 >> ~/backup.sh
echo -e \t screen -S spigot -p 0 -X say Server will restart in 2 seconds for backup. >> ~/backup.sh
echo -e \t sleep 1 >> ~/backup.sh
echo -e \t screen -S spigot -p 0 -X say Server will restart in 1 second for backup. >> ~/backup.sh
echo -e \t sleep 1 >> ~/backup.sh
echo -e \t screen -S spigot -p 0 -X stop
echo -e \t sleep 10 >> ~/backup.sh
echo fi >> ~/backup.sh
echo cp ~/Spigot ~/Backups/Live >> ~/backup.sh

# Overviewer
cd ~
mkdir Overviewer
cd Overviewer
wget -O /etc/yum.repos.d/overviewer.repo https://overviewer.org/rpms/overviewer.repo
yum install Minecraft-Overviewer -y

# Ownership
chown -R spigot:spigot .

# Web Server
dnf update
dnf install httpd* -y
systemctl enable httpd
systemctl restart httpd

# MySQL Database
dnf install httpd* mariadb* -y
systemctl enable mariadb
systemctl restart mariadb
mysqladmin -u root password "$DATABASE_PASS"
mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASS') WHERE User='root'"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# SSH
yum install openssh-server -y
sed "s/#Port 22/Port $SSH_PORT/gIm" /etc/ssh/sshd_config
systemctl restart sshd

# Firewall Rules
iptables --flush INPUT
iptables -A INPUT -p tcp --dport 25565 -j ACCEPT -m comment --comment "Minecraft Java"
iptables -A INPUT -p udp --dport 19132 -j ACCEPT -m comment --comment "Minecraft Bedrock"SUDO
iptables -A INPUT -p tcp --dport 80 -j ACCEPT -m comment --comment "Web Server"
iptables -A INPUT -p tcp --dport 22 -j ACCEPT -m comment --comment "SSH Connections"
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
service iptables save
