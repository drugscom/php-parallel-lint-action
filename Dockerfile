FROM ghcr.io/drugscom/composer-action:1.0.13 as BUILDER
RUN apk --no-cache add \
    php8-openssl=~8.0

RUN wget -q -O /usr/local/bin/box 'https://github.com/box-project/box2/releases/download/2.7.5/box-2.7.5.phar' \
    && chmod +x /usr/local/bin/box \
    && sed -i -e 's/^;phar.readonly = On/phar.readonly = Off/' /etc/php8/php.ini

WORKDIR /app
RUN git clone -q 'https://github.com/php-parallel-lint/PHP-Parallel-Lint.git' . \
    && git checkout -q 'v1.3.0' \
    && composer install --optimize-autoloader --prefer-dist --no-interaction --no-dev --quiet \
    && sed -i -e 's/"main": "parallel-lint.php",/"main": "parallel-lint",/' box.json \
    && box build

FROM alpine:3.15.0

LABEL 'com.github.actions.name'='PHP Parallel Lint'
LABEL 'com.github.actions.description'='PHP linting using PHP Parallel Lint'

RUN apk --no-cache add \
    jq=~1 \
    php8=~8.0 \
    php8-ctype=~8.0 \
    php8-dom=~8.0 \
    php8-fileinfo=~8.0 \
    php8-intl=~8.0 \
    php8-phar=~8.0 \
    php8-simplexml=~8.0 \
    php8-sockets=~8.0 \
    php8-tokenizer=~8.0 \
    php8-xml=~8.0 \
    php8-xmlwriter=~8.0 \
    && ln -s /usr/bin/php8 /usr/local/bin/php

COPY --from=BUILDER /app/parallel-lint.phar /usr/local/bin/parallel-lint

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

WORKDIR /app
