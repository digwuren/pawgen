require 'securerandom'

class PawGen
  DIGITS = '0123456789'.freeze
  UPPERCASE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.freeze
  LOWERCASE = 'abcdefghijklmnopqrstuvwxyz'.freeze
  SYMBOLS = '!"#$%&\'()*+,-./:<=>?@[\\]^_`{|}~'.freeze
  AMBIGUOUS = 'B8G6I1l0OQDS5Z2'.freeze
  VOWELS = '01aeiouyAEIOUY'.freeze

  def initialize
    super()
    # The original defaulted the length to 8, but it's a bit too
    # short to be the default length these days -- especially
    # considering that phonemic password construction shrinks
    # the password space.
    @length = 12
    @include_uppercase = true
    @include_digits = true
    @include_symbols = false
    @exclude_ambiguous = false
    @exclude_vowels = false
    @mode = method :anglophonemic
    return
  end

  def include_uppercase?
    return @include_uppercase
  end

  def include_uppercase!
    @include_uppercase = true
    return self
  end

  def no_uppercase!
    @include_uppercase = false
    return self
  end

  def include_digits?
    return @include_digits
  end

  def include_digits!
    @include_digits = true
    return self
  end

  def no_digits!
    @include_digits = false
    return self
  end

  def include_symbols?
    return @include_symbols
  end

  def include_symbols!
    @include_symbols = true
    return self
  end

  def no_symbols!
    @include_symbols = false
    return self
  end

  def exclude_ambiguous?
    return @exclude_ambiguous
  end

  def exclude_ambiguous!
    @exclude_ambiguous = true
    return self
  end

  def do_not_exclude_ambiguous!
    @exclude_ambiguous = false
    return self
  end

  alias_method :dont_exclude_ambiguous!,
      :do_not_exclude_ambiguous!

  def exclude_vowels?
    return @exclude_vowels
  end

  def exclude_vowels!
    @exclude_vowels = true
    return self
  end

  def do_not_exclude_vowels!
    @exclude_vowels = false
    return self
  end

  alias_method :dont_exclude_vowels!, :do_not_exclude_vowels!

  attr_reader :length

  def length= new_length
    set_length! new_length
    return new_length
  end

  def set_length! new_length
    raise 'invalid length' \
        unless new_length.is_a? Integer and new_length >= 1
    @length = new_length
    return self
  end

  def use_structureless_generator!
    @mode = method :structureless
    return
  end

  def use_anglophonemic_generator!
    @mode = method :anglophonemic
    return
  end

  def use_kanaphonemic_generator!
    @mode = method :kanaphonemic
    return
  end

  def generate
    return @mode.call
  end

  def self::random_bool probability_of_true
    return SecureRandom.random_number < probability_of_true
  end

  def self::random_item array
    return array[SecureRandom.random_number array.length]
  end

  def structureless
    charset = LOWERCASE
    charset += UPPERCASE if include_uppercase?
    charset += DIGITS if include_digits?
    charset += SYMBOLS if include_symbols?
    charset = charset.split('')
    charset -= AMBIGUOUS.split('') if exclude_ambiguous?
    charset -= VOWELS.split('') if exclude_vowels?
    return (0 ... @length).
        map{PawGen.random_item charset}.
        join ''
  end

  # Phoneme flags
  PHF_CONSONANT  = 0x01
  PHF_VOWEL      = 0x02
  PHF_DIPTHONG   = 0x04
  PHF_NOT_FIRST  = 0x08

  ANGLOPHONEMES = [
    ['a',   PHF_VOWEL],
    ['ae',  PHF_VOWEL | PHF_DIPTHONG],
    ['ah',  PHF_VOWEL | PHF_DIPTHONG],
    ['ai',  PHF_VOWEL | PHF_DIPTHONG],
    ['b',   PHF_CONSONANT],
    ['c',   PHF_CONSONANT],
    ['ch',  PHF_CONSONANT | PHF_DIPTHONG],
    ['d',   PHF_CONSONANT],
    ['e',   PHF_VOWEL],
    ['ee',  PHF_VOWEL | PHF_DIPTHONG],
    ['ei',  PHF_VOWEL | PHF_DIPTHONG],
    ['f',   PHF_CONSONANT],
    ['g',   PHF_CONSONANT],
    ['gh',  PHF_CONSONANT | PHF_DIPTHONG | PHF_NOT_FIRST],
    ['h',   PHF_CONSONANT],
    ['i',   PHF_VOWEL],
    ['ie',  PHF_VOWEL | PHF_DIPTHONG],
    ['j',   PHF_CONSONANT],
    ['k',   PHF_CONSONANT],
    ['l',   PHF_CONSONANT],
    ['m',   PHF_CONSONANT],
    ['n',   PHF_CONSONANT],
    ['ng',  PHF_CONSONANT | PHF_DIPTHONG | PHF_NOT_FIRST],
    ['o',   PHF_VOWEL],
    ['oh',  PHF_VOWEL | PHF_DIPTHONG],
    ['oo',  PHF_VOWEL | PHF_DIPTHONG],
    ['p',   PHF_CONSONANT],
    ['ph',  PHF_CONSONANT | PHF_DIPTHONG],
    ['qu',  PHF_CONSONANT | PHF_DIPTHONG],
    ['r',   PHF_CONSONANT],
    ['s',   PHF_CONSONANT],
    ['sh',  PHF_CONSONANT | PHF_DIPTHONG],
    ['t',   PHF_CONSONANT],
    ['th',  PHF_CONSONANT | PHF_DIPTHONG],
    ['u',   PHF_VOWEL],
    ['v',   PHF_CONSONANT],
    ['w',   PHF_CONSONANT],
    ['x',   PHF_CONSONANT],
    ['y',   PHF_CONSONANT],
    ['z',   PHF_CONSONANT],
  ]

  ANGLOPHONEMES.each do |entry|
    entry.first.freeze
    entry.freeze
  end
  ANGLOPHONEMES.freeze

  ANGLOVOWELS = ANGLOPHONEMES.
      select{|entry| (entry[1] & PHF_VOWEL) != 0}.
      freeze
  ANGLOCONSONANTS = ANGLOPHONEMES.
      select{|entry| (entry[1] & PHF_CONSONANT) != 0}.
      freeze

  # Requirement flags
  REQ_UPPERCASE  = 0x01
  REQ_DIGITS     = 0x02
  REQ_SYMBOLS    = 0x04

  def anglophonemic
    raise 'unable to generate such a ' +
        'short anglophonemic password' \
        unless length >= 5
    raise 'unable to generate an ' +
        'anglophonemic password with no vowels' \
        if exclude_vowels?

    reqs = 0
    reqs |= REQ_UPPERCASE if include_uppercase?
    reqs |= REQ_DIGITS if include_digits?
    reqs |= REQ_SYMBOLS if include_symbols?
    result, unmet_reqs = [] # declare local variables
    begin
      unmet_reqs = reqs
      first = true
          # also re-set after a digit (but not after a symbol)
      result = ''
      prev_phoneme_flags = 0
      should_be = nil
      while result.length < length do
        should_be ||=
            PawGen.random_item [ANGLOVOWELS, ANGLOCONSONANTS]
        phoneme, phoneme_flags = PawGen.random_item should_be
        next if first and (phoneme_flags & PHF_NOT_FIRST) != 0
        # block a vowel followed by a vowel-dipthong
        next if (prev_phoneme_flags & PHF_VOWEL) != 0 and
            (phoneme_flags & PHF_VOWEL) != 0 and
            (phoneme_flags & PHF_DIPTHONG) != 0
        next if result.length + phoneme.length > length

        if include_uppercase? and
            (first or (phoneme_flags & PHF_CONSONANT) != 0) and
            PawGen.random_bool 0.2 then
          phoneme = phoneme.capitalize
          unmet_reqs &= ~REQ_UPPERCASE
        end

        # Note that the unambiguous lowercase 'o' can become the
        # ambiguous 'O' through capitalisation.  Contrariwise,
        # the ambiguous lowercase 'l' can become the unambiguous
        # uppercase 'L'.
        next if exclude_ambiguous? and
            phoneme.split('').any?{|c| AMBIGUOUS.include? c}

        # All the checks for the phoneme passed.  Let's add it.
        result << phoneme

        break if result.length == length

        # Checking against the [[first]] flag here means
        # requiring at least _two_ phonemes before the digit can
        # appear, because if we just applied the first phoneme,
        # [[first]] is still true.
        if include_digits? and
            !first and
            PawGen.random_bool 0.3 then
          choice = DIGITS.split ''
          choice -= AMBIGUOUS.split '' if exclude_ambiguous?
          result << PawGen.random_item(choice)
          unmet_reqs &= ~REQ_DIGITS
          first = true
          prev_phoneme_flags = 0
          should_be = nil # pick next [[should_be]] at random
          next
        end

        if include_symbols? and
            !first and
            PawGen.random_bool 0.2 then
          choice = SYMBOLS.split ''
          # Our [[AMBIGUOUS]] does not actually contain any
          # symbols in the current version.  This may be a
          # problem, considering [['`]] and [[!/1l|]] and [[&8]]
          # and [[-_]] and [[^~]] and maybe even [[.,]] and
          # [[:;]] and [[()l|]] so we're excluding [[AMBIGUOUS]]
          # anyway in anticipation of a future version
          # mentioning some of those.
          choice -= AMBIGUOUS.split '' if exclude_ambiguous?
          result << PawGen.random_item(choice)
          unmet_reqs &= ~REQ_SYMBOLS
          # not resetting [[first]]; not [[next]]ing
        end

        if should_be.object_id == ANGLOCONSONANTS.object_id then
          should_be = ANGLOVOWELS
        else
          if (prev_phoneme_flags & PHF_VOWEL) != 0 or
              (phoneme_flags & PHF_DIPTHONG) != 0 or
              PawGen.random_bool(0.6) then
            should_be = ANGLOCONSONANTS
          else
            should_be = ANGLOVOWELS
          end
        end
        prev_phoneme_flags = phoneme_flags
        first = false
      end
    end until unmet_reqs.zero?
    return result
  end

  # Real kana includes signs to prolongate a preceding vowel or
  # a following consonant.  We're not including these, based on
  # the wild-assed guess that the advantage in memorability is
  # outweighed by the disadvantage in reduced password space.
  #
  # Similarly, we're not indicating palatalisation: we'll use
  # 'ti' rather than 'chi', 'tu' rather than 'tsu', and so on.
  KANA_MORAE = ([''] + %w{k g s z t d n h b p m y r w}).
      map{|c| %w{a i u e o}.map{|v| c + v}}.
      flatten + %w{n} - %w{yi ye wu}
  KANA_MORAE.each &:freeze
  KANA_MORAE.freeze

  def kanaphonemic
    raise 'unable to generate such a ' +
        'short kanaphonemic password' \
        unless length >= 5
    raise 'unable to generate an ' +
        'kanaphonemic password with no vowels' \
        if exclude_vowels?

    reqs = 0
    reqs |= REQ_UPPERCASE if include_uppercase?
    reqs |= REQ_DIGITS if include_digits?
    reqs |= REQ_SYMBOLS if include_symbols?
    result, unmet_reqs = [] # declare local variables
    begin
      unmet_reqs = reqs
      first = true
          # also re-set after a digit (but not after a symbol)
      result = ''
      while result.length < length do
        phoneme = PawGen.random_item KANA_MORAE
        next if result.length + phoneme.length > length

        if include_uppercase? and
            PawGen.random_bool 0.2 then
          phoneme = phoneme.capitalize
          unmet_reqs &= ~REQ_UPPERCASE
        end

        # Note that the unambiguous lowercase 'o' can become the
        # ambiguous 'O' through capitalisation.
        next if exclude_ambiguous? and
            phoneme.split('').any?{|c| AMBIGUOUS.include? c}

        # All the checks for the phoneme passed.  Let's add it.
        result << phoneme

        break if result.length == length

        # Checking against the [[first]] flag here means
        # requiring at least _two_ phonemes before the digit can
        # appear, because if we just applied the first phoneme,
        # [[first]] is still true.
        if include_digits? and
            !first and
            PawGen.random_bool 0.3 then
          choice = DIGITS.split ''
          choice -= AMBIGUOUS.split '' if exclude_ambiguous?
          result << PawGen.random_item(choice)
          unmet_reqs &= ~REQ_DIGITS
          first = true
          next
        end

        if include_symbols? and
            !first and
            PawGen.random_bool 0.2 then
          choice = SYMBOLS
          # Our [[AMBIGUOUS]] does not actually contain any
          # symbols in the current version.  This may be a
          # problem, considering [['`]] and [[!/1l|]] and [[&8]]
          # and [[-_]] and [[^~]] and maybe even [[.,]] and
          # [[:;]] and [[()l|]] so we're excluding [[AMBIGUOUS]]
          # anyway in anticipation of a future version
          # mentioning some of those.
          choice -= AMBIGUOUS.split '' if exclude_ambiguous?
          result << PawGen.random_item(choice)
          unmet_reqs &= ~REQ_SYMBOLS
          # not resetting [[first]]; not [[next]]ing
        end

        first = false
      end
    end until unmet_reqs.zero?
    return result
  end
end
