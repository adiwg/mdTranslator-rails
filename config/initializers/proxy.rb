ENV['SERVICE_URL'] ||= 'https://services.itis.gov'

# This exists because the frontend depends on an ITIS lookup (under record > Taxonomy) which doesn't support CORS
# HOPEFULLY this can be removed at some point, when services.itis.gov adds CORS headers

class ItisServiceProxy < Rack::Proxy
  def perform_request(env)
    request = Rack::Request.new(env)

    # use rack proxy for anything hitting our host app at /itis_proxy
    if request.path =~ %r{^#{ENV['RAILS_RELATIVE_URL_ROOT']}/itis-proxy$}
        backend = URI(ENV['SERVICE_URL'])
        # most backends required host set properly, but rack-proxy doesn't set this for you automatically
        # even when a backend host is passed in via the options
        env["HTTP_HOST"] = backend.host

        # This is the only path that needs to be set currently on Rails 5 & greater
        env['PATH_INFO'] = '/'

        # if RAILS_RELATIVE_URL_ROOT is set, it sets this too, which gets forwarded as part of the path
        env['SCRIPT_NAME'] = ''

        # don't send your sites cookies to target service, unless it is a trusted internal service that can parse all your cookies
        env['HTTP_COOKIE'] = ''
        super(env)
    else
      @app.call(env)
    end
  end
end

Rails.application.config.middleware.use ItisServiceProxy, backend: ENV['SERVICE_URL'], streaming: false
