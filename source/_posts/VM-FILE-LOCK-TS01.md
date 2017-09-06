---
title: 分析虚拟机文件会被 HA 锁-案列
date: 2015-11-06 11:37:43
categories: VMware运维
tags:
 - 排障
---

之前发生过集群中的有个ESXi与某个 Datastore ，导致虚拟机卡死宕机了，然后无法强制关机，通过命令杀死虚拟机后。
提示找不到虚拟机文件，无法启动，去 Datastore 对应的虚拟机目录看，虚拟机 vmx 配置文件是无图标的，即锁定状态。无法 ESXI 被读取到。
因此需要解锁，解锁要找到谁上锁，排障的过程搜索过资料和与官方工程师讨论后
决定从虚拟机清单中移除虚拟机，手动删除去 Datastore 对应的虚拟机目录 .LCK 锁定文件，修改 VMXF 后缀后，VMX 文件恢复为可注册状态。
但是依然无法开机，因为被锁的还有 VMDK 文件 ，奔溃的是 VMDK 的解锁方式还真有点不一样。
刚好搜索资料的时候，找到一篇博文，分析是 HA 的原因 导致被锁的，如下：

---

故障现象：启动虚拟机时 95 %，停顿并且启动任务中断，提示：ubable to access files since it is locked。

原因分析：是HA的原因。

解决方法：

1、首先将cluster中的HA功能关闭。如果该功能不关闭，容易造成死锁,，VM不断跳动，不断再不同的ESX内循环被锁，徒劳而无功。

2、磁盘文件被锁，要解决，必须要知道到底是哪台ESX把他给锁住了，这是关键。

操作：看/var/log/vmkernel但是，在做这些前, 再准备些别的工作。

3、在VC中，把被锁的VM从Inventory中remove掉。原因很简单，这是一个 unregister的过程。

4、根据/var/log/vmkernel，搜索owner，可以找到类似以下的语句:

```
Oct 19 04:23:33 esx-hostname vmkernel: 3:06:29:47.992 cpu6:1656)FS3: 1975: Checking if lock holders are live for lock [type 10c00001 offset 52008960 v 380, hb offset 3554304 Oct 19 04:23:33 esx-hostname vmkernel: gen 17, mode 1, owner 48f5f637-462688bc-fd28-0e1a6434b6f8mtime 38112]
```

OK，owner后面的48f5f637-462688bc-fd28-0e1a6434b6f8就是你的target了。 因为他就是锁住VM 的宿主.。


5、根据以下命令,，找出到底哪台ESX的UUID是 48f5f637-462688bc-fd28-0e1a6434b6f8

```
[iyunv@esxhostname root]# esxcfg-info |grep -i system uuid
```

6、找到目标主机后，当然是杀死他锁住VM的进程。之所以会被锁，原因就是HA 把VM从别的HOST迁移过来，但是又没有unregister和register的过程，所以在第3步的时候，你查看VM的Summary的时候，host ip还是属于出问题的 host。 但是VM又被新的host霸王硬上功的power on，注册都没注册, 又怎么启动呢。找到 PID 用下面的命令：

```
ps -efwww|grep virtualmachine.vmx
```

找到 PID 后, kill -9 PID

7、此时需确定一件事情（.vswp文件）。这个是给台客处理问题时吸取的经验。就因为忽略了这个，所以在杀掉?程后，重新注册VM，还说没有 SWAP文件，启动还是失败。

在 VM 启动时会自动生成SWAP，没有SWAP文件，其实就是因为 SWAP 存在了, 因为重名而导致无法正常生成。

进入到/vmfs/volumes/lunid/vm_path/下，vmkfs -d virtual_machine.vswp 或者进入Datastore Browser，在里面把SWAP文件删除也可。


8、完全之策，你还可以进入到VM的SETTINGS--OPTIONS--SWAPFILE LOCATION， 对该保存的位置做下设置。

9、重新注册VM。进入Datastore Browser，找到VM.vmx，add to inventory。

10、启动VM。