#참고 : http://inthound.blogspot.com/2015/04/how-to-install-hadoop-260-in-ubuntu.html
# 자신의 ip확인 : ip addr | grep "inet " | grep brd | awk '{print $2}' | awk -F/ '{print $1}'
myIp=`ip addr | grep "inet " | grep brd | awk '{print $2}' | awk -F/ '{print $1}'`

function astString(){
    str=$1 
    echo "******************************************"
    echo $str
    echo "******************************************"
}

function install_jdk(){
  jdk_targzfilename="jdk1.8.0_181"                   #압축푼파일이름    
  jdk_targzzipname="jdk-8u181-linux-x64.tar.gz"
  jdk_targzurl="http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.tar.gz"

    astString "자바설치중!!!!!!!"

    if [ -d ~/$jdk_targzfilename ]
        then
            echo " 자바가 이미 존재 합니다. "
        else
            if [ -e ~/$jdk_targzzipname ]
                then
                    echo "jdk파일은 이미 존재하네요"
                    #wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $jdk_targzurl
                else
                    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $jdk_targzurl
            fi
        #jdk 8u161 최신버전 http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
        #참고 : https://www.lesstif.com/pages/viewpage.action?pageId=26084289
        tar -zxvf /root/$jdk_targzzipname
        mv /root/$jdk_targzfilename /root/java
        #자바 환경변수 설정
        echo "JAVA_HOME=/root/jdk" >> ~/.bash_profile
        echo "export JAVA_HOME" >> ~/.bash_profile
        echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.bash_profile           
    fi
}
function netSet(){
    astString "아이피 고정중!!!!!!!"

    netsetDir=/etc/sysconfig/network-scripts/ifcfg-enp0s3
    echo 'TYPE="Ethernet"' > $netsetDir
    echo 'PROXY_METHOD="none"' >> $netsetDir
    echo 'BROWSER_ONLY="no"' >> $netsetDir
    echo '#BOOTPROTO="dhcp"' >> $netsetDir
    echo 'BOOTPROTO="static"' >> $netsetDir
    echo "IPADDR=$myIp" >> $netsetDir
    echo 'NETMASK=255.255.255.0' >> $netsetDir
    echo 'GATEWAY=192.168.1.1' >> $netsetDir
    echo 'DNS1=168.126.63.1' >> $netsetDir
    echo 'DNS2=168.126.63.2' >> $netsetDir
    echo 'DEFROUTE="yes"' >> $netsetDir
    echo 'IPV4_FAILURE_FATAL="no"' >> $netsetDir
    echo 'IPV6INIT="yes"' >> $netsetDir
    echo 'IPV6_AUTOCONF="yes"' >> $netsetDir
    echo 'IPV6_DEFROUTE="yes"' >> $netsetDir
    echo 'IPV6_FAILURE_FATAL="no"' >> $netsetDir
    echo 'IPV6_ADDR_GEN_MODE="stable-privacy"' >> $netsetDir
    echo 'NAME="enp0s3"' >> $netsetDir
    echo 'UUID="b46989d2-b04c-4b83-bd01-8cc289febb9c"' >> $netsetDir
    echo 'DEVICE="enp0s3"' >> $netsetDir
    echo 'ONBOOT="yes"' >> $netsetDir
    echo 'ZONE=public' >> $netsetDir
}

