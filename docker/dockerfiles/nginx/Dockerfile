FROM nginx:1.31-alpine AS nginx

COPY . /var/www/app

RUN ln -s /var/www/app/storage/app/public /var/www/app/public/storage

EXPOSE 80