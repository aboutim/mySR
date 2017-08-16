---
title: 解决 vCSA 6.0 vphere-web-client-页面无法打开
date: 2016-11-15 14:20:35
categories: 虚拟化
tags:
  - 虚拟化
  - VCSA
  - 排障
---

### 故障描述
5.5 版本 VMWare 就提倡用 web-client ，但是 web-client 的响应时间以及被动刷新真的很让人捉急，因此大部分人还是喜欢用 vsphere-client for desktop 。前端发现web-client无法打开，但是：5480 后台以及引导页面还是可以打开的。也就是https://#you-vc# /vsphere-client/?csp
初步估计是 VC 的 web 服务异常了

### 排错解决
SSH 上去 check 一下
    
    vcsa:~ # /etc/init.d/vsphere-client status
    VMware vSphere Web Client is running: PID:14701, Wrapper:STARTED, Java:STARTED
     
正在运行，但页面就是打不开。
重启服务试试
    
    vcsa:~ # /etc/init.d/vsphere-client restart

等一分钟左右，刷新页面，登录界面出来了
    
除此之外，遇到别的异常可考虑重启对应的功能模块来尝试解决修复
    
###  vCSA 服务列表
    

服务名称 | 	描述
---|---
applmgmt | VMware Appliance Management Service
vmware-cis-license | VMware License Service
vmware-cm | VMware Component Manager
vmware-eam | VMware ESX Agent Manager
vmware-sts-idmd | VMware Identity Management Service
vmware-invsvc | VMware Inventory Service
vmware-mbcs | VMware Message Bus Configuration Service
vmware-netdumper | VMware vSphere ESXi Dump Collector
vmware-perfcharts | VMware Performance Charts
vmware-rbd-watchdog | VMware vSphere Auto Deploy Waiter
vmware-rhttpproxy | VMware HTTP Reverse Proxy
vmware-sca | VMware Service Control Agent
vmware-sps | VMware vSphere Profile-Driven Storage Service
vmware-stsd | VMware Security Token Service
vmware-syslog | VMware Common Logging Service
vmware-syslog-health | VMware Syslog Health Service
vmware-vapi-endpoint | VMware vAPI Endpoint
vmware-vdcs | VMware Content Library Service
vmafdd | VMware Authentication Framework
vmcad | VMware Certificate Service
vmdird | VMware Directory Service
vmware-vpostgres | VMware Postgres
vmware-vpx-workflow | VMware vCenter Workflow Manager
vmware-vpxd | VMware vCenter Server
vmware-vsm | VMware vService Manager
vsphere-client | vSphere Web Client
vmware-vws | VMware System and Hardware Health Manager
vmware-vsan-health | VMware vSAN Health Service
    

### 其它命令
运行以下命令以列出 vCenter Server Appliance 服务：

service-control --list

要查看 vCenter Server Appliance 服务的当前状态，请键入以下命令：

service-control --status

运行以下命令以启动特定服务：

service-control --startservicename

也可以键入以下命令启动所有服务：

service-control --start --all

要执行该命令的预演，请将--dry-run选项添加到该命令。此时将显示该命令将运行哪些操作，而不执行这些操作。例如，键入以下命令：

service-control --start --all --dry-run

运行以下命令以停止特定服务：

service-control --stopservicename

也可以键入以下命令停止所有服务：

service-control --stop --all

要执行该命令的预演，请将--dry-run选项添加到该命令。此时将显示该命令将运行哪些操作，而不执行这些操作。例如，键入以下命令：

service-control --stop --all --dry-run

也可以键入以下命令停止所有服务：

service-control --stop --all

运行以下命令以启动特定服务：

service-control --startservicename

也可以键入以下命令启动所有服务：

service-control --start --all

服务列表以及其它命令来自官方 [KB2115730](https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2115730)
