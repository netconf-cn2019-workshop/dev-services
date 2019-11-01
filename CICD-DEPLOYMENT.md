
## 部署 CI/CD 环境

### 编辑变量文件

找到本项目目录下的 `cicd-infra/vars` 文件，使用文本编辑器编辑其中的变量。各个变量的含义如下：

| 变量 |  描述  |  
|----|----|
| dns_suffix | 环境中 Ingress 使用的顶级域名 |
| k8s_version | Kubernetes 集群的版本号，支持 `1.13.11`, `1.14.7`, `1.15.4`, `1.16.0` |
| ingress_apiversion | Ingress 的 apiVersion 值。如果 kubectl 版本小于 `1.14.0`，请使用 `extensions/v1beta1`，否则请使用 `networking.k8s.io/v1beta1` |
| import_repo | 要向 gogs、Jenkins 中默认导入的 Git 项目 |
| gogs_repo_name | 将项目导入 gogs 时，使用的名称 |
| deploy_suffix | 本次部署后缀（不需要修改，在运行部署脚本时指定） |

**部署后缀**请参考 [文档首页](https://github.com/netconf-cn2019-workshop/dev-services/blob/master/README.md) 的说明。

### 运行部署脚本

部署工作坊基础环境只需要运行一个简单的脚本即可。在运行时，需要指定 `--suffix` 部署后缀的变量值。

运行以下脚本，并部署你的 CI/CD 环境

```sh
./provision-cicd.sh --suffix <suffix>
```

等待部署完成。

### 访问相关服务

使用以下命令查看可用的网站入口：

```sh
kubectl get ingress
```

你应该能够获取类似下面的输出，访问 `HOSTS` 那一列的值即可访问相应的服务：

```
NAME                HOSTS                             ADDRESS      PORTS   AGE
gogs-ingress        gogs-user1.aks.cloudapp.cn        10.28.6.51   80      24h
jenkins-ingress     jenkins-user1.aks.cloudapp.cn     10.28.6.51   80      24h
nexus-ingress       nexus-user1.aks.cloudapp.cn       10.28.6.51   80      24h
sonarqube-ingress   sonarqube-user1.aks.cloudapp.cn   10.28.6.51   80      24h
```