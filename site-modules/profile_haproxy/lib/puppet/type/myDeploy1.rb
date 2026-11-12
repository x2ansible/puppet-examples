Puppet::Type.newtype(:myDeploy1) do
  @doc = "Fetches a URL over HTTP and writes the response to a file"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Deployment name"
  end

  newparam(:url) do
    desc "URL to fetch"
    validate do |value|
      raise ArgumentError, "Invalid HTTP/HTTPS URL" unless value =~ %r{\Ahttps?://}
    end
  end

  newparam(:file) do
    desc "Absolute path of the file to write the response to"
    validate do |value|
      raise ArgumentError, "file must be an absolute path" unless value.start_with?('/')
    end
  end
end
