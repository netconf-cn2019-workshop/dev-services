

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

下面介绍使用 kubectl 1.14 以上的版本，或者 kustomize 的安装方法。关于使用 Helm 安装 Ingress 的方法，请参考 [Azure 官方文档](https://docs.microsoft.com/zh-cn/azure/aks/ingress-basic)。

首先，下载用于安装 Ingress Controller 的部署文件：

```
mkdir -p ingress
curl -s -o "ingress/#1.yaml" "https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/{configmap,mandatory,namespace,rbac,with-rbac}.yaml"
curl -s -o "ingress/service.yaml" "https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml"
```

手动编辑 `ingress/mandatory.yaml` ，并删除其中的如下两行：

```
    nodeSelector:
      kubernetes.io/os: linux
```

然后执行安装：

```
kubectl create namespace ingress-nginx
kubectl config set-context $(kubectl config current-context) --namespace "ingress-nginx"
kubectl apply -f ./ingress
```

安装完毕后，使用以下命令获取你的公网 IP：

```
kubectl rollout status deployments/nginx-ingress-controller
kubectl get service/ingress-nginx --namespace ingress-nginx --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

如果发现 `deployments/nginx-ingress-controller` 迟迟不能完成，请使用 `kubectl get pods` 查看 Pod 运行状态，并配合使用 `kubectl describe pod/<pod-id>` 和 `kubectl logs pod/<pod-id>` 来了解部署失败的原因。


## 访问 Dashboard

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

