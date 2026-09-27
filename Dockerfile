FROM php:8.2-apache

# Extensiones necesarias:
# - pdo_mysql: usada por conexion.php (toda la app usa PDO, no mysqli)
# - gd (con soporte webp): usada solo por Logos/convert_logo.php (utilidad de línea de comandos, opcional)
RUN docker-php-ext-install pdo pdo_mysql
# /admin y /cliente a través de router.php) y permitir que .htaccess
# sobreescriba la configuración (AllowOverride All).
RUN a2enmod rewrite \
    && sed -ri -e 's!AllowOverride None!AllowOverride All!g' /etc/apache2/apache2.conf

WORKDIR /var/www/html
COPY . /var/www/html/

# Apache corre como www-data; el proyecto no escribe archivos en runtime
# salvo Logos/ (convert_logo.php), así que basta con dar permisos ahí.
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80