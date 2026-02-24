达梦8.4(arm64架构)测试镜像

此镜像仅供测试环境使用，默认的许可证有效期很短。

## 构建镜像

这里的`DMInstall.bin`来自官网的信创（arm）版本，CPU选鲲鹏920，操作系统选麒麟10 SP1。源文件名为dm8_20251114_HWarm920_kylin10_sp1_64.zip，解压后可以得到。
```bash
docker build -t dm8:8.4-arm .
```

## 启动示例
见`docker-compose.yml`