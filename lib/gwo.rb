module GWO
  module Helper
    def gwo_control(test_id)
      start = "<!-- Google Website Optimizer Control Script -->"
      start += %{<script>function utmx_section(){}function utmx(){}
      (function(){var k='#{test_id}',d=document,l=d.location,c=d.cookie;function f(n){
      if(c){var i=c.indexOf(n+'=');if(i>-1){var j=c.indexOf(';',i);return c.substring(i+n.
      length+1,j<0?c.length:j)}}}var x=f('__utmx'),xx=f('__utmxx'),h=l.hash;
      d.write('<sc'+'ript src="'+
      'http'+(l.protocol=='https:'?'s://ssl':'://www')+'.google-analytics.com'
      +'/siteopt.js?v=1&utmxkey='+k+'&utmx='+(x?x:'')+'&utmxx='+(xx?xx:'')+'&utmxtime='
      +new Date().valueOf()+(h?'&utmxhash='+escape(h.substr(1)):'')+
      '" type="text/javascript" charset="utf-8"></sc'+'ript>')})();</script>}
      start += "<!-- End of Google Website Optimizer Control Script -->"
    end
    
    def gwo_tracking(uacct, test_id)
      tracking = "<!-- Google Website Optimizer Tracking Script -->"
      tracking += %{<script>
        if(typeof(_gat)!='object')document.write('<sc'+'ript src="http'+
        (document.location.protocol=='https:'?'s://ssl':'://www')+
        '.google-analytics.com/ga.js"></sc'+'ript>')</script>
        <script type="text/javascript">
        try {
        var gwoTracker=_gat._getTracker("#{uacct}-1");
        gwoTracker._trackPageview("/#{test_id}/test");
        }catch(err){}
      </script>}
      tracking += "<!-- End of Google Website Optimizer Tracking Script -->"
    end
    
    def gwo_conversion(uacct, test_id)
      conversion = "<!-- Google Website Optimizer Conversion Script -->"
      conversion += %{<script>
        if(typeof(_gat)!='object')document.write('<sc'+'ript src="http'+
        (document.location.protocol=='https:'?'s://ssl':'://www')+
        '.google-analytics.com/ga.js"></sc'+'ript>')</script>
        <script type="text/javascript">
        try {
        var gwoTracker=_gat._getTracker("#{uacct}-1");
        gwoTracker._trackPageview("/#{test_id}/goal");
        }catch(err){}</script>
      }
      conversion += "<!-- End of Google Website Optimizer Conversion Script -->"
    end
    
    def gwo_static_section(name, &block)
      concat(script(name) { capture(&block) })
    end
    
    def gwo_section(name, html_options = {}, &block)
      concat(
        content_tag(:div, 
          capture(&block), 
          html_options.merge({
            :id    => "gwo_#{name.to_s}",
            :style => "display:none"
          })
        )
      )
    end
    
    def gwo_dynamic_end(default, uacct, id)
      javascript_tag(%{
        function GWO(name){
          document.getElementById("gwo_" + name).style.display = 'block';
        }
      }) + 
      script(default) { 
        javascript_tag("GWO(#{default.to_s.inspect})")
      } + 
      gwo_tracking(uacct, id)
    end
    
    def gwo(default, uacct, id)
      gwo_control(id) + gwo_dynamic_end(default, uacct, id)
    end
    
    private
    
      # I'm overriding this since GWO doesn't like the CDATA section for some reason...
      def javascript_tag(content_or_options_with_block = nil, html_options = {}, &block)
        content =
          if block_given?
            html_options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
            capture(&block)
          else
            content_or_options_with_block
          end
        tag = content_tag(:script, content, html_options.merge(:type => Mime::JS))
        if block_called_from_erb?(block)
          concat(tag)
        else
          tag
        end
      end
    
      def script(name, &block)
        javascript_tag("utmx_section(#{name.to_s.inspect})") + yield + "</noscript>"
      end
  end
end
