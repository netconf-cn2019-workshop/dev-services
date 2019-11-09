# 工作坊与会者文档

欢迎来到 .NET Core on Kubernetes 工作坊。本次工作坊将在 2019.11.10 在上海举行，同时提供线上直播。

2019.11.10 在上海 .NET Conf 大会第二天，由张善友、陈计节、刘腾飞三位合台为您呈现 NET Core 基于K8S的微服务和 CI/CD 动手工作坊，课程中会有三位助教（陈作、张潇、章展宏）协助各项准备和现场工作。

## 工作坊简介

本次工作坊会涉及到 .NET Core 容器开发、.NET Core 微服务开发、Kubernetes、以及 CI/CD 相关的内容。我们会用一个小型电商的项目做为 Demo，这个 Demo 的代码我们已经传到 [GitHub](https://github.com/netconf-cn2019-workshop/) 了。请大家务必在到场之前在自己的笔记本上安装好必要的工具以及 SDK。

现场工作坊地址： 上海市徐汇区田林路192号 J 座微软 Reactor （请大家不要迟到，我们会在 9 点准时开始；地点与前一天的会议不在同一个位置）

**请特别注意**

[由世纪互联运营的 Azure 中国](https://www.azure.cn/home/features/kubernetes-service)为现场的每一位同学提供了一个线上的 Kubernetes 集群环境，现场的同学只需要在自己的笔记本上有kubectl这个客户端即可，不需要自己建集群。

参与直播的同学如果想跟着直播一起做动手实践，需要自己有一套 Kubernetes 集群环境。可以用 Minikube，或者自己选用其他云服务。详情请参考[工作坊前的准备工作](https://github.com/netconf-cn2019-workshop/dev-services/blob/master/attendees/GETTING-READY.md#%E5%B7%A5%E4%BD%9C%E5%9D%8A%E5%89%8D%E7%9A%84%E5%87%86%E5%A4%87%E5%B7%A5%E4%BD%9C)

## 整体流程

**上午 9:00 ~ 12:00**

* 概要介绍 （主要介绍我们这6个小时做什么）
* 项目 Demo（动手项目整体demo)
* .NET Core 容器化开发
  * 完成一个.NET Core 项目的镜像构建及Docker部署 
* Kubernetes 基础原理及实践
  * 连接到 Azure Kubernetes 集群
  * 基础原理
  * 部署.NET Core服务镜像到 Kubernetes 并预览
* CI/CD 基础以及实践 
  * 基础介绍
  * 环境搭建 
  * 动手操作完成项目的 CI/CD

**下午 13:30~16:30**

* 微服务开发体系原理和概念介绍   60分钟 
  * 基础概念 
  * 网关
  * 统一认证及授权 
  * 服务通信 
  * 统一配置 on Kubernetes
* 微服务开发实践  90 分钟 
  * 在现有微服务示例项目上增加功能 
  * 部署微服务项目到 Kubernetes
  * 通过 CI/CD 部署所有微服务  
* 总结

## 本地电脑软硬件环境依赖

* 可用内存：8GB 或更多
* 操作系统：Windows/macOS
* 浏览器：Chrome/Edge/Safari
* .NET Core 开发环境
  * 集成开发 IDE，任选其一即可：
    * Visual Studio 2017 或更新
    * Visual Studio Code
    * JetBrains Rider 2018.3 或更新
  * [.NET Core SDK](https://dotnet.microsoft.com/download/dotnet-core/2.2)，请使用 2.2 版本
* [Git](http://git-scm.com) 1.9 或更新
* 容器开发环境
  * [Docker](https://docs.docker.com/install/) 18.09 或更新
  * [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) 1.14.7（对于不在现场参与的人士，请使用与你的集群相匹配的版本）
* 命令行环境
  * Git Bash/WSL
  * macOS Terminal/iTerm

## 验证你的环境

执行以下命令以确保你电脑上的各个软件均运行正确：

```sh
dotnet --version
git --version
docker --version
kubectl version --client
```

可以提前把相关基础镜像拉取到本地
```docker pull mcr.microsoft.com/dotnet/core/sdk:2.2
docker pull mcr.microsoft.com/dotnet/core/aspnet:2.2
```

## 提前熟悉代码

工作坊并不要求参与者提前熟悉代码，如果你希望提前熟悉一下，可以使用以下脚本：

用 PowerShell 克隆所有项目：

```ps1
"docker-workshop","dev-services", "ECommerce.Catalog.Api","ECommerce.Payment.Host","ECommerce.Shipping.Host","ECommerce.Common","ECommerce.Reporting.Api","ECommerce.WebApp","ECommerce.Customers.Api","ECommerce.Sales.Api","ECommerce.Services.Common"  | ForEach-Object { powershell git clone  "https://github.com/netconf-cn2019-workshop/$_.git" }
```

用 Shell Script 克隆所有项目：

```sh
for p in "docker-workshop" "dev-services" "ECommerce.Catalog.Api" "ECommerce.Payment.Host" "ECommerce.Shipping.Host" "ECommerce.Common" "ECommerce.Reporting.Api" "ECommerce.WebApp" "ECommerce.Customers.Api" "ECommerce.Sales.Api" "ECommerce.Services.Common" ;  do git clone https://github.com/netconf-cn2019-workshop/$p.git; done
```

在现场，讲师还会引导再次下载所有的代码。

## 工作坊前的准备工作

在现场参与工作坊的人士，下列准备工作将在现场按照讲师的引导完成。

### 不在现场的参与者

在现场参与工作坊的人士，请忽此节。此部分基础设施，将由工作坊组织方提供。对于不在现场的参与者，要么使用 [Azure Kubernetes Service 服务](https://www.azure.cn/home/features/kubernetes-service) (aks) 或其他云服务创建你自己的集群，要么请使用 [Minikube](https://minikube.sigs.k8s.io/) 创建一个自有集群。创建集群时，请确保集群的工作节点上至少有 8GB 的可用内存。

如果你使用 aks 集群，请[参考此处](https://github.com/netconf-cn2019-workshop/dev-services/blob/master/azure/INSTALLATION.md)的文档完成对集群的必要初始化工具。如果使用自建的集群，请根据其对应的文档添加 Ingress Controller 等扩展功能。

集群创建完成之后，请设置好你的本地工作环境的 kubectl，使用以下命令确保其能够成功连接到创建完成的集群：

```sh
kubectl cluster-info
```

### 现场参与的人士

不在现场参与工作坊的人士，请忽此节。现场参与人士访问集群的凭据，将由工作坊讲师在现场提供。

请将讲师提供的凭据文件置于 `~/.kube/config` 的位置：

请执行此命令完成用户凭据的放置：

```sh
mkdir -p ~/.kube
~/Downloads/kubeconfg ~/.kube/config
```

对于 Windows 用户，请使用 Git Bash 命令行工具执行上述命令。

注意，这一操作将覆盖你本地电脑上原有可能已经安装的 kubectl 凭据文件。如果有必要，请提前备份你原来位于 `~/.kube/config` 处的凭据文件。

然后测试你对工作坊环境的访问：

```sh
kubectl cluster-info
```

## 开始工作坊

### 部署 CI/CD 环境

请回到工作目录根目录，下载用于部署工作坊环境的脚本文件：

```sh
# cd <workspace>
git clone https://github.com/netconf-cn2019-workshop/dev-services.git
```

请根据 [CI/CD 部署文档](https://github.com/netconf-cn2019-workshop/dev-services/blob/master/CICD-DEPLOYMENT.md)，完成 CI/CD 环境的部署。

部署完成后，可以访问其中的 Jenkins 服务和 gogs 服务，以确定各个网站运行正常。


### 下载所有项目的源代码

CI/CD 环境部署完成之后，请回到工作目录根目录，使用如下脚本下载工作坊所需的所有项目代码：

```sh
# cd <workspace>
for p in "ECommerce.Catalog.Api" "ECommerce.Payment.Host" "ECommerce.Shipping.Host" "ECommerce.Common" "ECommerce.Reporting.Api" "ECommerce.WebApp" "ECommerce.Customers.Api" "ECommerce.Sales.Api" "ECommerce.Services.Common" ;  do git clone http://gogs-$(cat ./cicd-infra/vars | grep deploy_suffix | cut -d '=' -f 2).$(cat ./cicd-infra/vars | grep dns_suffix | cut -d '=' -f 2)/gogs/$p.git; done
```

  

至此你已经完成了参加工作坊的所有准备工作。
