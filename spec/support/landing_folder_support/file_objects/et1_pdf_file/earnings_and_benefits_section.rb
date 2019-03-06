require_relative './base.rb'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class EarningsAndBenefitsSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(employment:)
            employment.present? ? has_contents_for_employment?(employment) : has_contents_for_no_employment?
          end

          private

          def has_contents_for_employment?(employment)
            expected_values = {
                average_weekly_hours: employment['average_hours_worked_per_week']&.to_s,
                pay_before_tax: {
                    'amount': employment['gross_pay']&.to_s,
                    'period': employment['gross_pay_period_type']
                },
                pay_after_tax: {
                    'amount': employment['net_pay']&.to_s,
                    'period': employment['net_pay_period_type']
                },
                paid_for_notice_period: employment['worked_notice_period_or_paid_in_lieu'],
                notice_period: {
                    weeks: weekly_notice_period(employment),
                    months: monthly_notice_period(employment)
                },
                employers_pension_scheme: employment['enrolled_in_pension_scheme'],
                benefits: employment['benefit_details']
            }
            expect(mapped_field_values).to include expected_values
          end

          def has_contents_for_no_employment?
            expected_values = {
                average_weekly_hours: nil,
                pay_before_tax: {
                    'amount': nil,
                    'period': nil
                },
                paid_for_notice_period: nil,
                notice_period: {
                    weeks: nil,
                    months: nil
                },
                employers_pension_scheme: nil,
                benefits: nil
            }
            expect(mapped_field_values).to include expected_values
          end

          def weekly_notice_period(employment)
            return '' if employment['notice_pay_period_type']&.to_sym != :weekly
            employment['notice_pay_period_count'].to_s
          end

          def monthly_notice_period(employment)
            return '' if employment['notice_pay_period_type']&.to_sym != :monthly
            employment['notice_pay_period_count'].to_s
          end
        end
      end
    end
  end
end
