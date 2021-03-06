# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'

describe 'GetInbox integration tests' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_github
    DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Get an Inbox' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should return inbox and their suggestions' do
      # GIVEN: an inbox with suggestions exist
      inbox = MindMap::Entity::Inbox.new(id: nil,
                                         name: 'test',
                                         url: '12345',
                                         description: 'test',
                                         suggestions: [])
      saved_inbox = MindMap::Repository::Inbox::For.klass(MindMap::Entity::Inbox).create(inbox)

      # WHEN: we request an inbox and its suggestions
      result = MindMap::Service::GetInbox.new.call({ inbox_id: saved_inbox.url })

      # THEN: we should see our inbox with its suggestions
      _(result.success?).must_equal true
      inbox_result = result.value!
      _(inbox_result[:inbox].name).must_equal inbox.name
      _(inbox_result[:inbox].description).must_equal inbox.description
      _(inbox_result[:suggestions].count).must_equal 30
    end

    it 'SAD: should not return inbox if it does not exist' do
      # GIVEN: an inbox that does not exist
      # WHEN: we request an inbox and its suggestions
      result = MindMap::Service::GetInbox.new.call(inbox_id: SAD_INBOX_ID)

      # Then: we should get failure
      _(result.failure?).must_equal true
    end
  end
end
