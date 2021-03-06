# frozen_string_literal: true

require 'sequel'

module MindMap
  module Database
    # Object Relational Mapper for Topics
    class TopicOrm < Sequel::Model(:topics)
      many_to_many :documents,
                   class: :'MindMap::Database::DocumentOrm',
                   join_table: :documents_topics,
                   left_key: :topic_id, right_key: :document_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(topic_info)
        first(name: topic_info[:name]) || create(topic_info)
      end
    end
  end
end
