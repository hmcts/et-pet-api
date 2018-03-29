require 'csv'
grouped = CSV.read('db/offices.csv', headers: true).group_by {|r| r['office_code']}
office_cache = Office.where("code in(?)", grouped.keys.map(&:to_i)).includes(:post_codes).inject({}) do |acc, office|
  acc[office.code] = office
  acc
end
grouped.each_pair do |office_code, rows|
  office = office_cache.fetch(office_code.to_i) do
    Office.create code: rows.first.fetch('office_code').to_i,
      name: rows.first.fetch('office_name'),
      address: rows.first.fetch('office_address'),
      telephone: rows.first.fetch('office_telephone'),
      email: rows.first.fetch('office_email'),
      is_default: rows.first.fetch('is_default') == '1',
      tribunal_type: rows.first.fetch('tribunalType')
  end
  existing_post_codes = office.post_codes.map(&:postcode)
  rows.each do |row|
    office.post_codes.build(postcode: row.fetch('postcode')) unless existing_post_codes.include?(row.fetch('postcode'))
  end
  office.save
end