function install_hadoop(){
    astString "하둡 환경설정중!!!!!!!"

    hadoopUrl="http://apache.mirror.cdnetworks.com/hadoop/common/hadoop-2.9.0/hadoop-2.9.0.tar.gz"
    hadoopFile="hadoop"
    hadoopZfile="hadoop-2.9.0"
    hadoopZip="hadoop-2.9.0.tar.gz"

    #하둡 환경변수 설정
    echo "export HADOOP_HOME=/root/hadoop" >> ~/.bash_profile
    echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> ~/.bash_profile

    echo "export HDFS_NAMENODE_USER='root'" >> ~/.bash_profile   
    echo "export HDFS_DATANODE_USER='root'" >> ~/.bash_profile   
    echo "HDFS_SECONDARYNAMENODE_USER='root'" >> ~/.bash_profile   
    echo "export YARN_RESOURCEMANAGER_USER='root'" >> ~/.bash_profile   
    echo "export YARN_NODEMANAGER_USER='root'" >> ~/.bash_profile   
    echo "HD_SAMPLE=/root/hadoop/share/hadoop/mapreduce" >> ~/.bash_profile
    echo "export HD_SAMPLE" >> ~/.bash_profile   
    source ~/.bash_profile
    if [ -d $hadoopFile ]
        then
            echo "하둡이 이미 존재 합니다."
        else
            if [ -e /root/$hadoopZip ]
                then
                    echo "하둡파일은 이미 존재 합니다"
                else
                    wget $hadoopUrl
            fi
        tar -zxvf $hadoopZip -C ~/
        mv ~/$hadoopZfile ~/$hadoopFile
        #하둡 환경변수 설정
        echo "export HADOOP_HOME=/root/hadoop" >> ~/.bash_profile
        echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> ~/.bash_profile

        echo "export HDFS_NAMENODE_USER='root'" >> ~/.bash_profile   
        echo "export HDFS_DATANODE_USER='root'" >> ~/.bash_profile   
        echo "HDFS_SECONDARYNAMENODE_USER='root'" >> ~/.bash_profile   
        echo "export YARN_RESOURCEMANAGER_USER='root'" >> ~/.bash_profile   
        echo "export YARN_NODEMANAGER_USER='root'" >> ~/.bash_profile   
        echo "HD_SAMPLE=/root/hadoop/share/hadoop/mapreduce" >> ~/.bash_profile
        echo "export HD_SAMPLE" >> ~/.bash_profile   
        source ~/.bash_profile
    fi

# <configuration>
# <property>
# <name>dfs.replication</name>
# <value>2</value>
# </property>

# <property>
# <name>dfs.permissions</name>
# <value>false</value>
# </property>

# <property>
# <name>dfs.namenode.name.dir</name>
# <value>file:/root/hadoop/namenode</value>
# </property>
# </configuration>

}
function mainCluster(){
    ssh-keygen -t rsa -P ""
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    sed -i "25s/.*/export JAVA_HOME=\/root\/java/g" /root/hadoop/etc/hadoop/hadoop-env.sh
    sed -i "104s/.*/export HADOOP_PID_DIR=\/root\/hadoop\/pids/g" /root/hadoop/etc/hadoop/hadoop-env.sh
    sed -i 20d /root/hadoop/etc/hadoop/core-site.xml
    sed -i 19d /root/hadoop/etc/hadoop/core-site.xml
    echo "<configuration>" >> /root/hadoop/etc/hadoop/core-site.xml
    echo "<property>" >> /root/hadoop/etc/hadoop/core-site.xml
    echo "<name>fs.defaultFS</name>" >> /root/hadoop/etc/hadoop/core-site.xml
    echo "<value>hdfs://name:9000</value>" >> /root/hadoop/etc/hadoop/core-site.xml
    echo "</property>" >> /root/hadoop/etc/hadoop/core-site.xml
    echo "</configuration>" >> /root/hadoop/etc/hadoop/core-site.xml
    sed -i 19d /root/hadoop/etc/hadoop/hdfs-site.xml
    sed -i 20d /root/hadoop/etc/hadoop/hdfs-site.xml
    sed -i 21d /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<configuration>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<property>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<name>dfs.replication</name>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<value>2</value>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "</property>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<property>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<name>dfs.permissions</name>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<value>false</value>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "</property>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<property>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<name>dfs.namenode.name.dir</name>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<value>file:/root/hadoop/namenode</value>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "</property>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<property>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<name>dfs.datanode.data.dir</name>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<value>file:/root/hadoop/datanode</value>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "</property>" >> /root/hadoop/etc/hadoop/hdfs-site.xml    
    echo "</configuration>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    
    mkdir /root/hadoop/namenode
    mkdir /root/hadoop/datanode
    chmod 777 /root/hadoop/namenode

    echo "name" > /root/hadoop/etc/hadoop/masters
    echo "data1" > /root/hadoop/etc/hadoop/slaves
    echo "data2" >> /root/hadoop/etc/hadoop/slaves
    echo "data3" >> /root/hadoop/etc/hadoop/slaves
}
function subCluster(){
    #서브는 파라미터로 몇번제것인지 표기해줘야함
    sed -i "25s/.*/export JAVA_HOME=\/root\/java/g" /root/hadoop/etc/hadoop/hadoop-env.sh
    sed -i 20d /root/hadoop/etc/hadoop/core-site.xml
    sed -i 19d /root/hadoop/etc/hadoop/core-site.xml
    echo "<configuration>" >> /root/hadoop/etc/hadoop/core-site.xml
    echo "<property>" >> /root/hadoop/etc/hadoop/core-site.xml
    echo "<name>fs.defaultFS</name>" >> /root/hadoop/etc/hadoop/core-site.xml
    echo "<value>hdfs://name:9000</value>" >> /root/hadoop/etc/hadoop/core-site.xml
    echo "</property>" >> /root/hadoop/etc/hadoop/core-site.xml
    echo "</configuration>" >> /root/hadoop/etc/hadoop/core-site.xml    
    sed -i 19d /root/hadoop/etc/hadoop/hdfs-site.xml
    sed -i 20d /root/hadoop/etc/hadoop/hdfs-site.xml
    sed -i 21d /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<configuration>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<property>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<name>dfs.replication</name>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<value>2</value>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "</property>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<property>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<name>dfs.permissions</name>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<value>false</value>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "</property>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<property>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<name>dfs.datanode.data.dir</name>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "<value>file:/root/hadoop/datanode</value>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "</property>" >> /root/hadoop/etc/hadoop/hdfs-site.xml
    echo "</configuration>" >> /root/hadoop/etc/hadoop/hdfs-site.xml    

    mkdir /root/hadoop/datanode
    mkdir /root/.ssh

}

