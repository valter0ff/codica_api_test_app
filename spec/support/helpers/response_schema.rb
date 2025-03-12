# frozen_string_literal: true

module Helpers
  module ResponseSchema
    def response_schema(path)
      JSON.parse(
        Rails.root.join('spec', 'support', 'api', 'schemas', "#{path}.json").read
      )
    end
  end
end
