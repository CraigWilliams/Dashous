require 'feature_helper'

feature 'Create trade request', js: true do
  given(:user) { create :user }
  given(:trade_request) { user.trade_requests.last }

  given!(:geocode) { GeoHelper.define_stub 'New York City, New York', :geolocate_newyork }

  context 'authenticated' do
    background do
      login_as user
    end

    Steps 'I create my first trade request' do
      Given 'I am on the trade requests page' do
        should_be_located '/u/trade_requests'
      end
      When 'I click the create button' do
        click_link '+ Create New'
      end
      Then 'I should see the trade request form' do
        should_see 'New Trade Request'
        should_see 'Name'
        should_see 'Location'
        should_see 'Trade Type'
        should_see 'Percentage Profit'
        should_see 'Accepted Currency'
        should_be_located '/u/trade_requests/new'
      end
      When 'I click save' do
        click_button 'Save'
      end
      Then 'I should see validation errors' do
        should_see 'New Trade Request'
        should_see "Name can't be blank"
        should_see "Location can't be blank"
        should_see "Profit can't be blank"
      end
      When 'I fill out the form' do
        fill_in :trade_request_name, with: 'Best Trade Ever'
        fill_in :trade_request_location, with: 'New York City, New York'
        select "I am Buying Dash", from: "trade_request_kind"
        select "EUR", from: "trade_request_currency"
        fill_in :trade_request_profit, with: 'foo'
      end
      And 'I click save' do
        click_button 'Save'
      end
      Then 'I should see validation errors' do
        should_see "Profit must be a number"
      end
      When 'I fill out the form' do
        fill_in :trade_request_profit, with: '2.5'
      end
      And 'I click save' do
        click_button 'Save'
      end
      Then 'I should be on the list view' do
        should_see '+ Create New'
      end
      And 'the record should be created with correct data' do
        expect(trade_request.name).to eq 'Best Trade Ever'
        expect(trade_request.kind).to eq 'buy'
        expect(trade_request.profit).to eq '2.5'
        expect(trade_request.location).to eq 'New York City, New York'
        expect(trade_request.longitude).to eq -74.0059413
        expect(trade_request.latitude).to eq 40.7127837
        expect(trade_request.slug).to eq 'best_trade_ever'
        expect(trade_request.active).to eq true
        expect(trade_request.currency).to eq 'eur'
      end
    end

    describe 'correctly setting default active states based on limit of 2 active trade requests' do

      context 'I already have one active trade requests' do
        let!(:trade_request_1) { create :trade_request, user: user }

        Steps 'I create a trade request' do
          When 'I click the create button' do
            click_link '+ Create New'
          end
          When 'I fill out the form' do
            fill_in :trade_request_name, with: 'Best Trade Ever'
            fill_in :trade_request_location, with: 'New York City, New York'
            select "I am Buying Dash", from: "trade_request_kind"
            fill_in :trade_request_profit, with: '2.5'
          end
          And 'I click save' do
            click_button 'Save'
          end
          Then 'I should be on the list view' do
            should_see '+ Create New'
          end
          And 'the record should be created with correct data' do
            expect(trade_request.name).to eq 'Best Trade Ever'
            expect(trade_request.active).to eq true
          end
        end
      end

      context 'I already have two active trade requests' do
        let!(:trade_request_1) { create :trade_request, user: user }
        let!(:trade_request_2) { create :trade_request, user: user }

        Steps 'I create a trade request' do
          When 'I click the create button' do
            click_link '+ Create New'
          end
          When 'I fill out the form' do
            fill_in :trade_request_name, with: 'Best Trade Ever'
            fill_in :trade_request_location, with: 'New York City, New York'
            select "I am Buying Dash", from: "trade_request_kind"
            fill_in :trade_request_profit, with: '2.5'
          end
          And 'I click save' do
            click_button 'Save'
          end
          Then 'I should be on the list view' do
            should_see '+ Create New'
          end
          And 'the record should be created with correct data' do
            expect(trade_request.name).to eq 'Best Trade Ever'
            expect(trade_request.active).to eq false
          end
        end
      end

      context 'I already have two active trade requests and two inactive' do
        let!(:trade_request_1) { create :trade_request, user: user }
        let!(:trade_request_2) { create :trade_request, user: user }
        let!(:trade_request_3) { create :trade_request, user: user, active: false }
        let!(:trade_request_4) { create :trade_request, user: user, active: false }

        Steps 'I create a trade request' do
          When 'I click the create button' do
            click_link '+ Create New'
          end
          When 'I fill out the form' do
            fill_in :trade_request_name, with: 'Best Trade Ever'
            fill_in :trade_request_location, with: 'New York City, New York'
            select "I am Buying Dash", from: "trade_request_kind"
            fill_in :trade_request_profit, with: '2.5'
          end
          And 'I click save' do
            click_button 'Save'
          end
          Then 'I should be on the list view' do
            should_see '+ Create New'
          end
          And 'the record should be created with correct data' do
            expect(trade_request.name).to eq 'Best Trade Ever'
            expect(trade_request.active).to eq false
          end
        end
      end
    end
  end
end
