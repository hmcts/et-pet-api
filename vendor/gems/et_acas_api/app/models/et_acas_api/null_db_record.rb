require 'nulldb'
module EtAcasApi
  class NullDbRecord < ::ActiveRecord::Base
    establish_connection adapter: :nulldb,
                         schema: File.absolute_path(File.join('..', '..', '..', 'config', 'nulldb_schema.rb'), __dir__)

  end
end
