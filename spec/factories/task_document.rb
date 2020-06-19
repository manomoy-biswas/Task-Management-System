# FactoryBot.define do
#   factory :task_document do
#     task
#     document { Rack::Test::UploadedFile.new('spec/fixtures/myfile/myfile.pdf') }
#     # after :create do |b|
#     #   b.update_column(:avater, "foo/bar/baz.png")
#     # end
#   end
#  end