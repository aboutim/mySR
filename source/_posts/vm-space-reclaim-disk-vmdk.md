---
title: 虚拟机释放磁盘空间
date: 2015-12-07 15:59:54
categories: VMware运维
tags:
 - 运维
 - command
---

事实上虚拟机 Geust OS 存放了数据占用空间后再删除到回收站清理，对于VMware Datastore 的 VMFS文件系统来说无法直接感知到的，所以会常常有管理员觉得，虚拟机明明删掉了 100G 的数据，为啥在 VC 上面看到这个虚拟机占用的空间还是没有减少。

想要 Geust OS 把清理后的空间还给 Datastore ，换句话意思  Datastore 想识别到 Geust OS 释放出来的空间，则需要 Geust OS 重新把闲余空间进行一个置零操作，然后要使用 vmfstool 对相关的 VMDK 进行置零操作。整个过程数据不会丢失。

## Windows 

使用 Sdelete.exe 此命令行工，可以跟踪非零的垃圾块和未使用的块并将它们释放回数据存储中，有效地缩小磁盘。
``` cmd
sdelete -c -z C:\
```
执行过程，磁盘空间会一点点的被消耗，但不要担心。等待完成。

## Linux

```
$ dd if=/dev/zero of=/[mounted-volume]/zeroes && rm -f /[mounted-volume]/zeroes
```

## 在 ESXI 上回收空间

关闭VM的 Geust OS 系统，SSH 到任意能访问这个 VM 所在的 Datastore ESXI 主机开始回收 VMDK 空间

```
vmkfstools -K /path/disk-name.vmdk
```




