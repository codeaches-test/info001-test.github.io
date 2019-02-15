---
layout: default
title: "Deploy SCDF to PCF"

nav_order: 5
parent: "Spring Cloud Stream"

references_file: references.md
permalink: /spring-cloud-stream/deploy-scdf-to-pcf

gh-repo: codeaches/scdf-pcf-stream
gh-badge: [star, watch, follow]

---

# Deploy Spring Cloud Data Flow Server (SCDF) to cloudfoundry (PCF)
{: .no_toc }

---

Spring Cloud Data Flow (SCDF) is a toolkit for building data integration and real-time data processing pipelines. The SCDF server uses Spring Cloud Deployer, to deploy data pipelines onto modern runtimes such as Cloud Foundry (PCF). 

In this tutorial, let's download and deploy Spring Cloud Data Flow Server (SCDF) to cloudfoundry. We shall also download `SCDF CLI` which can be used to connect to `SCDF sever`.

## Table of contents
{: .no_toc }

1. TOC
{:toc}

---

## Prerequisites {#prerequisites}

 - JDK 8
 - An account on Pivotal Cloud Foundry (PCF). You can create one [here](https://console.run.pivotal.io/){:target="_blank"}
 - PCF Command Line Interface (CLI) installed on your computer. PCF CLI can be found in `tools` section of your [PCF account](https://console.run.pivotal.io/tools){:target="_blank"}

## Add Services from PCF Marketplace {#add_services_marketplace}

SCDF Server needs redis, rabbitmq and mysql services. Let's create them before we install SCDF Server.

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

For the above mentioned purposes, let's create rabbitmq, redis and mysql services from marketplace, using the below `cf` commands.

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

**Validate that all the 3 services are created successfully**

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

Let's download `spring-cloud-dataflow-server-cloudfoundry-1.7.3.RELEASE.jar` jar file from Spring repo using `wget` command.

```sh
$ wget http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-server-cloudfoundry/1.7.3.RELEASE/spring-cloud-dataflow-server-cloudfoundry-1.7.3.RELEASE.jar
```

>Version 1.7.3.RELEASE was the latest one during this tutorial creation. 

Let's provide configuration details like credentials to the Cloud Foundry instance so that the SCDF Server can itself spawn applications. Let's specify these configuration details in `manifest.yml` file.

```yml
---
applications:
- name: data-flow-server
  random-route: true
  memory: 2G
  disk_quota: 2G
  instances: 1
  path: spring-cloud-dataflow-server-cloudfoundry-1.7.3.RELEASE.jar
  routes:
  - route: codeaches-scdf-server.cfapps.io
  env:
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

You need to replace `{org}`, `{space}`, `{email}` and `{password}` with values specific to your cloudfoundry account. You will also need to replace `codeaches` with the name of your choice.  
Note that the `basic security` is enabled for SCDF server.

**Deploy SCDF server jar file to cloudfoundry**

Deploy `spring-cloud-dataflow-server-cloudfoundry-1.7.3.RELEASE.jar` to PCF using the `cf push` command.

```sh
$ cf push -f manifest.yml
```

**Validate the SCDF server deployment**

Verify the SCDF Server deployment status on cloudfoundry.

```sh
$ cf apps
Getting apps in org <org> / space <space> as as <email>...
OK

name               requested state   instances   memory   disk   urls
data-flow-server   started           1/1         2G       2G     codeaches-scdf-server.cfapps.io
```

## Download Spring Cloud Dataflow Shell {#download_scdf_shell}

`Spring Cloud Dataflow Shell` is a command line interface (CLI) which can be used to connect to SCDF Server. We shall use this CLI to deploy streams. 

Let's download the SCDF shell jar file using wget command.

```sh
$ wget http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/1.7.3.RELEASE/spring-cloud-dataflow-shell-1.7.3.RELEASE.jar
```

**Connect to SCDF Server from SCDF shell**

Start the `spring-cloud-dataflow-shell` spring boot application.

```sh
$ java -jar spring-cloud-dataflow-shell-1.7.3.RELEASE.jar
  ____                              ____ _                __
 / ___| _ __  _ __(_)_ __   __ _   / ___| | ___  _   _  __| |
 \___ \| '_ \| '__| | '_ \ / _` | | |   | |/ _ \| | | |/ _` |
  ___) | |_) | |  | | | | | (_| | | |___| | (_) | |_| | (_| |
 |____/| .__/|_|  |_|_| |_|\__, |  \____|_|\___/ \__,_|\__,_|
  ____ |_|    _          __|___/                 __________
 |  _ \  __ _| |_ __ _  |  ___| | _____      __  \ \ \ \ \ \
 | | | |/ _` | __/ _` | | |_  | |/ _ \ \ /\ / /   \ \ \ \ \ \
 | |_| | (_| | || (_| | |  _| | | (_) \ V  V /    / / / / / /
 |____/ \__,_|\__\__,_| |_|   |_|\___/ \_/\_/    /_/_/_/_/_/

1.7.3.RELEASE

Welcome to the Spring Cloud Data Flow shell. For assistance hit TAB or type "help".
server-unknown:>
```

Connect to SCDF Server using the route generated by cloudfoundry for the SCDF server. We will need to pass credentials of SCDF server as we have enabled the authentication.

```sh
server-unknown:>dataflow config server --uri "https://codeaches-scdf-server.cfapps.io" --username "user001" --password "pass001" --skip-ssl-validation "true"

Shell mode: classic, Server mode: classic
dataflow:>
```
## Summary {#summary}

Congratulations! You just deployed SCDF Server to pivotal cloud foundry.
