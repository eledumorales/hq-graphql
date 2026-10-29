# frozen_string_literal: true

require "hq/graphql/types"

module HQ
  module GraphQL
    class PaginationConnectionType < ::GraphQL::Types::Relay::BaseConnection
      field :cursors, [String], null: false
      field :total_count, Integer, null: false

      def cursors
        (0...(object.items.size)).step(object.first || object.items.size + 1).map do |item|
          Base64.urlsafe_encode64(item.to_s).delete("=")
        end
      end

      # Counts every record in the list, not just the ones a page can hold: root
      # queries hand over a relation already capped at limit_max (or at the
      # limit/offset arguments), so the cap is dropped before counting.
      def total_count
        items = object.items
        return items.size unless items.is_a?(::ActiveRecord::Relation)

        count = items.unscope(:limit, :offset, :order).count(:all)
        # A grouped relation counts per group
        count.is_a?(Hash) ? count.size : count
      end
    end
  end
end
