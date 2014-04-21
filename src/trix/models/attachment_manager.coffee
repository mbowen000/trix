#= require trix/models/collection
#= require trix/models/attachment

class Trix.AttachmentManager
  constructor: (@text, @responder) ->
    @collection = new Trix.Collection
    @reset()

  get: (id) ->
    @collection.get(id)

  add: (attachment) ->
    unless @collection.has(attachment.id)
      object = @attachmentObjectWithCallbacks(attachment)
      unless @responder?.addAttachment?(object) is false
        @collection.add(attachment)

  create: (file) ->
    if @responder
      @add(Trix.Attachment.forFile(file))

  remove: (id) ->
    if attachment = @collection.remove(id)
      @responder?.removeAttachment?(attachment.toObject())

  reset: ->
    attachments = @text.getAttachments()

    for attachment in @collection.difference(attachments)
      @remove(attachment.id)

    for attachment in attachments
      @add(attachment)

  attachmentObjectWithCallbacks: (attachment) ->
    object = attachment.toObject()

    object.update = (attributes) =>
      @text.setAttachmentAttributes(attachment.id, attributes)

    object.remove = =>
      @text.removeAttachment(attachment.id)

    object