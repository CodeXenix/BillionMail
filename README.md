<div align="center">
  <a name="readme-top"></a>
  <img src="core/frontend/src/assets/images/logo.svg" width="88" alt="Xenix Mail logo" />
  <h1>Xenix Mail</h1>

## An Open-Source Mail Server, Newsletter and Email Marketing Platform

[![][license-shield]][license-link] [![][github-release-shield]][github-release-link] [![][github-stars-shield]][github-stars-link]

English | [简体中文](README-zh_CN.md) | [日本語](README-ja.md) | [Türkçe](README-tr.md)
</div>
<br/>

## What is Xenix Mail?

Xenix Mail is an open-source **mail server and email marketing platform** that helps businesses and individuals run their email campaigns with ease. Whether you send newsletters, promotional emails or transactional messages, it gives you **full control** over your email marketing. With **advanced analytics** and **customer management**, you can create, send and track emails like a pro.

## Get started in 3 steps

### Step 1: Install Xenix Mail
It takes **about 8 minutes** from installation to your first successful send.
```shell
cd /opt && git clone -b main https://github.com/CodeXenix/XenixMail && cd XenixMail && bash install.sh
```

### Step 2: Connect your domain
- Add the sending domain
- Verify DNS records
- Auto-enable free SSL

### Step 3: Build your campaign
- Write or paste your email
- Choose list & tags
- Set send time or send now

## Install with Docker
Install Docker and the docker-compose plugin yourself, then edit the `.env` file.
```shell
cd /opt && git clone -b main https://github.com/CodeXenix/XenixMail && cd XenixMail && cp env_init .env && docker compose up -d || docker-compose up -d
```

## Management script
- Management help

  `bm help`

- View login default info

  `bm default`

- Show domain DNS records

  `bm show-record`

- Update Xenix Mail

  `bm update`

## WebMail

Xenix Mail includes **RoundCube**; open WebMail at `/roundcube/`.

## Why Xenix Mail?

Most email marketing platforms are **expensive**, **closed-source** or **missing essential features**. Xenix Mail is different:

✅ **Fully Open-Source** – No hidden costs, no vendor lock-in.  
📊 **Advanced Analytics** – Track delivery, open rates, click-through rates and more.  
📧 **Unlimited Sending** – No limit on how many emails you can send.  
🎨 **Customizable Templates** – Reusable, professional marketing templates.  
🔒 **Privacy-First** – Your data stays with you, no third-party tracking.  
🚀 **Self-Hosted** – Run it on your own server for complete control.  

## Issues

If you run into a problem or have a feature request, please [open an issue](https://github.com/CodeXenix/XenixMail/issues). Include:

- A clear description of the problem or request.
- Steps to reproduce the issue (if applicable).
- Screenshots or error logs (if applicable).

## License

Xenix Mail is licensed under the **AGPLv3 License**. This means you can:

✅ Use the software for free.  
✅ Modify and distribute the code.  
✅ Use it privately without restrictions.

Xenix Mail is a modified version of [BillionMail](https://github.com/aaPanel/BillionMail) by aaPanel, also licensed under AGPLv3. See the [LICENSE](LICENSE) file for more details.

---

[license-link]: https://www.gnu.org/licenses/agpl-3.0.html
[github-release-link]: https://github.com/CodeXenix/XenixMail/releases/latest
[github-stars-link]: https://github.com/CodeXenix/XenixMail

[github-release-shield]: https://img.shields.io/github/v/release/CodeXenix/XenixMail
[github-stars-shield]: https://img.shields.io/github/stars/CodeXenix/XenixMail?color=%231890FF&style=flat-square
[license-shield]: https://img.shields.io/github/license/CodeXenix/XenixMail
