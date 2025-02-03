# Azure Monitor

- [Azure Monitor](#azure-monitor)
  - [Introduction](#introduction)
  - [Azure Monitor Key Features](#azure-monitor-key-features)
  - [Creating dashboards](#creating-dashboards)
  - [Load testing with ApacheBench](#load-testing-with-apachebench)
  - [Alarms](#alarms)

## Introduction

- Azure Monitor is a comprehensive monitoring service provided by Microsoft Azure that helps you maximize the availability and performance of your applications and services.
- It delivers a full stack monitoring solution that collects, analyses, and acts on telemetry data from your cloud and on-premises environments.
- Equivalent to AWS CloudWatch.

## Azure Monitor Key Features

- **Data Collection**: Gathers metrics and logs from various Azure resources, applications, and the operating system.
- **Analysis**: Provides powerful analytics tools to help you understand the performance and health of your applications.
- **Visualisation**: Allows you to create custom dashboards and workbooks to visualize your data.
- **Alerts**: Enables you to set up alerts to notify you of critical conditions and automate responses.
- **Integration**: Integrates with other Azure services and third-party tools for a seamless monitoring experience.

Azure Monitor helps you gain deep insights into your applications, proactively identify issues, and maintain optimal performance.

## Creating dashboards

- Can create custom dashboards tracking various metrics e.g. average CPU usage, R/W disk operations, network load etc.
- Can pin these charts to our dashboard, and rearrange viewing, refresh interval, time-range in view etc.

![VMSS VM1 Average CPU Usage for past hour](/images/vmss_vm1_CPU.png)

## Load testing with ApacheBench

- Install apache2 utils with ab(ApacheBench) utility:

```bash
sudo apt-get install apache2-utils
```

- Need to use this tool to simulate user experience for our application i.e. at what point do we get congestion (whether CPU, network etc) that results in a poor user experience e.g. app takes 1 minute to load.

- Send 10000 requests in blocks of 200. Note, can have a timeout so may not send all the requests.

```bash
ab -n 10000 -c 200 http://<public_ip_address>/
```

- Once we have determined the saturation point, can set up alerts e.g. at 70% CPU usage alert me with a text message. And ultimately can add vertical scaling (more CPU, RAM etc) or horizontal scaling (more app instances with load balancing).

- Also observe the effects of our requests in the dashboard, although due to the simplicity of our application, the spikes may be minimal.

## Alarms