class EmberIndexController < ApplicationController
  before_action :set_response_format

  SHORT_UUID_V4_REGEXP = /\A[0-9a-f]{7}\z/i

  def index
    index = Sidekiq.redis { |r| r.get(fetch_index_key) }
    render text: process_index(index).html_safe, layout: false
  end

  private

    def fetch_index_key
      if Rails.env.development?
        "ember-cli-deploy-example-ember:index:__development__"
      elsif fetch_revision
        "ember-cli-deploy-example-ember:index:#{fetch_revision}"
      else
        "ember-cli-deploy-example-ember:index:#{fetch_current_revision}"
      end
    end

    def fetch_revision
      rev = params[:revision]
      return rev if rev =~ SHORT_UUID_V4_REGEXP
    end

    def fetch_current_revision
      Sidekiq.redis { |r| r.get("ember-cli-deploy-example-ember:index:current") }
    end

    def process_index(index)
      return "INDEX NOT FOUND" unless index

      relative_url = "/ember-cli-live-reload"
      absolute_url = "http://localhost:4200/ember-cli-live-reload"
      index.sub!(relative_url, absolute_url) if Rails.env.development?

      index
    end

    def set_response_format
      request.format = :html
    end
end