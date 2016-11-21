require "curses"
include Curses

$mode = :NT

class Verse
    @words = []

    def initialize
        @words = []
    end

    def add_word(_val)
        _word = Word.new
        _word.add_literal _val
        @words.push _word
    end

    def last_word
        @words.last
    end

    def deep_word(i)
        @words[i].get_everything
    end

    def get_words
        _a = []
        @words.each do |w|
            _a.push w.get_literal
        end
        _a.join " "
    end
end

class Word
    @literal = ""
    @strongnum = nil
    @morph = []
    @strongdef = ""

    def initialize
        @morph = []
    end

    def add_literal(l)
        @literal = l
    end

    def add_morph(_m)
        @morph.push _m
    end

    def add_strongnum(_s)
        @strongnum = _s.gsub(/[^0-9,.]/, "").to_i
    end

    def get_everything
        @strongdef = `diatheke -b StrongsGreek -k #{@strongnum}`
        _res = "#{@literal}: #{@morph.join " "}\n\n #{@strongdef}"
    end

    def get_literal
        @literal
    end
end

def get_verse(ref)
    where = "OSHB"
    if $mode == :NT
        where = "Elzevir"
    end
    res = `diatheke -b #{where} -o mn -k #{ref}`

    input = res.split.drop 2
    verse = Verse.new

    input.each do |i|
        if i =~ /\(.*\)/
            verse.last_word.add_morph i
        elsif i =~ /<.*>/
            verse.last_word.add_strongnum i
        else
            verse.add_word i
        end
    end
    verse
end

#v = get_verse "Jn 1:1"

#puts v.get_words
#puts
#puts v.deep_word 0

def show_message(message)
    width = message.length + 6
    win = Window.new(5, width,
                     (lines - 5) / 2, (cols - width) / 2)
    win.box(?|, ?-)
    win.setpos(2, 3)
    win.addstr(message)
    win.refresh
    win.getch
    win.close
end

v = get_verse "Jn 1:1"

init_screen
begin
    crmode
    def_win = Window.new(3, 0, lines - 3, cols)
    while getch != "q"
        setpos(0,0)
        addstr(v.get_words)
        def_win.setpos(0,0)
        def_win.addstr(v.deep_word 0)
        win.refresh
        refresh
    end
ensure
    close_screen
end
