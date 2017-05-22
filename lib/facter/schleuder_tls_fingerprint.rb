Facter.add('schleuder_tls_fingerprint') do
  setcode do
    # check whether schleuder could actually find a cert
    if File.exists?('/etc/schleuder/schleuder.yml') &&
        (config = YAML.load_file('/etc/schleuder/schleuder.yml')) &&
        File.exists?(config['api']['tls_cert_file']) &&
        (fp = Facter::Util::Resolution.exec('schleuder cert fingerprint'))
      fp.split(': ').last
    else
      nil
    end
  end
end
