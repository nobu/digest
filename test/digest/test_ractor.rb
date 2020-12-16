# frozen_string_literal: false
require 'test/unit'

require 'digest'
%w[digest/md5 digest/rmd160 digest/sha1 digest/sha2 digest/bubblebabble].each do |lib|
  begin
    require lib
  rescue LoadError
  end
end

module TestDigestRactor
  Data1 = "abc"
  Data2 = "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"

  def setup
    skip unless defined?(Ractor)
  end

  def test_s_hexdigest
    assert_in_out_err([], <<-"end;", ["true", "true"], [])
      $VERBOSE = nil
      require "digest"
      require "#{self.class::LIB}"
      DATA = #{self.class::DATA.inspect}
      rs = DATA.map do |str, hexdigest|
        r = Ractor.new str do |x|
          #{self.class::ALGO}.hexdigest(x)
        end
        [r, hexdigest]
      end
      rs.each do |r, hexdigest|
        puts r.take == hexdigest
      end
    end;
  end

  class TestMD5Ractor < Test::Unit::TestCase
    include TestDigestRactor
    LIB = "digest/md5"
    ALGO = Digest::MD5
    DATA = {
      Data1 => "900150983cd24fb0d6963f7d28e17f72",
      Data2 => "8215ef0796a20bcaaae116d3876c664a",
    }
  end if defined?(Digest::MD5)
end
