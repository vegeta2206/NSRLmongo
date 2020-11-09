#/bin/bash

docker run --privileged --network=host -p 27017:27017 -p 27018:27018 -v /dockers/nsrl/data_db:/data/db -v /dockers/nsrl/sources:/data/sources --name nsrl_sept2020 -d nsrl:1.0
