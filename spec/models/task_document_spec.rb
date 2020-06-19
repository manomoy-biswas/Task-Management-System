# require 'rails_helper'

# RSpec.describe TaskDocument, type: :model do
#   let (:user1) {create(:employee)}
#   let (:user2) {create(:hr)}
#   let (:category1) {create(:category)}
#   let (:task1) { create(:assigned_task1, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user1.id)}
#   let (:task2) { create(:assigned_task2, task_category: category1.id, assign_task_to: user2.id, priority: "Medium", assign_task_by: user1.id, approved: true)}
#   context "Association tests:" do
#     it { is_expected.to belong_to(:task)}
#   end
#   let (:doc) { create(:task_document) }
#   it "check uploads" do
#     expect(doc.document).to eq 'myfile.pdf'
#   end
# end
