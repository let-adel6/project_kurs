class Subscriber < ApplicationRecord
    has_and_belongs_to_many :categories
    # Добавьте поле для хранения подписок на категории
    serialize :subscribed_categories, Array
  
    def subscribe_to_category(category_name)
      category = Category.find_by(name: category_name)
      if category
        self.subscribed_categories ||= []
        self.subscribed_categories << category_name unless self.subscribed_categories.include?(category_name)
        self.save
        return true
      else
        return false
      end
    end
  
    def unsubscribe_from_category(category_name)
      self.subscribed_categories&.delete(category_name)
      self.save
    end
  end