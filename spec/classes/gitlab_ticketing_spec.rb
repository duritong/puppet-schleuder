require 'spec_helper'

describe 'schleuder::gitlab_ticketing' do
  let(:facts){
    {
      :operatingsystem => 'CentOS',
      :puppetversion   => ENV['PUPPET_VERSION'].nil? ? '5.0.0' : ENV['PUPPET_VERSION'],
      :concat_basedir  => '/tmp',
    }
  }
  let(:pre_condition){
    'Exec{ path => "/tmp" }
    include schleuder'
  }
  context 'default' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_file('/etc/schleuder/gitlab.yml').with_ensure('absent') }
  end

  context 'with params' do
    let(:params) {
      {
        :subject_filters => [
  "Encrypt certificate expiration notice",
  'Mailman.* post from .* requires approval',
  'Uncaught bounce notification',
        ],
        :lists => {
          'schleuder@example.com' => {
            'project' => 'tickets',
            'namespace' => 'group',
            'ticket_prefix' => 'tg',
            'gitlab' => {
              'endpoint' => 'https://gitlab.example.com/api/v4',
              'token' => 'hababa',
            }
          }
        }
      }
    }
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_file('/etc/schleuder/gitlab.yml').with_content("---
subject_filters:
  - 'Encrypt certificate expiration notice'
  - 'Mailman.* post from .* requires approval'
  - 'Uncaught bounce notification'

sender_filters: []

lists:
  'schleuder@example.com':
    project: 'tickets'
    namespace: 'group'
    ticket_prefix: 'tg'
    gitlab:
      endpoint: 'https://gitlab.example.com/api/v4'
      token: 'hababa'
") }
  end
end
