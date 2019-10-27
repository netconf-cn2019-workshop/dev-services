
# 基于 Kubernetes 的 .NET Core 工作坊环境


## 创建 Kubernetes 环境

推荐使用 [Azure Kubernetes](https://azure.microsoft.com/zh-cn/services/kubernetes-service/) 服务。你也可以使用 [Minikube](https://minikube.sigs.k8s.io/) 在自己的电脑上运行一个 Minikube 环境。

本 Workshop 所需的 Minikube 集群至少需要 8GB 内存。

## 部署工作坊环境

确保你能够运行 Shell 脚本。在 Windows 机器上，请安装并运行 [Git](http://git-scm.com)，并启动 Git Bash 命令行工具。

**第一步，确保登录到 Kubernetes 环境**

在你本地安装 `kubectl` 命令行工具，运行以下命令，以确保你的 `kubectl` 命令安装正确：

```sh
kubectl cluster-info
kubectl get namespaces
```

**第二步，编辑变量文件**

找到本项目目录下的 `cicd-infra/vars` 文件，使用文本编辑器编辑其中的变量。各个变量的含义如下：

| 变量 |  描述  |  
|----|----|
| dns_suffix | 环境中 Ingress 使用的顶级域名 |
| import_repo | 要向 gogs、Jenkins 中默认导入的 Git 项目 |
| gogs_repo_name | 将项目导入 gogs 时，使用的名称 |
| deploy_suffix | 本次部署后缀（不需要修改，在运行部署脚本时指定） |

**第三步，运行部署脚本**

部署工作坊基础环境只需要运行一个简单的脚本即可。在运行时，需要指定 `--suffix` 部署后缀的变量值。

运行以下脚本，并部署你的 CI/CD 环境

```sh
./provision-cicd.sh --suffix <suffix>
```

**关于部署后缀的说明**

**部署后缀** 指的是，当所有工作坊参与者都位于同一个 Kubernetes 集群中工作时，用于标识你自己的一个后缀字符串。这个后缀字符串将出现在 Kubernetes 的 `namespace` 名称，以及各个微服务、CI/CD 软件的公开 URL 的域名中。

在现场参与工作坊的人士，请根据讲师的指引输入此值；自行练习的人士，请自拟一个值。典型的值是：
* 讲师分配给你的序号，例如 `user12`
* 你电脑的用户名，比如`$(id -un | awk '{print tolower($0)}')`
* 你自拟的其他值，比如 `fancydotnet`

后缀的值应该只包含小写字母，不能包含任何大写字符、特殊字符和中文。

## 部署微服务

上面的基础环境创建完成之后，就可以开始部署微服务了，请参考 [微服务部署](https://github.com/netconf-cn2019-workshop/dev-services/blob/master/SERVICE-DEPLOYMENT.md) 文档。