# RATCHET_LOG · A→B Dönüşüm Günlüğü

Bu dosya, A koşusunda (rehbersiz çalışan ajan) gözlenen her hatayı
ve o hataya karşılık diktiğimiz kalıcı engeli (ratchet / mandal) kaydeder.

**Katmanlar:**
- **Rehber:** `AGENTS.md` içinde bir madde
- **Sensör:** `test/` içinde bir Minitest testi
- **Kanca:** `bin/kontrol` scripti

**A koşusunun ham çıktısı:** `A_run_log/` klasöründe saklanıyor.

---

## Gözlenen Hatalar ve Ratchet'leri

| #   | Karşılaşılan Hata (A Koşusu)                                                                                         | Kalıcı Karşılık                                                                                   | Katman | Dosya:satır                                  |
| --- | -------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- | ------ | -------------------------------------------- |
| 1   | `devamsizlik > 3` yazıldı; tam 3 devamsızlığı olan öğrenci RISKLI sayılmadı                                          | "N'in üzerinde" ifadesi `>= N` olarak okunur kuralı                                               | Rehber | AGENTS.md §3                                 |
| 2   | Aynı sınır hatası `> 4` olarak `:kaldi` kuralında tekrarlandı                                                        | Sınır değer için her sınırda **tam değer** testi zorunlu                                          | Rehber | AGENTS.md §3                                 |
| 3   | Ajan kendi yazdığı testte de yanlış spec'i teyit etti (`test_devamsizlik_3_ise_etiket_yok`) — test yeşil, kod yanlış | Sınır değer testleri rehberden değil, **spec'ten** türetilir — her sınırın tam değerine ayrı test | Sensör | test/ogrenci_test.rb — tam 3, tam 4 testleri |
| 4   | Sınır değer eşiği `devamsizlik: 4 + durum: :burslu` için ayrı test yoktu                                             | Her kuralın tam-sınır testi + negatif sınır testi (sınır-1, sınır+1)                              | Sensör | test/ogrenci_test.rb — burslu + 4 testi      |
| 5   | Minitest `::Spec` DSL (`describe`/`it`) kullanılmadı, klasik `test_xxx` yazıldı                                      | Minitest `::Spec` DSL kullanılacak; `it "..." do` bloğu zorunlu                                   | Rehber | AGENTS.md §4                                 |
| 6   | `?` ile biten boolean metodlar block-method olarak yazıldı; endless method kullanılmadı                              | Tek satırlık boolean/predicate metodları → endless method (`def riskli? = ...`)                   | Rehber | AGENTS.md §1                                 |
| 7   | Metin çalıştırmadan önce doğrulayan kanca yoktu                                                                      | Her commit öncesi `bin/kontrol` scripti çalıştırılır; kırmızı test commit'e giremez               | Kanca  | bin/kontrol                                  |

---

## Bu dosyada geçmeyen şeyler

A koşusunda **gözlenmeyen** ama hoca'nın kavram listesinde olan `method_missing`,
monkey patch, uydurma API gibi yasaklar yine de `AGENTS.md`'ye kondu — ileride
başka bir ajanın bu yollara sapmaması için **önleyici** olarak.

RATCHET_LOG yalnızca **gerçekten gözlenen** hataları listeler. Uydurma yoktur.

---

## Sayılar (ADIM 11'den sonra doldurulacak)

| Metrik                   | A Koşusu | B Koşusu |
| ------------------------ | -------- | -------- |
| Ajan tur sayısı          | —        | —        |
| Commit sayısı            | —        | —        |
| Sınır testleri yeşil mi? | ❌        | —        |
| bin/kontrol yeşil mi?    | —        | —        |