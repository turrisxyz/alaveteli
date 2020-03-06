require 'spec_helper'

RSpec.describe PublicTokensController, type: :controller do

  let(:ability) { Object.new.extend(CanCan::Ability) }
  let(:info_request) { FactoryBot.build(:info_request) }

  before do
    allow(controller).to receive(:current_ability).and_return(ability)
  end

  describe 'GET #show' do
    context 'when public token is valid and Info Request is readable' do
      before do
        allow(InfoRequest).to receive(:find_by!).and_return(info_request)
        ability.can :read, info_request
      end

      it 'finds Info Request by public token' do
        expect(InfoRequest).to receive(:find_by!).with(public_token: 'TOKEN')
        get :show, params: { id: 'TOKEN' }
      end

      it 'assigns info_request' do
        get :show, params: { id: 'TOKEN' }
        expect(assigns(:info_request)).to eq info_request
      end

      it 'assigns public_token_view' do
        get :show, params: { id: 'TOKEN' }
        expect(assigns(:public_token_view)).to eq true
      end

      it 'adds noindex header' do
        get :show, params: { id: 'TOKEN' }
        expect(response.headers['X-Robots-Tag']).to eq 'noindex'
      end

      it 'returns http success' do
        get :show, params: { id: 'TOKEN' }
        expect(response).to be_successful
      end

      it 'returns request show template' do
        get :show, params: { id: 'TOKEN' }
        expect(response.body).to render_template('request/show')
      end
    end

    context 'when public token is valid and Info Request is unreadable' do
      before do
        allow(InfoRequest).to receive(:find_by!).and_return(info_request)
        ability.cannot :read, info_request
      end

      it 'finds Info Request by public token' do
        expect(InfoRequest).to receive(:find_by!).with(public_token: 'TOKEN')
        get :show, params: { id: 'TOKEN' }
      end

      it 'assigns info_request' do
        get :show, params: { id: 'TOKEN' }
        expect(assigns(:info_request)).to eq info_request
      end

      it 'renders hidden request template' do
        get :show, params: { id: 'TOKEN' }
        expect(response).to render_template('request/hidden')
      end
    end

    context 'when public token is invalid' do
      it 'raises not found error' do
        expect { get :show, params: { id: 'NOT-FOUND' } }.to(
          raise_error(ActiveRecord::RecordNotFound)
        )
      end
    end
  end

end