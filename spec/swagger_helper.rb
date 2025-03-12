# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'www.example.com'
            }
          }
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml

  config.after do |example|
    next unless example.metadata[:rswag]

    summary = example.metadata[:example_group][:description]
    content = example.metadata[:response][:content] || {}
    value = JSON.parse(response.body, symbolize_names: true) if response.body.present?
    mime_type = response.media_type

    example_spec = {
      mime_type => {
        examples: {
          "#{summary}": {
            value:
          }
        }
      }
    }
    example.metadata[:response][:content] = content.deep_merge(example_spec) unless value.nil?
    next unless example.metadata[:operation][:parameters]

    # save the request payload as example
    example.metadata[:operation][:parameters].each.with_index do |param, i|
      value = send(param[:name])
      name = summary

      if param[:in] == :body
        # parameters in body require to be added to request_examples
        example.metadata[:operation][:request_examples] ||= []
        example.metadata[:operation][:request_examples] << { value:, summary:, name: }
      else
        # parameters in query, path, headers, etc.... require to be added to examples
        example.metadata[:operation][:parameters][i][:examples] ||= {}
        example.metadata[:operation][:parameters][i][:examples][name] = { value: }
      end
    end
  end
end
