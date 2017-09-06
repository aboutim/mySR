---
title: vSphere运维的一些命令
date: 2015-07-05 15:21:36
categories: VMware运维
tags:
 - ESXi
 - command
---

## 命令行取消正在运行的任务
1、SSH ESXi
2、执行一下命令查询当前任务列表
``` shell
#vim-cmd vimsvc/task_list
```

3、查看任务具体细节 “xxxxx” 代表任务ID
``` shell
#vim-cmd vimsvc/task_info xxxxx
```

4、确认之后，执行以下命令取消任务
``` shell
#vim-cmd vimsvc/task_cancel xxxxx
```

## 命令行杀死虚拟机
1、SSH ESXi
2、输入 esxtop , 打开 esxtop 界面
3、输入C 切换到 CPU 资源界面 按shift + V 只显示 VMs 相关的信息

![image](https://pek3a.qingstor.com/mynotes/esxtop-command-1.png)

4、接着输入 F  ，按 C 把 LWID 显示出来

![image](https://pek3a.qingstor.com/mynotes/esxtop-command-2.png)
![image](https://pek3a.qingstor.com/mynotes/esxtop-command-3.png)

5、按 K ，把需要杀死的虚拟机的LWID 输入回车即可

![image](https://pek3a.qingstor.com/mynotes/esxtop-command-4.png)

## 备份 ESXi 设定参数
1、WinSCP 登录到 ESXi ，找到 /bootbank/state.tgz 拷贝出来
2、然后进行要更改的设定
3、如需要恢复更改之前的状态，直接把副本覆盖到目录下替换
4、命令行执行 reboot -f 重启

## vmkping
默认情况下，ESXI 使用 PING 测试网络默认是用管理IP去发起的，如果是测试其它vmkernel的网络 则使用vmkping

## 禁用vSAN Health Service
如果没有使用 vSAN , VC 的任务栏会被
```
启用了 Non-Virtual SAN 的 ESXi 主机显示以下消息：检索用来注册 Virtual SAN VASA 提供程序的票证 (Retrieve a ticket to register the Virtual SAN VASA Provider)
```
这个任务刷屏，及其讨厌
不久前 [KB2145594](https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2145594)
终于解决了这个问题了
摘抄一下 vCSA 的操作

1、停止 vSAN Health Service：
```
# service vmware-vsan-health stop
```
2、禁用 vSAN Health Service：
```
# chkconfig vmware-vsan-health off
```
