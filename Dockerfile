FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /usr/app

ADD . /usr/app

ARG APP_VERSION
ARG APP_PROFILE

RUN set -ex; \
    mvn versions:set-property -Dproperty=project.version -DnewVersion=${APP_VERSION} && \
    mvn package -P${APP_PROFILE}

FROM eclipse-temurin:17-jre-jammy 
WORKDIR /usr/app
RUN apt-get update && \
    apt-get install -y netcat acl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/app/target/*.jar /usr/app/app.jar
COPY --from=build /usr/app/.env /usr/app/.env
COPY --from=build /usr/app/docker-entrypoint.sh /usr/app/docker-entrypoint.sh

RUN chmod +x /usr/app/docker-entrypoint.sh

ENTRYPOINT ["/usr/app/docker-entrypoint.sh"]