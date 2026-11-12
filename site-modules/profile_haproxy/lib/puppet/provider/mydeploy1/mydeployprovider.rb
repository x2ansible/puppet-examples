require 'net/http'
require 'json'
require 'uri'

Puppet::Type.type(:mydeploy1).provide(:mydeployprovider) do
  desc "Fetches the URL and writes the response to the target file"

  def exists?
    File.exist?(resource[:file])
  end

  def create
    result = fetch(resource[:url])
    content = result.is_a?(String) ? result : JSON.pretty_generate(result)
    File.write(resource[:file], content)
  end

  def destroy
    File.delete(resource[:file])
  end

  private

  # Same fetch logic as myfunction1: return parsed JSON, the raw body, or an
  # error/unreachable hash instead of raising.
  def fetch(url)
    begin
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)

      if response.is_a?(Net::HTTPSuccess)
        begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          response.body
        end
      else
        { 'status' => 'error', 'code' => response.code }
      end
    rescue => e
      { 'status' => 'unreachable', 'error' => e.message }
    end
  end
end
