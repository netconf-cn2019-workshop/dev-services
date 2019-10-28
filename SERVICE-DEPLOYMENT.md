

## 部署微服务

在每一套环境中，部署微服务都分为两个步骤，即部署基础设施和微服务本身。基础设施指的是微服务运行期间所需的数据库、缓存等服务。

当针对某一个特定的环境部署时，需要输入以下两个参数：
1. 环境名称（`--env`）
2. 部署后缀（`--suffix`）

**环境名称**指的是，当前要执行的部署任务的目标环境是哪一个，可以选择的值有：
* `dev` 表示开发环境，即开发人员自用的环境
* `stage`  表示预生产环境

**部署后缀**请参考 [文档首页](https://github.com/netconf-cn2019-workshop/dev-services/blob/master/README.md) 的说明。


### 部署基础设施

针对每一个环境，比如 `dev` 或者 `stage`，只需要部署一次基础设施。之后，多次部署微服务时，可持续使用这些基础设施。

```sh
./provision-infra.sh --env <env> --suffix <suffix>
```

如需删除已部署的基础设施，请手动执行：

```
# 请先切换到正确的 Kubernetes namespace 下
kubectl delete deployments,services,configmaps -l tier=infrastructure
```


### 部署微服务


针对每一个环境，比如 `dev` 或者 `stage`，微服务可以多次部署。

部署步骤是：

1. 如果在现场参与工作坊，请跳过这一步。手动编辑 `services/vars` 文件，将 `DNS_SUFFIX` 变量的值改成你的环境中的 Ingress 的域名后缀。

2. 手动编辑 `services/vars` 文件，请更改 `REGISTRY_SERVER` 变量为你存储微服务的镜像容器注册表（Image Registry）的位置。

3. 手动编辑 `services/service-list` 文件，将其中每行的最后一项（按冒号 `:` 分隔），改为你希望部署的镜像的版本号。

4. 回到上级目录，执行以下命令行，完成服务的部署：

```sh
./provision-services.sh --env <env> --suffix <suffix>
```

如需删除已部署的微服务，请手动执行：

```
# 请先切换到正确的 Kubernetes namespace 下
kubectl delete deployments,services,configmaps,ingress -l 'tier in (backend, frontend)'
```

### 访问微服务

使用以下命令查看可用的网站入口：

```sh
kubectl get ingress
```

你应该能够获取类似下面的输出，访问 `HOSTS` 那一列的值即可访问相应的服务：

```
NAME                       HOSTS                             ADDRESS      PORTS   AGE
ecommerce-webapp-ingress   ecommerce-user1.aks.cloudapp.cn   10.28.6.51   80      27h
```