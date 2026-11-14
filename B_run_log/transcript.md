# B Koşusu Görüşme ve Görev Dökümü (Transcript)

**Tarih:** 14 Kasım 2026  
**Ajan Modeli:** Gemini 3.8 Flash (Antigravity)  
**Hedef Dal:** `kosu-b`  
**Durum:** Başarılı — Tüm kontroller ilk çalıştırmada yeşil  

---

## 1. Kullanıcı İstemi (Prompt)

> **B Koşusu Görevi**
> 
> Bu repoda bir öğrenci devamsızlık motoru tamamlayacaksın.
> 
> **Başlamadan önce (zorunlu sıra):**
> 1. `ruby -v` çalıştır. Sürüm 3.4 değilse DUR ve bana bildir.
> 2. `AGENTS.md` dosyasını baştan sona oku. İçindeki her kural senin için bağlayıcıdır.
> 3. `RATCHET_LOG.md` dosyasını oku. Bu repoda daha önce yapılmış hataları ve onlara karşı dikilmiş kuralları öğrenirsin.
> 4. `test/ogrenci_test.rb` dosyasını oku. Testler zaten yazılmış ve sabittir. Senin görevin, bu testleri YEŞİL yapan `lib/` dosyalarını yazmak. Testleri değiştirmek YASAK.
> 
> **Görev:**
> `lib/` altında iki dosya oluştur:
> - `lib/ogrenci.rb`: `Ogrenci` sınıfı. `AGENTS.md § 5`'teki sözleşmeye uy (Alanlar: `ad`, `durum`, `devamsizlik`; durum: `:aktif`, `:pasif`, `:burslu`; Constructor: `Ogrenci.new(ad:, durum: :aktif, devamsizlik: 0)`).
> - `lib/devamsizlik_kontrol.rb`: `DevamsizlikKontrol` sınıfı. Tek giriş noktası: `DevamsizlikKontrol.kontrol(ogrenci)` → sembol dizisi.
> 
> **Uygulanacak 3 kural:**
> - Devamsızlığı 3'ün üzerinde olan öğrenciler riskli sayılır → `:riskli`
> - Devamsızlığı 4'ün üzerinde olanlar sınıfta kalır → `:kaldi`
> - Devamsızlığı 4'ün üzerinde olan burslu öğrencilerin bursu kesilir → `:burs_kesilir`
> 
> **Bitirme (zorunlu sıra):**
> 1. `ruby bin/kontrol` çalıştır. Çıkış kodu 0 (tüm kontroller yeşil) olmalı.
> 2. Kırmızı varsa düzelt, tekrar çalıştır. Yeşil olmadan commit atma.
> 3. Yeşil olunca commit at ve `kosu-b` dalına push et.

---

## 2. Ajanın Eylemleri ve Sıralı Adımları

### Adım 1: Ruby Sürüm Kontrolü
```powershell
$ ruby -v
ruby 3.4.11 (2026-09-23 revision 592f1ffdb3) +PRISM [x64-mingw-ucrt]
```
Sürüm 3.4 olarak doğrulandı.

### Adım 2: AGENTS.md Dosyasının Okunması
`AGENTS.md` baştan sona incelendi:
- Ruby 3.4 stdlib zorunluluğu, Gemfile ve dış gem yasağı.
- Boolean metotlar için `?` soneki ve endless method (`def method? = ...`) kuralı.
- Mimari yasaklar (`method_missing`, monkey patch, `eval` kesin yasağı).
- **Sınır Değer Kuralı (§ 3):** "N'in üzerinde" ifadesi daima `>= N` olarak okunur (A koşusunun ana hatası engellendi).
- Model sözleşmesi ve commit konvansiyonları (`feat:`, vb.).

### Adım 3: RATCHET_LOG.md Dosyasının Okunması
A koşusunda yapılan 7 hata ve dikilen engeller analiz edildi:
1. `> 3` yerine `>= 3` kuralı.
2. `> 4` yerine `>= 4` kuralı.
3. Yanlış spec onaylayan hatalı testlerin engellenmesi.
4. `:burslu` + 4 sınır vaka testi.
5. Minitest `::Spec` DSL zorunluluğu.
6. Endless method kuralı.
7. `bin/kontrol` doğrulama kancası.

### Adım 4: test/ogrenci_test.rb Dosyasının Okunması
15 test ve 30 assertion'lık sabit test kümesi okundu.

### Adım 5: Kodların Yazılması
- `lib/ogrenci.rb` oluşturuldu:
```ruby
# frozen_string_literal: true

class Ogrenci
  attr_reader :ad, :durum, :devamsizlik

  GECERLI_DURUMLAR = %i[aktif pasif burslu].freeze

  def initialize(ad:, durum: :aktif, devamsizlik: 0)
    @ad = ad
    @durum = durum
    @devamsizlik = devamsizlik
  end

  def burslu? = @durum == :burslu
  def aktif? = @durum == :aktif
  def pasif? = @durum == :pasif
end
```

- `lib/devamsizlik_kontrol.rb` oluşturuldu:
```ruby
# frozen_string_literal: true

class DevamsizlikKontrol
  def self.kontrol(ogrenci)
    sonuc = []
    sonuc << :riskli if riskli?(ogrenci)
    sonuc << :kaldi if kaldi?(ogrenci)
    sonuc << :burs_kesilir if burs_kesilir?(ogrenci)
    sonuc
  end

  def self.riskli?(ogrenci) = ogrenci.devamsizlik >= 3
  def self.kaldi?(ogrenci) = ogrenci.devamsizlik >= 4
  def self.burs_kesilir?(ogrenci) = ogrenci.devamsizlik >= 4 && ogrenci.durum == :burslu
end
```

### Adım 6: bin/kontrol ile Doğrulama
```text
Run options: --seed 41831

# Running:

...............

Finished in 0.003860s, 3886.2117 runs/s, 7772.4235 assertions/s.

15 runs, 30 assertions, 0 failures, 0 errors, 0 skips
==> Ruby sürümü kontrolü
==> Kaynak dosyaların sözdizim kontrolü
==> Minitest koşusu
==> OK — tüm kontroller yeşil
```
Çıkış kodu: `0` (İlk denemede tüm kontroller yeşil).

### Adım 7: Git Commit & Push (kosu-b)
- Commit ID: `bd5072e`
- Mesaj: `feat: implement Ogrenci and DevamsizlikKontrol respecting AGENTS.md contract`
- Dal: `kosu-b` dalına pushlandı.
