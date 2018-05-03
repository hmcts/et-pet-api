module EtApi
  module Test
    module NormalizeXmlHashHelper
      def normalize_xml_hash(xml_hash)
        h = xml_hash.inject({}) do |acc, (k, v) |
          acc[k.to_s.underscore.to_sym] = v
          acc
        end
        h[:claimants].map! {|c| normalize_xml_claimant(c)}
        h[:respondents].map! {|r| normalize_xml_respondent(r)}
        h
      end

      def normalize_xml_claimant(claimant_hash)
        {
          title: claimant_hash['Title'],
          first_name: claimant_hash['Forename'],
          last_name: claimant_hash['Surname'],
          address: normalize_xml_address(claimant_hash['Address']),
          address_telephone_number: claimant_hash['OfficeNumber'],
          mobile_number: claimant_hash['AltPhoneNumber'],
          email_address: claimant_hash['Email'],
          contact_preference: claimant_hash['PreferredContactMethod'],
          gender: claimant_hash['Sex'],
          date_of_birth: Date.parse(claimant_hash['DateOfBirth'])
        }
      end

      def normalize_xml_respondent(r)
        {
          name: r['Name'],
          address: normalize_xml_address(r['Address']),
          work_address: normalize_xml_address(r['AltAddress']),
          work_address_telephone_number: r['OfficeNumber'],
          address_telephone_number: r['PhoneNumber'],
          acas_number: r['Acas']['Number'],
          alt_phone_number: r['AltPhoneNumber']
        }
      end

      def normalize_xml_address(address_hash)
        {
          building: address_hash['Line'],
          street: address_hash['Street'],
          locality: address_hash['Town'],
          county: address_hash['County'],
          post_code: address_hash['Postcode']
        }
      end
    end
  end
end
RSpec.configure do |c|
  c.include ::EtApi::Test::NormalizeXmlHashHelper
end
