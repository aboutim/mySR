---
title: 故障排错-ESXI-VM无法启动以及迁移且SSH/shell服务无法启动
date: 2015-11-11 11:09:11
categories: VMWare运维
tags:
 - ESXI
 - 排障
---

## 故障信息
对象：ESXI 主机
现象：虚拟机无法正常开机，正在运行的虚拟机无法迁移到别的主机，SSH/shell服务挂死、重启启动失败。
尽量不能直接重启ESXI主机，会中断正在运行的虚拟机

## 排错步骤
1. 先把SSH/shell服务重新变为可用
``` shell
控制台重启 manager server
```

2. 但第二个问题诞生了，正在 此ESXI 主机上运行的虚拟机在 VC 上变成无效了 ，状态为未知
``` shell
SSH上去，使用 esxtop 查看虚拟机是正在运行的
出现这种情况是因为重启管理服务之后
HOSTD、VXPD服务起来之后无法读取到正在运行的虚机的VMX文件，无法读取配置文件。
需要命令行迁移VM（测试过不行）或者重新启动VM。
让VMX变为可读状态，hostd服务才能正确读取到虚机配置。
```

3. 翻 [KB2083312](https://kb.vmware.com/selfservice/microsites/search.do?cmd=displayKC&docType=kc&externalId=2083312&sliceId=1&docTypeID=DT_KB_1_1&dialogID=584477504&stateId=1%200%20485256400)  找到了一个答案，解释了TRP文件过多，影响了ESXI主机的部分服务
SSH上去一查，果然

![image](https://pek3a.qingstor.com/mynotes/esxi-ts-001.png)

4. 通过运行以下命令删除 /var/spool/snmp/ 目录中的 .trp 文件：
``` shell
# cd /var/spool/snmp
# for i in $(ls | grep trp); do rm -f $i;done

```
要确保此问题不会重复发生，可暂时禁用 snmpd 以停止日志记录。要停止 snmpd 服务，请运行以下命令：
``` shell
# /etc/init.d/snmpd stop
```
官方建议停止SNMPD这个服务，但是TRP文件依然增长，
启用后，TRP文件却停止增长了。
``` shell
snmpd is running
# /etc/init.d/snmpd start
```

5. 因为 trp 文件过多，所以对 ESXI 主机的服务状态进行维护变更会失败，现在清理完了，重新的把主要的服务 hostd 启动
``` shell
/etc/init.d/hostd status 
/etc/init.d/hostd start
```
Restart重启服务  start 启动服务

重启了 hostd 服务后，esxi主机的管理agent会短暂重启一下，并不会影响虚机，使用client重新连接ESXI主机后，hostd 能正确读取到正在运行的虚机状态。

另外如果资源池与虚拟机的目录关系有异常，把 vxpa 的服务也重新启动一下吧
``` shell
/etc/init.d/vpxa restart
```