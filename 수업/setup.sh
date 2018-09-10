#!/bin/sh
yum update -y
#조건 명령어 참고 http://jink1982.tistory.com/48
#단축키 0: tar.gz로 설치 1 rpm으로 설치
input_jdknum=0
input_apachenum=0
input_mavennum=0
input_connectnum=0
input_jenkinsnum=0
input_gitnum=0
apache_targzfilename=apache-tomcat-8.5.30                   #밖에서 많이사용함 

#함수부분
function install_jdk(){
  jdk_targzzipname=jdk-8u171-linux-x64.tar.gz
  jdk_targzurl=http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/$jdk_targzzipname
  jdk_targzfilename=/jdk/jdk1.8.0_171                   #압축푼파일이름
  if [ $input_jdknum -eq 0  ]  # jdknum이면 tar.gz로 설치
  then
    if [ -d ~/$jdk_targzfilename ]
      then
        echo " 자바가 이미 존재 합니다. "
      else
        if [ -e ~/$jdk_targzzipname ]
          then
          echo "jdk파일은 이미 존재하네요"
          #wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $jdk_targzurl
        fi
        #jdk 8u161 최신버전 http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
        #참고 : https://www.lesstif.com/pages/viewpage.action?pageId=26084289
        mkdir ~/jdk
        tar -zxvf $jdk_targzzipname ~/jdk
        #자바 환경변수 설정
        echo "JAVA_HOME=~/$jdk_targzfilename" >> ~/.bash_profile
        echo "export JAVA_HOME" >> ~/.bash_profile
        echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.bash_profile           
    fi
  else
    echo "!!!!!!!! jdk설치안함  !!!!!!!!"
  fi
}
function install_apache(){
  apache_targzzipname=apache-tomcat-8.5.32.tar.gz
  apache_targzurl=http://apache.mirror.cdnetworks.com/tomcat/tomcat-8/v8.5.32/bin/apache-tomcat-8.5.32.tar.gz
  apache_targzfilename=apache-tomcat-8.5.32                   #압축푼파일이름
  if [ $input_apachenum -eq 0  ]  # jdknum이면 tar.gz로 설치
  then
    if [ -d ~/$apache_targzfilename ]
    then
      echo "아파치가 이미 존재합니다."
    else
      if [ -e ~/$apache_targzzipname ]
        then
          echo "아파치 tar.gz파일은 이미 존재하네요"
        else
          wget $apache_targzurl       #아파치톰캣 안정버전 https://tomcat.apache.org/download-80.cgi
      fi
      tar -zxvf $apache_targzzipname
    fi
  else
   echo "!!!!!!!! 아파치설치안함  !!!!!!!! "
  fi

  #톰켓 기본포트인 8080개방
  firewall-cmd --zone=public --add-port=8080/tcp --permanent
  firewall-cmd --reload
}

