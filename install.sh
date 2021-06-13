# Update System & Utilities
sudo yum remove java*
sudo yum update -y
sudo dnf install epel-release -y
sudo dnf install screen -y
sudo yum install git iptables -y

# Install Java
#wget -O jdk-16.0.1_linux-x64_bin.rpm https://download.oracle.com/otn-pub/java/jdk/16.0.1+9/7147401fd7354114ac51ef3e1328291f/jdk-16.0.1_linux-x64_bin.rpm
wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/16.0.1+9/7147401fd7354114ac51ef3e1328291f/jdk-16.0.1_linux-x64_bin.rpm
#wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/15.0.1+9/51f4f36ad4ef43e39d0dfdbaf6549e32/jdk-15.0.1_linux-x64_bin.rpm
sudo rpm -ivh jdk-16.0.1_linux-x64_bin.rpm
#sudo yum install -y git java-16.0.0-openjdk-devel
#sudo yum install -y git java-16*

# Create BuildTools Directory
mkdir BuildTools && cd BuildTools

# Download BuildTools
wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar 

# Compile BuildTools
git config --global --unset core.autocrlf
java -jar BuildTools.jar --rev 1.17

# Prepare Server Directory
mkdir ../Server && cd ../Server
cp ../BuildTools/spigot-1.17.jar ./
echo eula=true > eula.txt
mkdir ./plugins && cd ./plugins
wget -O Geyser-Spigot.jar https://ci.opencollab.dev//job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar

# Startup Script
echo screen -dmS "spigot" java -Xmx3G -Xms3G -jar Server/spigot-1.17.jar nogui > Server/startup.sh

# Firewall Rules
iptables -A INPUT -p tcp --dport 25565 -j ACCEPT --comment "Minecraft Java" >> Server/Startup.sh
iptables -A INPUT -p tcp --dport 19132 -j ACCEPT --comment "Minecraft Bedrock" >> Server/Startup.sh
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
