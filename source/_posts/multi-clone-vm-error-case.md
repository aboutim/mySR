---
title: 并行批量克隆 VM 报由文件[datastore1] VM1/VM1.vmdk 引起的错误
date: 2017-01-20 11:54:52
categories: VMware运维
tags:
 - CBT
 - 克隆
---

VM 如果开机状态下，可以作为母本进行一次克隆任务。而关机状态下，则可以进行多次克隆任务。
一般情况下，VM 进行多次克隆是没问题的，但如果目标数据存储的块大小不支持与源一样大的 VMDK，克隆或者迁移的时候则会出现由文件 [datastore1] VM1/VM1.vmdk 引起的错误，[KB2101966](https://kb.vmware.com/selfservice/microsites/search.do?cmd=displayKC&externalId=2101966) 阐述了这个错误，但没有提供解决办法，甚至差点误导了我的方向，去研究 VMFS 数据存储的块大小限制 [KB2074624](https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2074624)。

---

本人的环境经常需要克隆 VM ，且数量不少。一个一个克隆是效率低下，无能的做法。要解决此问题，就要找出源头

故障现象：
发起两个克隆任务，第一个克隆成功第二个秒失败。
![image](https://pek3a.qingstor.com/mynotes/esxi-ts-002.png)

故障分析：
分析自身环境:
多个VC下多个DC的清单中都注册了该 VM 作为克隆模版。

分析日志：
先获取失败任务的ID，[获取方法](https://aboutim.github.io/2015/07/05/esxi-cmd-ops/)
我的任务ID 是 task-192681 
看一下 VC 和相关的两台 ESXI 的常见的几个日志（[VC的日志](https://kb.vmware.com/selfservice/search.do?cmd=displayKC&docType=kc&docTypeID=DT_KB_1_1&externalId=2115740)、[VMware 产品的日志文件位置](https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2095069)），
以任务ID 为关键词筛选出内容，看看有没有记录一些有利于解决问题的信息，如下

vpxd-391.log:2016-12-28T03:16:08.465Z error vpxd[7F026F0D7700] [Originator@6876 sub=VmProv opID=c4000f-c6] Failed to track task vim.Task:==task-192681==on host vim.HostSystem:host-2663: vim.fault.FileFault
vpxd-391.log:2016-12-28T03:16:08.465Z error vpxd[7F026F0D7700] [Originator@6876 sub=VmProv opID=c4000f-c6] Aborting task tracking since task vim.Task:task-192681 failed
vpxd-391.log:2016-12-28T03:16:08.465Z error vpxd[7F026F0D7700] [Originator@6876 sub=Datastore opID=c4000f-c6] [VpxdDatastore::UrlToDSPath] Received a non-url [/vmfs/volumes/57916ad0-f8a8e2f0-ce88-8cdcd4b658e4/W2K8R2-WEB-TEMP-V6/W2K8R2-WEB-TEMP-V6.vmdk], instead of a url
vpxd-391.log:2016-12-28T03:16:08.475Z error vpxd[7F026F0D7700] [Originator@6876 sub=VmProv opID=c4000f-c6] [WorkflowImpl] Get exception while executing action vpx.vmprov.CopyVmFiles: vim.fault.FileFault

时间点很吻合
虽然找出了日志了，但只是说明报错了。解决办法还需要依靠厂商或者KB（中文关键词很难查的）、搜索引擎

后来找 VMware 开 CASE ，后台扔了个 KB 过来[KB2119247](https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2119247)
按照 KB 的方法，解决了这个问题，操作摘抄如下：

删除与虚拟机模板关联的所有 -ctk.vmdk 文件。完成后，禁用更改块跟踪 (CBT)。
 
1. 要删除与虚拟机模板关联的所有 -ctk.vmdk 文件，请执行以下操作：
2. 通过 vSphere Client 或 vSphere Web Client 使用管理员凭据登录到 VMware vCenter Server。
3. 浏览受影响虚拟机模板所在的 VMFS 数据存储。
4. 从 VMFS 数据存储中移出或删除所有关联的 -ctk.vmdk 文件。
5. 要禁用更改块跟踪 (CBT)，请执行以下操作：
6. 关闭虚拟机电源。
7. 右键单击虚拟机，然后单击编辑设置。
8. 单击选项选项卡。
9. 单击“高级”区域下方的常规，然后单击配置参数。此时将打开“配置参数”对话框。
10. 请将相应 SCSI 磁盘的 ctkEnabled 参数设置为 false。


关于 CBT 
数据块修改跟踪技术(Changed Block Tracking)是vmware简化和提高虚拟机备份效率的重要组成部分，它可以实现只备份变化块数据，而不需要备份全部数据，减少备份数据，提高备份效率。












