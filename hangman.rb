require 'Debugger'

class Hangman

  def initialize
    @secret_word = ""
    @current_guess = ""
    @solution_progress = ""
    @guesser = nil
    @referee = nil
  end

  def determine_guesser
    puts "Choose guesser: 'c' for computer, 'h' for human"
    guesser_type = gets.chomp
    case guesser_type
    when "c"
      @guesser = ComputerPlayer.new
      @referee = HumanPlayer.new
    when "h"
      @guesser = HumanPlayer.new
      @referee = ComputerPlayer.new
    end
  end

  def play
    determine_guesser

    has_won = false
    @secret_word = @referee.choose_word
    puts @secret_word

    initialize_solution_progress #to "_____"
    puts @solution_progress

    until has_won
      @current_guess = @guesser.guess_letter(@secret_word.length)
      puts "computer's guess: #{@current_guess}"
      puts "#{@secret_word}"
      @solution_progress = calculate_progress
      if @solution_progress == @secret_word
        puts "You won!"
        has_won = true
      else #hasn't won yet
        print_progress
      end
    end
  end

  def initialize_solution_progress
    @solution_progress = '_' * @secret_word.length
  end

  def calculate_progress
    i = 0
    temp_solution_progress = @solution_progress
    @secret_word.each_char do |letter|
      if @current_guess == letter
        temp_solution_progress[i] = @current_guess
      end
      i += 1
    end
    temp_solution_progress
  end

  def print_progress
    puts @solution_progress
  end
end

class ComputerPlayer
  DICTIONARY_FILE = '2of12inf.txt'

  def initialize
    @dictionary = read_dictionary
    @prior_guesses = []
    @letter_freq_template = create_freq_template
    @guessed_letters = []
    @secret_word_length = 0
  end

  def create_freq_template
    freq_template = {}
    ('a'..'z').each { |l| freq_template[l] = 0 }
    freq_template
  end

  def reduce_set_by_length(possible_words)
    reduced_set = []
    possible_words.each do |word|
      reduced_set << word if word.length == @secret_word_length
    end
    reduced_set
  end

  def join_words_into_string(length_matched_words)
    length_matched_words.join
  end

  def guess_letter(word_length)
    @secret_word_length = word_length
    possible_words = cleanup_dictionary
    length_matched_words = reduce_set_by_length(possible_words)
    possible_words_joined = join_words_into_string(length_matched_words)
    letter_freqs = make_freq_hash(possible_words_joined)
    make_best_guess(letter_freqs)
  end

  def make_best_guess(letter_freqs)
    sorted_letter_freqs = letter_freqs.map {|k,v| [v,k]}.sort.reverse
    sorted_letter_freqs.each_with_index do |pair, i|
      possible_guess = pair[1]
      unless @guessed_letters.include? possible_guess
        @guessed_letters << possible_guess
        return possible_guess
      end
    end
  end

  def read_dictionary
    dictionary = []
    File.foreach(DICTIONARY_FILE) do |line|
      dictionary << line.chomp
    end
    dictionary
  end

  def cleanup_dictionary
    cleaned_dictionary = []
    @dictionary.each do |word|
      cleaned_dictionary << word.scan(/\w/).join
    end
    cleaned_dictionary
  end

  def make_freq_hash(possible_words_joined)
    letter_freqs = @letter_freq_template.dup
    letter_freqs.each do |letter, val|
      letter_freqs[letter] = possible_words_joined.count(letter)
    end
    letter_freqs
  end

  def choose_word
    read_dictionary
    cleanup_word(@dictionary.sample)
  end

  def cleanup_word(word)
    word.scan(/\w/).join
  end
end

class HumanPlayer
  def guess_letter
    puts "Please guess a letter"
    gets.chomp
  end

  def choose_word
    puts "Please enter the secret word:"
    gets.chomp
  end
end