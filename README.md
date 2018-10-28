# magento2-dev
Magento 2 development environment featuring:
* composer
* xdebug
* redis
* ssmtp
* apache

# docker-compose.yml sample

    version: '2'  
    services:
          apache:
            image: erighetto/magento2-dev
            ports:
              - "80:80"
            depends_on:
              - db
            links:
              - db
              - mailhog
            volumes:
              - ./../httpdocs:/var/www/html:cached
              - ~/.composer/auth.json:/root/.composer/auth.json
            environment:
              SSMTP_SERVER: mailhog
              SSMTP_PORT: 1025
              SSMTP_HOSTNAME: apache
              SSMTP_FROM: magento2@apache
        
          db:
            image: mariadb
            ports:
              - "3306:3306"
            volumes_from:
              - dbdata
            environment:
              MYSQL_ROOT_PASSWORD: magento2
              MYSQL_DATABASE: magento2
              MYSQL_USER: magento2
              MYSQL_PASSWORD: magento2
        
          dbdata:
            image: tianon/true
            volumes:
              - /var/lib/mysql
        
          pma:
            image: phpmyadmin/phpmyadmin
            environment:
              PMA_HOST: db
              PMA_USER: magento2
              PMA_PASSWORD: magento2
              PHP_UPLOAD_MAX_FILESIZE: 1G
              PHP_MAX_INPUT_VARS: 1G
            ports:
              - "8080:80"
        
          mailhog:
            image: mailhog/mailhog
            ports:
              - "1025:1025"
              - "8025:8025"

