require 'rails_helper'

RSpec.describe 'Api::Account', type: :request do
  let(:user) { create(:user, password: 'password123') }

  before { sign_in user }

  describe 'PATCH /api/account' do
    it 'updates the name without requiring a password' do
      patch '/api/account', params: { name: 'Sylvain' }

      expect(response).to have_http_status(:ok)
      expect(user.reload.name).to eq('Sylvain')
    end

    it 'updates the email when the current password is correct' do
      patch '/api/account', params: { name: 'Sylvain', email: 'new@example.com', current_password: 'password123' }

      expect(response).to have_http_status(:ok)
      user.reload
      expect(user.name).to eq('Sylvain')
      expect(user.unconfirmed_email).to eq('new@example.com')
    end

    it 'rejects an email change with the wrong current password' do
      patch '/api/account', params: { email: 'new@example.com', current_password: 'wrongpassword' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(user.reload.unconfirmed_email).to be_nil
    end
  end
end
