# php-nginx-mariadb

Single container that can conveniently run PHP-MySQL apps.

The default database password is `root`.

## Using

```sh
docker run --rm -d -v `pwd`/www:/www -v `pwd`/db:/var/lib/mysql -p=3306:3306 -p=8080:8080 php-app -f
```

```sh
docker exec -it php-app sh
```

## Testing

```sh
docker stop php-app; docker build -t php-app .; docker run --rm -d -v `pwd`/www:/www -v `pwd`/db:/var/lib/mysql -p=3306:3306 -p=8080:8080 --name=php-app php-app; docker logs php-app -f
```