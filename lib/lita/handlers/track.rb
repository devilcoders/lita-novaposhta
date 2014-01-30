require "lita"

module Lita
  module Handlers
    class Track < Handler
      route /^track\s+(.+)/, :track, help: { "track NUBER" => "Отслеживает посылку по номеру декларации" }

      def track(response)
        query = response.matches[0][0]
        http_resp = http.get("http://query.yahooapis.com/v1/public/yql?q=SELECT%20*%20FROM%20htmlpost%20WHERE%20url%3D%22http%3A%2F%2Fnovaposhta.ua%2Ffrontend%2Ftracking%2Fua%22%20and%20postdata%3D%22en%3D#{query}%22%20and%20xpath%3D%22%2F%2Fdiv%5B%40class%3D'result'%5D%20%22&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=")
        data = MultiJson.load(http_resp.body)

        if data['query']['results']['postresult'] != 'null'
          root = data['query']['results']['postresult']['div']
          
          title            = root['p']
          route            = "#{root['table']['tr'][0]['td'][0]['p']}: #{root['table']['tr'][0]['td'][1]['p']}"
          delivery_date    = "#{root['table']['tr'][1]['td'][0]['p']}: #{root['table']['tr'][1]['td'][1]['p']}"
          current_location = "#{root['table']['tr'][2]['td'][0]['p']}: #{root['table']['tr'][2]['td'][1]['p']['content']}"
          delivery_address = "#{root['table']['tr'][3]['td'][0]['p']}: #{root['table']['tr'][3]['td'][1]['a']['content']} (<http://novaposhta.ua#{root['table']['tr'][3]['td'][1]['a']['href']}>)"
          return_address   = "#{root['table']['tr'][4]['td'][0]['p']}: #{root['table']['tr'][4]['td'][1]['p']}"
          payment          = "#{root['table']['tr'][5]['td'][0]['p']}: #{root['table']['tr'][5]['td'][1]['p']}"
          documents        = "#{root['table']['tr'][6]['td'][0]['p']}: #{root['table']['tr'][6]['td'][1]['p']}"

          split            = "-------------------------------------------------------------------------------------------"

          response.reply "#{title}\n#{split}\n#{route}\n#{delivery_date}\n#{current_location}\n#{delivery_address}\n#{return_address}\n#{payment}\n#{documents}"

        else
          Lita.logger.error "#{self.class}: Unable to get info: #{http_resp.body}"
          response.reply "Error: Unable to track number"
        end

        #response.reply(response.matches)
      end
    end

    Lita.register_handler(Track)
  end
end
