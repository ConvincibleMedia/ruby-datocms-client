# frozen_string_literal: true
require 'dato/local/entities_repo'
require 'dato/local/items_repo'

module Dato
  module Local
    class Loader
      attr_reader :client
      attr_reader :entities_repo
      attr_reader :items_repo
      attr_reader :preview_mode

      def initialize(client, preview_mode = false)
        @client = client
        @preview_mode = preview_mode
        @entities_repo = EntitiesRepo.new
        @items_repo = ItemsRepo.new(@entities_repo)
      end

      def load
        @entities_repo = EntitiesRepo.new(site, all_items)
        @items_repo = ItemsRepo.new(@entities_repo)
      end

      private

      def site
        include = ['item_types', 'item_types.fields']
        client.request(:get, '/site', include: include)
      end

      def all_items
        client.items.all(
          { version: preview_mode ? 'latest' : 'published' },
          deserialize_response: false,
          all_pages: true
        )
      end
    end
  end
end
