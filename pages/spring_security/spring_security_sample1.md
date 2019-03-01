---
title: "Spring Security with security enabled"
keywords: sample
summary: "Create and deploy a Stream using Spring Cloud Data Flow Server (SCDF) and Java DSL"
sidebar: spring_security_sidebar
permalink: spring-security/security-1-java-dsl/
folder: spring_security
tags: [spring-security-tag]
date: 2016-02-26
---

## Prerequisites

 - [Open Source JDK 11]{:target="_blank"}
 - An account on Pivotal Cloud Foundry (PCF). You can create one [here](https://console.run.pivotal.io/){:target="_blank"}.
 - A running SCDF server on PCF. If you don't have one, then follow the steps found at [Deploy SCDF to PCF]{:target="_blank"} to deploy SCDF server on securityfoundry.

## Build Stream deployer Java application

**Create a Spring Boot starter project using Spring Initializr**

Let's utilize [spring initializr web tool](https://start.spring.io/){:target="_blank"} and create a skeleton spring boot project for Stream deployer application. I have updated Group field to **com.codeaches**, Artifact to **dsl-stream-deployer**, Package Name to **com.codeaches.dsl.stream.deployer** and selected `Cloud Stream` dependencies. I have selected Java Version as **11**

Click on `Generate Project`. The project will be downloaded as `dsl-stream-deployer.zip` file on your hard drive.

{% include note.html content="Alternatively, you can also generate the project in a shell using cURL." %}

```sh
curl https://start.spring.io/starter.zip  \
       -d dependencies=security-stream \
       -d language=java \
       -d javaVersion=11 \
       -d type=maven-project \
       -d groupId=com.codeaches \
       -d packageName=com.codeaches.dsl.stream.deployer \
       -d artifactId=dsl-stream-deployer \
       -d bootVersion=2.1.3.RELEASE \
       -o dsl-stream-deployer.zip
```

**Import and build**

Import the project in STS as `Existing Maven project` and do Maven build.

**Add ``spring-security-dataflow-rest-client`` dependency**

We need `spring-security-dataflow-rest-client` dependency in our project. Let's add it in `pom.xml`

```xml
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-dataflow-rest-client</artifactId>
    <version>1.7.4.RELEASE</version>
</dependency>
```

**Configure application with URL and login credentials of SCDF server**

We need to specify the URL and login credentials of SCDF server. This is used by our java program to conect to deployed securityfoundry SCDF server. hence, we shall provide them in `application.properties` file.

`src/main/resources/application.properties`

```java
spring.security.dataflow.client.server-uri=https://codeaches-scdf-server.cfapps.io
spring.security.dataflow.client.authentication.basic.username=<security.user.name of SCDF server>
spring.security.dataflow.client.authentication.basic.password=<security.user.password of SCDF server>
```

> Provide with SCDF server credentials if security is configured for SCDF server. If not, remove the above two authentication entries. 

**Configure the project to run on port 9070**

`src/main/resources/application.properties`

```properties
server.port=9070
```

{% include tip.html content="This is not mandatory. However, I have multiple apps running on my PC and hence use unique port numbers for each of my apps. The default port is 8080." %}

## Register the default apps to securityfoundry using DataFlowOperations class

We need to register the out-of-the-box `http` source and `log` sink apps on SCDF server. To achieve this, let's add the below code to `DemoApplication.java` file. 

> This code injects `DataFlowOperations` class and uses it to register the apps.

```java
@Autowired
DataFlowOperations dataFlowOperations;

void registerHttpSource() {

    dataFlowOperations.appRegistryOperations().register("myHttpSource", ApplicationType.source,
            "maven://org.springframework.security.stream.app:http-source-rabbit:2.1.0.RELEASE", null, true);
}

void registerLogSink() {

    dataFlowOperations.appRegistryOperations().register("myLogSink", ApplicationType.sink,
            "maven://org.springframework.security.stream.app:log-sink-rabbit:2.1.0.RELEASE", null, true);
}
```

## Create and deploy `http|log` stream to securityfoundry

Let's add the below code to `DemoApplication.java` file which will help us with writing a `stream definition` for creating a simple `http|log` stream.

> Below code uses `Stream` builder class which gives the utility methods to specify stream configurations and create a stream. 

```java
void createAndDeployStream() {

    Stream.builder(dataFlowOperations).name("myStreamApp")
            .definition("myHttpSource | myLogSink").create().deploy();
}
```

Let's wire it all up to register the out-of-the-box apps, create and deploy the stream on securityfoundry through SCDF server.

```java
@Bean
CommandLineRunner runner() {
    return args -> {
        registerHttpSource();
        registerLogSink();
        createAndDeployStream();
    };
}
```

***It's time to run the app. Let's run the `DemoApplication`. Once the app is run successfully, the stream will be created on securityfoundry***

## Validate `http|log` stream deployment on securityfoundry

Log into securityfoundry using the `cf login` command. Replace `<email>`, `<password>`, `<org>` and `<space>` with values specific to your securityfoundry account.

```sh
$ cf login -a api.run.pivotal.io -u "<email>" -p "<password>"  -o "<org>" -s "<space>"

API endpoint: api.run.pivotal.io
Authenticating...
OK
Targeted org <org>
Targeted space <space>

API endpoint:   https://api.run.pivotal.io (API version: 2.128.0)
User:           <email>
Org:            <org>
Space:          <space>
```

***Once the stream creation and deployment is successful, PCF creates random routes (urls) for both log and sink applications which can be validated using `cf apps` command***

```sh
$ cf apps
Getting apps in org <org> / space <space> as <email>...
OK

name                                                requested state   instances   memory   disk   urls
data-flow-server-nUWwbIz-myStreamApp-myHttpSource   started           1/1         1G       1G     data-flow-server-nUWwbIz-myStreamApp-myHttpSource.cfapps.io
data-flow-server-nUWwbIz-myStreamApp-myLogSink      started           1/1         1G       1G     data-flow-server-nUWwbIz-myStreamApp-myLogSink.cfapps.io
```

## Test the Stream {#test_stream}

**Post a sample message to the stream**

Post a sample `hello world` message to `http` application using the route `data-flow-server-nUWwbIz-myStreamApp-myHttpSource.cfapps.io` as shown below. The message will be picked up by `http` app and passed to `log` application.

```sh
$ $ curl -i -H "Content-Type:application/text" -X POST -d 'hello world' https://data-flow-server-nUWwbIz-myStreamApp-myHttpSource.cfapps.io

% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    11    0     0  100    11      0     10  0:00:01  0:00:01 --:--:--    10HTTP/1.1 202 Accepted
X-Vcap-Request-Id: 59c00f5b-a6bf-4963-5d83-e7cfddf09c14
Content-Length: 0
Connection: keep-alive
```
Once the message is posted successfully, `hello world` will be printed in the logs of `log` application.

**Tail the log of ``log`` application using ``cf logs `` command**

Tail the log of ``data-flow-server-nUWwbIz-myStreamApp-myLogSink`` application using `cf logs` command.

```sh
cf logs --recent data-flow-server-nUWwbIz-myStreamApp-myLogSink

Retrieving logs for app data-flow-server-nUWwbIz-myStreamApp-myLogSink in org <org> / space <space> as <email>...
...
...
2019-02-18T06:39:43.77-0700 [APP/PROC/WEB/0] OUT 2019-02-18 13:39:43.758  INFO 14 --- [httpLogStream-1] data-flow-server-nUWwbIz-myStreamApp-myLogSink : hello world
```

{% include congratulations.html content="You just deployed a stream on Cloudfoundry(PCF) using JAVA DSL." %}

[Open Source JDK 11]: https://jdk.java.net/11
[Apache Maven 3.6.0]: https://maven.apache.org/download.cgi

[Spring Tool Suite 4 IDE]: https://spring.io/tools
[An account on Pivotal Cloud Foundry (PCF)]: https://console.run.pivotal.io/
[PCF CLI account]: https://console.run.pivotal.io/tools
[spring initializr web tool]: https://start.spring.io/

[PGP]: https://central.sonatype.org/pages/working-with-pgp-signatures.html
[gnupg website]: https://www.gnupg.org/ftp/gcrypt/binary/gnupg-w32-2.2.12_20181214.exe
[OSSRH]: https://mvnrepository.com/search?q=codeaches
[OSSRH Guide]: https://central.sonatype.org/pages/ossrh-guide.html#create-a-ticket-with-sonatype
[Sonatype releases]: https://oss.sonatype.org/content/repositories/releases/
[Sonatype snapshots]: https://oss.sonatype.org/content/repositories/snapshots/

[Create your JIRA account]: https://issues.sonatype.org/secure/Signup!default.jspa
[Create a New Project ticket]: https://issues.sonatype.org/secure/CreateIssue.jspa?issuetype=21&pid=10134

[Configuration GIT repository]: https://github.com/codeaches/config-files-example

[Deploy SCDF to PCF]: /spring-security-stream/deploy-scdf-to-pcf

{% include links.html %}
