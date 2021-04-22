# This file includes code which was modified from https://github.com/openai/gpt-2
# & https://github.com/latitudegames/GPT-3-Encoder

module OpenAI
  class Tokens # rubocop:disable Metrics/ClassLength
    class << self
      def tokenize(text)
        new.tokenize(text)
      end

      def encode(text)
        new.encode(text)
      end

      def decode(tokens)
        new.decode(tokens)
      end
    end

    def tokenize(text)
      encode_bpe(text) { |bt| encoded_chars_to_utf8(bt) }
    end

    def encode(text)
      encode_bpe(text) { |bt| encoder[bt] }
    end

    def decode(tokens)
      text = tokens.map { |t| decoder[t] }.join
      encoded_chars_to_utf8(text)
    end

    private

    def encode_bpe(text, &block)
      bpe_tokens = []
      text.scan(pat).each do |token|
        t = token.encode("utf-8").bytes.map { |b| byte_encoder[b] }.join
        bpe_tokens.concat(bpe(t).split.map(&block))
      end
      bpe_tokens
    end

    def encoded_chars_to_utf8(string)
      string.chars.map { |x| byte_decoder[x] }.pack("C*").force_encoding("utf-8")
    end

    def bpe(token)
      return cache[token] if cache[token]

      word = token.chars
      pairs = get_pairs(word)

      return token if pairs.empty?

      word = process_pairs(word, pairs)

      word = word.join(" ")
      cache[token] = word
      word
    end

    def process_pairs(word, pairs)
      p_a = pairs.to_a
      inf = Float::INFINITY
      loop do
        bigram = p_a.min { |a, b| (bpe_ranks[a] || inf) <=> (bpe_ranks[b] || inf) }
        break unless bpe_ranks.include?(bigram)

        word = process_bigram(word, bigram)
        break if word.size == 1

        p_a = get_pairs(word)
      end
      word
    end

    def process_bigram(word, bigram) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      first, second = bigram

      new_word = []
      i = 0
      while i < word.size
        ws = word[i..]
        j = ws.find_index(first)

        if j.nil?
          new_word.concat(ws)
          break
        end

        # the index is relative to start of word
        j += i
        new_word.concat(word[i...j])
        i = j

        if word[i] == first && i < word.size - 1 && word[i + 1] == second
          new_word << first + second
          i += 2
        else
          new_word << word[i]
          i += 1
        end
      end
      new_word
    end

    def get_pairs(word)
      pairs = Set.new
      prev_char = word[0]
      word[1..].each do |char|
        pairs.add([prev_char, char])
        prev_char = char
      end
      pairs
    end

    def bpe_ranks
      @bpe_ranks ||= bpe_merges.zip((0...bpe_merges.size)).to_h
    end

    def bpe_merges
      bpe_lines[1..].map do |x|
        x.split(split_regex).reject { |e| e.strip.empty? }
      end
    end

    def bpe_lines
      bpe_file.split("\n")
    end

    def bpe_file
      File.open(File.expand_path("tokenizer/vocab.bpe", __dir__), "r:UTF-8", &:read)
    end

    def encoder
      @encoder ||= JSON.parse(File.read(File.expand_path("tokenizer/encoder.json", __dir__)))
    end

    def decoder
      @decoder ||= encoder.invert
    end

    def bytes_to_unicode
      bs = byte_keys
      cs = bs.dup
      n = 0
      (0...(2.pow(8))).each do |b|
        next if bs.include?(b)

        bs << b
        cs << 2.pow(8) + n
        n += 1
      end

      bs.zip(cs.map { |b| b.chr("utf-8") }).to_h
    end

    def byte_keys
      ("!".ord...("~".ord + 1)).to_a +
        ("¡".ord...("¬".ord + 1)).to_a +
        ("®".ord...("ÿ".ord + 1)).to_a
    end

    def byte_encoder
      @byte_encoder ||= bytes_to_unicode
    end

    def byte_decoder
      @byte_decoder ||= byte_encoder.invert
    end

    def pat
      @pat ||= /'s|'t|'re|'ve|'m|'l l|'d| ?\p{L}+| ?\p{N}+| ?[^\s\p{L}\p{N}]+|\s+(?!\S)|\s+/u
    end

    def split_regex
      @split_regex ||= /(\s+)/
    end

    def cache
      @cache ||= {}
    end
  end
end
