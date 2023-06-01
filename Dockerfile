FROM php:8.2-fpm

# Instale as dependências necessárias
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Configure a extensão PHP necessária
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Instale o Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Defina o diretório de trabalho como o diretório da aplicação Laravel
WORKDIR /var/www/html

# Copie os arquivos do aplicativo Laravel para o contêiner
# COPY . .

# ####################################
# COMPOSER
# ####################################
# RUN composer install --no-interaction --no-dev --optimize-autoloader
# RUN composer update --no-interaction --no-dev --optimize-autoloader

# Copie o arquivo de exemplo .env
# COPY .env.example .env

# Execute as migrações e as sementes
# RUN php artisan migrate --force
# RUN php artisan db:seed --force

# ####################################
# ORACLE INSTANTCLIENT
# ####################################
RUN mkdir /opt/oracle && cd /opt/oracle

ADD oracle/instantclient-basic-linux.x64-12.1.0.2.0.zip /opt/oracle
ADD oracle/instantclient-sdk-linux.x64-12.1.0.2.0.zip /opt/oracle

# Instalacao do instantclient
RUN  unzip /opt/oracle/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /opt/oracle \
    && unzip /opt/oracle/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /opt/oracle \
    && ln -s /opt/oracle/instantclient_12_1/libclntsh.so.12.1 /opt/oracle/instantclient_12_1/libclntsh.so \
    && ln -s /opt/oracle/instantclient_12_1/libclntshcore.so.12.1 /opt/oracle/instantclient_12_1/libclntshcore.so \
    && ln -s /opt/oracle/instantclient_12_1/libocci.so.12.1 /opt/oracle/instantclient_12_1/libocci.so \
    && rm -rf /opt/oracle/*.zip

ENV LD_LIBRARY_PATH  /opt/oracle/instantclient_12_1:${LD_LIBRARY_PATH}

# Instalacao libs oracle php
RUN echo 'instantclient,/opt/oracle/instantclient_12_1/' | pecl install oci8 \
    && docker-php-ext-enable oci8 \
    && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient_12_1,12.1 \
    && docker-php-ext-install pdo_oci 



# Copie a configuração do cron
# COPY cron /etc/cron.d/cron

# Dê permissão de execução ao script cron
# RUN chmod 0644 /etc/cron.d/cron

# Ative o cron
# RUN crontab /etc/cron.d/cron

# Execute o servidor PHP-FPM
CMD ["php-fpm"]

