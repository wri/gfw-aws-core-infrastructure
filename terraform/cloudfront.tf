resource "aws_cloudfront_origin_access_identity" "tiles" {}

resource "aws_cloudfront_distribution" "tiles" {

  aliases = var.environment == "production" ? ["tiles.globalforestwatch.org"] : null

  enabled         = true
  http_version    = "http2"
  is_ipv6_enabled = true
  comment         = "tiles.globalforestwatch.org"
  //  default_root_object = "index.html"

  price_class = "PriceClass_All"

  origin {
    domain_name = aws_s3_bucket.tiles.website_endpoint //"gfw-tiles.s3-website-us-east-1.amazonaws.com"
    origin_id   = "wdpa_protected_areas-latest"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }
  origin {
    domain_name = "wri-tiles.s3-website-us-east-1.amazonaws.com" // not managed by terraform b/c other account
    origin_id   = "wri-tiles"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }
  //  origin {
  //    domain_name = "4khgyzteea.execute-api.us-east-1.amazonaws.com"
  //    origin_id   = "Custom-4khgyzteea.execute-api.us-east-1.amazonaws.com/default"
  //    origin_path = "/default"
  //
  //    custom_origin_config {
  //      http_port                = 80
  //      https_port               = 443
  //      origin_keepalive_timeout = 5
  //      origin_protocol_policy   = "https-only"
  //      origin_read_timeout      = 30
  //      origin_ssl_protocols = [
  //        "TLSv1",
  //        "TLSv1.1",
  //        "TLSv1.2",
  //      ]
  //    }
  //  }

  origin {
    domain_name = aws_s3_bucket.tiles.bucket_domain_name // "gfw-tiles.s3.amazonaws.com"
    origin_id   = "S3-gfw-tiles"
    s3_origin_config { origin_access_identity = "${aws_cloudfront_origin_access_identity.tiles.cloudfront_access_identity_path}" }

  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "GET"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = "S3-gfw-tiles"

    compress = true


    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

  }

  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 86400
    max_ttl                = 86400
    min_ttl                = 0
    path_pattern           = "glad_prod/*"
    smooth_streaming       = false
    target_origin_id       = "wri-tiles"
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers                 = []
      query_string            = false
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }
  //  ordered_cache_behavior {
  //    allowed_methods = [
  //      "GET",
  //      "HEAD",
  //    ]
  //    cached_methods = [
  //      "GET",
  //      "HEAD",
  //    ]
  //    compress               = false
  //    default_ttl            = 86400
  //    max_ttl                = 31536000
  //    min_ttl                = 0
  //    path_pattern           = "*/index.html"
  //    smooth_streaming       = false
  //    target_origin_id       = "Custom-4khgyzteea.execute-api.us-east-1.amazonaws.com/default"
  //    trusted_signers        = []
  //    viewer_protocol_policy = "redirect-to-https"
  //
  //    forwarded_values {
  //      headers                 = []
  //      query_string            = false
  //      query_string_cache_keys = []
  //
  //      cookies {
  //        forward           = "none"
  //        whitelisted_names = []
  //      }
  //    }
  //  }
  //  ordered_cache_behavior {
  //    allowed_methods = [
  //      "GET",
  //      "HEAD",
  //    ]
  //    cached_methods = [
  //      "GET",
  //      "HEAD",
  //    ]
  //    compress               = false
  //    default_ttl            = 86400
  //    max_ttl                = 31536000
  //    min_ttl                = 0
  //    path_pattern           = "index.html"
  //    smooth_streaming       = false
  //    target_origin_id       = "Custom-4khgyzteea.execute-api.us-east-1.amazonaws.com/default"
  //    trusted_signers        = []
  //    viewer_protocol_policy = "redirect-to-https"
  //
  //    forwarded_values {
  //      headers                 = []
  //      query_string            = false
  //      query_string_cache_keys = []
  //
  //      cookies {
  //        forward           = "none"
  //        whitelisted_names = []
  //      }
  //    }
  //  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 0
    max_ttl                = 31536000
    min_ttl                = 0
    path_pattern           = "*/latest/*"
    smooth_streaming       = false
    target_origin_id       = "S3-gfw-tiles"
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers                 = []
      query_string            = false
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = module.tile_cache.lambda_redirect_latest_tile_cache_qualified_arn
    }
    lambda_function_association {
      event_type   = "viewer-response"
      include_body = false
      lambda_arn   = module.tile_cache.lambda_reset_response_header_caching_qualified_arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.environment == "production" ? aws_acm_certificate.globalforestwatch[0].arn : null
    cloudfront_default_certificate = var.environment == "production" ? false : true
    minimum_protocol_version       = "TLSv1" // "TLSv1.1_2016"
    ssl_support_method             = "sni-only"
  }


  tags = local.tags

}