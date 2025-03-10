# frozen_string_literal: true

module Helpers
  module ApiHelper
    def parsed_response_body
      response.parsed_body.deep_symbolize_keys
    end
  end
end
