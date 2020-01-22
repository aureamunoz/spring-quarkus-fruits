# Spring JPA on Quarkus

TODO : Define what is the goal of this demo

## Table of contents

  * [How to play locally](#how-to-play-locally)

## How to play locally

1- Generate the project within a terminal
```bash
mvn io.quarkus:quarkus-maven-plugin:1.1.1.Final:create \
    -DprojectGroupId=dev.snowdrop \
    -DprojectArtifactId=quarkus-spring-jpa \
    -DclassName="com.example.FruitController" \
    -Dpath="/api/fruits" \
    -Dextensions="spring-web,resteasy-jsonb,spring-data-jpa"
```

2- Add postgres dependency
```
    <dependency>
          <groupId>io.quarkus</groupId>
          <artifactId>quarkus-jdbc-postgresql</artifactId>
    </dependency>
```

3- Add datasource config

```
quarkus.datasource.url=jdbc:postgresql:quarkus_test
quarkus.datasource.driver=org.postgresql.Driver
quarkus.datasource.username=quarkus_test
quarkus.datasource.password=quarkus_test
quarkus.datasource.max-size=8
quarkus.datasource.min-size=2

quarkus.hibernate-orm.database.generation=drop-and-create
quarkus.hibernate-orm.sql-load-script=import.sql
```

4- Add import.sql with following content
```
insert into fruit (name) values ('Cherry');
insert into fruit (name) values ('Apple');
insert into fruit (name) values ('Banana');
```

5- Launch the database
```
docker run --ulimit memlock=-1:-1 -it --rm=true --memory-swappiness=0 --name quarkus_test -e POSTGRES_USER=quarkus_test -e POSTGRES_PASSWORD=quarkus_test -e POSTGRES_DB=quarkus_test -p 5432:5432 postgres:11.5
```

6- Copy the following code source files from crud-example

exception
service
index.html

7- Launch the app in dev mode
```
mvn compile quarkus:dev
```


