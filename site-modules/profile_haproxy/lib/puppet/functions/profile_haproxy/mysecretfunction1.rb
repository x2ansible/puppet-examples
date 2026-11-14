begin
  require 'company_internal_lib'
  INTERNAL_LIB_AVAILABLE = true
rescue LoadError
  INTERNAL_LIB_AVAILABLE = false
end

Puppet::Functions.create_function(:'profile_haproxy::mysecretfunction1') do
  dispatch :execute do
    param 'String', :credential_name
    return_type 'String'
  end

  def execute(credential_name)
    if INTERNAL_LIB_AVAILABLE
      CompanyInternal::SecretStore.fetch(credential_name)
    else
      Puppet.warning("company_internal_lib not available, returning fallback for #{credential_name}")
      "secret_fallback_#{credential_name}"
    end
  end
end
