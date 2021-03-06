# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'

describe 'Tests Github API library' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_github
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Search Query' do
    it 'Ensures that the correct parameters are returned' do
      document =
        MindMap::Github::DocumentsMapper
        .new(GITHUB_TOKEN)
        .search(SEARCH_QUERY, TOPICS)
      _(document.name).must_equal CORRECT['name']
      _(document.html_url).must_equal CORRECT['html_url']
      _(document.description).must_equal CORRECT['description']
    end

    it 'Ensures that an exception is raised when the query is too long' do
      _(proc do
        MindMap::Github::DocumentsMapper
          .new(GITHUB_TOKEN)
          .search(INVALID_SEARCH_QUERY, TOPICS)
      end).must_raise MindMap::Github::Api::Response::UnprocessableEntity
    end

    it 'Ensures that an exception is raised when the token is invalid' do
      _(proc do
        MindMap::Github::DocumentsMapper
          .new('BAD_TOKEN')
          .search(SEARCH_QUERY, TOPICS)
      end).must_raise MindMap::Github::Api::Response::Unauthorized
    end
  end

  describe 'Topic Information' do
    before do
      @document = MindMap::Github::DocumentsMapper
                  .new(GITHUB_TOKEN)
                  .search(SEARCH_QUERY, TOPICS)
    end

    it 'Ensures topics are formatted correct' do
      @document.topics.each do |topic|
        _(topic).must_be_kind_of(MindMap::Entity::Topic)
      end
    end

    it 'Ensure that the topic names are correct' do
      topics = @document.topics
      _(@document.topics.count).must_equal CORRECT['topics'].count

      topic_names = topics.map(&:name)
      _(topic_names).must_equal CORRECT['topics']
    end
  end

  describe 'Project Information' do
    it 'HAPPY: should provide correct project attributes' do
      document = MindMap::Github::DocumentMapper
                 .new(GITHUB_TOKEN)
                 .find("#{PROJECT_NAME}/#{PROJECT_OWNER}")

      _(document.origin_id).must_equal CORRECT['document_id']
      _(document.name).must_equal CORRECT['document_name']
      _(document.html_url).must_equal CORRECT['document_html_url']
      _(document.description).must_equal CORRECT['document_description']
    end

    it 'BAD: should raise exception on incorrect project' do
      _(proc do
        MindMap::Github::DocumentMapper
          .new(GITHUB_TOKEN)
          .find("#{PROJECT_NAME}/unknown")
      end).must_raise MindMap::Github::Api::Response::NotFound
    end

    it 'BAD: should raise exception when unauthorized' do
      _(proc do
          MindMap::Github::DocumentMapper
            .new('BAD_TOKEN')
            .find("#{PROJECT_NAME}/#{PROJECT_OWNER}")
        end).must_raise MindMap::Github::Api::Response::Unauthorized
    end
  end
end
