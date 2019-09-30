namespace :sweep do
  desc 'purges database of any record that is 7 days old or older.'
  task attachments: :environment do
    week_ago = 7.days.ago
    num_destroyed = Usecase::SweepDatabase.new(attachments_gateway: Gateway::Attachments.new).call(week_ago)
    puts "Deleted #{num_destroyed} old attachments from the database older than: #{week_ago}"
  end
end
