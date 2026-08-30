# frozen_string_literal: true

require "fileutils"
require "dato/dump/format"

module Dato
  module Dump
    module Operation
      class CreateDataFile
        attr_reader :context, :path, :format, :value

        def initialize(context, path, format, value)
          @context = context
          @path = path
          @format = format
          @value = value
        end

        def perform
          FileUtils.mkdir_p(File.dirname(path))

          File.write(File.join(context.path, path), Format.dump(format, value))
        end
      end
    end
  end
end
