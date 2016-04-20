# DokuWiki in Docker

## Running
```
docker-compose up -d dokuwiki
```

Classic way
```
docker run -d --name dokuwiki -p 8080:8080/tcp -v dokuwiki_conf:/opt/dokuwiki/conf -v dokuwiki_data:/opt/dokuwiki/data andrey01/dokuwiki
```

## Accessing
```
http://ip:8080
```

You can login with the Default credentials
```
Login: admin
Password: 12345
```

## Persistent data
Keep the following directories under the explicit Docker volumes
```
/opt/dokuwiki/conf
/opt/dokuwiki/data
```
