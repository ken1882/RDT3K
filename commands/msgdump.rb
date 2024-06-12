ARCHIVE_LIMIT = 10**4
##
# dumps all message history of given channel
#
# @param [Integer] channel_id - channel to dump
# @param [Integer] before_id - dumps messages before given one
def msgdump(channel_id, before_id=nil, before_ts=nil)
    folder = ".archive/#{channel_id}"
    FileUtils.mkdir_p(folder)
    channel = $bot.channel(channel_id)
    pointer = before_id
    messages = [nil]*100
    archive  = []
    processed_cnt = 0
    while messages.length == 100
        messages = channel.history(100, before_id=pointer)
        messages.each do |msg|
            next unless !msg.attachments.empty? || msg.content =~ /\.(\w+)/
            obj = {
                author: (msg.author.id rescue nil),
                content: msg.content,
                attachments: msg.attachments.collect{|a| a.url},
                timestamp: msg.timestamp.to_f
            }
            archive.push(obj)
        end
        processed_cnt += messages.length
        puts "Processed: #{processed_cnt}"
        pointer = messages.last.id
        next if archive.length < ARCHIVE_LIMIT
        save_message_archive(archive, folder)
        archive = []
    end
    save_message_archive(archive, folder)
end

def save_message_archive(archive, folder)
    archive.compact!
    return if archive.empty?
    sdate = Time.at(archive.first[:timestamp]).strftime("%Y%m%d")
    index = Dir.glob("#{folder}/#{sdate}*.json").length
    filename = sprintf("%s_%03d.json", sdate, index)
    File.open("#{folder}/#{filename}", 'w') do |fp|
        fp.write(JSON.dump(archive))
    end
end