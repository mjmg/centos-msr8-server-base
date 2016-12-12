FROM mjmg/centos-supervisor-base:latest

# Instructions from https://msdn.microsoft.com/en-us/microsoft-r/rserver-install-linux-server

# Install OpenJDK8
RUN \
  yum -y update  & \
  yum install -y java-1.8.0-openjdk-headless make gcc gcc-c++ gfortran cairo-devel libicu libicu-devel nfs-utils nfs-utils-lib sudo
  
ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0

# en_microsoft_r_server_for_linux_x64_8944657.tar.gz must exist in root directory with Dockerfile
COPY en_microsoft_r_server_for_linux_x64_8944657.tar.gz /tmp/en_microsoft_r_server_for_linux_x64_8944657.tar.gz

RUN \
  cd /tmp && \
  tar -xvzf en_microsoft_r_server_for_linux_x64_8944657.tar.gz 
  
RUN \
  cd /tmp/MRS80LINUX && \
  ./install.sh -a -d -u  
  
RUN \  
  cd /tmp/MRS80LINUX/DeployR/ && \
  tar -xvzf DeployR-Enterprise-Linux-8.0.5.tar.gz
  
# Add default root password with password r00tpassw0rd
RUN \
  echo "root:r00tpassw0rd" | chpasswd  

# Add default RUser user with pass RUser
RUN \
  useradd RUser && \
  echo "RUser:RUser" | chpasswd && \ 
  chmod -R +r /home/RUser

RUN \
  yum install -y /tmp/MRS80LINUX/microsoft-r-server-mro-8.0/microsoft-r-server-mro-8.0.rpm \
                 /tmp/MRS80LINUX/RPM/microsoft-r-server-packages-8.0.rpm \
                 /tmp/MRS80LINUX/RPM/microsoft-r-server-intel-mkl-8.0.rpm

# Add default deployr-user user with pass deployr-pass
#RUN \
#  useradd deployr-user && \
#  echo "deployr-user:deployr-pass" | chpasswd && \ 
#  chmod -R +r /home/deployr-user 

RUN \ 
  cd /tmp && \
  wget https://github.com/deployr/deployr-rserve/releases/download/v8.0.5.1/deployrRserve_8.0.5.1.tar.gz && \
  R CMD INSTALL deployrRserve_7.4.2.tar.gz
    
#RUN \ 
#  cd /home/deployr-user/ && \
#  wget http://downloads.mongodb.org/linux/mongodb-linux-x86_64-2.6.7.tgz
#  tar -xvzf mongodb-linux-x86_64-2.6.7.tgz
  
RUN \  
  cd /tmp/MRS80LINUX/DeployR/ && \
  tar -xvzf DeployR-Enterprise-Linux-8.0.5.tar.gz
  cd deployrInstall/installFiles
  ./installDeployREnterprise.sh --noask

EXPOSE 8050 8051 8052 8053 8054 8055 8056

# default command
CMD ["/usr/bin/R"]
