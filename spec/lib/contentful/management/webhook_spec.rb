require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe Webhook do
      let(:token) { '<ACCESS_TOKEN>' }
      let(:space_id) { 'bfsvtul0c41g' }
      let(:webhook_id) { '0rK8ZNEOWLgYnO5gaah2pp' }
      let!(:client) { Client.new(token) }

      subject { client.webhooks }

      describe '.all' do
        it 'class method also works' do
          vcr('webhook/all') { expect(Contentful::Management::Webhook.all(client, space_id)).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('webhook/all') { expect(subject.all(space_id)).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::Webhook object' do
          vcr('webhook/all') { expect(subject.all(space_id).first).to be_kind_of Contentful::Management::Webhook }
        end
      end

      describe '.find' do
        it 'class method also works' do
          vcr('webhook/find') { expect(Contentful::Management::Webhook.find(client, space_id, webhook_id)).to be_kind_of Contentful::Management::Webhook }
        end
        it 'returns a Contentful::Management::Webhook' do
          vcr('webhook/find') { expect(subject.find(space_id, webhook_id)).to be_kind_of Contentful::Management::Webhook }
        end
        it 'returns webhook for a given key' do
          vcr('webhook/find') do
            webhook = subject.find(space_id, webhook_id)
            expect(webhook.id).to eql webhook_id
          end
        end
        it 'returns an error when content_type does not exists' do
          vcr('webhook/find_not_found') do
            result = subject.find(space_id, 'not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
      end

      describe '.create' do
        it 'builds Contentful::Management::Webhook object' do
          vcr('webhook/create') do
            webhook = subject.create(space_id, id: 'test_webhook', url: 'https://www.example3.com')
            expect(webhook).to be_kind_of Contentful::Management::Webhook
            expect(webhook.url).to eq 'https://www.example3.com'
          end
        end
        it 'return error if url is already taken' do
          vcr('webhook/create_with_taken_url') do
            webhook = subject.create(space_id, id: 'taken_webhook', url: 'https://www.example3.com')
            expect(webhook).to be_kind_of Contentful::Management::Error
          end
        end
        it 'can create webhooks with name and custom headers' do
          vcr('webhook/create_with_name_and_headers') do
            webhook = subject.create(
              'zjvxmotjud5s',
              name: 'some_webhook',
              id: 'some_id',
              url: 'https://www.example2.com',
              headers: [
                {
                  key: 'MyHeader',
                  value: 'foobar'
                }
              ]
            )

            expect(webhook.name).to eq('some_webhook')
            expect(webhook.id).to eq('some_id')
            expect(webhook.headers.first).to eq({'key' => 'MyHeader', 'value' => 'foobar'})
          end
        end
        it 'can create webhooks with specific topics' do
          vcr('webhook/topics') do
            webhook = subject.create(
              'zjvxmotjud5s',
              name: 'test_topics',
              url: 'https://www.example3.com',
              topics: [
                'Entry.save',
                'Entry.publish',
                'ContentType.*'
              ]
            )

            expect(webhook.topics.size).to eq 3
            expect(webhook.topics).to eq ['Entry.save', 'Entry.publish', 'ContentType.*']
          end
        end
      end

      describe '#update' do
        it 'all parameters' do
          vcr('webhook/update') do
            webhook = subject.find(space_id, 'test_webhook')
            updated_webhook = webhook.update(url: 'https://www.example5.com',
                                             httpBasicUsername: 'test_username',
                                             httpBasicPassword: 'test_password')
            expect(updated_webhook).to be_kind_of Contentful::Management::Webhook
            expect(updated_webhook.url).to eq 'https://www.example5.com'
            expect(updated_webhook.http_basic_username).to eq 'test_username'
          end
        end
      end

      describe '#destroy' do
        it 'returns true' do
          vcr('webhook/destroy') do
            webhook = subject.find(space_id, 'test_webhook')
            result = webhook.destroy
            expect(result).to eq true
          end
        end
      end
    end
  end
end
