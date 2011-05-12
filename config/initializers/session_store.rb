# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_helloworld_session',
  :secret      => '6de937331bf913a91bc9cf5b674551d782328193473644b851908af58c1255dba33884b6f480ef4fa158950b0dad2ffa28e51c6fb7b2f3f87cc69b84debb222f',
  :namespace   => 'sessions',
  :expire_after => 180.minutes.to_i,
  :memcache_server => ['mc2.ec2.northscale.net'],
}

require 'action_controller/session/dalli_store'
ActionController::Base.session_store = :dalli_store
# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
