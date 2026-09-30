class AddAcasIssueAndReceiptDatesToRespondents < ActiveRecord::Migration[8.1]
  def change
    add_column :respondents, :acas_issue_date, :date
    add_column :respondents, :acas_receipt_date, :date
  end
end
