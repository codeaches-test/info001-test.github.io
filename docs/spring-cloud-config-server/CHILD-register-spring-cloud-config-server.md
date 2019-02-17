---
layout: default
title: "Register Spring Cloud Config Server on PCF"
description: "Register Spring Cloud Config Server on cloudfoundry (PCF)"

nav_order: 1
parent: "Spring Cloud Config Server"

references_file: references.md

permalink: /spring-cloud-config/register-spring-cloud-config-server-on-cloudfoundry

gh-repo: codeaches/config-client-pcf-app
gh-badge: [star, watch, follow]

date: 2018-11-28 1:00:00 -0700
---

Config Server for Pivotal Cloud Foundry (PCF) is an externalized configuration service, which gives us with a central place to manage an application's external properties across all environments.
Spring cloud config client applications can use the Config Server to manage configurations across environments.

In this tutorial, let's register Config Server for Pivotal Cloud Foundry (PCF) and configure it's git coordinates.

## Table of contents
{: .no_toc }

1. TOC
{:toc}

---

## Prerequisites {#prerequisites}

 - [Open Source JDK 11]{:target="_blank"}
 - [Apache Maven 3.6.0]{:target="_blank"}
 - [Spring Tool Suite 4 IDE]{:target="_blank"}
 - [An account on Pivotal Cloud Foundry (PCF)]{:target="_blank"}
 - PCF Command Line Interface (CLI) installed on your computer. PCF CLI can be found in `tools` section of your [PCF CLI account]{:target="_blank"}

## Add properties files in github for each of your environments {#git}

For this tutorial purpose, I have created a [Configuration GIT repository]{:target="_blank"} which has sample files `cfgclientpetstore.properties` and `petDetails.json` for both dev and prod environments.

## Register Spring Config Server Application on PCF {#register}

***Log into your PCF account using `cf` command***

>Replace `<email>`, `<password>`, `<org>` and `<space>` with values specific to your cloudfoundry account.

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

***Create a  configuration file ``cfg.json``***

```json
{  
  "git":{  
    "uri":"https://github.com/codeaches/config-files-example.git",
    "label":"master",
    "searchPaths":"dev"
  }
}
```

***Register the ``config-server``***

```sh
$ cf create-service -c cfg.json p-config-server trial my-config-server
```
## Summary {#summary}

Congratulations! You just a spring cloud config server on Pivotal cloudfoundry (PCF) using PCF CLI.

{% include_relative {{ page.references_file }} %}
