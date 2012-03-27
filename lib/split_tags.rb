module SplitTags
	def self.included(base)
		base.extend ClassMethods
	end	

	class Splitter
		def initialize(attr_name)
			@attribute = attr_name
		end

		def before_save(*args)
      doc = args[0] # TODO - should work with just (doc) instead of (args*), etc.
      puts "split_tags before_save"

			val = doc.send "#{@attribute}"
			if val.respond_to? :map
				val = (val.map {|t| if (not t.nil?) && t.respond_to?(:split) then t.split(',') else t end }).flatten!
			else
				val = val.to_s.split(',')
			end

			# TODO - this check shouldn't be needed
			if not val.nil?
				val.uniq!				
				val.reject! {|x| x.nil? || x == ""}
			end

			doc.send "#{@attribute}=", val
		end

		def after_find(doc)
			val = doc.send "#{@attribute}"
			if val.respond_to? :reject!							
				val = val.reject {|x| x.nil? || x == ""}
				doc.send "#{@attribute}=", val
			end
		end

		alias_method :after_initialize, :after_find
	end

	module ClassMethods
		def split_tags(*args)			
			args.each do |t|
				splitter = Splitter.new(t.to_s)
				before_save splitter
				after_find splitter
				after_initialize splitter
			end
		end
	end
end

if defined? MongoModel::EmbeddedDocument
	class MongoModel::EmbeddedDocument
		include SplitTags
	end
end