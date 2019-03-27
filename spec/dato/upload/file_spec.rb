# frozen_string_literal: true

require 'spec_helper'

module Dato
  module Upload
    describe File, :vcr do
      let(:account_client) do
        generate_account_client!
      end

      let(:site) do
        account_client.sites.create(name: 'Test site')
      end

      before { site }

      let(:site_client) do
        Dato::Site::Client.new(
          site[:readwrite_token],
          base_url: 'http://site-api.lvh.me:3001'
        )
      end

      subject(:command) do
        described_class.new(site_client, source)
      end

      context 'with a url' do
        let(:source) { 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf' }

        it 'downloads locally and then uploads the file' do
          expect(command.upload).not_to be_nil
        end
        context 'with a 404 url' do
          let(:source) { 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummyNotFound.pdf' }
  
          it 'raise an exception' do
            expect { command.upload }.to raise_error(Faraday::ResourceNotFound)
          end
        end
      end

      context 'with a local file' do
        let(:source) { './spec/fixtures/file.txt' }

        it 'uploads the file' do
          expect(command.upload).not_to be_nil
        end
      end
    end
  end
end