function install_maven(){
  maven_targzzipname=apache-maven-3.5.3-bin.tar.gz
  maven_targzurl=http://mirror.navercorp.com/apache/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz
  maven_targzfilename=apache-maven-3.5.3                   #압축푼파일이름
  if [ $input_mavennum -eq 0  ]  # jdknum이면 tar.gz로 설치
  then
    if [ -d ~/$maven_targzfilename ]
    then
      echo "메이븐이 이미 존재합니다"
    else 
      if [ -e ~/$maven_targzzipname ]
        then
        echo "메이븐 파일은 이미 존재하네요"
        else
        wget $maven_targzurl     #최신버전 확인 https://maven.apache.org/download.cgi
      fi  
      tar -zxvf $maven_targzzipname
        #자바 환경변수 설정
      echo "MAVEN_HOME=~/$maven_targzfilename" >> ~/.bash_profile
      echo "export MAVEN_HOM" >> ~/.bash_profile
      echo "export PATH=\$PATH:\$MAVEN_HOME/bin" >> ~/.bash_profile           
      source ~/.bash_profile
    fi
  else
   echo "!!!!!!!! 메이븐 설치안함 !!!!!!!!"
  fi
}
function install_connect(){
  connect_targzzipname=tomcat-connectors-1.2.43-src.tar.gz
  connect_targzurl=http://apache.tt.co.kr/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.43-src.tar.gz
  connect_targzfilename=tomcat-connectors-1.2.43-src                   #압축푼파일이름
  if [ $input_connectnum -eq 0  ]  # jdknum이면 tar.gz로 설치
  then
    if [ -d ~/$connect_targzfilename ]
      then
        echo "커넥트가 이미 존재합니다!!!"
      else
        #12일에한 전체설치후 포트처리(그냥 firewall로만 해도 될것같지만 안되는 경우에는 이친구가 꼭필요하다)
        yum install -y httpd setroubleshoot-server selinux-policy-devel policycoreutils-python
        yum install -y gcc gcc-c++ httpd-devel
        wget $connect_targzurl    #최신버전 https://tomcat.apache.org/download-connectors.cgi
        tar -zxvf $connect_targzzipname
        cd ~/$connect_targzfilename/native
        ./configure --with-apxs=/usr/bin/apxs && make && make install
        firewall-cmd --permanent --zone=public --add-port=80/tcp
        firewall-cmd --reload
        semanage port -a -t http_port_t -p tcp 8009 #Connector port적어야함
        cd ~
    fi
    #커넥트 환경설정을 자동으로해줌
    if [ -e ~/etc/httpd/conf.modules.d/mod_jk.conf ]
    then
      echo "mod_jk.conf가 존재한다는건 기본설정이 되있는거니깐 설정안합니다"
    else
    # mod_jk.conf생성
      
      sleep 1
      echo "<VirtualHost *:80>" > /etc/httpd/conf.d/vhost.conf
      echo "  ServerName 'jhs'" >> /etc/httpd/conf.d/vhost.conf
      echo "  JkMount /* tomcat" >> /etc/httpd/conf.d/vhost.conf
      echo "</VirtualHost>" >> /etc/httpd/conf.d/vhost.conf
    sleep 1
      echo "worker.list=tomcat" > /etc/httpd/conf.d/workers.properties
      echo "worker.tomcat.port=8009" >> /etc/httpd/conf.d/workers.properties
      echo "worker.tomcat.host=127.0.0.1" >> /etc/httpd/conf.d/workers.properties
      echo "worker.tomcat.type=ajp13" >> /etc/httpd/conf.d/workers.properties
    sleep 1
      echo "LoadModule jk_module modules/mod_jk.so" > /etc/httpd/conf.modules.d/mod_jk.conf
      echo "<IfModule mod_jk.c>" >> /etc/httpd/conf.modules.d/mod_jk.conf
      echo " JkWorkersFile conf.d/workers.properties" >> /etc/httpd/conf.modules.d/mod_jk.conf
      echo " JkLogFile logs/mod_jk.log" >> /etc/httpd/conf.modules.d/mod_jk.conf
      echo " Jkshmfile run/mod_jk.shm" >> /etc/httpd/conf.modules.d/mod_jk.conf
      echo " JkLogLevel info" >> /etc/httpd/conf.modules.d/mod_jk.conf
      echo " JkLogStampFormat '[%a %b %d %H:%M:%S %Y]'" >> /etc/httpd/conf.modules.d/mod_jk.conf
      echo " JkOptions +ForwardKeySize +ForwardURICompat -ForwardDirectories" >> /etc/httpd/conf.modules.d/mod_jk.conf
      echo " JkRequestLogFormat '%w %R %V %T %U %q'" >> /etc/httpd/conf.modules.d/mod_jk.conf
      echo "</IfModule>" >> /etc/httpd/conf.modules.d/mod_jk.conf
      #
      ## 이제 톰켓 설정을 확인하자 이건 셀프임 톰켓 여러대 사용하거나 봐야할곳들
      # 아파치톰캣 / conf / server.xml 에서
      # <Server port="8005" shutdown="SHUTDOWN">                      // 변경하고 "8005"를 변경하고
      # <Connector port="8080" protocol="HTTP/1.1"
      #               connectionTimeout="20000"
      #               redirectPort="8443" />                         //   에서 "8080"과 ridirectPort 를 바꿔준다
      # <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />  // Connector port는 workers.properties에서 ridirectPort 는 위와 동일하게한다.
      #       systemctl restart httpd
    fi
  else
   echo "!!!!!!!! 커넥트 설치안함 !!!!!!!!"
  fi
}
function install_jenkins(){
  jenkins_targzurl=http://mirrors.jenkins.io/war-stable/latest/jenkins.war
  jenkins_targzfilename=jenkins.war
  if [ $input_jenkinsnum -eq 0  ]  # jdknum이면 tar.gz로 설치
  then
    if [ -e ~/$apache_targzfilename/webapps/jenkins.war ]
    then
      echo "젠킨슨 파일이 이미 존재합니다"
    else
      cd ~/$apache_targzfilename/webapps
      wget $jenkins_targzurl
      cd ~
    fi
  else
   echo "!!!!!!!! 젠킨스 설치안함 !!!!!!!!"
  fi
}

