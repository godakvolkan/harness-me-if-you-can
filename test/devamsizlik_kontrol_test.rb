require "minitest/autorun"
require_relative "../lib/ogrenci"
require_relative "../lib/devamsizlik_kontrol"

class DevamsizlikKontrolTest < Minitest::Test
  def test_devamsizlik_3_ise_etiket_yok
    ogr = Ogrenci.new(ad: "Ali", durum: :aktif, devamsizlik: 3)
    assert_empty DevamsizlikKontrol.kontrol(ogr)
  end

  def test_devamsizlik_4_ise_riskli
    ogr = Ogrenci.new(ad: "Veli", durum: :aktif, devamsizlik: 4)
    assert_equal [:riskli], DevamsizlikKontrol.kontrol(ogr)
  end

  def test_devamsizlik_5_ise_riskli_ve_kaldi
    ogr = Ogrenci.new(ad: "Ayşe", durum: :aktif, devamsizlik: 5)
    sonuc = DevamsizlikKontrol.kontrol(ogr)
    assert_includes sonuc, :riskli
    assert_includes sonuc, :kaldi
  end

  def test_burslu_ogrenci_devamsizlik_5_ise_burs_kesilir
    ogr = Ogrenci.new(ad: "Mehmet", durum: :burslu, devamsizlik: 5)
    sonuc = DevamsizlikKontrol.kontrol(ogr)
    assert_includes sonuc, :riskli
    assert_includes sonuc, :kaldi
    assert_includes sonuc, :burs_kesilir
  end
end
