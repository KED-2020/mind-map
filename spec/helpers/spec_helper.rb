# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'
require 'minitest/autorun'
require 'minitest/rg'

require_relative '../../init'

GITHUB_TOKEN = MindMap::App.config.GITHUB_TOKEN

CORRECT = YAML.safe_load(File.read("#{__dir__}/../fixtures/github_results.yml"))

SEARCH_QUERY = 'pytorch-transformers in:readme'
TOPICS = %w[tensorflow natural-language-processing].freeze

INVALID_SEARCH_QUERY = 10.times.map { ('a'..'z').to_a }.join

DB_TEST_SEARCH_QUERY = 'bitcoin'
DB_TEST_TOPICS = %w[python].freeze

# Helper methods
def homepage
  MindMap::App.config.APP_HOST
end
GOOD_INBOX_ID = '12345'
SAD_INBOX_ID = '54321'
BAD_INBOX_ID = 'foo123'
SUGGESTION_NAMES = ['tensorflow', 'TensorFlow', 'TensorFlow-Examples']

PROJECT_OWNER = 'derrxb'
PROJECT_NAME = 'derrxb'
PROJECT_URL = 'https://github.com/derrxb/derrxb'