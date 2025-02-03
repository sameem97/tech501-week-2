# Week 2 Learning

Welcome to my week 2 learning repo. This is a continuation of my devops related learnings!

Much of the learnings this week was encompassed around deploying a test Node.js application coupled with a mongodb database in a two-tier application architecture. Using generalised azure images with User Data has greatly automated the deployments.

Concepts like autoscaling with deployment of Virtual Machine Scale Sets (VMSS) and monitoring with Azure Monitor has also been explored.

Lastly, further enhancements to the database security have been added with the three-subnet architecture, using a Network Virtual Appliance (NVA) in a DMZ subnet to filter incoming traffic (see mongodb section below for details).

Happy coding!

## Topics

- [Deploy Node.js app](/nodejs_app_deployment/README.md)
- [Deploy Mongodb database](/mongo_db_deployment/README.md)
- [Connect App to Database](/connect_app_db/README.md)
- [Two-Tier Application Architecture](/app_architecture/README.md)
- [Automate App Server Setup with User Data](/app_vm_initial_setup/run_app_only.sh)
- [Azure Monitor](/azure_monitor/README.md)
- [Autoscaling with Azure](/autoscaling/README.md)