#마리아db설치
function maria_db(){
  #등록 내용 다운받기위한 마리아db설정 (참조) -> https://downloads.mariadb.org/mariadb/repositories/#mirror=ka 
  echo "[mariadb]" > /etc/yum.repos.d/MariaDB.repo
  echo "name = MariaDB" >> /etc/yum.repos.d/MariaDB.repo
  echo "baseurl = http://yum.mariadb.org/10.1/centos7-amd64" >> /etc/yum.repos.d/MariaDB.repo
  echo "gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB" >> /etc/yum.repos.d/MariaDB.repo
  echo "gpgcheck=1" >> /etc/yum.repos.d/MariaDB.repo

  yum install -y MariaDB-server MariaDB-client 

  #mariaDB utf-8설정
  echo "###################" >> /etc/my.cnf
  echo "[client-server]" >> /etc/my.cnf
  echo "[client]" >> /etc/my.cnf
  echo "default-character-set=utf8" >> /etc/my.cnf
  echo "[mysqld]" >> /etc/my.cnf
  echo "init_connect=SET collation_connection=utf8_general_ci" >> /etc/my.cnf
  echo "init_connect=SET NAMES utf8" >> /etc/my.cnf
  echo "character_set_server=utf8" >> /etc/my.cnf
  echo "collation-server=utf8_general_ci" >> /etc/my.cnf
  echo "[mysqld_safe]" >> /etc/my.cnf
  echo "[mysqldump]" >> /etc/my.cnf
  echo "default-character-set=utf8" >> /etc/my.cnf
  echo "max_allowed_packet=256M" >> /etc/my.cnf
  echo "[mysql]" >> /etc/my.cnf
  echo "default-character-set=utf8" >> /etc/my.cnf
  echo "!includedir /etc/my.cnf.d" >> /etc/my.cnf
  echo "###################" >> /etc/my.cnf
 #10) utf-8 설정하기 -> vi /etc/my.cnf에 아래내용으로 다 바꿔준후 centOS 재부팅
   ############################
     [client-server]

     [client]
     default-character-set=utf8

     [mysqld]
     init_connect=SET collation_connection=utf8_general_ci
     init_connect=SET NAMES utf8
     character_set_server=utf8
     collation-server=utf8_general_ci

     [mysqld_safe]

     [mysqldump]
     default-character-set=utf8
     max_allowed_packet=256M

     [mysql]
     default-character-set=utf8

     !includedir /etc/my.cnf.d
   ############################
   
   #이후의 마리아 db 기본설정
  # 5) 시스템 재시작 -> init 6
  # 6) MariaDB 연결 -> mysql -uroot -p1234 (프로그램) (사용자 root) 
  # 7) 데이터베이스 교체 -> use mysql
  # 8) 사용자 테이블에 비밀번호 적용하기 ->  update user set password = PASSWORD('1234');
  #           수정내용 적용하기          ->  flush privileges;
  # 9) select host, user from user; 테이블에 외부사용자 접근할수있도록 설정(사용자 생성)
  #       -> host칼럼에 값이 %가 있어야한다. //host에서 접근설정하는듯
  #       create user 'root'@'%' identified by '1234';  
  #       -> 접근 권한 추가
  #       grant all privileges on *.* to 'root'@'%';  #전체데이터베이스의 모든테이블에 권한추가
  #       -> 수정 내용 적용
  #       flush privileges;
}


