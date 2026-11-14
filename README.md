# harness-me-if-you-can

**YZM379 · AI-Native Ruby Programlama — Vize Ödevi**
**Öğrenci:** Volkan Godak
**Ajan:** Gemini (Antigravity IDE)
**Teslim:** 20 Kasım 2026

Bu depo, aynı görevi bir AI ajanına **iki kez** yaptırarak "harness
mühendisliği"nin somut katkısını ölçer: önce **rehbersiz** (A koşusu), sonra
gözlenen hatalardan üretilen bir **harness** (AGENTS.md + testler + doğrulama
kancası) altında (B koşusu).

---

## Çalıştırma

```bash
ruby -v            # 3.4 olmalı (.ruby-version)
ruby bin/kontrol   # tüm kontroller: sürüm + sözdizim + testler
```

`bin/kontrol` çıkış kodu 0 → her şey yeşil. Başka değer → commit atılmamalı.

---

## Model

`Ogrenci`: `ad`, `durum` (`:aktif`, `:donduruldu`, `:mezun`), `devamsizlik`
(0..10), `burslu` (boolean). Durum sorguları (`aktif?`, `donduruldu?`,
`mezun?`) `define_method` ile üretilir; `method_missing` ve monkey patch yok.

## Kurallar

| Kural | Koşul | Sembol |
|-------|-------|--------|
| Riskli | devamsızlık **>= 3** | `:riskli` |
| Kaldı | devamsızlık **>= 4** | `:kaldi` |
| Bursu kesilir (özgün kural) | devamsızlık **>= 4** **ve** `burslu` | `:burs_kesilir` |

Giriş noktası: `DevamsizlikKontrol.kontrol(ogrenci)` → `Array<Symbol>`

---

## A Koşusu → Ratchet → B Koşusu

### A Koşusu (rehbersiz)

Ajana yalnızca kısa, günlük dildeki görev verildi; AGENTS.md, test ya da
doğrulama kancası yoktu. "Devamsızlığı 3'ün üzerinde" ifadesini `> 3` olarak
yorumladı. Kendi yazdığı testler de aynı yanlış yorumu doğruladığı için
**testler yeşil göründü, ama kod hatalıydı**.

### Ratchet (mandal)

A koşusunda gözlenen her hata kalıcı bir engele dönüştürüldü:
rehber katmanı (`AGENTS.md`), sensör katmanı (`test/ogrenci_test.rb`), kanca
katmanı (`bin/kontrol`). Dönüşüm tablosu: [RATCHET_LOG.md](RATCHET_LOG.md).

Ratchet kurulduğunda `lib/` henüz boştu → `bin/kontrol` **kırmızıydı**
(kanıt: `docs/screenshots/`). Bu beklenen durumdu: engel dikildi, henüz tatmin
edilmedi.

### B Koşusu (harness'lı)

Ajana aynı belirsiz görev verildi; ama bu kez önce `AGENTS.md` ve
`RATCHET_LOG.md` okutuldu, testler sabit bırakıldı. Ajan iki sınırı da doğru
(`>= 3`, `>= 4`) yazdı, endless method ve predicate yapısına uydu. `bin/kontrol`
**yeşile** döndü: `15 runs, 30 assertions, 0 failures`.

---

## Ölçüm Tablosu

