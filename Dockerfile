FROM docker.io/library/alpine:3.14.0 as BUILDER
RUN apk --no-cache add \
    composer=~2 \
    git=~2 \
    php7=~7.4 \
    php7-json=~7.4 \
    php7-phar=~7.4 \
    php7-simplexml=~7.4 \
    php7-tokenizer=~7.4 \
    php7-xmlwriter=~7.4

RUN wget -q -O /usr/local/bin/box 'https://github.com/box-project/box2/releases/download/2.7.5/box-2.7.5.phar' \
    && chmod +x /usr/local/bin/box \
    && sed -i -e 's/^;phar.readonly = On/phar.readonly = Off/' /etc/php7/php.ini

WORKDIR /app
RUN git clone -q 'https://github.com/php-parallel-lint/PHP-Parallel-Lint.git' . \
    && git checkout -q 'v1.2.0' \
    && composer install --optimize-autoloader --prefer-dist --no-interaction --no-dev --quiet \
    && sed -i -e 's/"main": "parallel-lint.php",/"main": "parallel-lint",/' box.json \
    && box build

FROM docker.io/library/alpine:3.14.0

LABEL 'com.github.actions.name'='PHP Parallel Lint'
LABEL 'com.github.actions.description'='PHP linting using PHP Parallel Lint'

RUN apk --no-cache add \
    jq=~1 \
    php7=~7.4 \
    php7-ctype=~7.4 \
    php7-dom=~7.4 \
    php7-fileinfo=~7.4 \
    php7-intl=~7.4 \
    php7-json=~7.4 \
    php7-phar=~7.4 \
    php7-simplexml=~7.4 \
    php7-sockets=~7.4 \
    php7-tokenizer=~7.4 \
    php7-xml=~7.4 \
    php7-xmlwriter=~7.4

COPY --from=BUILDER /app/parallel-lint.phar /usr/local/bin/parallel-lint

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

WORKDIR /app
