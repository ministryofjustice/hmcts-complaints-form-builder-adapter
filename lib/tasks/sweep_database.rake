namespace :sweep do
  desc 'purges database of any record that is 7 days old or older.'
  task :attachments => :environment do
    Usecase::SweepDatabase.new(attachments_gateway: Gateway::Attachments.new).call(7.days.ago)
  end
end
