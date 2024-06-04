class AddExtraAttendanceFieldToClaimants < ActiveRecord::Migration[7.1]
  def change
    add_column :claimants, :allow_phone_attendance, :boolean, default: false
    add_column :claimants, :no_phone_or_video_reason, :text
  end
end
