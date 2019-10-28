
## 部署 CI/CD 环境


确保你能够运行 Shell 脚本。在 Windows 机器上，请安装并运行 [Git](http://git-scm.com)，并启动 Git Bash 命令行工具。


**第一步，编辑变量文件**

找到本项目目录下的 `cicd-infra/vars` 文件，使用文本编辑器编辑其中的变量。各个变量的含义如下：

| 变量 |  描述  |  
|----|----|
| dns_suffix | 环境中 Ingress 使用的顶级域名 |
| import_repo | 要向 gogs、Jenkins 中默认导入的 Git 项目 |
| gogs_repo_name | 将项目导入 gogs 时，使用的名称 |
| deploy_suffix | 本次部署后缀（不需要修改，在运行部署脚本时指定） |

**部署后缀**请参考 [文档首页](https://github.com/netconf-cn2019-workshop/dev-services/blob/master/README.md) 的说明。

**第二步，运行部署脚本**

部署工作坊基础环境只需要运行一个简单的脚本即可。在运行时，需要指定 `--suffix` 部署后缀的变量值。

运行以下脚本，并部署你的 CI/CD 环境

```sh
./provision-cicd.sh --suffix <suffix>
```

