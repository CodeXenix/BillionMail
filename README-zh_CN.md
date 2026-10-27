<div align="center">
  <a name="readme-top"></a>
  <img src="core/frontend/src/assets/images/logo.svg" width="88" alt="Xenix Mail logo" />
  <h1>Xenix Mail</h1>

## 一个开源的邮件服务器、新闻通讯和电子邮件营销平台

[![][license-shield]][license-link] [![][github-release-shield]][github-release-link] [![][github-stars-shield]][github-stars-link]

[English](README.md) | 简体中文 | [日本語](README-ja.md) | [Türkçe](README-tr.md)
</div>
<br/>

## 什么是 Xenix Mail？

Xenix Mail 是一个开源的**邮件服务器和电子邮件营销平台**，帮助企业和个人轻松管理他们的电子邮件营销活动。无论您是发送新闻通讯、促销邮件还是交易消息，它都能让您对电子邮件营销拥有**完全控制**。通过**高级分析**和**客户管理**，您可以像专业人士一样创建、发送和跟踪电子邮件。

## 三步快速上手

### 第 1 步：安装 Xenix Mail
从安装到首次成功发送**大约只需 8 分钟**。
```shell
cd /opt && git clone https://github.com/CodeXenix/XenixMail && cd XenixMail && bash install.sh
```

### 第 2 步：连接您的域名
- 添加发送域名
- 验证 DNS 记录
- 自动启用免费 SSL

### 第 3 步：创建您的营销活动
- 撰写或粘贴您的邮件
- 选择列表和标签
- 设置发送时间或立即发送

## 使用 Docker 安装
请自行安装 Docker 和 docker-compose 插件，然后修改 `.env` 文件。
```shell
cd /opt && git clone https://github.com/CodeXenix/XenixMail && cd XenixMail && cp env_init .env && docker compose up -d || docker-compose up -d
```

## 管理脚本
- 管理帮助

  `bm help`

- 查看默认登录信息

  `bm default`

- 显示域名 DNS 记录

  `bm show-record`

- 更新 Xenix Mail

  `bm update`

## 网页邮箱

Xenix Mail 已集成 **RoundCube**，您可以通过 `/roundcube/` 访问网页邮箱。

## 为什么选择 Xenix Mail？

大多数电子邮件营销平台要么**昂贵**，要么**闭源**，或者**缺乏基本功能**。Xenix Mail 与众不同：

✅ **完全开源** – 没有隐藏成本，没有供应商锁定。  
📊 **高级分析** – 跟踪投递、打开率、点击率等。  
📧 **无限发送** – 对您可以发送的电子邮件数量没有限制。  
🎨 **可定制模板** – 可重复使用的专业营销模板。  
🔒 **隐私优先** – 您的数据保留在您这里，没有第三方跟踪。  
🚀 **自托管** – 在您自己的服务器上运行，完全控制。  

## 问题

如果您遇到任何问题或有功能请求，请[提交 issue](https://github.com/CodeXenix/XenixMail/issues)。请包括：

- 问题或请求的清晰描述。
- 重现问题的步骤（如适用）。
- 截图或错误日志（如适用）。

## 许可证

Xenix Mail 根据 **AGPLv3 许可证**授权。这意味着您可以：

✅ 免费使用该软件。  
✅ 修改和分发代码。  
✅ 私下使用，没有限制。

Xenix Mail 是 aaPanel 开发的 [BillionMail](https://github.com/aaPanel/BillionMail) 的修改版本，同样根据 AGPLv3 许可证授权。有关更多详细信息，请参阅 [LICENSE](LICENSE) 文件。

---

[license-link]: https://www.gnu.org/licenses/agpl-3.0.html
[github-release-link]: https://github.com/CodeXenix/XenixMail/releases/latest
[github-stars-link]: https://github.com/CodeXenix/XenixMail

[github-release-shield]: https://img.shields.io/github/v/release/CodeXenix/XenixMail
[github-stars-shield]: https://img.shields.io/github/stars/CodeXenix/XenixMail?color=%231890FF&style=flat-square
[license-shield]: https://img.shields.io/github/license/CodeXenix/XenixMail
