# A Koşusu Görüşme ve Görev Dökümü (Transcript)

**Tarih:** 14 Kasım 2026  
**Ajan Modeli:** Gemini 3.8 Flash (Antigravity)  
**Hedef Dal:** `kosu-a`  
**Ortam:** Rehbersiz (AGENTS.md yok, test yok, bin/kontrol yok)  
**Durum:** Hatalı Kod — Ajan kendi yazdığı yanlış testlerle hatasını onayladı  

---

## 1. Kullanıcı İstemi (Ham Prompt)

> Merhaba. Ruby ile küçük bir öğrenci devamsızlık motoru yazmanı istiyorum.
> 
> Şu klasörde çalışıyorsun: harness-me-if-you-can (git dalı: kosu-a)
> 
> **PROJE NE YAPACAK:**
> Öğrencilerin devamsızlık durumuna bakıp onlara etiket atayan bir sistem.
> 
> **GEREKSINIMLER:**
> 1. Bir Ogrenci sınıfı olacak; adı, durumu ve devamsızlık sayısı tutacak.
>    Durum :aktif, :pasif veya :burslu olabilir.
> 2. Bir DevamsizlikKontrol yapısı olacak; bir öğrenci alıp sembol listesi döndürecek.
> 3. Şu 3 kural uygulanacak:
>    - Devamsızlığı 3'ün üzerinde olan öğrenciler riskli sayılır → :riskli
>    - Devamsızlığı 4'ün üzerinde olanlar sınıfta kalır → :kaldi
>    - Devamsızlığı 4'ün üzerinde olan burslu öğrencilerin bursu kesilir → :burs_kesilir
> 4. Minitest ile birkaç test yaz.
> 5. İşin bittiğinde git ile commit at ve kosu-a dalına push et.
> 
> Kod kaliteli ve temiz olsun. Kolay gelsin.

---

## 2. Ajanın Eylemleri ve Üretilen Kod

Ajan herhangi bir rehber olmadan doğrudan kod üretimine başladı:

### lib/ogrenci.rb
```ruby
class Ogrenci
  attr_accessor :ad, :durum, :devamsizlik

  GECERLI_DURUMLAR = %i[aktif pasif burslu].freeze

  def initialize(ad:, durum: :aktif, devamsizlik: 0)
    @ad = ad
    @durum = durum
    @devamsizlik = devamsizlik
  end

  def burslu?
    @durum == :burslu
  end

  def aktif?
    @durum == :aktif
  end

  def pasif?
    @durum == :pasif
  end
end
```

### lib/devamsizlik_kontrol.rb (HATA NOKTASI)
Ajan "3'ün üzerinde" ifadesini kelimesi kelimesine `> 3` olarak yorumladı:
```ruby
class DevamsizlikKontrol
  def self.kontrol(ogrenci)
    sonuclar = []

    if ogrenci.devamsizlik > 3 # <-- HATA: >= 3 olmalıydı!
      sonuclar << :riskli
    end

    if ogrenci.devamsizlik > 4 # <-- HATA: >= 4 olmalıydı!
      sonuclar << :kaldi
      sonuclar << :burs_kesilir if ogrenci.durum == :burslu
    end

    sonuclar
  end
end
```

### test/devamsizlik_kontrol_test.rb (TEST ORACLE YANILGISI)
Ajan kendi yazdığı testte yanlış spec'i doğru kabul etti:
```ruby
def test_devamsizlik_3_ise_etiket_yok
  ogr = Ogrenci.new(ad: "Ali", durum: :aktif, devamsizlik: 3)
  assert_empty DevamsizlikKontrol.kontrol(ogr) # <-- Yanlış spec'i teyit etti!
end
```

### Test Koşusu:
```text
Run options: --seed 29447
# Running:
....
4 runs, 13 assertions, 0 failures, 0 errors, 0 skips
```
Ajan testleri yeşil gördü ve kodun doğru olduğunu zannederek commit attı:
`de1044d: feat: implement Ogrenci and DevamsizlikKontrol with tests`

---

## 3. A Koşusu Çıkarımları ve Ratchet İhtiyacı

1. **Sınır Değer Kaçışı:** Tam 3 ve tam 4 devamsızlığı olan öğrenciler yakalanamadı.
2. **Test Oracle Problemi:** Ajana kendi testini yazdırdığınızda, kendi mantık hatasını testte de tekrarlar ve testler yeşil çıkınca insan yanıltılır.
3. **Ratchet Sonucu:** Bu hatalar `RATCHET_LOG.md`'ye kaydedilerek `AGENTS.md` (§ 3) ve sabit `test/ogrenci_test.rb` sensörüne dönüştürülmüştür.
