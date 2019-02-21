---
layout: default
title: "Create A Stream using SCDF and Java DSL"
description: "Create and deploy a Stream using Spring Cloud Data Flow Server (SCDF) and Java DSL"

nav_order: 3
parent: "Spring Cloud Stream"

references_file: references.md

permalink: /spring-cloud-stream/create-stream-using-scdf-java-dsl

gh-repo: codeaches/scdf-pcf-stream-java-dsl
gh-badge: [star, watch, follow]

date: 2019-02-20 1:00:00 -0700
---

In this tutorial, let's use the Java-based DSL provided by the `spring-cloud-dataflow-rest-client` module to deploy a stream to PCF. 

***The Java DSL is a convenient wrapper around the DataFlowTemplate class that enables creating and deploying streams programmatically***

## Table of contents
{: .no_toc }

1. TOC
{:toc}

---

## Prerequisites

 - [Open Source JDK 11]{:target="_blank"}
 - An account on Pivotal Cloud Foundry (PCF). You can create one [here](https://console.run.pivotal.io/){:target="_blank"}.
 - A running SCDF server on PCF. Follow the steps found at [Deploy SCDF to PCF]{:target="_blank"}.

## Build Stream deployer Java application

**Create a Spring Boot starter project using Spring Initializr**

Let's utilize [spring initializr web tool](https://start.spring.io/){:target="_blank"} and create a skeleton spring boot project for Stream deployer application. I have updated Group field to **com.codeaches**, Artifact to **dslStreamDeployer** and selected `Cloud Stream` dependencies. I have selected Java Version as **11**

Click on `Generate Project`. The project will be downloaded as `dsl-stream-deployer.zip` file on your hard drive.

>Alternatively, you can also generate the project in a shell using cURL.

```sh
curl https://start.spring.io/starter.zip  \
       -d dependencies=cloud-stream \
       -d language=java \
       -d javaVersion=11 \
       -d type=maven-project \
       -d groupId=com.codeaches \
       -d artifactId=dslStreamDeployer \
       -d bootVersion=2.1.3.RELEASE \
       -o dsl-stream-deployer.zip
```

**Import and build**

Import the project in STS as `Existing Maven project` and do Maven build.

> Add the jaxb-runtime dependancy if the build fails with an error "javax.xml.bind.JAXBException: Implementation of JAXB-API has not been found on module path or classpath"

```xml
<dependency>
    <groupId>org.glassfish.jaxb</groupId>
    <artifactId>jaxb-runtime</artifactId>
</dependency>
```

**Add ``spring-cloud-dataflow-rest-client`` dependency**

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-dataflow-rest-client</artifactId>
    <version>1.7.4.RELEASE</version>
</dependency>
```

Add SCDF server URL and login credentials to `application.properties` file.

```java
spring.cloud.dataflow.client.server-uri=https://codeaches-scdf-server.cfapps.io
spring.cloud.dataflow.client.authentication.basic.username=user001
spring.cloud.dataflow.client.authentication.basic.password=pass001
```

Add SCDF server URL and login credentials to `application.properties` file.

```java
@Autowired
DataFlowOperations dataFlowOperations;

void registerHttpSource() {

    dataFlowOperations.appRegistryOperations().register("myHttpSource", ApplicationType.source,
            "maven://org.springframework.cloud.stream.app:http-source-rabbit:2.1.0.RELEASE", null, true);
}

void registerLogSink() {

    dataFlowOperations.appRegistryOperations().register("myLogSink", ApplicationType.sink,
            "maven://org.springframework.cloud.stream.app:log-sink-rabbit:2.1.0.RELEASE", null, true);
}

void createAndDeployStream() {

    Stream.builder(dataFlowOperations).name("myStreamApp")
            .definition("myHttpSource | myLogSink").create().deploy();
}
```

Let's create a stream by triggering the above created methods.

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

## Summary

Congratulations! You just deployed a stream on Cloudfoundry(PCF) using JAVA DSL.

{% include_relative {{ page.references_file }} %}
