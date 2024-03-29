require 'telegram/bot'

@telegram_bot_token = '6762288102:AAHnj8LT84iJSn0JssWwi6FBD-1B3kscngo'
Thread.new do
  Telegram::Bot::Client.run(@telegram_bot_token) do |bot|
    bot.listen do |message|
      case message
      when Telegram::Bot::Types::Message
        chat_id = message.chat.id
        case message.text
        when '/start'
          chatid_user = Subscriber.find_by(chat_id: chat_id)
          if chatid_user.present?
            bot.api.send_message(chat_id: chat_id, text: "Вы уже подписались на бота")
          else
            Subscriber.create(chat_id: chat_id)
            bot.api.send_message(chat_id: chat_id, text: "Добро пожаловать, вы будете получать уведомления о новых постах")
          end
        when '/stop'
          chatid_user = Subscriber.find_by(chat_id: chat_id)
          if chatid_user.present?
            bot.api.send_message(chat_id: chat_id, text: "Вы отписались от оповещений.")
            Subscriber.find_by(chat_id: chat_id)&.destroy
          else
            bot.api.send_message(chat_id: chat_id, text: "Вы еще не подписаны на рассылку бота")
          end
        when '/search_by_title'
          chatid_user = Subscriber.find_by(chat_id: chat_id)
          if chatid_user.present?
            bot.api.send_message(chat_id: chat_id, text: "Введите название статьи:")
            bot.listen do |message|
              case message
              when Telegram::Bot::Types::Message
                if message.text 
                  search_query = message.text.strip
                  articles = Article.where("title LIKE ?", "%#{search_query}%") 
                  if articles.any?
                    response = "Найденные статьи:\n"
                    articles.each_with_index do |article, index|
                      response += "#{index + 1}. #{article.title}\n"
                    end
                    bot.api.send_message(chat_id: chat_id, text: response)
                    bot.api.send_message(chat_id: chat_id, text: "Введите номер статьи, чтобы получить полный текст:")
                    bot.listen do |article_choice_message|
                      case article_choice_message
                      when Telegram::Bot::Types::Message
                        if article_choice_message.text.to_i.to_s == article_choice_message.text && articles[article_choice_message.text.to_i - 1]
                          chosen_article = articles[article_choice_message.text.to_i - 1]
                          bot.api.send_message(chat_id: chat_id, text: chosen_article.body)
                        else
                          bot.api.send_message(chat_id: chat_id, text: "Некорректный выбор статьи. Введите номер из списка.")
                        end
                      end
                      break
                    end
                  else
                    bot.api.send_message(chat_id: chat_id, text: "Статьи с таким названием не найдены.Введите команду еще раз")
                  end
                else
                  bot.api.send_message(chat_id: chat_id, text: "Название статьи не может быть пустым.")
                end
              end
              break
            end
          end
        when '/search_by_author'
          chatid_user = Subscriber.find_by(chat_id: chat_id)
          if chatid_user.present?
            bot.api.send_message(chat_id: chat_id, text: "Введите имя автора:")
            bot.listen do |message|
              case message
              when Telegram::Bot::Types::Message
                if message.text # Убедиться, что сообщение не пустое
                  author_name = message.text.strip
                  user = User.find_by(username: author_name)
                  if user
                    articles = Article.where(user_id: user.id)
                    if articles.any?
                      response = "Статьи автора #{author_name}:\n"
                      articles.each_with_index do |article, index|
                        response += "#{index + 1}. #{article.title}\n"
                      end
                      bot.api.send_message(chat_id: chat_id, text: response)
                      bot.api.send_message(chat_id: chat_id, text: "Введите номер статьи, чтобы получить полный текст:")
                      bot.listen do |article_choice_message|
                        case article_choice_message
                        when Telegram::Bot::Types::Message
                          if article_choice_message.text.to_i.to_s == article_choice_message.text && articles[article_choice_message.text.to_i - 1]
                            chosen_article = articles[article_choice_message.text.to_i - 1]
                            bot.api.send_message(chat_id: chat_id, text: chosen_article.body)
                            break  # Выйти из вложенного цикла bot.listen
                          else
                            bot.api.send_message(chat_id: chat_id, text: "Некорректный выбор статьи. Введите номер из списка.")
                          end
                        end
                      end
                    else
                      bot.api.send_message(chat_id: chat_id, text: "У автора #{author_name} нет статей.")
                    end
                  else
                    bot.api.send_message(chat_id: chat_id, text: "Пользователь с именем #{author_name} не найден.Введите команду еще раз")
                  end
                else
                  bot.api.send_message(chat_id: chat_id, text: "Имя автора не может быть пустым.")
                end
              end
              break
            end
          end
        when '/search_by_category'
          bot.api.send_message(chat_id: chat_id, text: "Введите название категории:")
          bot.listen do |message|
            case message
            when Telegram::Bot::Types::Message
              if message.text # Убедиться, что сообщение не пустое
                category_name = message.text.strip
                category = Category.find_by(name: category_name)
                if category
                  articles = category.articles
                  if articles.any?
                    response = "Статьи в категории '#{category_name}':\n"
                    articles.each_with_index do |article, index|
                      response += "#{index + 1}. #{article.title}\n"
                    end
                    bot.api.send_message(chat_id: chat_id, text: response)
                    bot.api.send_message(chat_id: chat_id, text: "Введите номер статьи, чтобы получить полный текст:")
                    bot.listen do |article_choice_message|
                      case article_choice_message
                      when Telegram::Bot::Types::Message
                        if article_choice_message.text.to_i.to_s == article_choice_message.text && articles[article_choice_message.text.to_i - 1]
                          chosen_article = articles[article_choice_message.text.to_i - 1]
                          bot.api.send_message(chat_id: chat_id, text: chosen_article.body)
                          break  # Выйти из вложенного цикла bot.listen
                        else
                          bot.api.send_message(chat_id: chat_id, text: "Некорректный выбор статьи. Введите номер из списка.")
                        end
                      end
                    end
                  else
                    bot.api.send_message(chat_id: chat_id, text: "В категории '#{category_name}' нет статей.")
                  end
                else
                  bot.api.send_message(chat_id: chat_id, text: "Категория '#{category_name}' не найдена.Введите команду еще раз")
                end
              else
                bot.api.send_message(chat_id: chat_id, text: "Название категории не может быть пустым.")
              end
            end
            break
          end
        when '/category_list'
          categories = Category.pluck(:name)
          if categories.any?
            bot.api.send_message(chat_id: chat_id, text: "Список категорий:\n#{categories.join("\n")}")
          else
            bot.api.send_message(chat_id: chat_id, text: "Категории не найдены.")
          end
        when '/author_list'
          authors = User.pluck(:username)
          if authors.any?
            bot.api.send_message(chat_id: chat_id, text: "Список авторов:\n#{authors.join("\n")}")
          else
            bot.api.send_message(chat_id: chat_id, text: "Авторы не найдены.")
          end
        end
      end
    end
  end
end


