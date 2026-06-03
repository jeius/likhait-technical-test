FactoryBot.define do
  factory :expense do
    description { "MyString" }
    amount { "9.99" }
    date { Date.today }
    category { nil }
    payer_name { "MyString" }
  end
end
