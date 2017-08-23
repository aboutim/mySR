---
title: 运维知识技能点汇总
date: 2017-02-11 21:38:00
categories: 运维
tags:
 - 运维
---

## 硬件
### 服务器
- 形态
  - 塔式
  - 刀片
  - 机架式
- 管理
  - 带外网络管理
  - 启动固件模式
    - Legacy BIOS
    - UEFI
- CPU
  - 内核
  - 缓存
  - 工艺
  - 指令
  - 功耗
- GPU
  - 显存
  - CUDA
  - 功耗
- Memmory
  - 工艺
  - 频率
  - 时延
- DISK
 - SSD
    - 存储颗粒 TLC、MLC、SLC、Optane 
    - 主控、预留空间、P/E
    - 垃圾回收、损耗均衡、TRIM
 - HDD
     - 转速（5K、7.2K、10K、15K）
     - 尺寸（2.5、3.5）
 - IDE、ACHI、Nvme 接口协议
 - SATA、SAS、U.2、PCI-e 接口
- Raid card
  - 缓存
  - 接口
  - 模式（直通）
  - 兼容性（特别是SDS）
- Network card
  - intel DPDK
  - vxlan offload 

### 存储
- 存储
    - 传统存储(共享式存储)
        - 设备类型
            - 控制器（机头）
            - 磁盘柜
            - FC 交换机
            - 存储网关（存储虚拟化）
        - 存储系统
            - ONtap (NETAPP)
            - EqualLogic (DELL)
            - VNXe (EMC)
            - VMX (EMC)
            - DS (IBM)
        - 形态
            - IP-SAN
            - FC-SAN
            - DAS
    - 软件定义存储
        - Windows Server Storege 2012
        - VSAN (VMWare)
        - InfoScale Storage (Veritas)
        - HUAWEI FusionStorage
        - Qingcloud Storage
    - 对象存储
        - AWS S3
        - 其它公有云厂商自研
    - 数据保护
        - Raid 0/1/10/5/6 
        - Raid2.0 (以硬盘切片后更小颗粒度作为Raid对象保护方式)
        - Raid DP (NETAPP)
    - 数据管理
        - 重读数据删除
        - 数据压缩
        - 同步/复制
        - 快照
        - 磁盘扫描
        - 加密
    - 连接方式
        - IP 网络(ISCSI)
        - FC 网络
        - RDMA
        - SAS
        - NVMeF

### 网络
- TCP/IP协议
- 抓包 tcpdump
- 动静态路由
- VPN
- DHCP

### 其它设备
- 堡垒机
- IDS、IPS

### 虚拟化
- 虚拟化概念
    - 半虚拟化
    - 全虚拟化
    - 虚拟化原理
- 虚拟化基础功能
    - CPU
    - 内存
    - 存储
    - 网络
    - 热插拔
    - 动态迁移
    - 快照
- 虚拟化管理工具
    - OpenStack
    - CloudStack
    - VMware vCenter
    - VMware vCLOUD
    - OpenNebula

### 基础服务
- FTP
- DNS
- SAMBA
- EMAIL
- NTP
- DHCP
- YUM
- WSUS
- AD

### 平台工具
- Nagios
- Puppet
- Zabbix
- Cacti
- Elasticsearch

### 脚本
- shell
- Python
- Perl
- Powershell

### Linux 基础
- 基本操作命令
- Linux内置编辑器

### 其它
- 安全意识
- 责任心
- 沟通方式/技巧
- 推进/该散
- 进取心/记录分享


部分内容摘自 [StuQ 的技能图谱](http://skill-map.stuq.org/)