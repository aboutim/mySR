---
title: 云计算工程技术点汇总
date: 2017-02-28 23:45:24
categories: 云计算
tags:
 - 云计算
---

## 基础架构
### 计算
- X86服务器
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
- 虚拟化
  - Hypervisor
    - VMWare
    - Xen
    - KVM
    - Hyper-V
- 容器
  - Docker
  - CoreOS
  - UnixLXC
- Unikernel

### 网络
- VPC（虚拟私有网络）
- SDN（软件定义网络，控制平面与数据平台面分开）
- CDN（内容分发网络）
- NFV（网络功能虚拟化）
- Overlay (实现多租户网络层面隔离 VXLAN、NVGRE、STT)
- GRE/VPN/专线接入
- 公网IP动态供给
- LoadBlanche（负载均衡）
- DNS/DHCP
- 基于 CLOS 组网架构 

### 存储
- 网络存储
  - NFS v4
  - Ceph
  - NAS
- 对象存储
  - AWS S3
  - Swift
  - 各家公有云
- 块存储
  - FC-SAN
  - IP-SAN
  - DAS
- 集群文件系统
  - VMFS (VMware)
  - GlusterFS
  - WAFL (netapp)
- 软件定义存储
  - VMWare VSAN
  - HUAWEI FusionStorage
  - Veritas InfoScale Storage
  - Ceph
  - GlusterFS
  - Sheepdog
- 存储虚拟化
  - EMC VPLEX
  - IBM SVC
  - HDS VSP
- 数据管理
  - 数据压缩
  - 重复数据删除
  - 数据备份
  - 同步/复制

### IDC 基础设施
- 供电系统
  - UPS
  - 双路市电
  - 柴油发电机
- 冷却系统与环境控制
  - 冷热空气流
  - 恒定温湿度
- 网络概况
  - 多线BGP网络
  - DDos防御分流
  - 综合布线
- 机房建筑
  - 楼宇抗震
  - 防火灭火
- 安保计划与措施
  - 授权进出
  - 值班机制

## 云平台
### 自助服务门户
- 身份验证
- 服务目录
- 主机
    - 通用计算型
    - 内存大容量型
    - IO 密度型
    - GPU 计算型
    - 容器
    - 物理服务器
- 存储
    - 硬盘
    - NAS
    - ISCSI
    - 对象存储
- 网络
    - VPC
    - 公网IP
    - 私有网络
    - 负载均衡
    - 流量镜像
    - DNS、DHCP
    - CDN
    - 抗D
    - 防火墙
- 操作系统映像
    - Windows
        - Server 2008/2012/2016
         - Desktop Win7/8/10
    - Linux
        - RedHat/Centos
        - Ubuntu
        - Debian
        - SUSE
- SQL/NOSQL
    - SQL Server
    - MySQL
    - PostgreSQL
    - MongoDB
    - Cassandra
- 缓存
    - Memcached
    - Redis
- 大数据
    - Hadoop
    - Spark
    - HBase
    - Storm
    - Elasticsearch
    - Zookeeper
- 拓扑图示
- 弹性伸缩
- 基于条件的触发，条件包括不限于时间、负载
- 适用对象包括不限于 主机、硬盘容量、网络带宽
- 资源编排
- 自助注册
- 权限控制
- 计量计费
- 工单系统
- 操作记录
- 监控告警
- 监控走势图
- 关键指标 CPU/MEM/DISK_SIZE/DISK_IO
- 备份快照
- 定时备份
- 在线快照
- 重定向恢复
- 归档

### 后台管理门户/BOSS
- 平台展板
- 资源管理
- 工单系统后台
- 资源配额
- 计量计费后台
- 系统映像管理
- SAAS 发布
- 管理维护
- 监控告警
- 权限控制
- 安全审计
- 日志服务

### 解决方案
- VPC解决方案
![image](https://pek3a.qingstor.com/mynotes/vpc-sovlotion.png)
- 混合云解决方案
![image](https://pek3a.qingstor.com/mynotes/hyper-cloud-sovlotion.png)


## 运维开发
- 流程开发
- 开发语言
    - Java
    - Go
    - Python
    - Javascript
    - PHP
    - Ruby

## 意识形态
### 名词
- 双模IT
- 私有云
- 混合云
- 行业云
- 政企云
- 金融云
- 公有云

### 成本
- 双路服务器比四路效能更高，性价比更优
- 冷数据应存放在成本低廉的存储设备
- 闪存的每GB成本并不比机械硬盘高多少
- 集中式存储是软硬件捆绑的商业产品，成本昂贵
- 分布式存储成熟度已经接近集中式存储，不绑定硬件
- 考虑2U4Node的服务器机型，节省机柜空间
- 只关注一次性投入成本，忽略后续投入成本是不可取的
- 人力也是成本，尽量依赖完善标准的自助服务满足用户大部分需求。
- 量大可考虑定制服务器，减少用不上的元器件不单止压缩成本也减少故障点


部分内容摘自 [StuQ 的技能图谱](http://skill-map.stuq.org/)