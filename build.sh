docker stop elk_stack
docker rm elk_stack
docker build -t vjm03/elk .
docker create -v ~/Code/docker-elk/data1:/data1 -p 5601:5601 -p 9200:9200 -p 9998:9998 --name elk_stack vjm03/elk
docker start elk_stack