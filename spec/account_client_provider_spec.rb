# frozen_string_literal: true

require "spec_helper"

RSpec.describe AccountClientProvider, :persistent_account do
  include described_class

  after do
    Thread.current[:datocms_vcr_live_secrets] = nil
  end

  subject(:account_client) { generate_account_client!(extra_headers: { "X-Test" => "true" }) }

  let(:anonymous_client) { instance_double(Dato::Account::Client) }
  let(:authenticated_client) { instance_double(Dato::Account::Client) }

  before do |example|
    next unless example.metadata[:account_login]

    expect(Dato::Account::Client).to receive(:new).with(
      nil,
      base_url: "https://account-api.datocms.com",
    ).ordered.and_return(anonymous_client)

    expect(anonymous_client).to receive(:post).with(
      "/sessions",
      data: {
        type: "email_credentials",
        attributes: {
          email: AccountClientProvider::PLAYBACK_EMAIL,
          password: AccountClientProvider::PLAYBACK_PASSWORD,
        },
      },
    ).and_return(
      data: { id: "<DATOCMS_ACCOUNT_SESSION>" },
    )

    expect(Dato::Account::Client).to receive(:new).with(
      "<DATOCMS_ACCOUNT_SESSION>",
      {
        base_url: "https://account-api.datocms.com",
        extra_headers: { "X-Test" => "true" },
      },
    ).ordered.and_return(authenticated_client)
  end

  it "logs into the persistent test account with playback credentials", :account_login do
    expect(account_client).to be(authenticated_client)
  end

  describe ".live_secret" do
    it "recovers a live value replaced by cassette redaction" do
      described_class.capture_live_secret(
        :site_access_token,
        "live-site-access-token",
      )

      expect(
        described_class.live_secret(
          :site_access_token,
          described_class::SITE_ACCESS_TOKEN_PLACEHOLDER,
        ),
      ).to eq("live-site-access-token")
    end

    it "leaves a playback placeholder unchanged when no live value was captured" do
      expect(
        described_class.live_secret(
          :site_access_token,
          described_class::SITE_ACCESS_TOKEN_PLACEHOLDER,
        ),
      ).to eq(described_class::SITE_ACCESS_TOKEN_PLACEHOLDER)
    end
  end

  describe "#site_api_token" do
    it "uses the owner-scoped access token for persistent account projects" do
      described_class.capture_live_secret(
        :site_access_token,
        "live-site-access-token",
      )

      token = site_api_token(
        access_token: described_class::SITE_ACCESS_TOKEN_PLACEHOLDER,
        readwrite_token: nil,
      )

      expect(token).to eq("live-site-access-token")
    end

    it "preserves the legacy read-write token path", persistent_account: false do
      token = site_api_token(
        access_token: "owner-access-token",
        readwrite_token: "legacy-readwrite-token",
      )

      expect(token).to eq("legacy-readwrite-token")
    end
  end
end
