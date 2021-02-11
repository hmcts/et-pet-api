require 'azure/storage/common/core/auth/shared_access_signature_generator'
# We all hate patches - I know !!
#
# But, at the moment, active storage will not generate valid SAS signatures when connected to azurite simulator.
# The bug occurs as the path contains the account name which is valid when using the simulator (as you cannot
# use subdomains like normal azure blob storage) - however, the signature generator adds the account name
# to the body of the text that it generates the signature for.
#
# So, to prevent you going mad when you upgrade for a different reason, this patch will deliberately fail, forcing you to come back to this file
# and read this comment - then deciding if the patch is still needed.  If it is, simply update the version checker in the code below
#

if Azure::Storage::Common::Version.to_s != '2.0.2'
  raise "The patch in #{__FILE__} is only compatible with azure-storage-common version 2.0.2 - please check if this is still required by running tests without it"
end
module Azure
  module Storage
    module Common
      module Core
        module Auth
          class SharedAccessSignature
            private

            # This patched version of canonicalized_resource will remove duplicate account names in the path
            def canonicalized_resource(service_type, path)
              optional_account_name = if path.start_with?("/#{account_name}/")
                                        ''
                                      else
                                        "/#{account_name}"
                                      end
              "/#{service_type}#{optional_account_name}#{path.start_with?('/') ? '' : '/'}#{path}"
            end
          end
        end
      end
    end
  end
end
