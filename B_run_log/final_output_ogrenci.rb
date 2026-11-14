# frozen_string_literal: true

class Ogrenci
  attr_reader :ad, :durum, :devamsizlik

  GECERLI_DURUMLAR = %i[aktif pasif burslu].freeze

  def initialize(ad:, durum: :aktif, devamsizlik: 0)
    @ad = ad
    @durum = durum
    @devamsizlik = devamsizlik
  end

  def burslu? = @durum == :burslu
  def aktif? = @durum == :aktif
  def pasif? = @durum == :pasif
end