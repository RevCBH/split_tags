require 'pp'

module SplitTags
	def self.included(base)
		base.extend ClassMethods
	end	

	class Splitter
		def initialize(attr_name)
			@attribute = attr_name
		end

		def before_save(*args)
      doc = args[0]      

			val = doc.send "#{@attribute}"
			val = (val.map {|t| if (not t.nil?) && t.respond_to?(:split) then t.split(',') else t end }).flatten!

			doc.send "#{@attribute}=", val
		end
	end

	module ClassMethods
		def split_tags(*args)			
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