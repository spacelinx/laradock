#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#
# To edit the 'php-fpm' base Image, visit its repository on Github
#    https://github.com/Laradock/php-fpm
#
# To change its version, see the available Tags on the Docker Hub:
#    https://hub.docker.com/r/laradock/php-fpm/tags/
#
# Note: Base Image name format {image-tag}-{php-version}


ARG LARADOCK_PHP_VERSION
ARG BASE_IMAGE_TAG_PREFIX=latest
FROM laradock/php-fpm:${BASE_IMAGE_TAG_PREFIX}-${LARADOCK_PHP_VERSION}

LABEL maintainer="Mahmoud Zalt <mahmoud@zalt.me>"

ARG LARADOCK_PHP_VERSION

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

# If you're in China, or you need to change sources, will be set CHANGE_SOURCE to true in .env.

ARG CHANGE_SOURCE=false
RUN if [ ${CHANGE_SOURCE} = true ]; then \
    # Change application source from deb.debian.org to aliyun source
    sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list && \
    sed -i 's/security-cdn.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
;fi

# always run apt update when start and after add new source list, then clean up at end.
RUN set -xe; \
    apt-get update -yqq && \
    pecl channel-update pecl.php.net && \
    apt-get install -yqq \
      apt-utils \
      gnupg2 \
      git \
      #
      #--------------------------------------------------------------------------
      # Mandatory Software's Installation
      #--------------------------------------------------------------------------
      #
      # Mandatory Software's such as ("mcrypt", "pdo_mysql", "libssl-dev", ....)
      # are installed on the base image 'laradock/php-fpm' image. If you want
      # to add more Software's or remove existing one, you need to edit the
      # base image (https://github.com/Laradock/php-fpm).
      #
      # next lines are here becase there is no auto build on dockerhub see https://github.com/laradock/laradock/pull/1903#issuecomment-463142846
      libzip-dev zip unzip && \
      if [ ${LARADOCK_PHP_VERSION} = "7.3" ] || [ ${LARADOCK_PHP_VERSION} = "7.4" ] || [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
        docker-php-ext-configure zip; \
      else \
        docker-php-ext-configure zip --with-libzip; \
      fi && \
      # Install the zip extension
      docker-php-ext-install zip && \
      php -m | grep -q 'zip'

#
#--------------------------------------------------------------------------
# Optional Software's Installation
#--------------------------------------------------------------------------
#
# Optional Software's will only be installed if you set them to `true`
# in the `docker-compose.yml` before the build.
# Example:
#   - INSTALL_SOAP=true
#


###########################################################################
# SSH2:
###########################################################################

ARG INSTALL_SSH2=false

RUN if [ ${INSTALL_SSH2} = true ]; then \
    # Install the ssh2 extension
    apt-get -y install libssh2-1-dev && \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
        pecl install -a ssh2-0.13; \
    else \
        pecl install -a ssh2-1.3.1; \
    fi && \
    docker-php-ext-enable ssh2 \
;fi



###########################################################################
# SQL SERVER:
###########################################################################

ARG INSTALL_MSSQL=false

RUN apt update \
    && apt -y install git \
    && apt -y --no-install-recommends install apt-utils libxml2-dev gnupg apt-transport-https \
    && apt clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN apt -yq install curl gnupg ca-certificates \
    && curl -L https://deb.nodesource.com/setup_14.x | bash \
    && apt install -yq nodejs

RUN set -eux; \
  if [ ${INSTALL_MSSQL} = true ]; then \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      apt-get -yqq install freetds-dev libsybdb5 \
      && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so \
      && docker-php-ext-install mssql pdo_dblib \
      && php -m | grep -oiE '^mssql$' \
      && php -m | grep -oiE '^pdo_dblib$' \
    ;else \
      ###########################################################################
      # Ref from https://github.com/Microsoft/msphpsql/wiki/Dockerfile-for-adding-pdo_sqlsrv-and-sqlsrv-to-official-php-image
      ###########################################################################
      # Add Microsoft repo for Microsoft ODBC Driver 13 for Linux
      apt-get install -yqq apt-transport-https gnupg lsb-release \
      && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
      && curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
      && apt update && apt install wget -y \
      && wget http://archive.ubuntu.com/ubuntu/pool/main/g/glibc/multiarch-support_2.27-3ubuntu1.4_amd64.deb \
      && apt install ./multiarch-support_2.27-3ubuntu1.4_amd64.deb \
      && apt update && ACCEPT_EULA=Y  apt -y --no-install-recommends install msodbcsql17 unixodbc-dev \
      && ACCEPT_EULA=Y apt-get install -yqq unixodbc unixodbc-dev libgss3 odbcinst msodbcsql17 locales \
      && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
      && ln -sfn /etc/locale.alias /usr/share/locale/locale.alias \
      && locale-gen \
      && if [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "70000" ]; then \
        pecl install pdo_sqlsrv-5.3.0 sqlsrv-5.3.0 \
      ;elif [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "70100" ]; then \
        pecl install pdo_sqlsrv-5.6.1 sqlsrv-5.6.1 \
      ;elif [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "70200" ]; then \
        pecl install pdo_sqlsrv-5.8.1 sqlsrv-5.8.1 \
      ;else \
        pecl install pdo_sqlsrv sqlsrv \
      ;fi \
      && docker-php-ext-enable pdo_sqlsrv sqlsrv \
      && php -m | grep -oiE '^pdo_sqlsrv$' \
      && php -m | grep -oiE '^sqlsrv$' \
    ;fi \
  ;fi



###########################################################################
# ping:
###########################################################################

USER root

ARG INSTALL_PING=false

RUN if [ ${INSTALL_PING} = true ]; then \
    apt-get -y install inetutils-ping \
;fi


###########################################################################
# Check PHP version:
###########################################################################

RUN set -xe; php -v | head -n 1 | grep -q "PHP ${LARADOCK_PHP_VERSION}."

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

COPY ./laravel.ini /usr/local/etc/php/conf.d
COPY ./xlaravel.pool.conf /usr/local/etc/php-fpm.d/

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

# Configure non-root user.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data

# Adding the faketime library to the preload file needs to be done last
# otherwise it will preload it for all commands that follow in this file
RUN if [ ${INSTALL_FAKETIME} = true ]; then \
    echo "/usr/lib/x86_64-linux-gnu/faketime/libfaketime.so.1" > /etc/ld.so.preload \
;fi

# # Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN rm -rf /var/www/*
COPY ./app/composer.json /var/www/composer.json
COPY ./app/package.json /var/www/package.json 

RUN cd /var/www/ \
  && composer install --prefer-dist --no-scripts --no-dev --no-autoloader && rm -rf /root/.composer

# Copy codebase
COPY ./app/ /var/www/

# Finish composer
RUN cd /var/www/ \
  && composer dump-autoload --no-scripts --no-dev --optimize \
  && composer update

# Configure locale.
ARG LOCALE=POSIX
ENV LC_ALL ${LOCALE}

WORKDIR /var/www
# USER root

RUN chown -R www-data:www-data . 
RUN chmod -R 777 .

RUN php artisan cache:clear
RUN php artisan config:clear
RUN php artisan config:cache
CMD ["php-fpm"]

EXPOSE 9000
