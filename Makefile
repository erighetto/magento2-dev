build:
	docker build -t erighetto/m2d:latest .

run:
	docker run --rm -it -v "${PWD}/index.php:/var/www/html/index.php" -p 8080:80 -p 8443:443 erighetto/m2d