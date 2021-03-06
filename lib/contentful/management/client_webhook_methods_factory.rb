require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Webhook API for usage from within Client
    # @private
    class ClientWebhookMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def new(*)
        fail 'Not supported'
      end
    end
  end
end
