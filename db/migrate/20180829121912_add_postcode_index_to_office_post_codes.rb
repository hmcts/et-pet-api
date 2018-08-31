class AddPostcodeIndexToOfficePostCodes < ActiveRecord::Migration[5.2]
  def change
    add_index :office_post_codes, :postcode, unique: true
  end
end
