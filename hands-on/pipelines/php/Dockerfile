FROM php:8.0-apache
WORKDIR /var/www/html

# Copy all website files to container
COPY ./src/ .

# Set correct permissions for Apache
RUN chown -R www-data:www-data /var/www/html \
    && a2enmod rewrite

# Expose port 80
EXPOSE 80