function install_End(){
  echo "컴퓨터를 재부팅시키겠습니까? y/Y"
  read end
  if [ $end = "y" -o $end = "Y" ] 
  then
    init 6
  else
    echo "종료를 안합니다. 톰켓을 구동하겠습니다. 자바 구동확인 mvn구동확인"
    source ~/.bash_profile
    systemctl start httpd
    sh ~/$apache_targzfilename/bin/startup.sh
    java -version
    mvn -version
    fi
}

function localhost(){
    echo "ip 4개를 순서대로 입력해주세요 메인부터 서브순으로"
    t1=0
    t2=0
    t3=0
    t4=0
    read t1
    read t2
    read t3
    read t4
    echo "127.0.0.1 localhost" > /etc/hosts
    echo "$t1 name" >> /etc/hosts
    echo "$t2 data1" >> /etc/hosts
    echo "$t3 data2" >> /etc/hosts
    echo "$t4 data3" >> /etc/hosts
    # 이 부분이 변동시 메인 분산모드 메소드 쪽의 slaves 부분도 수정해줘야해요!!
}

#시작부분
echo "설치를 방법을 선택해주세요 순서 1 > 4 > 2,3 > 5"
echo "1. 하둡 기본설정"
echo "2. 메인) 분산모드 설정"
echo "3. 서브) 분산모드 설정"
echo "4. 로컬Host변경"
echo "5. 메인) 키전송 (2번과 4번이 선행)"
echo "6. 설치 종료"
read a_input
check=$(yum list installed | grep wget)
echo $check

#yum -y update
if [ -z $check ]
 then
  yum install -y wget
 else
  echo "wget은 이미 설치되어있습니다"
fi
####

############################ 아래가 메인
if [ $a_input -eq 1 ]
    then
        firewall-cmd --zone=public --add-port=50070/tcp --permanent
        firewall-cmd --zone=public --add-port=8088/tcp --permanent
        firewall-cmd --zone=public --add-port=9000/tcp --permanent
        firewall-cmd --reload
        systemctl stop firewalld.service
        systemctl disable firewalld.service
        ##    
        #install_jdk
        #netSet
        install_hadoop
        #install_End
elif [ $a_input -eq 2 ]
  then
    mainCluster
elif [ $a_input -eq 3 ]
  then
    subCluster
elif [ $a_input -eq 4 ]
  then
   localhost
elif [ $a_input -eq 5 ]
  then
   scp -rp ~/.ssh/authorized_keys root@data1:~/.ssh/authorized_keys
   scp -rp ~/.ssh/authorized_keys root@data2:~/.ssh/authorized_keys
   scp -rp ~/.ssh/authorized_keys root@data3:~/.ssh/authorized_keys     
 else
  echo "설치를 종료합니다"
fi 

