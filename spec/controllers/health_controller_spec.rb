require 'rails_helper'

describe HealthController do
  describe 'GET #show' do
    context 'healthy' do
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

  describe 'GET #readiness' do
    context 'ready' do
      before do
        get :readiness
      end

      it 'returns 200 OK' do
        expect(response.status).to eq(200)
      end

      it 'returns the text "ready"' do
        expect(response.body).to eq('ready')
      end
    end
  end
end
