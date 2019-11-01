
# 基于 Kubernetes 的 .NET Core 工作坊环境

本工作坊需要一个运行中的 Kubernetes 环境，并要求整个集群中工作节点上至少有 8GB 可用内存。

推荐使用 [Azure Kubernetes](https://azure.microsoft.com/zh-cn/services/kubernetes-service/) 服务。2019.11.10 当天在上海的工作坊现场各位参与者所用的 Kubernetes 是[由世纪互联运营的 Microsoft Azure 云](https://www.azure.cn/home/features/kubernetes-service)赞助的。

你也可以使用 [Minikube](https://minikube.sigs.k8s.io/) 在自己的电脑上运行一个小型的 Kubernetes 环境。

请确保你的集群的版本号是下列版本之一：`1.13.11`, `1.14.7`, `1.15.4`, `1.16.0`。

### 确保登录到 Kubernetes 环境

在有了 Kubernetes 集群之后，请在本地电脑上安装 kubectl 命令行工具。安装完成之后，打开一个命令行窗口（PowerShell 或 Bash），执行以下命令，以确保你的 `kubectl` 命令安装正确：

```sh
kubectl cluster-info
kubectl get namespaces
```

确保能够看到类似于以下内容的输出：

```
Kubernetes master is running at https://10.28.6.51:8443
KubeDNS is running at https://10.28.6.51:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

NAME                   STATUS   AGE
default                Active   12d
kube-node-lease        Active   12d
kube-public            Active   12d
kube-system            Active   12d
kubernetes-dashboard   Active   12d
```


## 部署工作坊环境

请先确保你能够运行 Shell 脚本。在 Windows 机器上，请安装并运行 [Git](http://git-scm.com)，并启动 Git Bash 命令行工具。

工作坊环境包括三部分，通过运行对应的脚本即可完成对应部分的部署：

| 脚本 |  内容  |
|----|----|
| `provision-cicd.sh` | [部署 CI/CD 持续集成和持续交付依赖的服务](https://github.com/netconf-cn2019-workshop/dev-services/blob/master/CICD-DEPLOYMENT.md) |
| `provision-infra.sh` | [部署微服务基础设施，如数据库和消息队列等](https://github.com/netconf-cn2019-workshop/dev-services/blob/master/SERVICE-DEPLOYMENT.md) |
| `provision-services.sh` | [部署各个微服务](https://github.com/netconf-cn2019-workshop/dev-services/blob/master/SERVICE-DEPLOYMENT.md) |

运行这些脚本时，需要输入特定的参数。请点击链接访问具体的文档了解详情。

## 关于部署后缀参数

上述所有脚本都包含一个名为 `--suffix` 的参数，即 “部署后缀”。

**部署后缀** 指的是，当所有工作坊参与者都位于同一个 Kubernetes 集群中工作时，用于标识你自己的一个后缀字符串。这个后缀字符串将出现在 Kubernetes 的 `namespace` 名称，以及各个微服务、CI/CD 软件的公开 URL 的域名中。

在现场参与工作坊的人士，请根据讲师的指引输入此值；自行练习的人士，请自拟一个值。典型的值是：
* 讲师分配给你的序号，例如 `user12`
* 你电脑的用户名，比如`$(id -un | awk '{print tolower($0)}')`
* 你自拟的其他值，比如 `fancydotnet`

后缀的值应该只包含小写字母，不能包含任何大写字符、特殊字符和中文。
