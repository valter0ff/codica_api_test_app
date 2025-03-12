# frozen_string_literal: true

class ApplicationSerializer
  include JSONAPI::Serializer

  cache_options store: Rails.cache, namespace: 'jsonapi-serializer', expires_in: 1.hour, key: :cache_key_with_version
end
