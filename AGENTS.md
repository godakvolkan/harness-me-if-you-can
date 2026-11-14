# AGENTS.md — harness-me-if-you-can

Bu dosya, repoda çalışan her AI ajanının uyacağı **bağlayıcı kurallar** bütünüdür.
Her madde ya A koşusunda yakalanmış bir hataya karşılık düşer, ya da benzer
hataların önüne geçmek için **önleyici** olarak konmuştur.

**Ratchet (mandal) mantığı:** Kaybeden bir kez kaybeder; kaybettiği yere engel
diker, aynı yerden iki kez kaybedilmez.

Gözlemlenen hataların dönüşüm tablosu için `RATCHET_LOG.md`'ye bakın.

---

## 0 · Ortam

- Ruby sürümü: **3.4** (bkz. `.ruby-version`). Başka sürüm **yasak**.
- Test çerçevesi: **Minitest** (stdlib). `rspec`, `rails-controller-testing`,
  `factory_bot` **yasak**.
- Dış bağımlılık: **yok**. `Gemfile`, `bundle exec`, `gem install` yasak.
  Yalnızca Ruby standart kitaplığı.
- Doğrulama kancası: her commit öncesi `ruby bin/kontrol` çalıştır.
  Çıkış kodu 0 değilse commit **yasak**.

## 1 · Dil ve isim kuralları

- Boolean dönen her metod `?` ile biter: `riskli?`, `kaldi?`, `burs_kesilir?`.
- `is_risky`, `check_risk`, `hasRisk` gibi İngilizce karışımı isim **yasak**.
- Tek ifade ile sonuç dönen metod → **endless method** kullan (Ruby 3.0+):

  ```ruby
  def burslu? = @durum == :burslu
  ```

- Block parametresi için `it` (Ruby 3.4+) tercih edilir:

  ```ruby
  files.map { File.read(it) }
  ```

## 2 · Mimari yasakları

- `method_missing` ve `respond_to_missing?` **yasak**.
- Çekirdek sınıflara (Integer, String, Array, Hash, Numeric, Symbol, Object)
  açma / ekleme — **monkey patch yasak**.
- `instance_eval` / `class_eval` string argümanla **yasak**.
- `eval`, `instance_variable_set`, `send(:private_method, ...)` **yasak**.
- Stdlib dışı metod uydurma **yasak**: `3.business_days`, `str.nice_name` vb.

## 3 · Sınır değer kuralı (A koşusunun ana dersi)

**"N'in üzerinde" ifadesi daima `>= N` olarak okunur.** Asla `> N` değil.

Her sınır değer için en az **3 test** zorunlu:

| Test | Devamsızlık | Beklenti |
|------|-------------|----------|
| Sınırın altı | sınır − 1 | kural tetiklenmemeli |
| **Tam sınır** | sınır | **kural tetiklenmeli** ← A'da kaçırıldı |
| Sınırın üstü | sınır + 1 | kural tetiklenmeli |

Birleşik koşul (örn. `>= 4 && :burslu`) için her koşulu bağımsız test et.

## 4 · Test kuralları

- Minitest **::Spec DSL** kullan: `describe "..." do ... it "..." do ... end end`.
  `def test_xxx` klasik hali **yasak**.
- Her commit öncesi `ruby bin/kontrol` yeşil olmalı.
- Testi yorum satırına almak, `skip` etmek, silmek **yasak**.

## 5 · Alan modeli sözleşmesi

- `Ogrenci` sınıfı:
  - Alanlar: `ad` (String), `durum` (Symbol), `devamsizlik` (Integer)
  - `durum` yalnızca şu semboller: `:aktif`, `:pasif`, `:burslu`
  - Constructor keyword argümanlı:
    `Ogrenci.new(ad:, durum: :aktif, devamsizlik: 0)`
- `DevamsizlikKontrol` sınıfı:
  - Tek entry point: `DevamsizlikKontrol.kontrol(ogrenci)` → `Array<Symbol>`
  - Dönen semboller yalnızca şu kümeden: `{:riskli, :kaldi, :burs_kesilir}`

## 6 · Commit kuralları

- Mesaj ön eki zorunlu: `feat:`, `fix:`, `test:`, `docs:`, `chore:`, `refactor:`.
- Bir commit, bir mantıksal değişiklik. "Her şeyi düzelttim" commit'i yasak.
- Commit öncesi `ruby bin/kontrol` çıkış kodu 0 olmalı.

## 7 · Yapmayacakların

- Bu `AGENTS.md` ve `RATCHET_LOG.md` dosyalarını **değiştirmeyeceksin**.
  İnsan editör sorumluluğundadır.
- Testleri yeşil göstermek için **spec'i değiştirmeyeceksin**. Spec sabit; kod ona uyar.
- `bin/kontrol`'ü atlamayacaksın. "Çalıştırmaya gerek görmedim" yok.
- Çıktı dosyalarına, run_log klasörlerine (`A_run_log/`, `B_run_log/`) dokunmayacaksın.
