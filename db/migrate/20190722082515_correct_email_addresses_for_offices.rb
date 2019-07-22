require 'csv'
class CorrectEmailAddressesForOffices < ActiveRecord::Migration[5.2]
  class Office < ::ActiveRecord::Base
    self.table_name = :offices
  end

  def change
    csv = <<CSV
office_code,office_name,office_telephone,office_email
13,Midlands (West) ET,0121 600 7780,midlandswestet@justice.gov.uk
14,Bristol,01224 593 137,bristolet@justice.gov.uk
16,Wales,029 2067 8100,cardiffet@justice.gov.uk
18,Leeds,0113 245 9741,leedset@justice.gov.uk
22,London Central,020 7273 8603,londoncentralet@justice.gov.uk
23,London South,020 8667 9131,londonsouthet@justice.gov.uk
24,Manchester,0161 833 6100,manchesteret@justice.gov.uk
25,Newcastle,0191 260 6900,newcastleet@justice.gov.uk
26,Midlands (East) ET,0115 947 5701,midlandseastet@justice.gov.uk
32,East London,020 7538 6161,eastlondon@justice.gov.uk
33,Watford,01923 281 750,watfordet@justice.gov.uk
41,Glasgow,0141 204 0730,glasgowet@justice.gov.uk
99,Default,0161 833 5113,employmentJurisdictionalSupportTeamInbox@justice.gov.uk
CSV
    offices = CSV.parse(csv, headers: true)
    offices.each do |office_row|
      puts office_row.to_s
      office = Office.where(code: office_row.fetch('office_code')).first
      next if office.nil?
      office.update name: office_row.fetch('office_name'),
                    telephone: office_row.fetch('office_telephone'),
                    email: office_row.fetch('office_email')
    end


  end
end
