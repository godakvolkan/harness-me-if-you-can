# frozen_string_literal: true
require "minitest/autorun"
require "minitest/spec"
require_relative "../lib/ogrenci"
require_relative "../lib/devamsizlik_kontrol"

describe Ogrenci do
  describe "constructor" do
    it "varsayılan durum :aktif, devamsizlik 0, burssuz" do
      o = Ogrenci.new(ad: "Test")
      _(o.durum).must_equal :aktif
      _(o.devamsizlik).must_equal 0
      _(o.burslu?).must_equal false
    end

    it "geçersiz durum ArgumentError fırlatır" do
      _ { Ogrenci.new(ad: "X", durum: :silindi) }.must_raise ArgumentError
    end

    it "0..10 dışı devamsizlik ArgumentError fırlatır" do
      _ { Ogrenci.new(ad: "X", devamsizlik: 11) }.must_raise ArgumentError
      _ { Ogrenci.new(ad: "X", devamsizlik: -1) }.must_raise ArgumentError
    end
  end

  describe "durum sorguları (define_method ile üretilmiş)" do
    it "aktif? doğru çalışır" do
      _(Ogrenci.new(ad: "A", durum: :aktif).aktif?).must_equal true
      _(Ogrenci.new(ad: "A", durum: :mezun).aktif?).must_equal false
    end

    it "donduruldu? doğru çalışır" do
      _(Ogrenci.new(ad: "A", durum: :donduruldu).donduruldu?).must_equal true
    end

    it "mezun? doğru çalışır" do
      _(Ogrenci.new(ad: "A", durum: :mezun).mezun?).must_equal true
    end

    it "tanımsız bir metot NoMethodError verir (method_missing YOK)" do
      _ { Ogrenci.new(ad: "A").uzaylimi? }.must_raise NoMethodError
    end
  end
end

describe DevamsizlikKontrol do
  describe ":riskli kuralı (devamsizlik >= 3)" do
    it "sınır altı: 2 → riskli DEĞİL" do
      o = Ogrenci.new(ad: "Ali", durum: :aktif, devamsizlik: 2)
      _(DevamsizlikKontrol.kontrol(o)).wont_include :riskli
    end

    it "TAM SINIR: 3 → RISKLI" do
      o = Ogrenci.new(ad: "Veli", durum: :aktif, devamsizlik: 3)
      _(DevamsizlikKontrol.kontrol(o)).must_include :riskli
    end

    it "sınır üstü: 5 → riskli" do
      o = Ogrenci.new(ad: "Ayse", durum: :aktif, devamsizlik: 5)
      _(DevamsizlikKontrol.kontrol(o)).must_include :riskli
    end
  end

  describe ":kaldi kuralı (devamsizlik >= 4)" do
    it "sınır altı: 3 → kaldi DEĞİL" do
      o = Ogrenci.new(ad: "Ali", durum: :aktif, devamsizlik: 3)
      _(DevamsizlikKontrol.kontrol(o)).wont_include :kaldi
    end

    it "TAM SINIR: 4 → KALDI" do
      o = Ogrenci.new(ad: "Veli", durum: :aktif, devamsizlik: 4)
      _(DevamsizlikKontrol.kontrol(o)).must_include :kaldi
    end
  end

  describe ":burs_kesilir özgün kuralı (devamsizlik >= 4 && burslu)" do
    it "burslu + 4 → BURSU KESILIR" do
      o = Ogrenci.new(ad: "Mehmet", durum: :aktif, devamsizlik: 4, burslu: true)
      _(DevamsizlikKontrol.kontrol(o)).must_include :burs_kesilir
    end

    it "burslu + 3 → henüz kesilmez (devamsızlık sınırı tutmuyor)" do
      o = Ogrenci.new(ad: "Zeynep", durum: :aktif, devamsizlik: 3, burslu: true)
      _(DevamsizlikKontrol.kontrol(o)).wont_include :burs_kesilir
    end

    it "burssuz + 4 → kesilmez (ikinci koşul tutmuyor)" do
      o = Ogrenci.new(ad: "Can", durum: :aktif, devamsizlik: 4, burslu: false)
      _(DevamsizlikKontrol.kontrol(o)).wont_include :burs_kesilir
    end
  end

  describe "AGENTS.md § 2 — mimari yasakların statik denetimi" do
    let(:kaynak) { Dir["lib/*.rb"].map { |path| File.read(path, encoding: "UTF-8") }.join("\n") }

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
