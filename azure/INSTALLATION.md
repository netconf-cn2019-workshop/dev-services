

# 在 Azure 环境运行工作坊

首先，请根据[官方文档](https://docs.azure.cn/zh-cn/aks/)创建你的集群。

下面的内容适用于你已经成功完成了集群的创建的后续操作。完成下述各步骤之后，即可继续按照工作坊 [文档首页](https://github.com/netconf-cn2019-workshop/dev-services/blob/master/README.md) 的说明继续操作。

 

## 安装 Azure 命令行工具

请根据 Azure CLI 的文档安装 [Azure 命令行工具](https://docs.azure.cn/zh-cn/cli/index)。

如果你使用由世纪互联运营的中国区 Azure 云，请设置云环境为中国区：

```
az cloud set -n AzureChinaCloud
```

然后，完成 Azure 命令行工具的登录：

```
az login
```

如果你的账号中有多个订阅，请注意切换到正确的订阅上。

## 配置 kubectl

[安装 kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/), 请确保 kubectl 与 aks 中的集群的版本一致。

```
az aks get-credentials -g <resource_group> --name <cluster_name>
```

## 安装 Ingress Controller

下面介绍直接使用 Yaml 配置文件的安装方法。关于使用 Helm 安装 Ingress 的方法，请参考 [Azure 官方文档](https://docs.microsoft.com/zh-cn/azure/aks/ingress-basic)。

执行安装：

```
kubectl create namespace ingress-nginx
kubectl config set-context $(kubectl config current-context) --namespace "ingress-nginx"
kubectl apply -f ./nginx-ingress-controller
```

安装完毕后，使用以下命令获取 Ingress 的公网 IP：

```
kubectl rollout status deployments/nginx-ingress-controller
kubectl get service/ingress-nginx --namespace ingress-nginx --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

获得了 Ingress 的公网 IP 之后，请手动设置泛域名（例如 `workshop.dotnetconf.cn`）解析到该 IP。后续部署 CI/CD 环境或者部署微服务时，请将该泛域名作为 `dns_suffix` 变量的值设置到变量文件中。

如果发现 `deployments/nginx-ingress-controller` 迟迟不能完成，请使用 `kubectl get pods` 查看 Pod 运行状态，并配合使用 `kubectl describe pod/<pod-id>` 和 `kubectl logs pod/<pod-id>` 来了解部署失败的原因。


## 访问 Dashboard（可选）

Azure aks 环境默认已经启用了 Dashboard。首次使用之前，需要为 `kubernetes-dashboard` 用户赋予集群管理员的角色。

```
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin -serviceaccount=kube-system:kubernetes-dashboard
```

后续只需要在本地运行以下命令，即可：

```
kubectl proxy
```

或者，也可以运行 azure cli 提供的命令：

```
az aks browse -g <resource_group> -n <cluster_name>
```

## 分配学员用户

学员用户是参与工作坊的用户，他们每个人可以操作自己命令空间（namespace）中的对象，部署自己的工作坊环境，相互互不干扰。

执行以下命令创建一个工作坊用户：

```sh
cd azure
./create-user.sh <suffix>
```

此命令将新建 `users` 子目录，并在其中放置用于新用户设置他们的 kubectl 命令行工具的 config 文件。

### 删除学员用户

请执行以下命令，以删除一个学员用户。学员用户被删除之后，他所创建的各种资源也将一并被自动删除。该学员用户将失去访问 aks 集群的权限。

```sh
cd azure
./delete-user.sh <suffix>
```
