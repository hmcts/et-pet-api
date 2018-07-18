# This migration comes from et_acas_api (originally 20180718151913)
class CreateEtAcasApiDownloadLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :et_acas_api_download_logs do |t|
      t.string :user_id
      t.string :certificate_number
      t.string :method_of_issue
      t.string :message
      t.string :description

      t.timestamps
    end
  end
end
