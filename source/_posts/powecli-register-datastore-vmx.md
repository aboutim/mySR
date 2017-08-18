---
title: 使用 PowerCLI 批量获取 VMX 并注册到 VC 清单中
date: 2017-07-17 13:23:10
categories: 虚拟化
tags:
  - PowerCLI
  - VMWare运维
  - VMX
---

## 适合场景
  - 存储搬迁到别的机房，VM 计划性停机，使用需要批量的把 VM 注册到新机房的计算资源池中。
  - 适合找出没有注册到VC指定位置中的非活动 VM

## 思路
1. 获取 Datastore 的信息 ，示例是获取集群内的 Datastore
    ```
    $Datastoreinfo =  Get-Datastore -Nmae 'DatastoreName' | %{Get-View $_.Id}
    ```
2. 处理 Datastore 的信息
    ```
    $DsBrowser = Get-View $Datastoreinfo.browser
    ```
3. 新建搜索对象，附加搜索条件
    ```
   $SearchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
   $SearchSpec.matchpattern = "*.vmx"
   $DsPath = "[" + $Datastoreinfo.Name + "]"
    ```
4. 搜索并展现
    ```
   $SearchResult = $DsBrowser.SearchDatastoreSubFolders($DsPath, $SearchSpec) | where {$_.FolderPath -notmatch ".snapshot"} | %{$.FolderPath + ($_.File | select Path).Path}
    ```
    最终输出的结果为
    ```
    [datastorename] VMnameFolder/VMname.vmx
    ```

5. 注册VM
    ```
    New-VM -Name $VMname -VMFilePath $VMXpath -ResourcePool $vmhost -Location $VMFolder -RunAsync
    ```
    
*如果 VM 名称曾经修改过，又没有做过 XvMotion (storeger vMotion) VMnameFolder以及目录下所有的VM文件，还是原来旧的 VMname 命名。

## 扩展
  - 可套用 foreach 循环，对多个 Datastore 进行检索VMX文件
  - 如果是场景1，可在 VM 是注册状态下，使用 PowerCLI 直接获取 VMX_PATH 路径以及对应的 VMname，位置信息等，导出为表，将来可使用 PowerCLI 根据表的信息进行注册。
   
