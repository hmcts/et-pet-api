FactoryBot.define do
  factory :claim_claimant do
    primary false
    claimant { build(:claimant, :example_data) }

    trait :example_data do
      claimant { build(:claimant, :example_data) }
    end

    trait :tamara_swift do
      claimant { build(:claimant, :tamara_swift) }
    end

    trait :diana_flatley do
      claimant { build(:claimant, :diana_flatley) }
    end

    trait :mariana_mccullough do
      claimant { build(:claimant, :mariana_mccullough) }
    end

    trait :eden_upton do
      claimant { build(:claimant, :eden_upton) }
    end

    trait :annie_schulist do
      claimant { build(:claimant, :annie_schulist) }
    end

    trait :thad_johns do
      claimant { build(:claimant, :thad_johns) }
    end

    trait :coleman_kreiger do
      claimant { build(:claimant, :coleman_kreiger) }
    end

    trait :jenson_deckow do
      claimant { build(:claimant, :jenson_deckow) }
    end

    trait :darien_bahringer do
      claimant { build(:claimant, :darien_bahringer) }
    end

    trait :eulalia_hammes do
      claimant { build(:claimant, :eulalia_hammes) }
    end

    trait :mr_na_o_malley do
      claimant { build(:claimant, :mr_na_o_malley) }
    end
  end
end
