class CreateAcasDownloadLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :acas_download_logs do |t|
      t.string :user_id
      t.string :certificate_number
      t.string :method_of_issue
      t.string :message
      t.string :description

      t.timestamps
    end
  end
end
