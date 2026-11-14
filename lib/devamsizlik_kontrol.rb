# frozen_string_literal: true

class DevamsizlikKontrol
  # Tek giriş noktası: bir Ogrenci alır, uygulanan kuralların sembollerini döndürür.
  def self.kontrol(ogrenci)
    sonuc = []
    sonuc << :riskli       if riskli?(ogrenci)
    sonuc << :kaldi        if kaldi?(ogrenci)
    sonuc << :burs_kesilir if burs_kesilir?(ogrenci)
    sonuc
  end

  # "3'ün üzerinde" == tam 3 dahil (>= 3). Sınır vaka: 3 devamsızlık RISKLIDIR.
  def self.riskli?(ogrenci) = ogrenci.devamsizlik >= 3

  def self.kaldi?(ogrenci) = ogrenci.devamsizlik >= 4

  # Özgün kural: iki koşul birden — hem devamsızlık sınırı hem burs durumu.
  def self.burs_kesilir?(ogrenci) = ogrenci.devamsizlik >= 4 && ogrenci.burslu?
end
