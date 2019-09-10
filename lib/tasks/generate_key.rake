namespace :auth do
  desc 'run locally to generate a key for use as the shared secret'
  task :generate_key do
    puts 'Use this key by setting it as a the value for DEVELOPMENT_JWE_SHARED_KEY or JWE_SHARED_KEY env vars'
    puts
    puts SecureRandom.hex(8)
  end
end
