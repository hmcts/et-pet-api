class AddAllowVideoAttendanceToRespondents < ActiveRecord::Migration[6.0]
  def change
    add_column :respondents, :allow_video_attendance, :boolean
  end
end
