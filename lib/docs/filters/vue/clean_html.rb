module Docs
  class Vue
    class CleanHtmlFilter < Filter
      def call
        if current_url.host == 'vitejs.dev'
          return '<h1>Vite</h1>' if root_page?
          @doc = at_css('.content > div')
        else
          return '<h1>Vue.js</h1>' if root_page?
          @doc = at_css(version == '3' ? 'main > div > div' : '.content')
        end

        at_css('h1').content = 'Vue.js' if root_page?
        doc.child.before('<h1>Vue.js API</h1>') if slug == 'api/' || slug == 'api/index'

        css('.demo', '.guide-links', '.footer', '#ad').remove
        css('.header-anchor', '.page-edit', '.page-nav').remove
        css('.next-steps').remove

        css('.custom-block-title').each do |node|
          node.name = 'strong'
        end

        # Remove CodePen div
        css('.codepen').each do |node|
          next if node.previous_element.nil?
          span = node.css('span:contains("See the Pen")').remove
          node.previous_element.add_child(' ')
          node.previous_element.add_child(span)
          node.remove
        end

        # Remove code highlighting
        css('figure').each do |node|
          node.name = 'pre'
          node.content = node.at_css('td.code pre').css('.line').map(&:content).join("\n")
          node['data-language'] = node['class'][/highlight (\w+)/, 1]
        end

        css('.line-numbers-wrapper').remove
        css('pre').each do |node|
          node.content = node.content.strip
          node['data-language'] = 'javascript'
        end

        css('iframe').each do |node|
          node['sandbox'] = 'allow-forms allow-scripts allow-same-origin'
          node.remove if node['src'][/player.vimeo.com/] # https://v3.vuejs.org/guide/migration/introduction.html#overview
        end

        css('details').each do |node|
          node.name = 'div'
        end

        doc
      end
    end
  end
end
