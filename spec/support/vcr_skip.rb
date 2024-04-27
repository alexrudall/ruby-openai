module VCRHelpers
  def vcr_skip
    VCR.configure { |c| c.allow_http_connections_when_no_cassette = true }
    yield
  ensure
    VCR.configure { |c| c.allow_http_connections_when_no_cassette = false }
  end
end
