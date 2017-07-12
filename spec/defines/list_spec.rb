require 'spec_helper'

describe 'schleuder::list', :type => 'define' do
  let(:facts){
    {
      :operatingsystem => 'CentOS',
      :puppetversion   => ENV['PUPPET_VERSION'].nil? ? '5.0.0' : ENV['PUPPET_VERSION'],
      :concat_basedir  => '/tmp',
    }
  }
  let(:pre_condition){
    'Exec{ path => "/tmp" }'
  }
  let(:title){ 'somelist@example.com' }
  let(:params){ {
    :admin => 'admin@example.com'
  } }
  context 'default' do
    it { is_expected.to compile.with_all_deps }
  end

end
