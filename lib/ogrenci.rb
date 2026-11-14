class Ogrenci
  attr_accessor :ad, :durum, :devamsizlik

  GECERLI_DURUMLAR = %i[aktif pasif burslu].freeze

  def initialize(ad:, durum: :aktif, devamsizlik: 0)
    @ad = ad
    @durum = durum
    @devamsizlik = devamsizlik
  end

  def burslu?
    @durum == :burslu
  end

  def aktif?
    @durum == :aktif
  end

  def pasif?
    @durum == :pasif
  end
end
