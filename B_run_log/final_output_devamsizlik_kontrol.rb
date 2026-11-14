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