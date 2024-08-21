class AddPhoneAndVideoAttendanceToRepresentatives < ActiveRecord::Migration[7.1]
  def change
    add_column :representatives, :allow_video_attendance, :boolean
    add_column :representatives, :allow_phone_attendance, :boolean
  end
end
