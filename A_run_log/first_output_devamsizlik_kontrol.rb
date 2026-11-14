class DevamsizlikKontrol
  def self.kontrol(ogrenci)
    sonuclar = []

    if ogrenci.devamsizlik > 3
      sonuclar << :riskli
    end

    if ogrenci.devamsizlik > 4
      sonuclar << :kaldi
      sonuclar << :burs_kesilir if ogrenci.durum == :burslu
    end

    sonuclar
  end
end
