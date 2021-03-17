class Word < ApplicationRecord
  def self.find_words_from_title(title)
    title.split.map do |word|
      Word.find_or_create_by(word: word)
    end
  end

  def self.update_word_counts(word_data)
    if word_data[:old_title].present?
      Word.find_words_from_title(word_data[:old_title]).each(&:decrement)
    end
    if word_data[:new_title].present?
      Word.find_words_from_title(word_data[:new_title]).each(&:increment)
    end
  end

  def increment
    self.update(count: self.count + 1)
  end

  def decrement
    self.update(count: self.count - 1)
  end
end
