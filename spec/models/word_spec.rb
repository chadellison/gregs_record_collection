require 'rails_helper'

RSpec.describe Word, type: :model do
  describe 'increment' do
    it 'increments the count of a word' do
      word = Word.create(word: 'word', count: 2)
      word.increment
      expect(word.count).to eq 3
    end
  end

  describe 'decrement' do
    it 'decrements the count of a word' do
      word = Word.create(word: 'word', count: 2)
      word.decrement
      expect(word.count).to eq 1
    end
  end

  describe 'find_words_from_title' do
    it 'splits a title and calls find_or_create_by for each word' do
      expect(Word).to receive(:find_or_create_by).with({word: 'so'})
      expect(Word).to receive(:find_or_create_by).with({word: 'happy'})

      Word.find_words_from_title('so happy')
    end
  end

  describe 'update_word_counts' do
    context 'when an old title is present' do
      it 'calls find_words_from_title with the correct argument and decrement' do
        old = Word.new(word: 'old')
        expect(Word).to receive(:find_words_from_title)
          .with('old')
          .and_return([old])

        expect(old).to receive(:decrement)

        Word.update_word_counts({old_title: 'old'})
      end
    end

    context 'when a new title is present' do
      it 'calls find_words_from_title with the correct argument and increment' do
        new_word = Word.new(word: 'new')
        expect(Word).to receive(:find_words_from_title)
          .with('new')
          .and_return([new_word])

        expect(new_word).to receive(:increment)

        Word.update_word_counts({new_title: 'new'})
      end
    end

    context 'when neither a new title nor an old title are present' do
      it 'does not call find_words_from_title' do
        expect(Word).not_to receive(:find_words_from_title)
      end
    end
  end
end
