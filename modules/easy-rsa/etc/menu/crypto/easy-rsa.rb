class OnBoard
  MENU_ROOT.add_path('/crypto', {
    :name => 'Cryptography',
    :n    => 3
  })
end

class OnBoard
  MENU_ROOT.add_path('/crypto/external', {
    :href => '/crypto/easy-rsa/external',
    :name => 'External/Imported Certificates and Keys',
    #:desc => 'Public Key Infrastructures and own Certificate Authorities',
    :n    => 0
  })
end

class OnBoard
  MENU_ROOT.add_path('/crypto/easy-rsa', {
    :href => '/crypto/easy-rsa',
    :name => 'Own Certificate Authorities / PKIs',
    #:desc => 'Public Key Infrastructures and own Certificate Authorities',
    :n    => 2
  })
end
