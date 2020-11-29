require 'spec_helper'

describe 'schleuder::web' do
  let(:facts){
    {
      :operatingsystem => 'CentOS',
      :operatingsystemmajrelease => '7',
      :concat_basedir  => '/tmp',
    }
  }
  let(:params) {
    {
      :api_key => 'aaa',
      :api_tls_fingerprint => '123',
    }
  }
  let(:pre_condition){
    'Exec{ path => "/tmp" }'
  }
  context 'default' do
    it { is_expected.to compile.with_all_deps }
  end

end
