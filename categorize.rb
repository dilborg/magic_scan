require 'nokogiri'
require 'sqlite3'
require 'uri'

base_dir = ARGV[0]

class Card
  attr_reader :doc

  def initialize doc
    @doc = doc
  end

  def name
    node = doc.at_css "#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_nameRow > div.value"
    node.text.strip
  end

  def mana_cost
    nodes = doc.css "#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_manaRow > div.value > img"
    if nodes.any?
      nodes.map { |node|
        extract_mana_color node
      }.join
    else
      nil
    end
  end

  def converted_mana_cost
    node = doc.at_css "#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_cmcRow > div.value"
    if node
      node.text.strip
    else
      nil
    end
  end

  def types
    node = doc.at_css "#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_typeRow > div.value"
    node.text.strip
  end

  def text
    nodes = doc.css "#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_textRow > div.value > div"
    nodes.each { |n|
      n.css('img').each { |img|
        img.add_next_sibling extract_mana_color img
      }
      n.css('img').each(&:unlink)
    }
    nodes.map { |n| n.text }.join "\n"
  end

  def pt
    node = doc.at_css "#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ptRow > div.value"
    if node
      node.text.strip
    else
      nil
    end
  end

  def rarity
    node = doc.at_css "#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_rarityRow > div.value"
    node.text.strip
  end

  def rating
    node = doc.at_css "#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_currentRating_textRating"
    node.text.strip
  end

  private
  def extract_mana_color node
    URI(node['src']).query.split('&').map { |part|
      part.split '='
    }.find { |l,r| l == 'name' }[1]
  end
end

Dir.chdir base_dir do
  Dir.entries('.').each do |dir|
    next if dir == '.' || dir == '..'
    next unless File.directory? dir

    Dir.chdir dir do
      doc = File.open('page.html') do |f|
        Nokogiri.HTML f
      end
      p :CARD_ID => dir
      card = Card.new doc
      [
        :name,
        :mana_cost,
        :converted_mana_cost,
        :types,
        :text,
        :pt,
        :rarity,
        :rating
      ].each do |attr|
        p attr => card.send(attr)
      end
    end
  end
end
__END__
doc = File.open(File.join(base_dir, '373661', 'page.html')) do |f|
  Nokogiri.HTML f
end

card = Card.new doc
p card.name
p card.mana_cost
p card.converted_mana_cost
p card.types
p card.text
p card.pt
p card.rarity
p card.rating