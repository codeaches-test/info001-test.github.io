---
layout: default
title: "Deploy SCDF to PCF"
description: "Deploy Spring Cloud Data Flow Server (SCDF) to cloudfoundry (PCF)"

nav_order: 1
parent: "Spring Cloud Stream"

references_file: references.md
permalink: /spring-cloud-stream/deploy-scdf-to-pcf

gh-repo: codeaches/scdf-pcf-stream
gh-badge: [star, watch, follow]

date: 2019-02-19 1:00:00 -0700
---

In this tutorial, let's download and deploy Spring Cloud Data Flow Server (SCDF) to cloudfoundry. 

## Table of contents
{: .no_toc }

1. TOC
{:toc}

---

## Prerequisites {#prerequisites}

 - An account on Pivotal Cloud Foundry (PCF). You can create one [here](https://console.run.pivotal.io/){:target="_blank"}

## Add Services from PCF Marketplace {#add_services_marketplace}

SCDF Server needs redis, rabbitmq and mysql services. Let's create them before we dewnload and deploy the SCDF Server.

**Log into your PCF account using `cf` command**

Replace `<email>`, `<password>`, `<org>` and `<space>` with values specific to your cloudfoundry account.

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

**Add the required services from marketplace for SCDF Server**

 - SCDF server needs a valid Redis store for its analytic repository. 
 - It also needs an RDBMS for storing stream/task definitions, application registration, and for job repositories. 
 - RabbitMQ is used as a messaging middleware between streaming apps and is bound to each deployed streaming app. Kafka is other option. Let's stick with rabbit for this tutorial purposes.

For the above mentioned purposes, let's create rabbitmq, redis and mysql services from marketplace, using `cf create-service` command.

```sh
$ cf create-service cloudamqp lemur my_rabbit
Creating service instance my_rabbit in org <org> / space <space> as <email>...
OK

$ cf create-service rediscloud 30mb my_redis
Creating service instance my_redis in org <org> / space <space> as <email>...
OK

$ cf create-service cleardb spark my_mysql
Creating service instance my_mysql in org <org> / space <space> as <email>...
OK
```

**Validate that all the 3 services are created successfully using ``cf services`` command**

```sh
$ cf services
Getting services in org <org> / space <space> as <email>....

name        service      plan    bound apps   last operation
my_mysql    cleardb      spark                create succeeded
my_rabbit   cloudamqp    lemur                create succeeded
my_redis    rediscloud   30mb                 create succeeded
```

## Download SCDF Server and deploy it to cloudfoundry {#download_deploy_scdf_to_pcf}

**Download SCDF server jar file for cloudfoundry**

Let's download `spring-cloud-dataflow-server-cloudfoundry-1.7.4.RELEASE.jar` jar file (latest one during this tutorial creation) from Spring repo using `wget` command.

```sh
$ wget http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-server-cloudfoundry/1.7.4.RELEASE/spring-cloud-dataflow-server-cloudfoundry-1.7.4.RELEASE.jar
```

**Create manifest.mf file**

Cloudfoundry expects configuration details like credentials, maven coordinates as part of SCDF jar file deployment. So, let's create `manifest.yml` file and specify these configuration details.

> You need to replace `{org}`, `{space}`, `{email}` and `{password}` with values specific to your cloudfoundry account. You will also need to replace the value for `route` with the name of your choice. However, make sure that the route ends with `.cfapps.io`.  

```yml
---
applications:
- name: data-flow-server
  random-route: true
  memory: 2G
  disk_quota: 2G
  instances: 1
  path: spring-cloud-dataflow-server-cloudfoundry-1.7.4.RELEASE.jar
  routes:
  - route: codeaches-scdf-server.cfapps.io
  env:
    JBP_CONFIG_OPEN_JDK_JRE: '{ jre: { version: 1.8.+ } }'
    SPRING_APPLICATION_NAME: data-flow-server
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL: https://api.run.pivotal.io
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG: {org}
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE: {space}
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME: {email}
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD: {password}
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN: cfapps.io
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES: my_rabbit
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_TASK_SERVICES: my_mysql
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SKIP_SSL_VALIDATION: true
    SPRING_APPLICATION_JSON: '{"maven":{"remote-repositories":{"repo1":{"url":"https://repo.spring.io/libs-release"},"repo2":{"url":"https://oss.sonatype.org/content/repositories/snapshots"},"repo3":{"url":"https://oss.sonatype.org/content/repositories/snapshots"}}}}'
    security.basic.enabled: true
    security.user.name: user001
    security.user.password: pass001
    security.user.role: VIEW,CREATE,MANAGE
  services:
    - my_mysql
    - my_redis
```

> The `basic security` is enabled for SCDF server using `user001` and `pass001` as the credentials. These credentials must be provided when logging into SCDF server.

**Deploy SCDF server jar file to cloudfoundry**

Deploy `spring-cloud-dataflow-server-cloudfoundry-1.7.4.RELEASE.jar` to PCF using the `cf push` command.

```sh
$ cf push -f manifest.yml
```

**Validate the SCDF server deployment**

Verify the SCDF Server deployment status on cloudfoundry using `cf apps` command.

```sh
$ cf apps
Getting apps in org <org> / space <space> as as <email>...
OK

name               requested state   instances   memory   disk   urls
data-flow-server   started           1/1         2G       2G     codeaches-scdf-server.cfapps.io
```

## Summary {#summary}

Congratulations! You just downloaded and deployed the SCDF Server to pivotal cloudfoundry(PCF).
