
# required items
require 'chef'
require 'chef/handler'
require "net/http"
require "uri"
require "openssl"

# start class
module ErrorsToSlackModule
  class ErrorsToSlack < Chef::Handler
    def initialize
      # Setup the values to be used
      @api_url = 'https://192.168.1.60:443/vco/api/workflows/e431d379-ea2f-4491-b16c-1682de68d197/executions'
      @api_user = 'vroapiSlackMessage@boyce.local'
      @api_pass = 'P@ssw0rd!'
    end

    def formatted_run_list
      node.run_list.map { |r| r.type == :role ? r.name : r.to_s }.join(", ")
    end

    def report
      puts "Using api_url value of: #{@api_url}"

      uri = URI(@api_url)
      puts "uri value is: #{uri}"

      http = Net::HTTP.new(uri.host, uri.port)
      puts "http object: #{http}"

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri)
      puts "Using request_uri value of: #{uri.request_uri}"
      puts "Request Object: #{request}"

      request.content_type = 'application/json'
      puts "Using content type value of: #{request.content_type}"
      request.basic_auth(@api_user, @api_pass)

      @api_error_message = "Something went horribly wrong when converging `#{node.name}` :scream:  Some details are below, maybe they can help... :thinking_face: \\n*Run List:*\\n`#{formatted_run_list}`\\n*Exception:*\\n`#{run_status.exception}`"
      puts "API Error Message is: #{@api_error_message}"

      @api_data = "{\"parameters\": [{\"name\": \"slackMessage\",\"scope\": \"local\",\"type\": \"string\",\"value\": {\"string\": {\"value\": \"#{@api_error_message}\"}}}]}"
      request.body = @api_data
      puts "Request Body: #{request.body}"

      response = http.request request
      puts "Response: #{response}"
    end
  end
end
