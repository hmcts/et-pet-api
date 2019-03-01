require_relative './base.rb'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class TypeAndDetailsSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          # Note that at present, the test framework suggests only one claim type but ET1 can have many selected - this code will need to expect
          # various fields to be Yes/No based on a list of claim types in the future.
          # Also, alot of values have hard coded true or falses as I expect these to come from factories but at the time of writing this there are
          # no values for them - so Im not going mad - calling a method that returns "yes" or "no" - knowing it will always return "no" as I am passing it false
          # it simply to allow for the value to be added at some point soon.
          def has_contents_for?(claim:)
            expected_values = {
                unfairly_dismissed: claim.is_unfair_dismissal,
                discriminated: claim.discrimination_claims.present?,
                discriminated_age: claim.discrimination_claims.include?('age'),
                discriminated_race: claim.discrimination_claims.include?('race'),
                discriminated_gender_reassignment: claim.discrimination_claims.include?('gender_reassignment'),
                discriminated_disability: claim.discrimination_claims.include?('disability'),
                discriminated_pregnancy: claim.discrimination_claims.include?('pregnancy_or_maternity'),
                discriminated_marriage: claim.discrimination_claims.include?('marriage_or_civil_partnership'),
                discriminated_sexual_orientation: claim.discrimination_claims.include?('sexual_orientation'),
                discriminated_sex: claim.discrimination_claims.include?('sex_including_equal_pay'),
                discriminated_religion: claim.discrimination_claims.include?('religion_or_belief'),
                claiming_redundancy_payment: claim.pay_claims.include?('redundancy'),
                owed: owed_anything?(claim),
                owed_notice_pay: claim.pay_claims.include?('pay_notice'),
                owed_holiday_pay: claim.pay_claims.include?('pay_holiday'),
                owed_arrears_of_pay: claim.pay_claims.include?('pay_arrears'),
                owed_other_payments: claim.pay_claims.include?('pay_other'),
                other_type_of_claim: claim.other_claim_details.present?,
                other_type_of_claim_details: claim.other_claim_details || '',
                claim_description: claim.description
            }
            expect(mapped_field_values).to include expected_values
          end

          private

          def owed_anything?(claim)
            ['notice', 'holiday', 'arrears', 'other'].any? { |type| claim.pay_claims.include?(type) }
          end
        end
      end
    end
  end
end
