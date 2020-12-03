class RepairUploadedFile325810 < ActiveRecord::Migration[6.0]
  class UploadedFile < ActiveRecord::Base
    self.table_name = :uploaded_files
  end

  def up
    uploaded_file = UploadedFile.where('created_at > ? AND created_at < ?', DateTime.parse('22/9/2020 00:00:00'), DateTime.parse('23/9/2020')).find_by(id: 325810)
    return if uploaded_file.nil?

    uploaded_file.import_file_url = URI.parse(uploaded_file.import_file_url).tap {|u| u.query = nil }.to_s
    UploadedFileImportService.import_file_url(uploaded_file.import_file_url, into: uploaded_file)
    uploaded_file.save
  end

  def down
    # Do nothing
  end
end
