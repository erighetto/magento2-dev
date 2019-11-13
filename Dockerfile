FROM php:7.2-apache

RUN apt-get update && apt-get install -y \
    ca-certificates \
    cron \
    default-mysql-client \
    git \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libsodium-dev \
    libxslt1-dev \
    libzip-dev \
    lynx \
    msmtp \
    nano \
    patch \
    psmisc \
    unzip \
    wget \
    zip \

RUN docker-php-ext-configure \
    gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/; \
    docker-php-ext-install \
    bcmath \
    gd \
    intl \
    mbstring \
    pdo_mysql \
    xsl \
    zip \
    opcache \
    soap
    
RUN pecl install xdebug redis libsodium \
    && docker-php-ext-enable xdebug redis sodium \
    && docker-php-source delete

RUN apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*    

COPY docker-php-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-php-entrypoint

RUN {  \
    echo ';;;;;;;;;; Recommended PHP.ini settings ;;;;;;;;;;'; \
    echo 'memory_limit = 768M'; \
    echo 'upload_max_filesize = 64M'; \
    echo 'post_max_size = 64M'; \
    echo 'max_execution_time = 18000'; \
    echo 'date.timezone = Europe/Rome'; \
    echo 'error_reporting = E_ALL & ~E_NOTICE & ~E_WARNING'; \
    echo ';;;;;;;;;; xDebug ;;;;;;;;;;'; \
    echo 'xdebug.remote_host = "host.docker.internal"'; \
    echo 'xdebug.idekey = "phpstorm"'; \
    echo 'xdebug.default_enable = 1'; \
    echo 'xdebug.remote_autostart = 1'; \
    echo 'xdebug.remote_connect_back = 0'; \
    echo 'xdebug.remote_enable = 1'; \
    echo 'xdebug.remote_handler = "dbgp"'; \
    echo 'xdebug.remote_port = 9000'; \
    echo ';;;;;;;;;; Mailhog ;;;;;;;;;;'; \ 
    echo 'sendmail_path = "/usr/bin/msmtp -C /etc/msmtprc -a -t"'; \   
	} >> /usr/local/etc/php/conf.d/custom-php-settings.ini	

RUN usermod -u 1000 www-data; \
    a2enmod rewrite; \
    curl -o /tmp/composer-setup.php https://getcomposer.org/installer; \
    curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig; \
    php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"; \
    php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer; \
    rm /tmp/composer-setup.php; \
    chmod +x /usr/local/bin/composer; \
    composer global require hirak/prestissimo;

RUN curl -o n98-magerun2.phar http://files.magerun.net/n98-magerun2-latest.phar; \
    chmod +x ./n98-magerun2.phar; \
    mv n98-magerun2.phar /usr/local/bin/n98-magerun;    

EXPOSE 80 443 9000

WORKDIR /var/www/html
