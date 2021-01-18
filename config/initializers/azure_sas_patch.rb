require 'azure/storage/common/core/auth/shared_access_signature_generator'
# We all hate patches - I know !!
#
# But, at the moment, active storage can only work with azure-storage gem 0.15.0.preview (it has been in this state for over a year !!)
# I have put in a PR for this change into azure-storage-ruby gem - but we will see if it gets merged.  In the mean time, we must put
# up with this patch to allow us to parse xml data from both azure and azurite (test environments).
#
# The only change is the addition of ', nil, nil, Nokogiri::XML::ParseOptions::DEFAULT_XML | Nokogiri::XML::ParseOptions::NOBLANKS' to the Nokogiri.Slop call
# which does at it says on the tin - if we have blank nodes containing just whitespace (\n was the culprit)
#
# So, to prevent you going mad when you upgrade for a different reason, this patch will deliberately fail, forcing you to come back to this file
# and read this comment - then deciding if the patch is still needed.
#

module Azure
  module Storage
    module Common
      module Core
        module Auth
          class SharedAccessSignature
            private

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
