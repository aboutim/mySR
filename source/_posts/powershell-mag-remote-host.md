---
title: 使用 Powershell 远程管理服务器
date: 2015-11-18 16:29:24
categories: Powershell
tags:
  - Powershell
---

## 管理环境-条件

- 远程服务器（客户端）
    
    默认情况下，PowerShell 禁止 PowerShell 脚本在 Windows 系统中执行。需要修改策略来解除。
1. PowerShell 管理员模式下执行：
    ``` powershell
    Set-ExecutionPolicy bypass 
    ```
2. 启用远程处理模式
    ``` powershell
    Enable-PSRemoting -force 
    ```
- 管理服务器（管理端）
1. 添加信任列表，PowerShell 管理员模式下执行：
    ``` powershell
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -force
    ```

## 扩展
远程操作主要依赖几个Session（会话）命令和Invoke-Command命令来进行。总结下
1. Enter-PSSession 远程交互式会话

    这个场景一般用于手动进行远程操作，输入命令，查看结果。方法很简单。进入交互式会话的命令是Enter-PSSession，退出时键入Exit-PSSession或者exit都可以。远程交互式操作期间，输入的命令在远程计算机上运行，就像直接在远程计算机上输入并执行这些命令一样。期间所定义的变量和命令的执行结果在退出交互式会话之后不再可用。
    
2.  New-pssession 建立会话执行一次性操作

    这种在本地计算机与远程计算机上建立一个临时会话。将脚本块或者脚本文件的内容发送到远程计算机执行，并将结果发回本地计算机。这种方法执行效率很高，是PowerShell推荐的执行远程命令的方法。除非需要在会话中共享数据，否则建议使用该使用方法。注意，会话数量是有限制的，用完务必释放会话。
    
3. Invoke-Command 命令/脚本在命名会话中执行
    
    用 New-pssession 建立会话并保存到一个变量中，然后在Invoke-Command中指定会话使用该变量。可将执行结果赋予到新的变量中
    格式：
    ``` powershell
    $sub = Invoke-Command -Session $session1 -ScriptBlock {dir c:\}
    ```
    
## 其它
PowerShell 在网络处理方面有诸多限制。比如 PowerShell 不能在远程机器上显示界面，即使是有界面的程序，也只能在后台运行。
 
