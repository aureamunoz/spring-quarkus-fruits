# Spring JPA on Quarkus

The purpose of this demo is to showcase how you can :

- Create a new `Quarkus Spring JPA project` using a maven archetype
- Configure the Database `Datasource` using env var to access a `PostgreSQL DB`
- Create the different Java classes used by Spring to expose using `REST` the `CRUD` methods
- Run you project `locally` or in the `cloud`
- Deploy it on the cluster using :
  - Plain kubernetes files
  - The `Halkyon` operator and Developer `hal` client

# Table of contents

  * [How to play locally](#how-to-play-locally)
     * [Create a project](#create-a-project)
     * [Add some code](#add-some-code)
        * [Fruit entity](#fruit-entity)
        * [FruitRepository](#fruitrepository)
        * [FruitController](#fruitcontroller)
        * [NotFoundException](#notfoundexception)
        * [UnsupportedMediaTypeException](#unsupportedmediatypeexception)
        * [UnprocessableEntityException](#unprocessableentityexception)
        * [index.html](#indexhtml)
  * [Deploy on the cluster](#deploy-on-the-cluster)
     * [With the help of hal/halkyon](#with-the-help-of-halhalkyon)
     * [Using plain k8s resources](#using-plain-k8s-resources)
  * [Using locally H2](#using-locally-h2)

## How to play locally

### Create a project

- Generate the project within a terminal
   ```bash
   mvn io.quarkus:quarkus-maven-plugin:1.1.1.Final:create \
       -DprojectGroupId=dev.snowdrop \
       -DprojectArtifactId=quarkus-spring-jpa \
       -DclassName="com.example.FruitController" \
       -Dpath="/api/fruits" \
       -Dextensions="spring-web,resteasy-jsonb,spring-data-jpa"
   ```

- Add postgres dependency

To install the PostgreSQL driver dependency, just run the following command
```shell script
    ./mvnw quarkus:add-extension -Dextensions="jdbc-postgresql"
   ```
Or add the following dependency in the `pom.xml` file:
   ```xml
   <dependency>
         <groupId>io.quarkus</groupId>
         <artifactId>quarkus-jdbc-postgresql</artifactId>
   </dependency>
   ```  
   
- Add datasource config

Make sure to have the following configuration in your `application.properties` (located in src/main/resources)
   ```
   quarkus.datasource.url=jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
   quarkus.datasource.username=${DB_USER}
   quarkus.datasource.password=${DB_PASSWORD}   
   quarkus.datasource.driver=org.postgresql.Driver
   quarkus.datasource.max-size=8
   quarkus.datasource.min-size=2
   ```
### Add some code

- Add a package `service` that will contain the needed code to access and manipulate the fruits via the endpoint
  
  #### Fruit entity
  ```java
    package com.example.service;
    
    import javax.persistence.Entity;
    import javax.persistence.GeneratedValue;
    import javax.persistence.GenerationType;
    import javax.persistence.Id;
    
    @Entity
    public class Fruit {
    
        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Integer id;
    
        private String name;
    
        public Fruit() {
        }
    
        public Fruit(String type) {
            this.name = type;
        }
    
        public Integer getId() {
            return id;
        }
    
        public void setId(Integer id) {
            this.id = id;
        }
    
        public String getName() {
            return name;
        }
    
        public void setName(String name) {
            this.name = name;
        }
    }
   ```
  #### FruitRepository
  
  We need a Spring `CrudRepository` providing methods modifying the database.
  ```java
      package com.example.service;
      
      import org.springframework.data.repository.CrudRepository;
      
      public interface FruitRepository extends CrudRepository<Fruit, Integer> {
      }
  ```
  #### FruitController
  
  And finally, the Spring Controller that will allow CRUD operation on fruits:
   ```java
      package com.example.service;
      
      import com.example.exception.NotFoundException;
      import com.example.exception.UnprocessableEntityException;
      import com.example.exception.UnsupportedMediaTypeException;
      import org.springframework.http.HttpStatus;
      import org.springframework.web.bind.annotation.*;
      
      import java.util.List;
      import java.util.Objects;
      import java.util.Spliterator;
      import java.util.stream.Collectors;
      import java.util.stream.StreamSupport;
      
      @RestController
      @RequestMapping(value = "/api/fruits")
      public class FruitController {
      
          private final FruitRepository repository;
      
          public FruitController(FruitRepository repository) {
              this.repository = repository;
          }
      
          @GetMapping("/{id}")
          public Fruit get(@PathVariable(value="manolo") Integer id) {
              verifyFruitExists(id);
      
              return repository.findById(id).get();
          }
      
          @GetMapping
          public List<Fruit> getAll() {
              Spliterator<Fruit> fruits = repository.findAll()
                      .spliterator();
      
              return StreamSupport
                      .stream(fruits, false)
                      .collect(Collectors.toList());
          }
      
          @ResponseStatus(HttpStatus.CREATED)
          @PostMapping
          public Fruit post(@RequestBody(required = false) Fruit fruit) {
              verifyCorrectPayload(fruit);
      
              return repository.save(fruit);
          }
      
          @ResponseStatus(HttpStatus.OK)
          @PutMapping("/{id}")
          public Fruit put(@PathVariable("id") Integer id, @RequestBody(required = false) Fruit fruit) {
              verifyFruitExists(id);
              verifyCorrectPayload(fruit);
      
              fruit.setId(id);
              return repository.save(fruit);
          }
      
          @ResponseStatus(HttpStatus.NO_CONTENT)
          @DeleteMapping("/{id}")
          public void delete(@PathVariable("id") Integer id) {
              verifyFruitExists(id);
      
              repository.deleteById(id);
          }
      
          private void verifyFruitExists(Integer id) {
              if (!repository.existsById(id)) {
                  throw new NotFoundException(String.format("Fruit with id=%d was not found", id));
              }
          }
      
          private void verifyCorrectPayload(Fruit fruit) {
              if (Objects.isNull(fruit)) {
                  throw new UnsupportedMediaTypeException("Fruit cannot be null");
              }
      
              if (Objects.isNull(fruit.getName()) || fruit.getName().trim().length() == 0) {
                  throw new UnprocessableEntityException("The name is required!");
              }
      
              if (!Objects.isNull(fruit.getId())) {
                  throw new UnprocessableEntityException("Id field must be generated");
              }
          }
      
      }
     ```
- Add some Exceptions to manage the errors

- First, create an `exception` package and add the following classes
  #### NotFoundException
  ```java
  package com.example.exception;
  
  import org.springframework.http.HttpStatus;
  import org.springframework.web.bind.annotation.ResponseStatus;
  
  @ResponseStatus(HttpStatus.NOT_FOUND)
  public class NotFoundException extends RuntimeException {
  
      public NotFoundException(String message) {
          super(message);
      }
  
  }
  ```
  #### UnsupportedMediaTypeException
  ```java
  package com.example.exception;
  
  import org.springframework.http.HttpStatus;
  import org.springframework.web.bind.annotation.ResponseStatus;
  
  @ResponseStatus(HttpStatus.UNPROCESSABLE_ENTITY)
  public class UnprocessableEntityException extends RuntimeException {
  
      public UnprocessableEntityException(String message) {
          super(message);
      }
  
  }
  ```
  #### UnprocessableEntityException
  ```java
  package com.example.exception;
  
  import org.springframework.http.HttpStatus;
  import org.springframework.web.bind.annotation.ResponseStatus;
  
  @ResponseStatus(HttpStatus.UNPROCESSABLE_ENTITY)
  public class UnprocessableEntityException extends RuntimeException {
  
      public UnprocessableEntityException(String message) {
          super(message);
      }
  
  }
  ```
- Add an index.html in `/resources/META-INF.resources` in order to provide an UI
  #### index.html
  ```xml
    <!doctype html>
     <html>
     <head>
         <meta charset="utf-8"/>
         <title>CRUD Mission - Quarkus </title>
         <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/wingcss/0.1.8/wing.min.css"/>
         <style>
             input[type=number] {
                 width: 100%;
                 padding: 12px 20px;
                 margin: 8px 0;
                 display: inline-block;
                 border: 1px solid #ccc;
                 border-radius: 4px;
                 box-sizing: border-box;
                 -webkit-transition: .5s;
                 transition: .5s;
                 outline: 0;
                 font-family: 'Open Sans', serif;
             }
         </style>
         <!-- Load AngularJS -->
         <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.4.8/angular.min.js"></script>
         <script type="text/javascript">
           var app = angular.module("FruitManagement", []);
     
           //Controller Part
           app.controller("FruitManagementController", function ($scope, $http) {
     
             //Initialize page with default data which is blank in this example
             $scope.fruits = [];
     
             $scope.form = {
               id: -1,
               name: ""
             };
     
             //Now load the data from server
             _refreshPageData();
     
             //HTTP POST/PUT methods for add/edit fruits
             $scope.update = function () {
               var method = "";
               var url = "";
               var data = {};
               if ($scope.form.id == -1) {
                 //Id is absent so add fruits - POST operation
                 method = "POST";
                 url = '/api/fruits';
                 data.name = $scope.form.name;
               } else {
                 //If Id is present, it's edit operation - PUT operation
                 method = "PUT";
                 url = '/api/fruits/' + $scope.form.id;
                 data.name = $scope.form.name;
               }
     
               $http({
                 method: method,
                 url: url,
                 data: angular.toJson(data),
                 headers: {
                   'Content-Type': 'application/json'
                 }
               }).then(_success, _error);
             };
     
             //HTTP DELETE- delete fruit by id
             $scope.remove = function (fruit) {
               $http({
                 method: 'DELETE',
                 url: '/api/fruits/' + fruit.id
               }).then(_success, _error);
             };
     
             //In case of edit fruits, populate form with fruit data
             $scope.edit = function (fruit) {
               $scope.form.name = fruit.name;
               $scope.form.id = fruit.id;
             };
     
               /* Private Methods */
             //HTTP GET- get all fruits collection
             function _refreshPageData() {
               $http({
                 method: 'GET',
                 url: '/api/fruits'
               }).then(function successCallback(response) {
                 $scope.fruits = response.data;
               }, function errorCallback(response) {
                 console.log(response.statusText);
               });
             }
     
             function _success(response) {
               _refreshPageData();
               _clearForm()
             }
     
             function _error(response) {
               alert(response.data.message || response.statusText);
             }
     
             //Clear the form
             function _clearForm() {
               $scope.form.name = "";
               $scope.form.id = -1;
             }
           });
         </script>
     </head>
     <body ng-app="FruitManagement" ng-controller="FruitManagementController">
     
     <div class="container">
         <h1>CRUD Mission - Quarkus</h1>
         <p>
             This application demonstrates how a Quarkus application implements a CRUD endpoint to manage <em>fruits</em>.
             This management interface invokes the CRUD service endpoint, that interact with a ${db.name} database using JDBC.
         </p>
     
         <h3>Add/Edit a fruit</h3>
         <form ng-submit="update()">
             <div class="row">
                 <div class="col-6"><input type="text" placeholder="Name" ng-model="form.name" size="60"/></div>
             </div>
             <input type="submit" value="Save"/>
         </form>
     
         <h3>Fruit List</h3>
         <div class="row">
             <div class="col-2">Name</div>
         </div>
         <div class="row" ng-repeat="fruit in fruits">
             <div class="col-2">{{ fruit.name }}</div>
             <div class="col-8"><a ng-click="edit( fruit )" class="btn">Edit</a> <a ng-click="remove( fruit )" class="btn">Remove</a>
             </div>
         </div>
     </div>
     
     </body>
     </html>
  ```

- Add import.sql with following content
  ```sql
  insert into fruit (name) values ('Cherry');
  insert into fruit (name) values ('Apple');
  insert into fruit (name) values ('Banana');
  ```
  We use `quarkus.hibernate-orm.database.generation=drop-and-create` in conjunction with `import.sql` , the database schema will be properly recreated and your data (stored in import.sql) will be used to repopulate it from scratch
  ```
      quarkus.hibernate-orm.database.generation=drop-and-create
      quarkus.hibernate-orm.sql-load-script=import.sql
  ```

- Launch the database
  ```bash
  docker run --ulimit memlock=-1:-1 -it --rm=true --memory-swappiness=0 --name quarkus_test \
     -e POSTGRES_USER=quarkus_test \
     -e POSTGRES_PASSWORD=quarkus_test \
     -e POSTGRES_DB=quarkus_test \
     -p 5432:5432 \
     postgres:11.5
  ```

- Launch the app in dev mode
  ```bash
  mvn compile quarkus:dev \
     -DDB_HOST=localhost \
     -DDB_PORT=5432 \
     -DDB_USER=quarkus_test \
     -DDB_PASSWORD=quarkus_test \
     -DDB_NAME=quarkus_test
  ```

## Deploy on the cluster

### With the help of hal/halkyon

- Create first a component for the Maven module using the hal client
  ```bash
  hal component create 
  ? Runtime quarkus
  ? Version 1.1.1.Final
  ? Expose microservice Yes
  ? Port 8080
  ? Use code generator No
  ? Local component directory  [Use arrows to move, space to select, type to filter]
    quarkus-rest
  ❯ quarkus-spring-jpa
  ```
- Create next a `Postgresql Database` capability using the following hal command
  ```bash
  hal capability create
  ? Category database
  ? Type Postgres
  ? Version  [Use arrows to move, space to select, type to filter]
  ...
  ```  
- Next, bind/link the capability information to the Component using the secret
  ```bash
  hal link create
  ❯ Selected target: 
  ? Target component: quarkus-spring-jpa
  ? Use Secret Yes
  ❯ Selected link type: Secret
  ? Secret (only potential matches shown) postgres-capability-config
  ? Name (quarkus-spring-jpa-link-1579770809293878000) (quarkus-spring-jpa-link....)
  ```  
- Check if the component,link and capability have their status equal to ready
  ```bash
  oc get component,link,capability
  ```
- Open the index page to create some `Fruits` and enjoy !

### Using plain k8s resources
  
## Using locally H2

- Steps to execute to create the Quarkus REST project
```bash
mvn io.quarkus:quarkus-maven-plugin:1.1.1.Final:create \
    -DprojectGroupId=dev.snowdrop \
    -DprojectArtifactId=quarkus-spring-jpa \
    -DclassName="com.example.FruitController" \
    -Dpath="/api/fruits" \
    -Dextensions="spring-web,resteasy-jsonb,spring-data-jpa"
```
- Add postgres dependency
   ```xml
   <dependency>
         <groupId>io.quarkus</groupId>
         <artifactId>quarkus-jdbc-h2</artifactId>
   </dependency>
   ```
- Add datasource config
  ```
  quarkus.datasource.url=jdbc:h2:tcp://localhost/mem:quarkus_test
  quarkus.datasource.driver=org.h2.Driver
  quarkus.datasource.username=quarkus_test
  quarkus.datasource.password=
  
  quarkus.hibernate-orm.dialect=org.hibernate.dialect.H2Dialect
  quarkus.hibernate-orm.database.generation=drop-and-create
  quarkus.hibernate-orm.sql-load-script=import.sql
  ```
- Add import.sql with following content
  ```sql
  insert into fruit (name) values ('Cherry');
  insert into fruit (name) values ('Apple');
  insert into fruit (name) values ('Banana'); 
  ```
  
- Start locally the h2 database
  ```bash
  cd /path/to/h2/installed
  java -cp bin/h2-1.4.199.jar org.h2.tools.Server -ifNotExists
  ```  
  
- Launch the app in dev mode
  ```bash
  mvn compile quarkus:dev  
  ```

