FactoryBot.define do
  factory :notification do
    recipient_id {1}
    user_id {1}
    action {"approved"}
    notifiable_type {"Task"}
    notifiable_id {1}
  end
end