function install_git(){
  if [ $input_gitnum -eq 0  ]  # jdknum이면 tar.gz로 설치
  then
    listgit=$(yum list installed | grep git.x86)
    echo $listgit
    if [ -z $listgit ]
    then
      echo "깃설치"
      yum -y install git
    else
      echo "깃은 이미 존재합니다."
    fi
  else
   echo "!!!!!!!! 깃설치안함 !!!!!!!!"
  fi
}
#추가된 리빌드해주는곳 나중에 함수화 해주면 더 편해지지 않을까..   여기부분은 변수화해서 사용할려면 전역으로 선언해야하는게 있음 아파치 파일이름 같은거
function rebuild_git(){
  if [ -d repo ]
   then
    echo "repo파일은 이미있습니다"
   else
    mkdir ~/repo
   cd ~/repo
   echo "1. 제대로 돌고있어??"
    if [ -d WebTest ]
      then
        echo "깃에서 이미 다운받았네요"
      else
        git clone https://github.com/trullo/WebTest.git
    fi
    echo "2. 제대로 돌고있어??" $apache_targzfilename
    cd ~/repo/WebTest
    source ~/.bash_profile
    git pull
    mvn clean package
    if [ -e ~/apache-tomcat-8.5.30/webapps/WebTest.war ]
      then
        rm -rf ~/apache-tomcat-8.5.30/webapps/WebTest.war
    fi
  ln -s ~/repo/WebTest/target/WebTest.war ~/apache-tomcat-8.5.30/webapps/ROOT.war
  fi
}

function rebuild(){
rm -rf ~/server/apache-tomcat-8.5.31/webapps/ROOT.war
rm -rf ~/server/apache-tomcat-8.5.31/webapps/ROOT
rm -rf ~/server2/apache-tomcat-8.5.31/webapps/ROOT.war
rm -rf ~/server2/apache-tomcat-8.5.31/webapps/ROOT
cd ~/repo/Spring_Server
git pull
mvn clean package
ln -s ~/repo/Spring_Server/target/Spring_Server-1.0.0-BUILD-SNAPSHOT.war ~/server/apache-tomcat-8.5.31/webapps/ROOT.war
cd ~/repo/Spring_Server2
git pull
mvn clean package
ln -s ~/repo/Spring_Server2/target/Spring_Server2-1.0.0-BUILD-SNAPSHOT.war ~/server2/apache-tomcat-8.5.31/webapps/ROOT.war  
sh ~/server/apache-tomcat-8.5.31/bin/shutdown.sh
sleep 1
sh ~/server/apache-tomcat-8.5.31/bin/startup.sh  
sleep 1
sh ~/server2/apache-tomcat-8.5.31/bin/shutdown.sh
sleep 1
sh ~/server2/apache-tomcat-8.5.31/bin/startup.sh
}

#시작부분
echo "설치를 방법을 선택해주세요"
echo "1. 전체설치"
echo "2. 프로젝트 다시 빌드하기"
echo "3. 설치 종료"
read a_input
check=$(yum list installed | grep wget)
echo $check
if [ -z $check ]
 then
  yum install -y wget
 else
  echo "wget은 이미 설치되어있습니다"
fi

if [ $a_input -eq 1 ]
 then
  install_git 
  install_jdk
  install_apache
  install_maven
  install_connect
  #install_jenkins
  #maria_db
  #rebuild_git
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
 elif [ $a_input -eq 2 ]
  then
   rebuild
   echo "리빌드가 완료했습니다"
 else
  echo "설치를 종료합니다"
fi 

# 권한설정 http.conf에서 User apache Group root로 바꿔준다.

for ((i=1987;i<2009;i++)) ; do
  load data local inpath '/root/csv/$i.csv' overwrite into table ontime partition (delayyear = '$i');