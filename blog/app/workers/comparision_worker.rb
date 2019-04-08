class ComparisionWorker
	include Sidekiq::Worker
 
	def perform(title,body)
      Post.create({title: title,body: body})
	end
end