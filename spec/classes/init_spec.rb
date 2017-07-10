require 'spec_helper'

describe 'schleuder' do
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
  context 'default' do
    it { is_expected.to compile.with_all_deps }
  end

end
