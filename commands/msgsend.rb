def msgsend(channel_id, archive_id, before_id=nil, after_ts=nil)
   channel = $bot.channel(channel_id)
   files = Dir.glob(".archive/#{archive_id}/*.json")
   files.sort_by! do |file|
        parts = file.split('/').last.split('_')
        parts.first.to_i * 1000 + (1000 - parts.last.to_i)
   end
   processed_cnt = 0
   files.each do |file| # 1665116584.88
        data = []
        File.open(file, 'r'){|fp| data = JSON.load(fp)}
        data.reverse.each do |msg|
            before_id = nil if before_id && msg == before_id
            processed_cnt += 1
            next unless before_id.nil?
            next if after_ts && msg['timestamp'] <= after_ts
            author = $bot.user(msg['author']) rescue nil
            if author
                author = "#{author.display_name} (#{author.name})"
            else
                author = "Unknown"
            end
            contents = []
            content = "> Posted by: #{author}\n"
            content += msg['content'] + "\n"
            msg['attachments'].each do |att|
                if (content + att).length > 1900
                    contents << content
                    content = ''
                end
                content += att + "\n"
            end
            contents << content if content.length > 0
            contents.each{|c| channel.send(c); sleep(0.1); }
            puts "Processed: #{processed_cnt}" if processed_cnt % 100 == 0
        end
   end
   puts "Processed: #{processed_cnt}"
end