# frozen_string_literal: true

require "spec_helper"

module Dato
  module Local
    describe Site do
      describe "#frontend_url" do
        it "returns nil when the current API omits the optional attribute" do
          entity = double
          allow(entity).to receive(:[]).with(:frontend_url).and_return(nil)

          site = described_class.new(entity, double)

          expect(site.frontend_url).to be_nil
        end
      end
    end
  end
end
