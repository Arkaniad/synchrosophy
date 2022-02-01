#!/usr/bin/env ruby

# frozen_string_literal: true

require 'octokit'
require 'logger'
require 'jira-ruby'
require 'yaml'
require 'erb'

require './config.rb'

module IssueSync
  class Main
    attr_reader :jira_client, :github_client, :config

    def initialize(config:, log: Logger.new(STDOUT).level(Logger::DEBUG))
      @log = log
      @log.info 'Initializing issue-syncer'
      @config = config

      @jira_client = init_jira_client(@config)
      @github_client = init_github_client(@config)
    end

    def test
      repository_names = config.repositories.map do |cfg|
        cfg.source.path if cfg.source.type == 'github'
      end

      @log.info "Repositories: #{repository_names.join(', ')}"

      repositories = repository_names.map do |repo_name|
        @log.debug "Fetching repository #{repo_name}"
        github_client.repo(repo_name)
      end

      repositories.each do |repo|
        @log.debug "Fetching issues for repository #{repo.full_name}"
        issues = github_client.list_issues(repo.full_name)

        @log.debug "repo: #{repo.full_name} - issues: #{issues.length}"

        issues.each do |issue|
          tags = issue.labels.map{ |label| label.name }.join(', ')
          @log.debug "- issue #{issue.number}: #{issue.title} #{"(tags: " + tags + ")" if not tags.empty?}"
        end

      end
    end

    private

    def init_jira_client(config)
      @log.debug 'Instantiating jira client with jira-ruby'

      jira_config = config.services.select { |svc| svc.type == 'jira' }.first

      jira_url = jira_config.credentials['jira_url']
      jira_username = jira_config.credentials['jira_username']
      jira_password = jira_config.credentials['jira_password']

      JIRA::Client.new(
        {
          site: jira_url,
          username: jira_username,
          password: jira_password,
          context_path: '',
          auth_type: :basic
        }
      )
    end

    def init_github_client(github_token)
      @log.debug 'Instantiating github client with octokit'

      github_config = config.services.select { |svc| svc.type == 'github' }.first
      github_client = Octokit::Client.new(access_token: github_config.credentials['github_token'])
      github_client.auto_paginate = true

      github_client
    end
  end
end

log = Logger.new($stdout)
log.level = Logger::DEBUG

config_contents = File.open('./config.yaml').read
config = YAML.load(ERB.new(config_contents).result)

is = IssueSync::Main.new(
  config: config,
  log: log
)

is.test
