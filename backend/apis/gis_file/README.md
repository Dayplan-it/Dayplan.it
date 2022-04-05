# 설명

임의의 도형이상이 없는지역을 추출하였음
용량이 커서 QGIS전처리이후 알수없는 null값 발생
추후 서울시 전역으로 수정예정

# 1. 테이블이름

장고 ORM을 사용하지않으므로 수동으로 입력해줘야함

- 노드 : node2
- 링크 : link2

터미널에서 실행

shp2pgsql -I -s 4326 링크파일경로 link2 | psql -U 유저이름 -d DB이름

shp2pgsql -I -s 4326 링크파일경로 node2 | psql -U 유저이름 -d DB이름
