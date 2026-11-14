# frozen_string_literal: true

class Ogrenci
  # Hocanın şartnamesindeki geçerli durumlar (ödev § 1, satır 21).
  DURUMLAR = %i[aktif donduruldu mezun].freeze

  # Devamsızlık aralığı: 0..10 oturum (ödev § 1, satır 21).
  DEVAMSIZLIK_ARALIGI = (0..10).freeze

  attr_reader :ad, :durum, :devamsizlik

  def initialize(ad:, durum: :aktif, devamsizlik: 0, burslu: false)
    unless DURUMLAR.include?(durum)
      raise ArgumentError, "geçersiz durum: #{durum.inspect} (geçerli: #{DURUMLAR.join(', ')})"
    end
    unless DEVAMSIZLIK_ARALIGI.cover?(devamsizlik)
      raise ArgumentError, "devamsizlik #{DEVAMSIZLIK_ARALIGI} aralığında olmalı: #{devamsizlik}"
    end

    @ad = ad
    @durum = durum
    @devamsizlik = devamsizlik
    @burslu = burslu
  end

  # Durum sorguları define_method ile açıkça üretilir (dinamik ad yakalama yok).
  # Üretilen aranabilir metotlar: aktif?  donduruldu?  mezun?
  DURUMLAR.each do |durum_adi|
    define_method(:"#{durum_adi}?") { @durum == durum_adi }
  end

  # Burs bilgisi durumdan ayrı bir bayraktır; özgün :burs_kesilir kuralı bunu kullanır.
  def burslu? = @burslu
end
