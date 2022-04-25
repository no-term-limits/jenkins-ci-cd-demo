ARG GOGS_VERSION=0.11.86
ARG APP_TIMEZONE=UTC

FROM gogs/gogs:${GOGS_VERSION}

# timezone
RUN ln -snf /usr/share/zoneinfo/${APP_TIMEZONE} /etc/localtime && echo ${APP_TIMEZONE} > /etc/timezone && date
