require 'pp'

module Jekyll
  class Page
    def menu
      self.data['menu'] ||= {}
    end
  end

  class Menu
    include Comparable
    attr_accessor :name, :position, :href, :parent, :children

    def initialize(param)
      self.name = param['name']
      self.position = param['position']
      self.href = param['href']
      self.parent = param['parent']
      self.children = []
    end

    def self.from_page(page)
      page.menu['name'] ||= page.data['title']
      page.menu['href'] ||= page.data['permalink']
      self.new(page.menu)
    end

    def self.from_doc(doc)
      lqd = doc.to_liquid
      lqd['menu']['name'] ||= lqd['title']
      lqd['menu']['href'] ||= lqd['permalink']
      self.new(lqd['menu'])
    end

    def to_liquid(attrs = nil)
      {
        'name' => self.name,
        'href' => self.href || '#',
        'children' => self.children
      }
    end

    def <=>(other)
      if self.position.nil? and other.position.nil? or self.position == other.position
        # Neither have a position or both have same position -> sort by name
        self.name <=> other.name
      elsif self.position.nil?
        # self has no position, it goes after other
        +1
      elsif other.position.nil?
        # other has no position, it goes after self
        -1
      else
        # both have position, compare them
        self.position <=> other.position
      end
    end
  end

  class MenuGenerator < Generator

    def generate(site)
      # Create main menu
      main_menu = Menu.new 'name' => 'main'
      lookup = { 'main' => main_menu }

      # Add menus defined in config
      site.config['menu'].each do |m|
        menu = Menu.new m
        lookup[menu.parent].children << menu
        lookup[menu.name] = menu
      end

      # Collect menus defined in pages and collections
      page_menus = extract_menus(site)

      # Create tree of menu objects
      build_tree(lookup, page_menus)

      sort_children(main_menu)

      site.config['menu'] = main_menu
    end

    def extract_menus(site)
      menus = []
      site.pages.each do |page|
        unless page.menu.empty?
          menus << Menu.from_doc(page)
        end
      end

      site.collections.each_value do |coll|
        coll.docs.each do |doc|
          unless doc.to_liquid['menu'].empty?
            menus << Menu.from_doc(doc.to_liquid)
          end
        end
      end

      menus
    end

    def build_tree(lookup, menus)
      loop do
        size_before = menus.size

        menus.reject! do |m|
          parent = lookup[m.parent]
          if parent.nil?
            false
          else
            lookup[m.parent].children << m
            lookup[m.name] = m
            true
          end
        end

        break if menus.size == size_before
      end
    end

    def sort_children(menu)
      menu.children.sort!
      menu.children.map { |c| sort_children(c) }
    end
  end
end
