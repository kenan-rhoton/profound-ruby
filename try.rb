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

v = get_verse "Jn 1:1"

init_screen
begin
    crmode
    noecho
    nl
    verse_win = Window.new(3,cols,0,0)
    def_win = Window.new(lines - 3, cols, 3, 0)
    mychar = "-"
    wordnum = 0
    while mychar != "q"
        verse_win.setpos(0,0)
        verse_win.addstr(v.get_words)
        def_win.setpos(0,0)
        def_win.addstr(v.deep_word wordnum)
        def_win.refresh
        verse_win.refresh
        case mychar
        when "h"
            wordnum = wordnum - 1
            wordnum = 0 if wordnum < 0
        when "l"
            wordnum = wordnum + 1
        when "c"
            echo
            verse_win.clear
            verse_win.refresh
            verse_win.setpos(0,0)
            new_verse = verse_win.getstr
            v = get_verse new_verse
            noecho
            wordnum = 0
        end
        mychar = getch
    end
ensure
    close_screen
end
