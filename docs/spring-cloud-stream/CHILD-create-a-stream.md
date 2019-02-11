---
layout: default
title: "Create A Stream using SCDF"

nav_order: 6
parent: "Spring Cloud Stream"

references_file: references.md

permalink: /spring-cloud-create-stream-using-scdf

gh-repo: codeaches/scdf-pcf-stream
gh-badge: [star, watch, follow]

sitemap:
  changefreq: daily
  priority: 1
---

# Deploy Spring Cloud Data Flow Server (SCDF) to cloudfoundry (PCF)
{: .no_toc }

---

Spring Cloud Data Flow (SCDF) is a toolkit for building data integration and real-time data processing pipelines. The SCDF server uses Spring Cloud Deployer, to deploy data pipelines onto modern runtimes such as Cloud Foundry (PCF). 

In this tutorial, let's create a simple ``http|log`` stream which consumes payload over HTTP and prints it. We shall use an out-of-the-box `http` application which is a REST service which consumes the data and pushes it to the queue. We shall use out-of-the-box `log` application which consumes the data from queue and prints it to the log file. We need Spring Cloud Data Flow Server (SCDF) for creating and deploying the stream to cloudfoundry, the tutorial of which can be found at [Deploy SCDF to PCF]{:target="_blank"}.

## Table of contents
{: .no_toc }

1. TOC
{:toc}

---

## Prerequisites {#prerequisites}

 - An account on Pivotal Cloud Foundry (PCF). You can create one [here](https://console.run.pivotal.io/){:target="_blank"}
 - PCF Command Line Interface (CLI) installed on your computer. PCF CLI can be found in `tools` section of your [PCF account](https://console.run.pivotal.io/tools){:target="_blank"}
 - A running SCDF server on PCF. Follow the steps found at [Deploy SCDF to PCF]{:target="_blank"}.

## Log into your PCF account using `cf` command {#add_services_marketplace}

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

## Create a `http|log` Stream {#create_htp_log_stream}

Cloudfoundry provides with few out-of-the-box source and sink spring boot applications which can be used for stream creation. Lets register the out-of-the-box `http` and `log` spring boot apps, specific to `rabbit` messaging broker, in SCDF server.

```sh
dataflow:>app register --name http --type source --uri maven://org.springframework.cloud.stream.app:http-source-rabbit:2.0.3.RELEASE
Successfully registered application 'source:http'

dataflow:>app register --name log --type sink --uri maven://org.springframework.cloud.stream.app:log-sink-rabbit:2.0.2.RELEASE
Successfully registered application 'sink:log'
```

Let's utilize the above registered apps `http` and `log` to create ``http|log`` stream. This stream, `httpLogStream`, will take HTTP POST request and prints the body in log file.

```sh
dataflow:>stream create --name httpLogStream --definition "http | log" --deploy
Created new stream 'httpLogStream'
Deployment request has been sent
```

>Once the stream creation and deployment is successful, PCF creates random routes (urls) for both log and sink applications which can be validated using `cf apps` command.

```sh
$ cf apps
Getting apps in org org <org> / space <space> as <email>
OK

name                                          requested state   instances   memory   disk   urls
data-flow-server-hd6lIb0-httpLogStream-http   started           1/1         1G       1G     data-flow-server-hd6lIb0-httpLogStream-http.cfapps.io
data-flow-server-hd6lIb0-httpLogStream-log    started           1/1         1G       1G     data-flow-server-hd6lIb0-httpLogStream-log.cfapps.io
```

## Test the Stream {#test_stream}

**Tail the log of ``log`` application**

Tail the log of ``data-flow-server-hd6lIb0-httpLogStream-log`` application using `cf` command.

```sh
cf logs data-flow-server-hd6lIb0-httpLogStream-log
Retrieving logs for app data-flow-server-hd6lIb0-httpLogStream-log in org <org> / space <space> as <email>...
```

**Post a sample message to the stream**

Post a sample `hello world` message to `http` application using the route `data-flow-server-hd6lIb0-httpLogStream-http.cfapps.io` as shown below. The message will be picked up by `http` app and passed to `log` application.

```sh
$ curl -i -H "Content-Type:application/text" -X POST -d 'hello world' https://data-flow-server-hd6lIb0-httpLogStream-http.cfapps.io

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    15    0     0  100    15      0     21 --:--:-- --:--:-- --:--:--    21HTTP/1.1 202 Accepted
Date: Wed, 16 Jan 2019 04:43:55 GMT
X-Vcap-Request-Id: f0282b62-c09f-4c23-4e90-0f374ba2cca9
Content-Length: 0
Connection: keep-alive
```

Once the message is posted successfully, `hello world` will be printed in the logs of `log` application.

```sh
2019-01-16T06:39:43.77-0700 [APP/PROC/WEB/0] OUT 2019-01-16 13:39:43.758  INFO 14 --- [httpLogStream-1] ta-flow-server-hd6lIb0-httpLogStream-log : hello world
```

## Summary {#summary}

Congratulations! You just deployed a stream on PCF using SCDF Server and created a `http|log` stream.

{% include_relative {{ page.references_file }} %}
