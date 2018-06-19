#### JDK버전 변경후 에러발생시

검색을 통해 찾아본결과 이러한 에러는 JDK버전 변경시 발생하고 톰켓버전 변경과 Servlet버전이 맞지않아도 발생하는것 같다.

에러 부분
  java.util.concurrent.ExecutionException: org.apache.catalina.LifecycleException: Failed to start component....
  ......


해결방법
1. JDK로 버전변경으로 인한 에러발생시
  직접해본 방법으로 jdk재설치 - 환경변수 재설정 - 이클립스 설정 - java -installed JREs - add추가 - 이클립스 서버 전부삭제 
  - 종료후 .m2/repository 전부삭제후 이클립스 재실행됨
  //고쳤는데도 갑자기 왜 실행이 되는지 모르겠음 다음번에도 이런일이있으면 상세히 파악필
  
2. Servlet으로 인한 에러발생
  가장 많이 보이는 증상같은데 Servlet버전이 톰켓과 호환이 안되서 발생하기도 한다.
  이럴때 일단 pom.xml의 Servlet <dependency>의 버전을 확인해서 수정한다.
  그래도 이상이있으면 tomcat/lib/servlet-api.jar를 jdk/lib/로 옮긴다.
  이외에는 나중에 문제발생시 추가할예정
  
