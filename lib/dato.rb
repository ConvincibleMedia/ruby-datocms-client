# frozen_string_literal: true

require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/hash/keys"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"

require "dato/version"

require "dato/site/client"
require "dato/account/client"
require "dato/local/site"
require "dato/cli"
require "dato/utils/seo_tags_builder"
require "dato/utils/favicon_tags_builder"
require "dato/utils/build_modular_block"

module Dato
end
