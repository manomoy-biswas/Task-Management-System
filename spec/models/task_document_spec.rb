require 'rails_helper'

RSpec.describe TaskDocument, type: :model do
  context "Association tests:" do
    it { is_expected.to belong_to(:task)}
  end

end
