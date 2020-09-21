class RepopulateMissingRtfFilesFrom1409 < ActiveRecord::Migration[6.0]
  class Command < ActiveRecord::Base
    self.table_name = :commands
  end

  class Claim < ActiveRecord::Base
    self.table_name = :claims
    has_many :claim_uploaded_files, foreign_key: :claim_id
    has_many :uploaded_files, through: :claim_uploaded_files
  end

  def up
    Command.where('request_body LIKE ? AND created_at > ? AND created_at < ?', '%BuildClaimDetailsFile%', DateTime.parse('14/9/2020 00:00:00'), DateTime.parse('14/9/2020 23:59:59')).all.each do |command|
      file_command = JSON.parse(command.request_body).with_indifferent_access['data'].detect {|c| c['command'] == 'BuildClaimDetailsFile'}
      reference = JSON.parse(command.response_body).with_indifferent_access.dig('meta', 'BuildClaim', 'reference')
      claim = Claim.where(reference: reference).first
      next if claim.nil? || claim.uploaded_files.where('filename LIKE ?', '%.rtf').count > 0

      input_data = file_command['data']
      uploaded_file = claim.uploaded_files.create(input_data.merge(import_file_url: input_data.delete('data_url'), import_from_key: input_data.delete('data_from_key')))
      UploadedFileImportService.import_file_url(uploaded_file.import_file_url, into: uploaded_file)
      claim.save(touch:false)
    end
  end

  def down
    # Do nothing
  end
end
