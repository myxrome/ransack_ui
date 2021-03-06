require 'ransack/nodes/condition'

module Ransack
  module Nodes
    Condition.class_eval do
      attr_writer :is_default

      def default?
        @is_default
      end

      # Override to allow resetting of values if a single node is sent for validation
      def set_boolean_value
        @values = [Value.new(@context, true)]
      end

      def arel_predicate
        predicates = attributes.map do |attr|
          attr.attr.send(
            arel_predicate_for_attribute(attr),
            formatted_values_for_attribute(attr)
          )
        end
        if predicates.size > 1
          case combinator
          when 'and'
            Arel::Nodes::Grouping.new(Arel::Nodes::And.new(predicates))
          when 'or'
            Arel::Nodes::Grouping.new(predicates.inject(&:or))
          end
        else
          Arel::Nodes::Grouping.new(predicates.first)
        end
      end
    end
  end
end
