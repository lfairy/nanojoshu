#!/usr/bin/env ruby

require 'active_support/core_ext/file'
require 'json'
require 'twitter'

class State
  DATA_PATH = File.join(File.expand_path(File.dirname(__FILE__)), 'state.json')
  def self.DATA_PATH
    DATA_PATH
  end

  def initialize(followers)
    @followers = followers
  end

  def self.load
    begin
      data = JSON.parse(File.read(DATA_PATH))
      State.new(data['followers'])
    rescue Errno::ENOENT
      puts "Could not find data file; using default state!"
      State.new({})
    end
  end

  def update(current_followers)
    current_followers = Hash[
      current_followers.map { |user| [
        # In JSON, hash keys must be strings not integers
        user.id.to_s,
        {
          'screen_name' => user.screen_name,
          'name' => user.name
        }
      ]}
    ]
    unfollowers = @followers.clone.delete_if { |id| current_followers.has_key? id }
    @followers = current_followers
    unfollowers
  end

  def dump
    data = JSON.pretty_generate({ 'followers' => @followers })
    File.atomic_write(DATA_PATH) { |f| f.write(data) }
  end
end

def main
  puts "Loading state from #{State::DATA_PATH}"
  state = State.load

  puts "Connecting to Twitter"
  target_user = ENV['TARGET_USER']
  client = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end

  puts "Querying list of followers"
  followers = []
  followers_coll = client.followers(target_user)
  begin
    followers_coll.each { |user| followers << user }
  rescue Twitter::Error::TooManyRequests => error
    puts "Retrying in #{error.rate_limit.reset_in} seconds"
    sleep error.rate_limit.reset_in + 1
    retry
  end
  puts "Found #{followers.length} followers"

  # Compare with previous follower list
  unfollowers = state.update(followers)

  unless unfollowers.empty?
    message = "Heads up! These horrible people had the nerve to unfollow you:"
    unfollowers.sort_by { |id, user| user['screen_name'] }.each do |id, user|
      message << "\n • #{user['name']} (@#{user['screen_name']})"
    end
    puts message
    client.create_direct_message(target_user, message)
  else
    puts "No defectors found 🙃"
  end

  puts "Saving updated state"
  state.dump
end

if __FILE__ == $0
  begin
    STDOUT.sync = true
    main
  rescue
    puts  # Make sure the stack trace is on a separate line
    puts " 🚫 ERROR! 🚫 "
    raise
  end
end
