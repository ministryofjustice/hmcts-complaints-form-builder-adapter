require 'rails_helper'

describe HealthController do
  describe 'GET #show' do
    before do
      get :show
    end

    it 'returns 200 OK' do
      expect(response.status).to eq(200)
    end

    it 'returns the text "healthy"' do
      expect(response.body).to eq('healthy')
    end
  end
end
