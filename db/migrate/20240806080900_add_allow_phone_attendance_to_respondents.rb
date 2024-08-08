class AddAllowPhoneAttendanceToRespondents < ActiveRecord::Migration[7.1]
  def change
    add_column :respondents, :allow_phone_attendance, :boolean
  end
end
