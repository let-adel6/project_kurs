require 'telegram/bot'

class BotsController < ApplicationController
  def create
    head :ok
  end

  def client
    message = params[:message]
    article = params[:article]
    category = params[:category]
    user = params[:user]
    @telegram_bot_token = '6762288102:AAHnj8LT84iJSn0JssWwi6FBD-1B3kscngo'
    Telegram::Bot::Client.run(@telegram_bot_token) do |bot|
      chat_ids = Subscriber.pluck(:chat_id)
      chat_ids.each do |chat_id|
          if category.present?
              bot.api.send_message(chat_id: chat_id, text: "#{message}")
              redirect_to category_path(category)
          else
              bot.api.send_message(chat_id: chat_id, text: "#{message}, Автор: #{user}\nСсылка: #{article_url(article)}")
              redirect_to article_path(article)
          end
        end
      end
    end
end