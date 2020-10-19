class RepopulateMissingEt3RtfFilesFrom1409 < ActiveRecord::Migration[6.0]
  class Command < ActiveRecord::Base
    self.table_name = :commands
  end

  class Response < ActiveRecord::Base
    self.table_name = :responses
    has_many :response_uploaded_files, foreign_key: :response_id
    has_many :uploaded_files, through: :response_uploaded_files
  end

  def up
    Command.where('request_body LIKE ? AND created_at > ? AND created_at < ?', '%BuildResponse%', DateTime.parse('14/9/2020 00:00:00'), DateTime.parse('14/9/2020 23:59:59')).all.each do |command|
      build_response_command = JSON.parse(command.request_body).with_indifferent_access['data'].detect {|c| c['command'] == 'BuildResponse'}
      reference = JSON.parse(command.response_body).with_indifferent_access.dig('meta', 'BuildResponse', 'reference')
      response = Response.where(reference: reference).first
      next if build_response_command.dig('data', 'additional_information_key').nil? || response.nil? || response.uploaded_files.where('filename LIKE ?', '%.rtf').count > 0

      announce "Adding new RTF file for response id #{response.id} reference #{response.reference}"
      input_data = build_response_command['data']
      key = input_data.delete('additional_information_key')
      uploaded_file = response.uploaded_files.create(input_data.merge(import_file_url: nil, import_from_key: key))
      begin
        UploadedFileImportService.import_from_key(key, into: uploaded_file)
      rescue ActiveStorage::FileNotFoundError
        announce "Attempt to fetch blob with key #{key} failed - file not found"
        uploaded_file.destroy
      end
      response.save(touch:false)
      announce "Added new RTF file for claim id #{claim.id} reference #{claim.reference}"
    end
  end

  def down
    # Do nothing
  end
end
