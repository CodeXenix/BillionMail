<div align="center">
  <a name="readme-top"></a>
  <img src="core/frontend/src/assets/images/logo.svg" width="88" alt="Xenix Mail logo" />
  <h1>Xenix Mail</h1>

## Açık Kaynaklı Bir Posta Sunucusu, Bülten ve E-posta Pazarlama Platformu

[![][license-shield]][license-link] [![][github-release-shield]][github-release-link] [![][github-stars-shield]][github-stars-link]

[English](README.md) | [简体中文](README-zh_CN.md) | [日本語](README-ja.md) | Türkçe
</div>
<br/>

## Xenix Mail Nedir?

Xenix Mail, işletmelerin ve bireylerin e-posta kampanyalarını kolayca yönetmelerine yardımcı olan açık kaynaklı bir **posta sunucusu ve e-posta pazarlama platformudur**. İster bültenler, ister tanıtım e-postaları veya işlem mesajları gönderiyor olun, e-posta pazarlamanız üzerinde size **tam kontrol** sağlar. **Gelişmiş analitik** ve **müşteri yönetimi** ile e-postaları bir profesyonel gibi oluşturabilir, gönderebilir ve takip edebilirsiniz.

## 3 Adımda Başlayın

### Adım 1: Xenix Mail'i Kurun
Kurulumdan ilk başarılı gönderime geçmek **yaklaşık 8 dakika** sürer.
```shell
cd /opt && git clone https://github.com/CodeXenix/XenixMail && cd XenixMail && bash install.sh
```

### Adım 2: Alan Adınızı Bağlayın
- Gönderim alan adını ekleyin
- DNS kayıtlarını doğrulayın
- Ücretsiz SSL'yi otomatik etkinleştirin

### Adım 3: Kampanyanızı Oluşturun
- E-postanızı yazın veya yapıştırın
- Liste ve etiketleri seçin
- Gönderim zamanını ayarlayın veya hemen gönderin

## Docker ile Kurulum
Docker'ı ve docker-compose eklentisini kendiniz kurun, ardından `.env` dosyasını düzenleyin.
```shell
cd /opt && git clone https://github.com/CodeXenix/XenixMail && cd XenixMail && cp env_init .env && docker compose up -d || docker-compose up -d
```

## Yönetim Scripti
- Yönetim yardımı

  `bm help`

- Varsayılan oturum açma bilgilerini görüntüleme

  `bm default`

- Alan adı DNS kayıtlarını gösterme

  `bm show-record`

- Xenix Mail'i güncelleme

  `bm update`

## WebMail

Xenix Mail, **RoundCube** içerir; WebMail'i `/roundcube/` üzerinden açabilirsiniz.

## Neden Xenix Mail?

Çoğu e-posta pazarlama platformu ya **pahalı**, ya **kapalı kaynaklı** ya da **temel özelliklerden yoksundur**. Xenix Mail farklıdır:

✅ **Tamamen Açık Kaynaklı** – Gizli maliyetler yok, tedarikçi bağımlılığı yok.  
📊 **Gelişmiş Analitik** – Teslimatı, açılma oranlarını, tıklanma oranlarını ve daha fazlasını takip edin.  
📧 **Sınırsız Gönderim** – Gönderebileceğiniz e-posta sayısında kısıtlama yok.  
🎨 **Özelleştirilebilir Şablonlar** – Yeniden kullanılabilir, profesyonel pazarlama şablonları.  
🔒 **Gizlilik Öncelikli** – Verileriniz sizde kalır, üçüncü taraf takibi yok.  
🚀 **Kendi Sunucunuzda Barındırma** – Tam kontrol için kendi sunucunuzda çalıştırın.  

## Sorunlar

Bir sorunla karşılaşırsanız veya bir özellik talebiniz olursa, lütfen [bir sorun açın](https://github.com/CodeXenix/XenixMail/issues). Şunları ekleyin:

- Sorunun veya talebin açık bir açıklaması.
- Sorunu yeniden oluşturma adımları (varsa).
- Ekran görüntüleri veya hata günlükleri (varsa).

## Lisans

Xenix Mail, **AGPLv3 Lisansı** altında lisanslanmıştır. Bu, şunları yapabileceğiniz anlamına gelir:

✅ Yazılımı ücretsiz kullanma.  
✅ Kodu değiştirme ve dağıtma.  
✅ Özel olarak kısıtlama olmaksızın kullanma.

Xenix Mail, aaPanel tarafından geliştirilen ve yine AGPLv3 altında lisanslanan [BillionMail](https://github.com/aaPanel/BillionMail)'in değiştirilmiş bir sürümüdür. Daha fazla ayrıntı için [LICENSE](LICENSE) dosyasına bakın.

---

[license-link]: https://www.gnu.org/licenses/agpl-3.0.html
[github-release-link]: https://github.com/CodeXenix/XenixMail/releases/latest
[github-stars-link]: https://github.com/CodeXenix/XenixMail

[github-release-shield]: https://img.shields.io/github/v/release/CodeXenix/XenixMail
[github-stars-shield]: https://img.shields.io/github/stars/CodeXenix/XenixMail?color=%231890FF&style=flat-square
[license-shield]: https://img.shields.io/github/license/CodeXenix/XenixMail
