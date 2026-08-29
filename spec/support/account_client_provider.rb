# frozen_string_literal: true

module AccountClientProvider
  PLAYBACK_EMAIL = "vcr-test-account@example.invalid"
  PLAYBACK_PASSWORD = "vcr-test-password"
  ACCOUNT_SESSION_PLACEHOLDER = "<DATOCMS_ACCOUNT_SESSION>"
  SITE_ACCESS_TOKEN_PLACEHOLDER = "<DATOCMS_ACCESS_TOKEN>"
  SITE_TOKEN_PLACEHOLDER = "<DATOCMS_SITE_TOKEN>"

  PLACEHOLDERS = {
    account_session: ACCOUNT_SESSION_PLACEHOLDER,
    site_access_token: SITE_ACCESS_TOKEN_PLACEHOLDER,
    site_token: SITE_TOKEN_PLACEHOLDER,
  }.freeze

  def self.capture_live_secret(name, value)
    return if value.nil? || value.empty?

    live_secrets[name] = value
  end

  def self.live_secret(name, cassette_value)
    return cassette_value unless cassette_value == PLACEHOLDERS.fetch(name)

    live_secrets.fetch(name, cassette_value)
  end

  def self.live_secrets
    Thread.current[:datocms_vcr_live_secrets] ||= {}
  end

  def generate_account_client!(options = {})
    if persistent_test_account?
      generate_persistent_account_client!(options)
    else
      generate_legacy_account_client!(options)
    end
  end

  def persistent_test_account?
    RSpec.current_example.metadata[:persistent_account]
  end

  def live_recording?
    ENV["DATOCMS_LIVE_TESTS"] == "1"
  end

  def site_api_token(site)
    return site[:readwrite_token] unless persistent_test_account?

    AccountClientProvider.live_secret(
      :site_access_token,
      site[:access_token],
    )
  end

  private

  def generate_persistent_account_client!(options)
    email = test_account_credential(
      "DATOCMS_TEST_ACCOUNT_EMAIL",
      PLAYBACK_EMAIL,
    )
    password = test_account_credential(
      "DATOCMS_TEST_ACCOUNT_PASSWORD",
      PLAYBACK_PASSWORD,
    )

    anonymous_client = Dato::Account::Client.new(
      nil,
      base_url: ENV.fetch("ACCOUNT_API_BASE_URL"),
    )

    session = anonymous_client.post(
      "/sessions",
      data: {
        type: "email_credentials",
        attributes: {
          email: email,
          password: password,
        },
      },
    )

    session_token = AccountClientProvider.live_secret(
      :account_session,
      session[:data][:id],
    )

    Dato::Account::Client.new(
      session_token,
      options.merge(
        base_url: ENV.fetch("ACCOUNT_API_BASE_URL"),
      ),
    )
  end

  def generate_legacy_account_client!(options)
    random_string = (0...8).map { rand(65..90).chr }.join

    anonymous_client = Dato::Account::Client.new(
      nil,
      base_url: ENV.fetch("ACCOUNT_API_BASE_URL"),
    )

    account = anonymous_client.account.create(
      email: "#{random_string}@delete-this-at-midnight-utc.tk",
      password: "veryst_9rong_passowrd4_",
      name: "Test",
      company: "DatoCMS",
    )

    Dato::Account::Client.new(
      account[:id],
      options.merge(
        base_url: ENV.fetch("ACCOUNT_API_BASE_URL"),
      ),
    )
  end

  def test_account_credential(name, playback_value)
    return playback_value unless live_recording?

    ENV.fetch(name) do
      raise "#{name} is required when DATOCMS_LIVE_TESTS=1"
    end
  end
end

RSpec.configure do |_config|
  include AccountClientProvider
end
