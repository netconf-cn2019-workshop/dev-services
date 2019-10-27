

## 部署微服务

在每一套环境中，部署微服务都分为两个步骤，即部署基础设施和微服务本身。基础设施指的是微服务运行期间所需的数据库、缓存等服务。

当针对某一个特定的环境部署时，需要输入以下两个参数：
1. 环境名称（`--env`）
2. 你的部署后缀（`--suffix`）

环境名称指的是，当前要执行的部署任务的目标环境是哪一个，可以选择的值有：
* `dev` 表示开发环境，即开发人员自用的环境
* `stage`  表示预生产环境

部署后缀指的是，当所有工作坊参与者都位于同一个 Kubernetes 集群中工作时，用于标识你自己的一个后缀。这个后缀将出现在 Kubernetes 的 `namespace` 名称，以及各个微服务、CI/CD 软件的公开 URL 的域名中。

在现场参与工作坊的人士，请根据讲师的指引输入此值；自行练习的人士，请自拟一个值。典型的值是：
* 讲师分配给你的序号，例如 `user12`
* 你电脑的用户名，比如`$(id -un | awk '{print tolower($0)}')`
* 你自拟的其他值，比如 `fancydotnet`

前缀的值应该只包含小写字母，不能包含任何大写字符、特殊字符和中文。


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
kubectl delete deployments,services,configmaps -l tier=backend -l tier=frontend
```