class VCRMultipartMatcher
  MULTIPART_HEADER_MATCHER = %r{^multipart/form-data; boundary=(.+)$}.freeze
  BOUNDARY_SUBSTITUTION = "----MultipartBoundaryAbcD3fGhiXyz00001".freeze

  def call(request1, request2)
    return false unless same_content_type?(request1, request2)
    unless headers_excluding_content_type(request1) == headers_excluding_content_type(request2)
      return false
    end

    normalized_multipart_body(request1) == normalized_multipart_body(request2)
  end

  private

  def same_content_type?(request1, request2)
    content_type1 = (request1.headers["Content-Type"] || []).first.to_s
    content_type2 = (request2.headers["Content-Type"] || []).first.to_s

    if multipart_request?(content_type1)
      multipart_request?(content_type2)
    elsif multipart_request?(content_type2)
      false
    else
      content_type1 == content_type2
    end
  end

  def headers_excluding_content_type(request)
    request.headers.reject { |key, _| key == "Content-Type" }
  end

  def normalized_multipart_body(request)
    content_type = (request.headers["Content-Type"] || []).first.to_s

    return request.headers unless multipart_request?(content_type)

    boundary = MULTIPART_HEADER_MATCHER.match(content_type)[1]
    request.body.gsub(boundary, BOUNDARY_SUBSTITUTION)
  end

  def multipart_request?(content_type)
    return false if content_type.empty?

    MULTIPART_HEADER_MATCHER.match?(content_type)
  end
end