| Metrik | A Koşusu (rehbersiz) | B Koşusu (harness'lı) |
|--------|----------------------|------------------------|
| Rehber (AGENTS.md okundu mu) | Hayır | Evet |
| `:riskli` sınırı | `> 3` ❌ tam 3 kaçtı | `>= 3` ✅ |
| `:kaldi` sınırı | `> 4` ❌ tam 4 kaçtı | `>= 4` ✅ |
| `:burs_kesilir` | `> 4 && :burslu` ❌ | `>= 4 && :burslu` ✅ |
| Endless method | Yok | Var ✅ |
| Predicate metod (`?`) | Yok | Var ✅ |
| Alan erişimi | `attr_accessor` | `attr_reader` ✅ |
| Ajanın attığı commit | 1 | 1 |
| Ajan tur sayısı (Antigravity) | 1 | 1 |
| Projenin sabit testlerini geçer mi | ❌ | ✅ (18/18) |
| `bin/kontrol` sonucu | yok / kırmızı | **yeşil** |

### Tablonun okunması

Commit sayısı her iki koşuda da 1'dir — yani "daha az tur" gibi yüzeysel bir
kazanç yoktur. Fark **kalitededir**: A koşusundaki tek commit sessizce hatalı
kod taşıdı ve ajan bunu fark etmedi, çünkü doğrulama onun kendi (yanlış)
testlerine bırakılmıştı. B koşusunda doğrulama **sabit, dışarıdan dayatılan**
testlere bağlandığı için aynı tek commit doğru kodu üretti.

**Ratchet'in değeri turu azaltmak değil, yanlışın sessizce geçmesini
engellemektir.** Bu, derste işlenen "doğrulama darboğazı" ve "test oracle
problemi"nin doğrudan gözlemidir: ajana kendi işini kendi doğrulattığında,
yanlış bir oracle yanlış kodu onaylar.

### İkinci Ratchet Turu — Bağımsız Denetim

B koşusundan sonra kod, **ikinci bir ajanla bağımsız denetime** sokuldu.
Denetim, harness'ın kendisinde (`AGENTS.md` sözleşmesi) ödev şartnamesine göre
üç boşluk buldu: durum setinin yanlış kurulması, durum sorgularının
`define_method` yerine elle yazılması ve `devamsizlik` 0..10 aralığının
doğrulanmaması. Üçü de düzeltildi ve `RATCHET_LOG.md`'de Tur 2 olarak
kaydedildi. Bu, ratchet'in tek seferlik değil **sürekli** bir döngü olduğunu
gösterir: doğrulama ayrı bir ajana devredildiğinde, ilk turda kaçan sözleşme
boşlukları yakalanır.

---

## Dosya Yapısı

```
harness-me-if-you-can/
├── .ruby-version              # 3.4
├── AGENTS.md                  # 7 bölümlük ajan anayasası (ratchet rehber katmanı)
├── CLAUDE.md                  # AGENTS.md'ye yönlendirici
├── RATCHET_LOG.md             # A hatalarının kalıcı engellere dönüşüm tablosu
├── README.md                  # bu dosya
├── bin/
│   └── kontrol                # doğrulama kancası (sürüm + sözdizim + test)
├── lib/
│   ├── ogrenci.rb             # Ogrenci sınıfı (B koşusu final kod)
│   └── devamsizlik_kontrol.rb # DevamsizlikKontrol (B koşusu final kod)
├── test/
│   └── ogrenci_test.rb        # 15 test: sınır değer + yasak denetimi
├── A_run_log/                 # A koşusu ham çıktısı + transcript (kanıt)
├── B_run_log/                 # B koşusu ham çıktısı + transcript + metrics.json
└── docs/screenshots/          # bin/kontrol kırmızı→yeşil kanıt görselleri
```

---

## Dal Mimarisi

- `main` — ratchet altyapısı + B koşusunun final kodu
- `kosu-a` — A koşusunun ham, rehbersiz çıktısı (main'e **merge edilmedi**; tarih kanıtı)
- `kosu-b` — B koşusunun ham, harness'lı çıktısı (main'e **merge edilmedi**; tarih kanıtı)

İki koşunun ham hali bilerek merge edilmedi; `git log kosu-a` ve `git log kosu-b`
ile her koşunun kendi tarihçesi incelenebilir.

---

## Yapamadıklarım / Sınırlar

Dürüstlük, bu ödevin değerlendirme ilkesidir. Eksik ve belirsiz bıraktıklarım:

- **Token sayısı kesin ölçülmedi.** Antigravity oturum arayüzünün gösterdiği
  değerler haricinde bağımsız bir token ölçümü yapmadım; bu yüzden tabloya
  tahmini token koymadım.
- **Ajan tur sayısı** Antigravity oturum geçmişinden elle sayıldı; otomatik bir
  telemetri kaydı yok.
- **CI yok.** Doğrulama yalnızca yerel `bin/kontrol` ile; GitHub Actions gibi
  bir sürekli entegrasyon kancası kurulmadı. `bin/kontrol`'ü bir pre-commit
  git hook'una bağlamak doğal bir sonraki adım olurdu.
- **Tek ajan.** Yalnızca Gemini (Antigravity) ile koşuldu; farklı ajanların
  aynı harness altında nasıl davrandığı karşılaştırılmadı.
- **A koşusu belirsiz spec ile başlatıldı.** "3'ün üzerinde" ifadesi bilerek
  muğlak bırakıldı; amaç, gerçek dünyadaki belirsiz gereksinimlerin ajanı nasıl
  yanlış yorumlara ittiğini gözlemlemekti. Bu bir kurgu değil, tasarım kararıdır
  ve RATCHET_LOG'da açıkça belirtilmiştir.

---

## Kaynaklar

- Nurettin Senyer, YZM379 ders slaytları ve transkriptleri (Ekim–Kasım 2026)
- AGENTS.md biçimi: <https://agents.md>
- Ratchet / harness engineering kavramları: ders materyalleri
