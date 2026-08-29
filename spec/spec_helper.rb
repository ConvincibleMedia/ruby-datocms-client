# frozen_string_literal: true

require "simplecov"
require "coveralls"
require "json"
require "active_support/core_ext/object/blank"

ENV["SITE_API_BASE_URL"] ||= "https://site-api.datocms.com"
ENV["ACCOUNT_API_BASE_URL"] ||= "https://account-api.datocms.com"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                 SimpleCov::Formatter::HTMLFormatter,
                                                                 Coveralls::SimpleCov::Formatter,
                                                               ])

SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

Dir["spec/support/**/*.rb"].each { |f| require_relative "../#{f}" }

require "pry"
require "vcr"
require "i18n"
require "i18n/backend/fallbacks"
require "webmock/rspec"

I18n.enforce_available_locales = false
I18n.available_locales = %i[it en ru]
I18n::Backend::Simple.include I18n::Backend::Fallbacks
I18n.fallbacks[:ru] = [:"es-ES"]

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.preserve_exact_body_bytes do |http_message|
    http_message.body.encoding.name == "ASCII-8BIT" ||
      !http_message.body.valid_encoding?
  end
  config.configure_rspec_metadata!

  config.register_request_matcher :modified_body do |request1, request2|
    if URI(request1.uri).path == "/account" &&
       URI(request2.uri).path == "/account" &&
       request1.method == request2.method

      true
    else
      request1.body == request2.body
    end
  end

  config.before_record do |interaction|
    authorization = interaction.request.headers["Authorization"]
    if authorization
      interaction.request.headers["Authorization"] = ["Bearer <DATOCMS_TOKEN>"]
    end

    uri = URI(interaction.request.uri)

    if uri.path == "/sessions"
      request_body = JSON.parse(interaction.request.body)
      attributes = request_body.dig("data", "attributes")
      if attributes
        attributes["email"] = AccountClientProvider::PLAYBACK_EMAIL
        attributes["password"] = AccountClientProvider::PLAYBACK_PASSWORD
      end
      interaction.request.body = JSON.generate(request_body)
    end

    content_type = Array(interaction.response.headers["Content-Type"]).join(";")
    response_body_present = interaction.response.body &&
                            !interaction.response.body.empty?

    if !uri.path.include?("/docs/") &&
       content_type.include?("json") &&
       response_body_present
      response_body = JSON.parse(interaction.response.body)

      if uri.path == "/sessions"
        session_data = response_body["data"]
        if session_data.is_a?(Hash)
          AccountClientProvider.capture_live_secret(
            :account_session,
            session_data["id"],
          )
          session_data["id"] = AccountClientProvider::ACCOUNT_SESSION_PLACEHOLDER
        end

        Array(response_body["included"]).each do |resource|
          next unless resource["type"] == "account"
          next unless resource["attributes"].is_a?(Hash)

          resource["attributes"]["email"] = AccountClientProvider::PLAYBACK_EMAIL
        end
      end

      scrub_sensitive_site_data = lambda do |value|
        case value
        when Hash
          if value["type"] == "site" && value["attributes"].is_a?(Hash)
            attributes = value["attributes"]
            if attributes["access_token"]
              AccountClientProvider.capture_live_secret(
                :site_access_token,
                attributes["access_token"],
              )
              attributes["access_token"] =
                AccountClientProvider::SITE_ACCESS_TOKEN_PLACEHOLDER
            end

            if attributes["readwrite_token"]
              AccountClientProvider.capture_live_secret(
                :site_token,
                attributes["readwrite_token"],
              )
              attributes["readwrite_token"] =
                AccountClientProvider::SITE_TOKEN_PLACEHOLDER
            end

            if attributes["readonly_token"]
              attributes["readonly_token"] = "<DATOCMS_READONLY_TOKEN>"
            end
          end

          owner = value["owner"]
          if owner.is_a?(Hash) && owner["type"] == "account" && owner.key?("email")
            owner["email"] = AccountClientProvider::PLAYBACK_EMAIL
          end

          value.each_value do |nested_value|
            scrub_sensitive_site_data.call(nested_value)
          end
        when Array
          value.each { |nested_value| scrub_sensitive_site_data.call(nested_value) }
        end

        value
      end

      scrub_sensitive_site_data.call(response_body)
      interaction.response.body = JSON.generate(response_body)
    end
  rescue JSON::ParserError, TypeError
    # Non-JSON responses do not contain the credentials filtered above.
  end

  config.default_cassette_options = {
    match_requests_on: %i[method uri query modified_body],
    record: ENV["DATOCMS_LIVE_TESTS"] == "1" ? :all : :once,
  }
end

require "dato"
