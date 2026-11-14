# RATCHET_LOG · A→B Dönüşüm Günlüğü

Bu dosya, A koşusunda (rehbersiz çalışan ajan) gözlenen her hatayı
ve o hataya karşılık diktiğimiz kalıcı engeli (ratchet / mandal) kaydeder.

**Katmanlar:**
- **Rehber:** `AGENTS.md` içinde bir madde
- **Sensör:** `test/ogrenci_test.rb` içinde bir Minitest testi
- **Kanca:** `bin/kontrol` scripti

**A koşusunun ham çıktısı:** `A_run_log/` klasöründe saklanıyor.
**B koşusunun ham çıktısı:** `B_run_log/` klasöründe saklanıyor.

---

## Tur 1 · A Koşusunda Gözlenen Hatalar

| # | Karşılaşılan Hata (A Koşusu) | Kalıcı Karşılık | Katman | Dosya |
|---|------------------------------|-----------------|--------|-------|
| 1 | `devamsizlik > 3` yazıldı; tam 3 devamsızlığı olan öğrenci RISKLI sayılmadı | "N'in üzerinde" ifadesi `>= N` olarak okunur kuralı | Rehber | AGENTS.md §3 |
| 2 | Aynı sınır hatası `> 4` olarak `:kaldi` kuralında tekrarlandı | Sınır değer için her sınırda tam değer testi zorunlu | Rehber | AGENTS.md §3 |
| 3 | Ajan kendi yazdığı testte de yanlış spec'i teyit etti (`test_devamsizlik_3_ise_etiket_yok`) — test yeşil, kod yanlış | Sınır testleri rehberden değil spec'ten türetilir; her sınırın tam değerine ayrı test | Sensör | test/ogrenci_test.rb |
| 4 | `:burs_kesilir` eşiği (`devamsizlik 4 + koşul`) için ayrı test yoktu | Her kuralın tam-sınır + negatif sınır testi | Sensör | test/ogrenci_test.rb |
| 5 | Minitest `::Spec` DSL kullanılmadı, klasik `test_xxx` yazıldı | Minitest `::Spec` DSL (`describe`/`it`) zorunlu | Rehber | AGENTS.md §4 |
| 6 | `?` ile biten metodlar block-method; endless method kullanılmadı | Tek satırlık predicate → endless method | Rehber | AGENTS.md §1 |
| 7 | Kod çalıştırmadan doğrulayan kanca yoktu | Her commit öncesi `bin/kontrol`; kırmızı test commit'e giremez | Kanca | bin/kontrol |

## Önleyici (A'da gözlenmedi ama şartname gereği konuldu)

| # | Risk | Kalıcı Karşılık | Katman | Dosya |
|---|------|-----------------|--------|-------|
| Ö1 | `method_missing` ile dinamik metot | Yasak + statik kaynak testi | Rehber+Sensör | AGENTS.md §2, test |
| Ö2 | Çekirdek sınıfa monkey patch | Yasak + statik kaynak testi | Rehber+Sensör | AGENTS.md §2, test |

---

## Tur 2 · Bağımsız Kod Denetimi Sonrası (ikinci ratchet turu)

B koşusu tamamlandıktan sonra, kod **ikinci bir ajanla bağımsız denetime**
sokuldu (çapraz inceleme). Denetim, harness'ın kendisinde — yani `AGENTS.md`
sözleşmesinde — ödev şartnamesine göre eksikler buldu. Bunlar da birer
ratchet olarak kalıcılaştırıldı:

| # | Karşılaşılan Hata | Kalıcı Karşılık | Katman | Dosya |
|---|-------------------|-----------------|--------|-------|
| 8 | Durum seti şartnameyle uyuşmuyordu: `:aktif/:pasif/:burslu` kurulmuştu, şartname `:aktif/:donduruldu/:mezun` istiyor | Durum seti düzeltildi; burs ayrı `burslu` bayrağına taşındı | Rehber+Sensör | AGENTS.md §5, ogrenci.rb, test |
| 9 | Durum sorguları endless method ile elle yazılmıştı; şartname `define_method` istiyor | Durum sorguları `DURUMLAR` listesinden `define_method` ile üretiliyor | Rehber+Sensör | AGENTS.md §1, ogrenci.rb, test |
| 10 | `devamsizlik` 0..10 aralığı doğrulanmıyordu | Constructor'da Range kontrolü + aralık dışı `ArgumentError` testi | Sensör | ogrenci.rb, test |

Bu tur, ratchet mantığının bir kez değil **sürekli** döndüğünü gösterir:
denetim katmanı bağımsız bir ajana devredildiğinde, ilk ajanın (ve harness'ı
hazırlayanın) gözden kaçırdığı sözleşme boşlukları yakalandı.

---

## Sayılar

| Metrik | A Koşusu | B Koşusu |
|--------|----------|----------|
| Ajan tur sayısı | 1 | 1 |
| Ajanın attığı commit | 1 | 1 |
| `:riskli` sınırı | `> 3` (yanlış) | `>= 3` (doğru) |
| `:kaldi` sınırı | `> 4` (yanlış) | `>= 4` (doğru) |
| Sınır testleri (tam 3 / tam 4) yeşil mi? | ❌ | ✅ |
| `bin/kontrol` yeşil mi? | kanca yoktu | ✅ |
| Projenin sabit testlerini geçer mi? | ❌ | ✅ (18/18) |

**Not:** Commit sayısı her iki koşuda da 1'dir. Fark turda değil kalitededir:
A'daki tek commit sessizce hatalı kod taşıdı (ajan kendi yanlış testiyle
doğruladı); B'deki tek commit sabit, dışarıdan dayatılan testlere karşı doğru
çıktı. Ratchet'in değeri turu azaltmak değil, yanlışın sessizce geçmesini
engellemektir.
