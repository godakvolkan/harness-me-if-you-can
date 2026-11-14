# frozen_string_literal: true
require "minitest/autorun"
require "minitest/spec"
require_relative "../lib/ogrenci"
require_relative "../lib/devamsizlik_kontrol"

describe Ogrenci do
  describe "constructor" do
    it "varsayılan devamsizlik 0" do
      o = Ogrenci.new(ad: "Test")
      _(o.devamsizlik).must_equal 0
    end

    it "varsayılan durum :aktif" do
      o = Ogrenci.new(ad: "Test")
      _(o.durum).must_equal :aktif
    end
  end
end

describe DevamsizlikKontrol do
  # ============================================================
  # :riskli kuralı — "devamsızlığı 3'ün üzerinde" == devamsizlik >= 3
  # ============================================================
  describe ":riskli kuralı (devamsizlik >= 3)" do
    it "sınır altı: devamsizlik 2 → riskli DEĞİL" do
      o = Ogrenci.new(ad: "Ali", durum: :aktif, devamsizlik: 2)
      _(DevamsizlikKontrol.kontrol(o)).wont_include :riskli
    end

    it "TAM SINIR: devamsizlik 3 → RISKLI (A koşusunda bu test eksikti)" do
      o = Ogrenci.new(ad: "Veli", durum: :aktif, devamsizlik: 3)
      _(DevamsizlikKontrol.kontrol(o)).must_include :riskli
    end

    it "sınır üstü: devamsizlik 5 → riskli" do
      o = Ogrenci.new(ad: "Ayse", durum: :aktif, devamsizlik: 5)
      _(DevamsizlikKontrol.kontrol(o)).must_include :riskli
    end
  end

  # ============================================================
  # :kaldi kuralı — "devamsızlığı 4'ün üzerinde" == devamsizlik >= 4
  # ============================================================
  describe ":kaldi kuralı (devamsizlik >= 4)" do
    it "sınır altı: devamsizlik 3 → kaldi DEĞİL" do
      o = Ogrenci.new(ad: "Ali", durum: :aktif, devamsizlik: 3)
      _(DevamsizlikKontrol.kontrol(o)).wont_include :kaldi
    end

    it "TAM SINIR: devamsizlik 4 → KALDI (A koşusunda bu test eksikti)" do
      o = Ogrenci.new(ad: "Veli", durum: :aktif, devamsizlik: 4)
      _(DevamsizlikKontrol.kontrol(o)).must_include :kaldi
    end

    it "sınır üstü: devamsizlik 5 → hem riskli hem kaldi" do
      o = Ogrenci.new(ad: "Ayse", durum: :aktif, devamsizlik: 5)
      etiketler = DevamsizlikKontrol.kontrol(o)
      _(etiketler).must_include :riskli
      _(etiketler).must_include :kaldi
    end
  end

  # ============================================================
  # :burs_kesilir ÖZGÜN KURAL — devamsizlik >= 4 && durum == :burslu
  # İki koşul birden tutmalı
  # ============================================================
  describe ":burs_kesilir özgün kuralı (devamsizlik >= 4 && durum == :burslu)" do
    it "burslu + devamsizlik 3 → henüz bursu KESİLMEZ (devamsızlık sınırı tutmuyor)" do
      o = Ogrenci.new(ad: "Zeynep", durum: :burslu, devamsizlik: 3)
      _(DevamsizlikKontrol.kontrol(o)).wont_include :burs_kesilir
    end

    it "TAM SINIR: burslu + devamsizlik 4 → BURSU KESILIR" do
      o = Ogrenci.new(ad: "Mehmet", durum: :burslu, devamsizlik: 4)
      _(DevamsizlikKontrol.kontrol(o)).must_include :burs_kesilir
    end

    it "burslu DEĞİL + devamsizlik 4 → burs kesilmez (ikinci koşul tutmuyor)" do
      o = Ogrenci.new(ad: "Can", durum: :aktif, devamsizlik: 4)
      _(DevamsizlikKontrol.kontrol(o)).wont_include :burs_kesilir
    end

    it "pasif + devamsizlik 10 → burs kesilmez (pasif, burslu değil)" do
      o = Ogrenci.new(ad: "Elif", durum: :pasif, devamsizlik: 10)
      _(DevamsizlikKontrol.kontrol(o)).wont_include :burs_kesilir
    end
  end

  # ============================================================
  # Kaynak kodu denetimi — AGENTS.md § 2 yasaklarını statik test
  # ============================================================
  describe "AGENTS.md § 2 — mimari yasakların statik denetimi" do
    let(:kaynak) do
      Dir["lib/*.rb"].map { File.read(it) }.join("\n")
    end

    it "method_missing kullanılmamalı" do
      _(kaynak).wont_match(/method_missing/)
    end

    it "çekirdek sınıflar açılmamalı (monkey patch)" do
      _(kaynak).wont_match(/class\s+(Integer|String|Array|Hash|Numeric|Symbol|Object)\b/)
    end

    it "eval çağrısı olmamalı" do
      _(kaynak).wont_match(/\beval\s*\(/)
    end
  end
end
