### Operations Servive

To check if the operation service is working try the below command.

```
docker exec cli.unibw.de curl -v peer0.deoni.de:9443/healthz

docker exec cli.unibw.de curl -v peer0.salers.de:9443/healthz

docker exec cli.unibw.de curl -v peer0.brangus.de:9443/healthz

docker exec cli.unibw.de curl -v peer0.pinzgauer.de:9443/healthz

docker exec cli.unibw.de curl -v peer0.tuxer.de:9443/healthz
```