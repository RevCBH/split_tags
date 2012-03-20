require 'pp'

module SplitTags
	def self.included(base)
		base.extend ClassMethods
	end	

	class Splitter
		def initialize(attr_name)
      puts "creating splitter"
			@attribute = attr_name
		end

		def before_save(*args)
      doc = args[0]
      puts "doc:"
      pp doc
      puts "args:"
      pp args

			val = doc.send "#{@attribute}"
			val = (val.map {|t| t.split ','}).flatten!

			doc.send "#{@attribute}=", val
		end
	end

	module ClassMethods
		def split_tags(*args)			
			puts "split_tags: #{args}"
			args.each do |t|
				before_save Splitter.new(t.to_s)
			end
		end
	end
end

if defined? MongoModel::EmbeddedDocument
	class MongoModel::EmbeddedDocument
		include SplitTags
	end
end