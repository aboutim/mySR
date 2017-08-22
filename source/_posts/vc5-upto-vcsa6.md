---
title: 另类方式实现 VCS5.5 安全有效地"升级"至 vCSA6.0
date: 2016-10-13 19:38:09
categories: 虚拟化
tags:
 - vCenter
 - vCSA
 - PowerCLI
 - 虚拟化
---

## 常规升级方式

VCS (vCenter Server for Windows)平滑升级到 vCSA (vCenter Server Appliance) ？ 对不起，这种操作在6.0之前 官方文档是不存在的。
VCS 是运行在 Windows 之上的虚拟化管理程序，而 vCSA 是运行在 Linux 上的，且是由 VMWare 定制开发好的appliance ，这也是 vCSA 的 **A**。两者的管理功能在6.0后几乎一样，但却是使用的底层操作系统，中间件，数据库都有极大的不同，无法平滑升级，数据无法从 VCS 导出，然后导入到 vCSA ，当中涉及到太多利害关系了，光网络和数据库就够你喝一壶（ps:vCSA比VCS 部署和架构都简单，而且能省掉M$的License）虽然之前在Flings 上有大神做了一个 [VCS to VCVA Converter](https://labs.vmware.com/flings/vcs-to-vcva-converter) 的转换程序，之后正式被官方集成生产——[vCenter Server Appliance (VCSA) Migration Tool officially GAs w/vSphere 6.0 Update 2m](http://www.virtuallyghetto.com/2016/09/vcenter-server-appliance-vcsa-migration-tool-officially-gas-wvsphere-6-0-update-2m.html)

## 我的方式

 [VCS to VCVA Converter](https://labs.vmware.com/flings/vcs-to-vcva-converter) 很早之前我就做了实验去验证，那时候实验环境比较简单，所以试了两次后，便完成验证了。在接触到复杂的虚拟化环境后，我开始考虑到这个物件的不确定性了，每个环境的管理者的技术水平都不是同一水平的，因此环境变得不可捉摸，如果有别的物件如监控，备份的依赖 VCS ，那转换成 VCSA 就很可能发生不可预测的错误，转换失败虽然不会破坏 VCS 的数据，但转换过程需要把 VCS 关机 ，但做我们这一行，很忌讳服务器关机/重启，因为很可能就启动不了或者启动失败。整好，目前我管理的虚拟化环境VCS 5.5 有升级到 VCSA 的需求，而且环境巨复杂，简单的说一下：
1.  有4个集群，有的集群多达 30 个 ESXI-HOST 主机，几乎是vSphere 5.5 的最高配置。
2.  每个集群独立的 VDS (虚拟分布式交换机)，总 VDP （分布式端口组）超过 200 个
3.  每个 VDS 都关联了两个上联口
4.  总 VM 数量超过 1000 个
5.  每个 VM 的网卡都挂载了一个 VDP （分布式端口组），可怕吧·····

 因此我在寻求一种平滑升级的方式，尽量的、原生的，可持续的完成VCSA 接管 VCS 的ESXI、VM、分布式虚拟网络配置等。
 后来在 PowerCLI 上看到了可能
 
###  思路

利用跑业务流量的双网卡冗余特点，编写脚本实现精准切换端口组
1.	先部署 VCSA6.0（已部署）
2.	在 VCSA 上创建与 VC一样的集群架构，以及分布式交换机的端口组一致（脚本保证一致性）
3.	通过脚本控制 VDS (分布式端口组)-> VSS (标准端口组)的精准切换（保证端口组的影响降到最低）
4.	把 ESXI 注册到 VCSA 上，VM 绑定在 VSS，注册过程不受影响
5.	通过脚本回切端口组（VSS -> VDS）

迁移图示

![image](https://pek3a.qingstor.com/mynotes/vc-to-vcsa.png)

### 特点

除了第一步，其余步骤均是通过脚本实现以 ESXI 为单位逐台注册到 VCSA，随时可中断回滚，为了解决 VDS 与 VM 之间的关联关系，VM 先绑定在 VSS 上，脱离了对 VDS的影响。一切变更操作设计以保护VM链路不中断为原则；
整个变更中，基本上是管理上的调整，不会改变ESXI既定的物理网络配置

### 难点
因为涉及到 VM 网卡上的端口组配置变换，必须保证绝对的精准记录每个 VM 网卡上面的 连接的端口组名称是什么，新建的 VDP 的 VLAN 号必须要跟原来的端口组 VLAN 号一致。我的解决办法是，导出这些配置，然后根据导出的内容，在新建的 VSS 上创建相应的端口组，且端口组名称尽量还是要增加标识来区分，来维护全局唯一的规则，这样降低报错和变更风险。

### 风险

正在变更的ESXI上负载的VM在切换端口组的时候可能会有1~2个丢包的影响，类似情况就是双线冗余的业务链路断开了一线，正在使用该链路的流量会从另一个冗余的链路过来。

### PowerCLI 脚本
需要在PowerCLI把新旧两个VC都Login上
```powershell
$Cred = get-credential
Connect-VIServer "old-VC-address" -Credential $Cred  -SaveCredentials -WarningAction SilentlyContinue
$Cred1 = get-credential
Connect-VIServer "new-VC-address" -Credential $Cred1  -SaveCredentials -WarningAction SilentlyContinue
```
#### 公共参数
```powershell
#把之前导出的HOST-VM-PG-VMNIC-LIST.csv 导入到变量中---------这部分导入适用于需要从表获取信息配置的操作
$xpath = split-path -parent $MyInvocation.MyCommand.Definition
$CsvPath= "$xpath\HOST-VM-PG-VMNIC-LIST.csv"
$vmlists = Import-Csv $CsvPath -encoding Default | ?{$_.deploy -like "*Y*" -and $_.VMHOST -eq $vmhost} -ErrorAction SilentlyContinue
```
#### 生成 HOST-VM-PG-VMNIC-LIST
靠人是记不住，也记不完的，所以要把目前的配置导出（VM、VMHOST、VMNAME、NICNAME、NICMAC、PGNAME、VLAN、VSSPG、VSSNIC 、VDSNIC、VDSNAME
）。
```powershell
#导出指定 ESXI 主机的信息
param($vmhost)
$getvmhost = get-vmhost $vmhost -ErrorAction SilentlyContinue
$getvds = $getvmhost | Get-VDSwitch
$getcluster = $getvmhost | Get-cluster
$getdc = $getvmhost | Get-Datacenter
#获取 VDS 的端口组列表
$getvdspg = $getvmhost | Get-VirtualPortGroup -Distributed
#获取 VDS 的上联口
$getvmnic = $getvds | Get-VMHostNetworkAdapter | ?{$_.VMHOST -like $vmhost}
if($getvmnic.Count -eq 2)
{#获取 VDS 的两个上联口
	$vdsnic = $getvmnic[0].name
	$vssnic = $getvmnic[1].name
}
else
{#如果只有一个上联口，网络会中断的。
	$vssnic = "none"
	$vdsnic = $getvmnic[0].name
}
#获取每个 VM 的 NETINFO
foreach($GETVM in $getvmhost | Get-vm)
{#遍历 ESXI 主机上的每个 VM
	foreach($GETVMNIC in $GETVM | Get-NetworkAdapter)
	{#遍历 VM 上的每个 VNIC
		$VMname = $GETVM.name
		$nicname = $GETVMNIC.Name
		$nicmac = $GETVMNIC.MacAddress
		$pgname = $GETVMNIC.NetworkName 
		$Newvsspg = "none"
		$PGVLAN = "none"
		if($getvdspg.name -contains $pgname)
		{#判断 PG 是否是分布式端口组，如果是，则定义新建的对应的 VSS PG
			$Newvsspg = "VSS" +$GETVMNIC.NetworkName
			$PG = $getvdspg | ?{$_.name -eq $pgname}
			$PGVLAN = $PG.ExtensionData.Config.DefaultPortConfig.Vlan.VlanId
		}
		#导出 
		$Y = "Y"
		$outlist = [PSCustomObject]@{
		Deploy = $Y
		DC = $getdc.name
		Cluster = $getcluster.name
		VMHOST = $vmhost
		VMNAME = $VMname
		NICNAME = $nicname
		NICMAC = $nicmac
		PGNAME = $pgname
		VLAN = $PGVLAN
		VSSPG = $Newvsspg
		VSSNIC = $vssnic
		VDSNIC = $vdsnic
		VDSNAME = $getvds.name
		}
		$outlist | Export-CSV -Path $CsvPath -Append -NoTypeInformation -encoding Default
	}
}
```
#### 在新的VC创建对应的VDS以及VDPG
```powershell
#因为集群可配置项比较多，每人的要求都不尽想停，没写自动创建集群，需要在新的VC上手动创建Cluster。
#新建VDS
foreach($creatvds in $vmlists | Select-Object -Property DC,VDSNAME -Unique)
{##指定一下VDS的版本
    $VER = "5.5.0" 
	$DC = $creatvds.DC
	$VDS = $creatvds.VDSNAME
	$VDSinfo = Get-VDSwitch $VDS -ErrorAction SilentlyContinue
	if($VDSinfo -eq $null)
	{#如果没有VDS则创建
		$myDC = Get-Datacenter -Name $DC
		New-VDSwitch -Name $VDS -Location $myDC -NumUplinkPorts 2 -LinkDiscoveryProtocol "LLDP" -LinkDiscoveryProtocolOperation "Listen" -Version $VER -Confirm:$false -RunAsync | OUT-NULL
		write-host "$DC 创建 $VDS 成功。" -f green
	}  
}
#获取现有的VDSPG清单
$VDSPG = Get-VDPortgroup -VDSwitch "$VDSNAME" | Where { $_.Name -NotMatch "-DVUplinks" }
#循环需要创建的VDPG清单
foreach($creatvdspg in $vmlists | Select-Object -Property VDSNAME,VLAN,PGNAME -Unique)
{
    $VDS = $creatvdspg.VDSNAME
	$PG = $creatvdspg.PGNAME
	$VLAN = $creatvdspg.VLAN
	Get-VDSwitch -Name $VDS | New-VDPortgroup -Name $PG -NumPorts 8 -VLanId $VLAN -RunAsync | OUT-NULL
	write-host "$VDS 创建 $PG 成功。" 
}

```
#### 创建临时 VSW 标准虚拟交换机
```powershell
#操作指定的ESXI主机
$getvmhost = get-vmhost $vmhost -ErrorAction SilentlyContinue

#临时的虚拟交换机的名称，如果冲突请修改后面的数字
$vssw = "vSwitch2" 
$getvmhost | New-VirtualSwitch -Name $vssw | out-null
"$vssw 创建成功"
Start-Sleep -Seconds 1
#获取相关对象 （已经创建的vsw，目前vsw所关联的nic，目前vds所关联的nic，目前vsw上已经存在的vpg）
$getvsw = $getvmhost | Get-VirtualSwitch -Name $vssw
$getvssvmnic = $getvsw | Get-VMHostNetworkAdapter -Physical
$getvmnic = $getvmhost | Get-VDSwitch | Get-VMHostNetworkAdapter | ?{$_.VMHOST -like $vmhost}
$getvspg = $getvmhost | Get-VirtualPortGroup -Standard

#根据之前导出的配置表，在新建的VSS上创建响应的端口组newvsspg
foreach($creatvsspg in $vmlists | Select-Object -Property Deploy,VMHOST,VLAN,VSSPG -Unique)
{
	$vlanid = $creatvsspg.VLAN
	$vsspg = $creatvsspg.VSSPG
	if($vsspg -eq "none")
	{}
	elseif($getvspg.name -contains $vsspg)
	{
		"$vsspg 已存在,跳过"
	}
	else
	{
		$getvsw | New-VirtualPortGroup -Name $vsspg -VLanId $vlanid -confirm:$false | Out-Null
		"$vsspg 创建成功"
	}
}

if($getvssvmnic.count -eq 0)
{#判断如果VSS没有挂载VMNIC,移除VDS的VSSNIC出来
	foreach($migratevmnic in $vmlists | Select-Object -Property Deploy,VMHOST,VSSNIC,VDSNIC,VDSNAME -Unique)
	{#迁移VDS-VMNIC到VSS-VMNIC
		$VSSNIC = $migratevmnic.VSSNIC
		$VDSNIC = $migratevmnic.VDSNIC
		if($VSSNIC -eq "none" -or $VDSNIC -eq "none")
		{"0"}
		elseif($getvmnic.name -contains $VSSNIC -and $getvmnic.name -contains $VDSNIC)
		{#必须两个 VMNIC 都在 VDS-UPLINK 中才能移除 VSSNIC,并挂载到 VSSW
			$getvmhost | Get-VMHostNetworkAdapter -Physical -Name $VSSNIC | Remove-VDSwitchPhysicalNetworkAdapter -confirm:$false
			$getvssnic = $getvmhost | Get-VMHostNetworkAdapter -Physical -Name $VSSNIC
			$getvsw | Add-VirtualSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $getvssnic -confirm:$false
		}
		elseif($getvmnic.name -notcontains $VSSNIC -and $getvmnic.name -contains $VDSNIC)
		{#如已经移除则挂载 VSSNIC 到 VSSW
			$getvssnic = $getvmhost | Get-VMHostNetworkAdapter -Physical -Name $VSSNIC
			$getvsw | Add-VirtualSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $getvssnic -confirm:$false
		}
	}
}
else
{
	read-host "$vssw 已存在 $getvssvmnic "
}
```
#### 重定向VM的NIC端口组至VSS端口组
```powershell
foreach($vmlist in $vmlists | Select-Object -Property PGNAME,VSSPG -Unique)
{
	$PGNAME	= $vmlist.PGNAME
	$VSSPG	= $vmlist.VSSPG
	if($VSSPG -ne "none")
	{#把该ESXI上的VDSPG迁移到VSSPG上, PG by PG
		$getvmhost | Get-VM | Get-NetworkAdapter | ?{$_.NetworkName -eq $PGNAME} | Set-NetworkAdapter -NetworkName $VSSPG -Confirm:$false -RunAsync | out-null
		"$getvmhost $PGNAME ==> $VSSPG  DONE."
		#这一步会把操作的ESXI-HOST 上所有关联到VDSPG的VM-NIC，重定向关联到VSSPG上
	}
}
```
#### 移除/新建分布式交换机
```powershell
$VDSinfo =  $vmlists | Select-Object -Property VDSNIC,VDSNAME -Unique
$VDSNIC = $vdsinfo.VDSNIC
$VDSNAME = $vdsinfo.VDSNAME
$getvdsw = Get-VDSwitch $VDSNAME
if($getvds -ne "none")
{#如果还没有移除则
	$getvdsw | Remove-VDSwitchVMHost -VMHost $getvmhost -Confirm:$false
	read-host "已移除VDS,确认再从VC中移除$vmhost 则按回车继续"
	Set-VMHost -VMHost $getvmhost -State "Disconnected" | out-null
}
else
{#如果没有注册到新的VDS..
	$getvdsw |  Add-VDSwitchVMHost -VMHost $getvmhost
	$GETVMHOSTNIC = $getvmhost | Get-VMHostNetworkAdapter -Physical -Name $VDSNIC
	$getvdsw | Add-VDSwitchPhysicalNetworkAdapter -VMHostNetworkAdapter $GETVMHOSTNIC -Confirm:$false
}
```
#### 添加ESXI到指定的位置
```powershell
if(!$getvmhost  -eq $null)
{#使用ESXI的凭据 添加到新的VC指定的位置
	$users="root"
	$password="password"
	$Datacenter = "Datacenter"
	$Cluster = "Cluster"
	read-host "按回车确认添加 $vmhost 到 $Datacenter 集群 $Cluster 吗?! 请等待添加完成后再执行任务4 "
	Add-VMHost -Name $vmhost -Location (Get-Datacenter $Datacenter | get-cluster $Cluster)  -User $users -Password $password -force:$true -RunAsync -Confirm:$false | Out-Null
	Start-Sleep -Seconds 30
	#完成后最好等个 30 秒。因为新的 ESXI 加入集群要初始化 HA 状态
}
```
#### 重定向VM的NIC端口组至VDS端口组
```powershell
foreach($vmlist in $vmlists | Select-Object -Property PGNAME,VSSPG,VSSNIC,VDSNAME -Unique)
{
	$PGNAME	= $vmlist.PGNAME
	$VSSPG	= $vmlist.VSSPG
	$VSSNIC = $vmlist.VSSNIC
	$VDSNAME = $vmlist.VDSNAME
	#把该ESXI上的VSSPG迁移到VDSPG上,按PG来
	if($VSSPG -ne "none")
	{
		$getvmhost | Get-VM |Get-NetworkAdapter | ?{$_.NetworkName -eq $VSSPG} | Set-NetworkAdapter -NetworkName $PGNAME -Confirm:$false -RunAsync | out-null
		"$getvmhost $VSSPG  ==>  $PGNAME DONE."
	}
}
Start-Sleep -Seconds 3
#检查VSW上还有没有没被处理的VM
$vssw = "vSwitch2" 
$getvdsw = Get-VDSwitch $VDSNAME
$getvssw =  Get-VirtualSwitch $getvmhost -Name $vssw
$vspgnum = $getvssw | Get-VirtualPortGroup
$vspgvmnum = $getvssw | Get-VM
$vmnum = $vspgvmnum.count
" $vssw 上共有 $vmnum 个VM ,如果存在VM,请检查"
read-host "按回车确认移除VSS,并把$VSSNIC 添加至 VDS $VDSNAME"
if($vspgvmnum.Count -eq 0)
{#只有VSSPG上没有挂载VM,才可以移除VSSPG,归还VMNIC给VDS
	Remove-VirtualSwitch -VirtualSwitch $getvssw -Confirm:$false
	$GETVMHOSTNIC = $getvmhost | Get-VMHostNetworkAdapter -Physical -Name $VSSNIC
	$getvdsw | Add-VDSwitchPhysicalNetworkAdapter -VMHostNetworkAdapter $GETVMHOSTNIC -Confirm:$false
	"移除VSS, $VSSNIC 添加至 VDS $VDSNAME DONE"
}
else
{
	"$vssw 上连接了 $vmnum 个VM ,请检查并移除后继续"
	read-host
	$vspgvmnum = $getvssw | Get-VM
	if($vspgvmnum.Count -eq 0)
	{#直到VSSPG上没有挂载VM
		Remove-VirtualSwitch -VirtualSwitch $getvssw -Confirm:$false
		$GETVMHOSTNIC = $getvmhost | Get-VMHostNetworkAdapter -Physical -Name $VSSNIC
		$getvdsw | Add-VDSwitchPhysicalNetworkAdapter -VMHostNetworkAdapter $GETVMHOSTNIC -Confirm:$false
		"移除VSS, $VSSNIC 添加至 VDS $VDSNAME DONE"
	}
}
```
## 简单新建代替会死吗？

当我提出这个方案的时候，很多人问我的一个问题。
其实并不会死，指示会让你麻烦死。
首先，肯定不能直接在集群里移除ESXI，你只能断开连接这个ESXI 
其次，未从 VDS 移除 ESXI ，ESXI 会残留这原来的VDS信息，直接去注册到别的 VDS ，你需要替换对应的端口组，但很不幸的告诉你，这个时候你已经无法看到VM的网卡原来关联的端口组名称是什么了，这会让你的运维带来困境。万一你选错关联的端口组。VM 的网络会中断。

## 运行好好的为什么升级？
通过从 VC5.5 升级到使用 VCSA6.0 可获得以下收益。
- 支持更大的集群规模，支持 64 个主机组成集群
- 为后续ESXi5.5 升级到 ESXi6.0 夯实基础
- 节约额外的授权费用（VC需要Windows，sql server授权，VCSA则不需要）
- 节省独占物理主机的运营成本
- 部署 VCSA 比 VC 要更快
- 日常运行效率更高
- 可获得虚拟机的高可用，数据保护，中高端存储的性能优势
- 灵活的增配VC资源
- 两个VC共享验证凭据，SSO单点登陆







